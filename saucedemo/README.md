# Jeu de données saucedemo et captures du guide

Ce répertoire construit le jeu de données du [guide d'utilisation](../docs/guide/README.md) à partir
d'une vraie application de démonstration, [Swag Labs](https://www.saucedemo.com). Hypothèse : la
release 1.0 couvre la connexion, le catalogue et le panier en deux sprints. Le parcours de commande
(checkout) n'est pas développé.

| Dossier | Contenu |
| --- | --- |
| `app-tests/` | Tests Playwright **réels** de www.saucedemo.com : connexion pilotée par les données, catalogue, panier, API (contrat HTTP), performance |
| `features/` | Scénario Gherkin du critère d'acceptation de REQ-10, joué par `app-tests/panier-bdd.spec.ts` (exécuteur minimal `support/gherkin.ts`) |
| `data/comptes.json` | Jeu de données « Comptes » (3 lignes), partagé par le test automatisé et le test manuel TC-1 |
| `guide/` | Scénario TraceAgile : crée le projet `SWAG`, joue sprint 1 et sprint 2, capture les écrans dans `docs/guide/images/` |

## Lancer

Prérequis :
- la pile TraceAgile démarrée sur un projet sans clé `SWAG`, avec le serveur d'exécution réel
  (service `execution-server`). Les runs du guide exécutent réellement les tests de ce dossier : le
  serveur clone ce dépôt, monté en lecture seule (`file:///depots/traceagile`), sur la **branche
  courante**, qu'il faut donc committer avant de lancer ;
- un accès à Internet depuis le conteneur (npm, Chromium, www.saucedemo.com).

`GUIDE_DEPOT`, `GUIDE_BRANCHE` et `GUIDE_SERVEUR` changent le dépôt, la branche ou le serveur. Avec
`GUIDE_SERVEUR=Simulateur`, les runs sont simulés ; ils sont alors reproductibles avec
`SIMULATOR_PASS_RATE=1` et `SIMULATOR_ERROR_RATE=0`.

```bash
docker compose up -d --build
cd saucedemo
npm ci
npx playwright install chromium
npm run tout
```

`npm run tout` enchaîne `npm test` puis `npm run guide`.

- **`npm test`** joue les tests réels sur www.saucedemo.com et produit le rapport JUnit
  `results/junit-saucedemo.xml`.
  - Un échec est attendu : `Panier › problem_user retire un produit depuis le catalogue @fail`
    révèle un vrai défaut de Swag Labs.
- **`npm run guide`** joue le scénario `guide/01` à `guide/06`, qui importe ce rapport.
  - Pour rejouer sur la même base, choisir une autre clé de projet : `GUIDE_PROJET=SWAGB npm run guide`.
  - Pour repartir de zéro : `docker compose down -v`.

## Correspondance avec TraceAgile

Chaque nom de test du rapport JUnit est le `testIdentifier` du test automatisé dans TraceAgile, ce
qui permet l'import :

| Test du dépôt | Test TraceAgile | Exigence |
| --- | --- | --- |
| `Authentification › connexion avec chaque compte du jeu de données` | TC-3 (piloté par les données, jeu « Comptes ») | REQ-3, REQ-4 |
| `Catalogue › affiche les six produits du catalogue` | TC-4 (UI) | REQ-6 |
| `Catalogue › trie les produits par prix croissant` | TC-5 (UI) | REQ-7 |
| `Catalogue › ouvre la fiche d’un produit` | TC-6 (UI) | REQ-8 |
| `Contrat HTTP › expose le manifeste PWA et ses icônes` | TC-7 (API) | REQ-17 (ENF) |
| `Ajouter un produit au panier depuis le catalogue` | TC-8 (BDD, généré depuis le critère) | REQ-10 |
| `Panier › visualise le contenu du panier` | TC-9 (UI) | REQ-11 |
| `Panier › problem_user retire un produit depuis le catalogue @fail` | TC-10 (UI) | REQ-12 |
| `Performance › temps de chargement du catalogue` | TC-11 (performance) | REQ-16 (ENF) |

Sur le serveur d'exécution, TC-10 échoue réellement (défaut de `problem_user`) avec la copie d'écran
de Playwright. Le tag `@fail` le fait aussi échouer sur le simulateur. Le test de performance dépose
son p95 dans `TRACEAGILE_OUTPUT_DIR/metrics.json`, qui devient la valeur mesurée de l'ENF REQ-16.
