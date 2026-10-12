# Décisions d'architecture (ADR)

Consigne §16.1-5 : en cas d'ambiguïté de la spécification, l'option la plus simple compatible est
retenue et consignée ici. Format court : contexte, décision, conséquences.

| N° | Titre | Lot |
| --- | --- | --- |
| [0001](0001-consigner-les-decisions.md) | Consigner les décisions d'architecture | 0 |
| [0002](0002-architecture-hexagonale-legere.md) | Architecture hexagonale légère et modules Maven | 0 |
| [0003](0003-authentification-jwt-et-refresh-cookie.md) | Jeton d'accès JWT et jeton de rafraîchissement en cookie | 0 |
| [0004](0004-administrateur-systeme-et-roles-projet.md) | Administrateur système et rôles par projet | 0 |
| [0005](0005-patch-merge-patch-et-if-match.md) | PATCH (JSON Merge Patch) et verrou optimiste If-Match | 0 |
| [0006](0006-format-des-erreurs.md) | Format des erreurs et codes HTTP | 0 |
| [0007](0007-client-front-genere-depuis-openapi.md) | Client front généré depuis l'OpenAPI exporté par un test | 0 |
| [0008](0008-versions-ports-et-routes.md) | Versions, ports et routes du front | 0 |
| [0009](0009-regles-metier-des-exigences.md) | Précisions sur les règles métier des exigences | 1 |
| [0010](0010-audit-par-instantanes.md) | Audit par instantanés applicatifs plutôt que listener JPA | 1 |
| [0011](0011-formats-csv-gherkin-recherche.md) | Formats : CSV, Gherkin, recherche et rang | 1 |
| [0012](0012-referentiel-de-tests.md) | Référentiel de tests : natures, versions, BDD, découverte | 2 |
| [0013](0013-parametres-jeux-de-donnees-dossiers.md) | Paramètres, jeux de données nommés, dossiers de tests, menus contextuels | 0-2 |
| [0014](0014-tracabilite-et-couverture.md) | Traçabilité et couverture avant les exécutions | 3 |
| [0015](0015-planification.md) | Releases, sprints et planification | 4 |
| [0016](0016-campagnes-execution-anomalies.md) | Campagnes, exécution manuelle et anomalies | 5 |
| [0017](0017-duplication-campagnes.md) | Dupliquer une campagne ou la générer depuis les résultats d'une autre | 5 |
| [0018](0018-complements-execution.md) | Jeux de données en campagne, appel de cas de test, dossiers de campagnes, traçabilité des anomalies | 5 |
| [0019](0019-sessions-exploratoires.md) | Sessions exploratoires, débriefing PROOF et métriques | 6 |
| [0020](0020-execution-automatisee.md) | Exécution automatisée : jeton émis par le serveur, runs, webhooks, import, tests instables | 7 |
| [0021](0021-artefacts-execution-automatisee.md) | Artefacts d'exécution automatisée : traces système, JUnit XML, Jest JSON, copies d'écran | 7 |
| [0022](0022-selection-jeux-de-donnees.md) | Un test manuel à jeu de données est sélectionné avec ses lignes | 5 |
| [0023](0023-bilans-et-rapports-configurables.md) | Bilans, tableau de bord et générateur de rapports configurables (HTML, PDF, Word, Excel, Markdown, CSV, JSON) | 8 |
| [0024](0024-atelier-et-finitions.md) | Atelier Example Mapping, commentaires, pièces jointes, recherche, raccourcis, finitions et vérification des NF | 9 |
| [0025](0025-guide-et-jeu-saucedemo.md) | Guide d'utilisation et jeu de données saucedemo ; runId qualifié par le projet, artefacts du serveur lus en fin de run | — |
| [0026](0026-serveur-execution.md) | Serveur d'exécution réel : jar autonome multiplateforme, outils installés à chaud, adaptateurs de frameworks, parallélisme, interface de suivi | 10 |
| [0027](0027-installation-hors-docker.md) | Installation hors Docker : jar de TraceAgile avec interface, administrateur initial, script de base, démo SwagLabs en export SQL | — |
