# Serveur d'exécution TraceAgile

Le serveur d'exécution reçoit les tests automatisés que TraceAgile lui confie. Il installe les outils
de test, exécute les tests et renvoie les résultats à TraceAgile. Il se livre sous forme d'un **jar
autonome** qui contient aussi son interface d'administration. Il se lance sur n'importe quelle
machine Windows, Linux ou macOS, ou dans Docker. Les décisions de conception sont dans l'[ADR-0026](../../docs/adr/0026-serveur-execution.md).

| Fonction | Où |
| --- | --- |
| Émettre et révoquer les jetons de sécurité de TraceAgile | Interface › Jetons (ou `POST /api/v1/tokens`) |
| Détecter, installer et expliquer les outils : JDK, Maven, JUnit, Gatling, Playwright, Cypress, Selenium/pytest, Robot Framework avec SeleniumLibrary et Browser (Playwright) | Interface › Outils, assistant d'installation |
| Exécuter les tests reçus par l'API REST, en parallèle, et renvoyer les résultats (webhooks signés, polling, artefacts) | Contrat [execution-server-api.yaml](../../docs/execution-server-api.yaml) |
| Suivre l'activité : tableau de bord, jobs, journaux, statistiques | Interface |

## Obtenir le jar

```bash
cd backend
mvn -pl execution-server -am package -DskipTests
# → backend/execution-server/target/execution-server.jar (≈ 30 Mo, interface incluse)
```

Le build Maven télécharge lui-même Node.js pour construire l'interface. La CI publie aussi le jar
comme artefact (`execution-server-jar`).

## Lancer sur une machine

Seul **Java 21** est nécessaire au lancement. Les autres prérequis dépendent des tests à exécuter :

| Prérequis | Pour | Installation |
| --- | --- | --- |
| Git | cloner les dépôts de tests | `winget install Git.Git` · `apt install git` · `brew install git` |
| Node.js 20 ou 22 | Playwright, Cypress, Cucumber-JS, Robot Framework Browser | `winget install OpenJS.NodeJS.LTS` · paquet NodeSource · `brew install node` |
| Python 3.10+ | Selenium, pytest, Robot Framework | `winget install Python.Python.3.12` · `apt install python3 python3-venv` · `brew install python` |

```bash
java -jar execution-server.jar
# Windows (PowerShell) :
$env:EXECUTION_SERVER_ADMIN_PASSWORD = "un-mot-de-passe" ; java -jar execution-server.jar
# Linux / macOS :
EXECUTION_SERVER_ADMIN_PASSWORD=un-mot-de-passe java -jar execution-server.jar
```

Ouvrez ensuite http://localhost:8091 et connectez-vous avec l'administrateur du serveur.

L'onglet **Outils** détecte ce que la machine possède déjà. Il installe le reste, sans droits
d'administrateur, dans le dossier des outils. L'**assistant d'installation** part des frameworks
utilisés par vos tests et propose les outils dans le bon ordre.

Sous Linux, hors de l'image Docker, les navigateurs ont besoin de bibliothèques système, à
installer une fois avec les droits d'administrateur :
- `sudo npx playwright install-deps chromium` ;
- pour Cypress : `libgtk-3-0 libgbm1 libnss3 libxss1 libasound2 libxtst6 xauth xvfb`.

### Réglages

Chaque réglage se donne par une variable d'environnement ou par une option `--execution-server.xxx=` :

| Variable | Défaut | Rôle |
| --- | --- | --- |
| `EXECUTION_SERVER_ADMIN_USER` / `_PASSWORD` | `admin` / `executeur` | Administrateur : interface et émission des jetons. **À changer.** |
| `EXECUTION_SERVER_DATA_DIR` | `./data` | Base H2, jobs (dépôts clonés, rapports, artefacts), journaux |
| `EXECUTION_SERVER_TOOLS_DIR` | `./tools` | Outils installés : npm global, environnement Python, Maven, JDK, Gatling, navigateurs |
| `EXECUTION_SERVER_AGENTS` | `4` | Tests exécutés en même temps sur la machine, tous jobs confondus |
| `EXECUTION_SERVER_RETENTION_DAYS` | `14` | Conservation des espaces de travail et des artefacts |
| `EXECUTION_SERVER_NAME` | `executeur` | Nom affiché et agent annoncé à TraceAgile |
| `SERVER_PORT` | `8091` | Port HTTP |

## Appairer avec TraceAgile

1. Dans TraceAgile, ouvrez **Administration › Serveurs d'exécution › Ajouter**. Donnez l'adresse du
   serveur, par exemple `http://machine-de-test:8091`.
2. Cliquez sur **Appairer**. Deux possibilités :
   - TraceAgile demande lui-même un jeton avec les identifiants de l'administrateur du serveur ;
   - ou vous collez un jeton et son secret, émis dans l'onglet **Jetons** du serveur.
3. Le serveur doit pouvoir joindre TraceAgile pour lui envoyer les résultats. Réglez dans TraceAgile
   `TRACEAGILE_CALLBACK_URL=http://<adresse de TraceAgile vue du serveur>:8085/api/v1/execution-callbacks`.
4. Pour les dépôts privés, enregistrez un utilisateur et un jeton d'accès par hôte dans l'onglet
   **Paramètres**.

Avec `docker compose up`, le serveur tourne déjà dans la pile (service `execution-server`) et il est
appairé automatiquement par le profil de démonstration. Il apparaît sous le nom « Serveur
d'exécution », à côté du simulateur.

## Exécution d'un test

Chaque test reçu porte :
- un **framework** ;
- un **chemin** dans le dépôt ;
- un **identifiant** : le nom du test dans son rapport.

| Framework de TraceAgile | Commande lancée | Identifiant attendu |
| --- | --- | --- |
| Playwright | `npx playwright test <fichier> --grep <titre> --reporter=junit` | `Describe › titre` |
| Cypress | `npx cypress run --spec <fichier> --reporter junit` | titre du test |
| JUnit 5, REST Assured, Selenium (Java), Pact… | `mvn test -Dtest=<sélecteur>` | `com.exemple.ClasseTest#methode` |
| Cucumber-JVM, ou BDD dans un projet Maven | `mvn test` avec le moteur Cucumber et le scénario | nom du scénario |
| Cucumber-JS, ou BDD dans un projet Node.js | `npx cucumber-js <feature> --name <scénario>` | nom du scénario |
| Robot Framework | `python -m robot --test <nom> --xunit` ; les paramètres deviennent des `--variable` | nom du test |
| pytest, Selenium (Python) | `python -m pytest <nœud> --junitxml` | `tests/test_x.py::test_y` |
| Gatling | `mvn gatling:test` ou bundle `gatling.sh` | classe de simulation |

Pour chaque job, le serveur suit ces étapes :

1. **Clone.** Il clone la branche du dépôt (clone superficiel). Sans dépôt, seuls les tests dont le
   Gherkin est fourni peuvent s'exécuter.
2. **Préparation.** Il prépare chaque projet une seule fois : `npm ci`, navigateurs Playwright,
   `pip install -r requirements.txt` ou `mvn test-compile`.
3. **Exécution.** Il lance les tests en parallèle, avec deux plafonds :
   - le `parallelism` du job ;
   - les `agents` de la machine.

   Les tests Maven d'un même projet passent l'un après l'autre. Un test en échec est rejoué si
   `retryFailed` le demande.
4. **Environnement des tests.** Les paramètres et la ligne de jeu de données deviennent des
   variables `TRACEAGILE_PARAM_<NOM>`. Le paramètre `jdk: 17` choisit un JDK installé par le serveur.
5. **Résultats et artefacts.** Le résultat vient du rapport JUnit du framework (sinon du code de
   retour). Le serveur joint :
   - les copies d'écran ;
   - le journal du test ;
   - le rapport Robot ou l'archive Gatling.

   Pour Gatling, les métriques `p95Ms`, `throughputRps` et `koRequests` alimentent les ENF de
   TraceAgile.
6. **Fin du job.** Le serveur envoie `JOB_FINISHED` avec la synthèse, `system.log`, `junit.xml` et
   `report.json`.

## Développement

```bash
cd backend && mvn -pl execution-server -am test -DskipUi   # tests (processus simulés, aucun outil réel lancé)
cd backend/execution-server/ui && npm ci && npm run dev     # interface sur http://localhost:5174, API sur :8091
npm run lint && npm run typecheck && npm test
```
