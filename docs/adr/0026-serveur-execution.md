# ADR-0026 — Serveur d'exécution réel

**Statut** : acceptée (lot 10)

**Contexte.** Jusqu'ici, les runs automatisés étaient joués par un simulateur (ADR-0020). On veut
un vrai serveur d'exécution, qui doit :
- tourner en Spring Boot avec une interface React ;
- émettre les jetons de sécurité ;
- aider à installer les outils de test et les installer :
  - Robot Framework avec ses bibliothèques Selenium et Playwright ;
  - Playwright, Selenium, Cypress ;
  - JUnit, Maven, JDK, Gatling ;
- exécuter les tests reçus par l'API REST, en parallèle si besoin, et renvoyer les résultats ;
- fournir journaux et statistiques.

Il doit aussi exister sous forme d'un **jar indépendant**, lançable sur une autre machine que celle
de TraceAgile. Choix de l'utilisateur :
- exécution en conteneur Docker (le jar reste utilisable seul) ;
- tests venant d'un dépôt Git ou du Gherkin transmis ;
- le simulateur est conservé.

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Module | `backend/execution-server`, application Spring Boot autonome (port 8091) sans dépendance aux modules de TraceAgile. Seul le contrat est partagé : [execution-server-api.yaml](../execution-server-api.yaml), sans changement. L'interface React (`ui/`) est construite par Maven (frontend-maven-plugin, Node.js téléchargé) et servie par le jar ; `-DskipUi` la saute. |
| Données | Base H2 sur fichier (`dataDir/db`), accès JDBC (`JdbcClient`) et Flyway, sans JPA : quelques tables simples (jetons, jobs, tests, événements, artefacts, installations, identifiants Git). Les fichiers des jobs (dépôt cloné, rapports, artefacts, journal) sont sous `dataDir/jobs/<id>` ; une purge nocturne les supprime au-delà de `retentionDays`. |
| Sécurité | Comme le simulateur (ADR-0020). Le serveur émet le jeton Bearer et le secret de signature des webhooks ; il ne garde que l'empreinte SHA-256 du jeton. Un jeton révoqué est conservé (historique). L'administration (`/api/admin/**`, `/api/v1/tokens`) passe par HTTP Basic, avec l'administrateur défini au lancement. L'interface garde les identifiants pour l'onglet (sessionStorage). Les identifiants Git par hôte sont stockés dans la base du serveur, jamais renvoyés ni journalisés (masqués dans la sortie de `git clone`). |
| Multiplateforme | `Platform` choisit l'interpréteur : `cmd /c` et PowerShell sous Windows, `bash` ailleurs. Chaque outil a sa recette Windows et Unix. Au démarrage sous Windows, le serveur fixe `jdk.net.unixdomain.tmpdir` ; sinon, un TEMP en nom court 8.3 empêche Tomcat de démarrer (déjà vu dans CLAUDE.md). |
| Outils | Catalogue figé (`ToolCatalog`) aux versions épinglées. Les **prérequis** de la machine (Java, Node.js, Python, Git) sont détectés et expliqués, jamais installés : il faudrait des droits d'administrateur. Les autres outils s'installent sans droits dans `toolsDir` : préfixe npm global, environnement virtuel Python, archives Maven, JDK Temurin, Gatling, JUnit Console, navigateurs Playwright et Cypress, dépôt Maven local. Ce dossier passe en tête du PATH des installations et des exécutions. La détection lit la version dans la sortie, quel que soit le code de retour (`robot --version` sort avec 251). Les installations passent une par une (npm et pip ne supportent pas les écritures concurrentes), avec un journal chacune, les dépendances en premier. L'assistant traduit des frameworks en plan ordonné. Pas de désinstallation : une réinstallation écrase. |
| Image Docker | `execution-server/Dockerfile` : JDK 21, Node.js 22, Python 3, Git, et les bibliothèques système des navigateurs installées dans l'image (Playwright install-deps, dépendances de Cypress). Ainsi, des outils installés à chaud dans le volume `/opt/tools` restent utilisables après recréation du conteneur. L'utilisateur est non root. Le service `execution-server` de docker compose est appairé par le profil demo (`TRACEAGILE_EXECUTION_SERVER_URL`). |
| Exécution | Un adaptateur par framework (`TestExecutor`) : Playwright, Cypress, Maven (JUnit 5, REST Assured, Selenium Java, Cucumber-JVM…), Gatling, Robot Framework, pytest (Selenium Python), Cucumber-JS. Le choix suit le framework déclaré dans TraceAgile, sinon le fichier, sinon le Gherkin et le type de projet. Chaque test est lancé seul et lu dans le rapport JUnit XML du framework (cas correspondant à l'identifiant), à défaut par le code de retour. |
| Parallélisme | Les tests d'un job s'exécutent en parallèle, dans deux limites : `parallelism` du job et `agents` du serveur (sémaphore global). La préparation d'un projet (`npm ci`, navigateurs, `pip install`, `mvn test-compile`) n'a lieu qu'une fois par job. Les adaptateurs « exclusifs » (Maven, Gatling) sérialisent les tests d'un même projet, qui partagent `target/`. Un test en échec est rejoué jusqu'à `retryFailed` fois. L'échéance du job (`timeoutMinutes`) limite chaque processus ; l'annulation arrête l'arbre de processus. |
| Résultats | Mêmes événements que le simulateur (JOB_STARTED, TEST_STARTED, TEST_FINISHED, JOB_FINISHED), enregistrés pour le polling et envoyés signés (trois essais). Un TEST_FINISHED porte : statut, message, trace, métriques (Gatling : `p95Ms`, `throughputRps`, `koRequests`), nombre de tentatives, artefacts (copies d'écran, journal du test, rapports). JOB_FINISHED joint `system.log`, `junit.xml` et `report.json`. Les paramètres et la ligne de jeu de données deviennent des variables d'environnement (`TRACEAGILE_PARAM_*`) et, pour Robot Framework, des `--variable` ; le paramètre `jdk` choisit un JDK installé par le serveur. Après un redémarrage, un job en cours est clos (tests restants en erreur, JOB_FINISHED). |
| Artefacts servis | `nosniff` sur tous les artefacts ; le HTML (rapports Robot) est servi en pièce jointe. |
| Suivi | Tableau de bord de l'interface : activité en direct, 7 jours, série quotidienne sur 14 jours, résultats par framework et tests les plus en échec sur 30 jours, état des outils. Pages jobs (tests, journal en direct, artefacts, annulation), outils, jetons, paramètres, journal du serveur filtré par niveau. |
| Tests | Les tests d'API remplacent le port `ProcessRunner` par des processus scriptés (`FakeProcessRunner`), qui produisent les rapports que les frameworks écriraient ; aucun outil réel n'est lancé par `mvn verify`. Le jar a aussi été vérifié sur un poste Windows réel : détection, installation de JUnit puis de Robot Framework, job réel avec Robot Framework et Playwright sur saucedemo. |

**Conséquences.**
- `mvn verify` construit l'interface du serveur (téléchargement de Node.js au premier build). L'image
  de l'API passe `-DskipUi`.
- TraceAgile peut piloter plusieurs serveurs d'exécution. La démo en déclare deux, le simulateur et le
  serveur réel, appairés automatiquement.
- Reporté :
  - désinstallation d'un outil ;
  - Appium, k6, JMeter, Karate, Postman/Newman, Jest/Vitest (pas d'adaptateur) ;
  - files d'attente persistantes entre redémarrages (un job interrompu est clos, pas repris) ;
  - plusieurs comptes d'administration.
