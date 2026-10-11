# ADR-0025 — Guide d'utilisation et jeu de données saucedemo

**Statut** : acceptée (après le lot 9)

**Contexte.** On veut un guide d'utilisation qui illustre toutes les fonctions de TraceAgile et les
principes de la QA agile, avec un minimum de données et beaucoup de captures d'écran. Le jeu de
démonstration SHOP (§15.1) est volontairement fourni : il couvre beaucoup de cas, mais il est trop
dense pour un pas à pas.

La demande fixe le cadre :
- l'application testée est www.saucedemo.com ;
- deux sprints mènent jusqu'à la visualisation du panier ; le checkout n'est pas développé ;
- au moins un test de chaque type : manuel, exploratoire (sur le panier), automatisé, avec un jeu de
  données d'au moins deux lignes ;
- des tests de bout en bout en Gherkin et en Playwright ;
- un test d'API et un test de performance.

Construire le jeu a révélé deux défauts de l'exécution automatisée, quand deux projets partagent le
même serveur.

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Répertoire | `saucedemo/`, projet npm autonome (Playwright 1.63, sans autre dépendance). `app-tests/` contient de **vrais** tests de www.saucedemo.com et produit `results/junit-saucedemo.xml`. `guide/` contient le scénario TraceAgile, qui crée les données et capture les écrans dans `docs/guide/images/`. `npm run tout` enchaîne les deux. |
| Gherkin | Un exécuteur minimal (`support/gherkin.ts`, mots-clés français) joue `features/panier.feature`. Chaque test porte le nom exact du scénario, c'est-à-dire l'identifiant du test BDD que TraceAgile génère depuis le critère : l'import JUnit les rapproche. On évite ainsi une dépendance (playwright-bdd, Cucumber) pour un seul scénario. |
| Test d'API | Swag Labs n'a pas d'API métier. Le test d'API vérifie le contrat HTTP des ressources publiques : page, manifeste d'application web, icônes. Il est rattaché à une ENF « Contrat HTTP du site ». |
| Test de performance | Mesure légère : p95 de cinq connexions jusqu'à l'affichage du catalogue, métrique `p95Ms` jointe au rapport. Dans TraceAgile, la valeur mesurée de l'ENF vient du run sur le simulateur (`metrics` de `TEST_FINISHED`, ADR-0024). |
| Défaut réel | `Panier › problem_user retire un produit depuis le catalogue @fail` échoue réellement, car le bouton « Remove » du catalogue est sans effet pour `problem_user`. Le tag `@fail` le fait aussi échouer sur le simulateur (ADR-0020) : le run du sprint 2 montre un échec avec ses artefacts. La session exploratoire trouve un autre défaut réel : trois produits ne s'ajoutent pas au panier. |
| Résultats reproductibles | Le simulateur lit `SIMULATOR_PASS_RATE` et `SIMULATOR_ERROR_RATE` (0,8 et 0,05 par défaut). Le guide se génère avec 1 et 0 : seuls les tests `@fail` échouent. |
| Clés | Sur un projet neuf, les clés sont déterministes (REQ-1 à REQ-17, TC-1 à TC-12) et citées dans les tags `@REQ-n` des tests du dépôt. Le projet s'appelle `SWAG` ; `GUIDE_PROJET` permet de rejouer sur une autre clé, car l'API ne supprime pas de projet. |
| `runId` envoyé au serveur | Il était égal à la clé du run (`RUN-1`), unique par projet seulement. Or le serveur est idempotent par `runId` (§10.1) : le `RUN-1` d'un second projet recevait le job déjà terminé du premier et restait « envoyé ». Le `runId` est désormais **qualifié par le projet** (`SHOP/RUN-1`). Un webhook est rapproché par projet et clé ; l'ancien format sans projet reste accepté. |
| Artefacts listés par le serveur | `artifactsOf` complétait les artefacts annoncés par les webhooks avec la liste du serveur, à chaque affichage. Pendant un run, il pouvait enregistrer le même artefact qu'un webhook `JOB_FINISHED` simultané : erreur 500 (clé unique `run_id, name`). La liste du serveur n'est plus lue qu'une fois le run terminé ; après cela, les webhooks n'écrivent plus rien. |

**Conséquences.**
- Pour régénérer le guide : la pile Docker démarrée avec `SIMULATOR_PASS_RATE=1 SIMULATOR_ERROR_RATE=0`, puis
  `cd saucedemo && npm run tout`. Compter environ deux minutes.
- Les tests de `app-tests/` dépendent d'un site externe : ils ne font pas partie de la CI du dépôt.
- Le guide ([docs/guide/README.md](../guide/README.md)) est écrit à la main sur les captures. Si un
  écran change, régénérer les captures puis relire le texte.
