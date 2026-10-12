# CLAUDE.md — TraceAgile

Prototype de gestion des exigences agiles et des tests. **La spécification fait foi :
[`SPECIFICATION.md`](SPECIFICATION.md)** ; les décisions prises en cas d'ambiguïté sont dans
[`docs/adr/`](docs/adr/README.md).

## Avancement des lots (§16.2)

| Lot | Contenu | État |
| --- | --- | --- |
| 0. Socle | Multi-modules, Docker Compose, Flyway, JWT, utilisateurs, projets, membres, squelette React, CI | **Fait** (branche `lot-0-socle`) |
| 1. Exigences | Backlog, fiche, critères, ENF, rang, DoR/DoD, versions, audit, CSV | **Fait** (branche `lot-1-exigences`) |
| 2. Tests | Référentiel, manuels, automatisés, Gherkin Monaco, génération BDD, tags `@REQ-` | **Fait** (branche `lot-2-tests`) |
| Corrections 0-2 | Défilement après panneau latéral, paramètres `${nom}` et jeux de données nommés, dossiers de tests et menus contextuels des arbres (ADR-0013) | **Fait** (branche `lot-2-corrections`) |
| 3. Traçabilité | Liens, statut de vérification, couverture, matrice, orphelins, impact | **Fait** (branche `lot-3-tracabilite`) |
| 4. Planification | Releases, sprints, planification, démarrage / clôture | **Fait** (branche `lot-4-planification`) |
| 5. Campagnes et exécution manuelle | Campagnes, sélection, affectation, exécution pas à pas, anomalies | **Fait** (branches `lot-5-campagnes`, `lot-5-duplication`, `lot-5-complements`) |
| 6. Exploratoire | Chartes, sessions, TBS, PROOF, métriques | **Fait** (branche `lot-6-exploratoire`) |
| 7. Exécution automatisée | `ExecutionServerClient`, simulateur, webhooks, SSE, import de rapports, artefacts (traces, JUnit, Jest, copies d'écran) | **Fait** (branches `lot-7-execution-automatisee`, `lot-7-artefacts`) |
| 8. Bilans | Tableau de bord, burndown / burnup, bilans de sprint et de release, verdict, rapports configurables, exports HTML / PDF / Word / Excel / Markdown / CSV / JSON | **Fait** (branche `lot-8-bilans`) |
| 9. Atelier et finitions | Example Mapping, commentaires, pièces jointes, Ctrl+K, aperçus des clés, raccourcis, notifications, accessibilité (axe-core), SpotBugs, seuil JaCoCo, banc NF-01 à NF-03 | **Fait** (branche `lot-9-finitions`) |
| Guide saucedemo | Guide d'utilisation illustré (`docs/guide/`), jeu de données Swag Labs (`saucedemo/`) : vrais tests Playwright, Gherkin, API, performance ; runId qualifié par le projet (ADR-0025) | **Fait** (branche `saucedemo-guide`) |
| 10. Serveur d'exécution | Serveur réel (Spring Boot + React, jar autonome Windows / Linux / macOS, image Docker) : jetons, installation des outils, exécution parallèle par framework, webhooks, statistiques (ADR-0026) | **Fait** (branche `lot-10-serveur-execution`) |
| Installation hors Docker | Jar de TraceAgile avec interface (`-Pdistribution`), administrateur initial, scripts de base et démo SwagLabs, note [docs/installation.md](docs/installation.md) (ADR-0027) | **Fait** (branche `installation-hors-docker`) |

Reporté (hors périmètre du prototype à l'issue du lot 9, ADR-0024) :
- Traçabilité : suspicion « modifiée après la dernière exécution » (§7.3) couverte par le passage
  des tests à NEEDS_UPDATE (non sélectionnables) ; pas de cache des statuts (calcul par sous-arbre).
- F-AUT-09 annotations autres que `@REQ-n` ; choix de la ligne de jeu de données d'un run automatisé.
- Vidéos et stockage des artefacts de run dans TraceAgile (ils sont relus sur le serveur, ADR-0021).
- Rapports (ADR-0023) : périmètre « campagne », traduction des documents produits par le serveur.
- Glisser-déposer des campagnes d'un dossier à l'autre dans l'arbre lui-même.
- NF-11 : seul Chromium est testé automatiquement (Edge et Firefox à la main).

## Méthode de travail (§16.1)

1. Un lot par branche (`lot-N-nom`) et par pull request ; l'application reste démarrable et tous
   les tests verts.
2. **TDD** : tests des règles métier d'abord, puis le code, puis le jeu de démonstration
   (`DemoDataLoader`) et ce fichier.
3. Les tests et commentaires citent les identifiants de la spec : `@DisplayName("§3.1 …")`,
   `F-REQ-07`, `NF-08`… dans les noms de tests ou `describe`/`it`.
4. Ambiguïté → option la plus simple, nouvelle ADR dans `docs/adr/` (et ligne dans son README).
5. Ne rien implémenter de la colonne « Exclu » du §1.3.

## Commandes

Prérequis : Java 21, Maven 3.9, Node 22, Docker (les tests d'intégration lancent PostgreSQL via
Testcontainers).

```bash
# Tout lancer (PostgreSQL, API, simulateur, front) avec le jeu de démonstration
docker compose up --build            # ou scripts/start.ps1 / scripts/start.sh
# → http://localhost:3000  (admin / demo, po, qa1, qa2, dev, viewer — mot de passe « demo »)
# → http://localhost:8085/swagger-ui.html

# Back-end : build + tous les tests (unitaires, intégration Testcontainers, ArchUnit) + JaCoCo
cd backend && mvn verify
mvn -pl traceagile-api -am test -Dtest=ProjectApiTest -Dsurefire.failIfNoSpecifiedTests=false

# Back-end en local contre le PostgreSQL de Compose
docker compose up -d postgres
cd backend && mvn -pl traceagile-api -am spring-boot:run -Dspring-boot.run.profiles=demo

# Front-end
cd frontend && npm ci
npm run dev            # http://localhost:5173, relaie /api vers :8085
npm test               # Vitest + Testing Library + MSW
npm run lint && npm run typecheck && npm run build
npm run api:generate   # après une modification de l'API (voir ci-dessous)

# Bout en bout (Playwright, parcours du §15.3) contre la pile Docker Compose démarrée
cd e2e && npm ci && npx playwright install chromium
npx playwright test            # E2E_BASE_URL=http://localhost:5173 pour viser le serveur Vite
# après `docker compose up --build -d`, attendre l'état « healthy » de backend avant Playwright
# (accessibilite.spec.ts : contrôle axe-core WCAG 2.1 AA des écrans principaux, NF-10)

# Guide d'utilisation (docs/guide/) : jeu de données saucedemo et captures, ADR-0025 (~2 min)
docker compose up -d   # runs du guide exécutés par le serveur d'exécution réel (branche courante committée)
cd saucedemo && npm ci && npm run tout   # npm test (vrais tests saucedemo) puis npm run guide (projet SWAG)
npm run publier                          # docs/guide/guide-traceagile.html et .docx ; copie servie à /guide/ (menu Documentation)
# rejouer sur la même base : GUIDE_PROJET=SWAGB npm run guide (pas de suppression de projet dans l'API)

# §14 vérification des NF-01 à NF-16 : docs/nf-verification.md
# §14 banc de performance NF-01 à NF-03 (5 000 exigences, 10 000 tests ; ~10 min) → target/nf-benchmark.md
cd backend && mvn -Pperf -pl traceagile-api test -Dtest=PerformanceBenchmarkTest -Dsurefire.failIfNoSpecifiedTests=false
# diagnostic rapide (requêtes SQL d'un appel) : -Dperf.scale=0.2 -Dperf.diagnostic=true
```

Windows : si une JVM échoue avec `Unable to establish loopback connection` (sockets unix des
`Pipe` NIO : WireMock, Jetty, client HTTP du JDK), le TEMP en nom court 8.3 est en cause ; le pom
passe `-Djdk.net.unixdomain.tmpdir=${user.home}` aux tests. Les clients HTTP du code (webhooks du
simulateur, `HttpExecutionServerClient`) utilisent `SimpleClientHttpRequestFactory` pour l'éviter.

Serveur d'exécution réel (ADR-0026, [backend/execution-server/README.md](backend/execution-server/README.md)) :
`docker compose up` le démarre aussi (port 8091, interface `admin` / `executeur`) et le profil demo l'appaire
(« Serveur d'exécution ») ; jar autonome : `cd backend && mvn -pl execution-server -am package -DskipTests`
→ `execution-server/target/execution-server.jar`, lancé par `java -jar` sur toute machine (Java 21).
`-DskipUi` saute la construction de son interface (`execution-server/ui`, npm : `lint`, `typecheck`, `test`).

Installation hors Docker (ADR-0027, [docs/installation.md](docs/installation.md)) :
`scripts/construire-distribution.(sh|ps1)` → `dist/traceagile-<version>/` (deux jars, configurations
`install/*/…env.exemple`, démarrage, scripts de base `install/base-de-donnees/installer-base.(sh|ps1)`).
Chaque logiciel s'installe aussi en conteneur, indépendamment de l'autre : `install/*/Dockerfile` construit
l'image depuis le jar, `docker-compose.yml` lit la même configuration en `.env` (TraceAgile : profil
`base-locale` pour PostgreSQL, service `installation-demo` pour la démo ; réseau partagé `traceagile-reseau`).
La note décrit les 8 combinaisons ; garder ses tableaux d'adresses (§1.2) à jour si un port ou un nom change.
Le jar de TraceAgile n'embarque l'interface qu'avec `-Pdistribution` (`EmbeddedFrontendFilter`). Hors
profil demo, `InitialAdministrator` crée l'administrateur sur une base sans utilisateur
(`TRACEAGILE_ADMIN_*`). La démo SwagLabs est un export SQL (`demo/swaglabs.sql`, comptes en
`SwagLabs-2026`) : la régénérer avec `install/base-de-donnees/generer-demo-swaglabs.sh` après toute
nouvelle migration ou évolution du guide (pile Docker démarrée, branche committée, jar `-Pdistribution`).

Exécution automatisée (ADR-0020) : `docker compose up` démarre le simulateur (port 8090) ; l'API
l'appaire seule (profil demo) avec les identifiants `SIMULATOR_ADMIN_USER` / `SIMULATOR_ADMIN_PASSWORD`
(`admin` / `simulateur` par défaut). Contrat : `docs/execution-server-api.yaml`. Jeton à la main :
`curl -u admin:simulateur -X POST http://localhost:8090/api/v1/tokens`.

## Architecture (§11, ADR-0002)

```
backend/
  traceagile-domain/          entités JPA, énumérations, règles métier pures (pas de Spring Web)
  traceagile-application/     services @Transactional + ports (UserRepository, PasswordHasher…)
  traceagile-infrastructure/  adaptateurs Spring Data (JpaXxxRepository), Flyway, BCrypt
  traceagile-api/             contrôleurs, DTO, MapStruct, sécurité JWT, ApiExceptionHandler, démo
  mock-execution-server/      simulateur §10.5 (lot 0 : /api/v1/health seulement)
e2e/                          Playwright : un fichier par parcours du §15.3 (rédigé en français)
frontend/src/
  api/          client openapi-fetch (schema.d.ts généré), hooks TanStack Query, ApiError
  features/     auth, projects, admin, dashboard… (une fonctionnalité = un dossier)
  layouts/      AppLayout (barre supérieure, menu §13.1), navigation.ts (écrans et lot de livraison)
  routes/       routes.tsx (§13.2, chargement paresseux)
  components/   composants partagés
  locales/      fr.json (défaut), en.json
```

Découpage par fonctionnalité dans chaque module : `administration`, `requirement`, `audit`, puis
`testcase`, `exploratory`, `planning`, `campaign`, `execution`, `traceability`, `reporting`.

## Conventions

### Back-end
- Entités : héritent d'`AuditableEntity` (UUID, createdAt/By, updatedAt/By, `@Version`). Les
  invariants sont dans l'entité et lèvent `BusinessRuleException(code, message)`.
- Dans une entité, ne jamais lire un champ d'une **autre** instance (`other.parent`) : passer par
  l'accesseur, sinon un proxy Hibernate renvoie `null`.
- Clés lisibles : `KeyGenerator.next(project, "REQ")` (table `key_sequences`, transactionnelle).
- Audit (NF-16, ADR-0010) : instantané avant / après + `AuditService.record(…)` dans chaque service
  qui modifie une entité auditée ; événement de domaine (`RequirementChanged`) si quelque chose a
  changé. `jsonb` ne garde pas l'ordre des clés : rétablir l'ordre canonique à la lecture.
- Erreurs métier avec détails pour l'interface : `UnprocessableException(code, message, details)`
  → 422, les détails deviennent des propriétés du `ProblemDetail`.
- Migrations Flyway `traceagile-infrastructure/src/main/resources/db/migration/V{n}__{sujet}.sql` ;
  `ddl-auto: validate`. Ne jamais modifier une migration déjà livrée.
- Ports dans `application`, implémentés par une interface `JpaXxxRepository` dans `infrastructure`.
- Jamais d'entité exposée : DTO `record` dans `XxxDtos`, mapping MapStruct
  (`unmappedTargetPolicy=ERROR`). Champs toujours présents : `@Schema(requiredMode = REQUIRED)`.
- Sécurité : chaque endpoint porte `@PreAuthorize` ; pour un projet,
  `hasPermission(#key, 'Project', 'PERMISSION')` avec une valeur de `Permission` (§2.2).
  `EndpointSecurityTest` (NF-08) échoue sinon ; liste d'exemptions justifiées dans ce test.
- Erreurs : exceptions applicatives (`NotFoundException`, `ConflictException`,
  `VersionConflictException`…) → `ApiExceptionHandler` → RFC 9457 avec `code` (ADR-0006).
- Pagination : `PageResponse` `{content, page, size, totalElements}`, `?page=0&size=50&sort=x,asc`.
- PATCH : merge-patch, `If-Match` → `Versions.parseIfMatch`, réponse avec `ETag` (ADR-0005). Quand
  un champ peut être effacé, lire le corps en `JsonNode` avec `MergePatch` (absent = inchangé,
  `null` = effacé) et documenter le schéma avec un DTO validé (ADR-0009).
- Droits dépendant de l'objet (ex. nature d'un test, §2.2) : `@PreAuthorize` sur la règle la plus
  large, puis vérification fine dans le contrôleur (`TestPermissions.checkWrite`) → 403.
- `POST` dont le corps mêle des champs communs et des champs optionnels d'un merge-patch : lire le
  corps en `JsonNode` et le valider avec deux DTO via `MergePatch.of` (cf. `TestCaseController`).
- Ne jamais nommer une méthode de test `status()` (elle masque `MockMvcResultMatchers.status()`).
- Tests : unitaires purs (domaine), Mockito (application), `AbstractApiTest` (MockMvc +
  PostgreSQL Testcontainers partagé, base vidée avant chaque test : `truncate … cascade` depuis
  `projects`/`users`, plus les tables sans clé étrangère comme `audit_events`). Chaque contrôleur :
  nominal, 400, 403, 412 si PATCH, 422 pour les règles métier.
- Ports : API **8085**, simulateur 8090, PostgreSQL 5433 (hôte). Voir ADR-0008.
- Duplication / génération d'une campagne depuis les résultats d'une autre (ADR-0017) :
  `CampaignService.copy`, `POST /campaigns/{key}/copy`, `CopyCampaignModal` côté front.
- Exécution automatisée (ADR-0020) : domaine `automation` (`ExecutionServer`, `AutomatedRun`,
  `FlakyDetector`, `WebhookSignature`) ; une tentative automatisée référence son run
  (`Execution.automated`, `automatedFinished`, `abandon`). Port `ExecutionServerClient` (adaptateur
  `HttpExecutionServerClient`), secrets chiffrés par `SecretCipher` (`AesGcmSecretCipher`), rapports
  par `ReportParser` (`ReportParsers`). L'envoi d'un job se fait **hors transaction**
  (`AutomatedRunService.dispatch`, `TransactionTemplate`) ; les changements de run publient
  `RunChanged`, diffusé en SSE après commit (`RunEventStreams`). Les dépôts Spring Data doivent être
  des interfaces de premier niveau (pas imbriquées). Tests d'API : `@MockitoBean ExecutionServerClient`
  et webhooks signés avec `WebhookSignature.sign`. Le `runId` envoyé au serveur est qualifié par le projet
  (`SHOP/RUN-1`, `AutomatedRunService.runId`) : le serveur est idempotent par `runId` et peut servir
  plusieurs projets (ADR-0025).
- Artefacts (ADR-0021) : références dans `RunArtifact` (annoncées par `TEST_FINISHED` / `JOB_FINISHED`,
  complétées par `ExecutionServerClient.artifacts`), contenu relayé sans stockage
  (`AutomatedRunService.artifact` → `ExecutionServerClient.download`). Simulateur : `system.log`,
  `junit.xml`, `jest.json`, `report.json`, `screenshot-<test>.png` par échec (`ResultFormats`, `Screenshots`).
  Côté front, contenu par `fetchArtifact` (Bearer + URL d'objet), jamais par lien direct. La liste du
  serveur ne complète les artefacts qu'une fois le run terminé (sinon course avec `JOB_FINISHED`).
- « Open in view » est enregistré par `OpenInViewConfig` (et non `spring.jpa.open-in-view`) pour
  en exclure les flux SSE : une requête asynchrone garderait sa connexion JDBC tant que le flux est
  ouvert. Tout nouveau flux SSE s'ajoute à `OpenInViewConfig.STREAMS` (test
  `AutomatedRunApiTest.streamsDoNotHoldConnections`). La CSP de `frontend/nginx.conf` autorise
  `img-src blob:` pour les images chargées avec le jeton.
- Bilans et rapports (ADR-0023) : règles pures dans le domaine `reporting` (`VerdictRules`,
  `Burndown`, `ReportDefinition`, `ReportSnapshot`) ; `ReportCalculator` calcule les sections
  (records `ReportData`, stockés en `jsonb` dans l'instantané), `ReportDocumentBuilder` en fait un
  `ReportDocument` (libellés français : `Labels`), rendu par un `ReportRenderer` par format
  (`infrastructure.reporting` : gabarit Thymeleaf `templates/reports/report.html` pour HTML et PDF
  via OpenHTMLtoPDF, POI pour Word / Excel avec graphiques natifs). Pas de flexbox ni de caractère
  hors WinAnsi (« → », « ≥ ») dans le gabarit : OpenHTMLtoPDF, polices PDF de base. La clôture d'un
  sprint publie `PlanningService.SprintClosed` → `ReportService.onSprintClosed` fige son bilan.
  Tableau de bord : `DashboardService` (une requête). Les records applicatifs exposés tels quels
  doivent garder des noms de schéma uniques (`RequirementRef` existait déjà → `UnmetRequirement`).
- Lot 9 (ADR-0024) : commentaires et atelier Example Mapping dans `WorkshopService` (`Comment` porte
  les questions, `ExampleCard` les règles et exemples) ; les questions ouvertes s'ajoutent aux items
  à acquitter de la DoR (`RequirementService.changeStatus`). Pièces jointes : `AttachmentService`,
  port `FileStorage` (`LocalFileStorage`, volume Docker `attachments`), type déduit de l'extension,
  contenu partagé quand une anomalie reprend les captures d'un pas. Valeurs mesurées des ENF :
  `NfrMeasurementService` (métriques de TEST_FINISHED, `RunEvent.metrics`). Recherche, aperçu des
  clés, notifications : `SearchService` (port `SearchIndex`), `NotificationService`.
- Performances (NF-01, ADR-0024) : ne jamais recharger toute la traçabilité pour une page ou une
  fiche — `TraceabilityService.statusesOf` (sous-arbres) ; les `@OneToOne(mappedBy)` de `TestCase`
  ne sont pas paresseux : tout chargement en masse passe par une requête avec `left join fetch`
  (`JpaTestCaseRepository`) ; `default_batch_fetch_size` est réglé à 100.
- Qualité : `mvn verify` échoue sous 70 % de lignes couvertes (agrégat JaCoCo vérifié dans
  `traceagile-api`, NF-12) ou sur une anomalie SpotBugs « High » (NF-13 ; exclusions justifiées dans
  `backend/spotbugs-exclude.xml`).
- Serveur d'exécution réel (ADR-0026) : module autonome `execution-server` (aucune dépendance aux
  modules de TraceAgile, seul le contrat est partagé) ; H2 + Flyway + `JdbcClient`. Processus externes
  par le port `ProcessRunner` (tests : `FakeProcessRunner` scripté, qui écrit les rapports des
  frameworks) ; `Platform` (cmd / PowerShell sous Windows, bash ailleurs) ; outils dans `ToolCatalog`
  (recette Windows et Unix, versions figées, prérequis seulement détectés) et `ToolService` (une
  installation à la fois, journal) ; un `TestExecutor` par framework, choisi par `ExecutorRegistry`,
  résultat lu dans le JUnit XML (`JUnitReports`) ; `JobRunner` orchestre (parallélisme job / agents,
  préparation une fois par projet, verrou des projets Maven, reprises, échéance, annulation, webhooks).
  Les tests d'API figent la plateforme à LINUX (`AbstractServerTest`). Sous Windows, `main` fixe
  `jdk.net.unixdomain.tmpdir` (TEMP 8.3).
- Sessions exploratoires (ADR-0019) : règles dans `ExploratorySession`, `SessionNote`, `Tbs`,
  `Proof` (domaine `exploratory`) ; une session porte une tentative (`Execution.exploratory`,
  `finishSession`) et son identifiant d'API est celui de la tentative. Métriques §5.4 :
  `ExploratoryMetrics` ; propositions de chartes F-EXP-04 : `CharterProposals`. Seul le testeur agit
  sur sa session (`ForbiddenException` → 403).
- Compléments d'exécution (ADR-0018) : ligne de jeu de données portée par `CampaignItem`
  (`Campaign.add/bindDataSet/expandDataSet`, valeurs : `DataSetRow`) ; appel de cas de test par un
  pas (`StepContent`, `ManualStep.calledTest`, contrôle de boucle dans `TestCase`, déroulé dans
  `Execution.unfold`) ; dossiers de campagnes (`CampaignFolder`, `CampaignFolderService`, mêmes
  chemins « a/b » que les tests) ; anomalies d'une exigence par traçabilité
  (`DefectService.tracedFor`). Un test peut figurer plusieurs fois dans une campagne : les
  `data-testid` des lignes prennent le suffixe `itemSuffix` (« -2 » = ligne 2 du jeu). La sélection
  décline d'office un test manuel à jeu de données sur les lignes de son premier jeu (`Campaign.select`, ADR-0022).
  Un test manuel à paramètres ne passe à READY qu'avec un jeu de données non vide (`TEST_DATASET_REQUIRED`,
  ADR-0028) : dans les tests et les données de démo, donner un jeu à tout test manuel paramétré.
- Campagnes et exécutions (ADR-0016) : règles dans `Campaign`, `CampaignItem`, `Execution`
  (statut déduit : `ExecutionRules`), `Defect`, `DefectDraft` (domaine). Après avoir ajouté des
  éléments à une collection en cascade, `flush()` avant de renvoyer leurs identifiants.
- Exécutions dans un périmètre sprint / release : `TraceabilityService.executionScope` (§7.2).
- DTO : noms simples uniques dans tout `com.traceagile.api` (springdoc nomme les schémas d'après
  eux) ; `ArchitectureTest.dtoNamesAreUnique` le vérifie.
- Planification (ADR-0015) : règles de dates et de cycle de vie dans `Release` / `Sprint` /
  `SprintSchedule` (domaine) ; transitions d'exigences décidées par la planification via
  `RequirementService.applyPlanningStatus` (sans DoR, auditée).
- Traçabilité (ADR-0014) : statuts et couverture calculés par `TraceabilityService` sur une
  `ProjectTrace` chargée une fois par requête (jamais exigence par exigence) ; règles pures dans
  `VerificationRules` / `CoverageCalculator` (domaine). Les faits d'exécution passent par le port
  `ExecutionResults`. La suspicion (§3.3-7) est un écouteur de `RequirementChanged` (champs de contenu).

### Front-end
- TypeScript strict, ESLint sans avertissement. Mantine 7, TanStack Query, Zustand, RHF + Zod.
- Appels API uniquement via `api` (`src/api/client.ts`) et des hooks par domaine
  (`src/api/queries.ts`, `src/api/requirements.ts`) ; `unwrap()` transforme les erreurs RFC 9457 en
  `ApiError` (`code`, `fieldErrors`, `problem` pour les détails comme `unmetItems`).
- Un fichier de composant n'exporte que des composants (ESLint react-refresh) : helpers dans
  `model.ts`, `filters.ts`, `permissions.ts`…
- Formulaires à sous-éditeurs (fiche test) : brouillon local + `toPatch()` champ à champ
  (`features/tests/draft.ts`) plutôt que React Hook Form.
- Arbres : menu contextuel avec `components/tree/NodeMenu` (`NodeMenuRow` : clic droit + bouton
  « ⋯ » `{testId}-menu`, entrées `menu-{clé}`) ; saisies et confirmations avec `components/Dialogs`
  (`PromptModal`, `ConfirmModal`, testids `prompt-input`, `prompt-submit`, `confirm-submit`).
- Éditeur Markdown (`MarkdownField`) : garder `overflow={false}` (sinon le `body` reste bloqué
  après un panneau latéral, ADR-0013).
- Statut de vérification : `features/traceability/VerificationBadge` (pastille, `data-status`) ;
  hooks dans `src/api/traceability.ts`, qui invalident traçabilité, tests et exigences.
- Pluriels i18next : en français, 0 est au singulier (`_one`).
- Clés : `components/keys/KeyLink` (lien + aperçu au survol), `MarkdownView` (Markdown assaini, clés
  cliquables). Raccourcis (§13.3) : `components/search/useShortcuts` (N, E et touches de page ;
  ignorés pendant la saisie) ; `?` et `Ctrl+K` sont gérés par `AppLayout`. Pièces jointes :
  `components/attachments/AttachmentsPanel` (téléversement, collage d'image avec `pasteZone`).
  Sous jsdom, un `FormData` n'arrive pas à MSW : tester la requête (paramètres), pas son corps.
- Graphiques (tableau de bord) : `components/charts/Charts` (`LineChart`, `ColumnChart`, SVG maison,
  géométrie dans `geometry.ts`) ; pas de bibliothèque de graphiques. Rapports : hooks dans
  `src/api/reports.ts`, exports par `downloadReport` (Bearer + URL d'objet), affichage web dans une
  `iframe` `sandbox` alimentée par l'export HTML. Textes génériques : `common.cancel|save|edit|delete`.
- Glisser-déposer entre colonnes (planification) : `useDraggable` / `useDroppable` de dnd-kit, avec
  toujours un bouton équivalent (clavier, tests) ; en Playwright, `glisser()` de `e2e/tests/support.ts`.
- Mutation optimiste suivie d'une navigation : dans un test bout en bout, attendre la réponse
  (`page.waitForResponse`) avant de quitter la page.
- Redéploiement : `index.html` est servi en `no-cache` (nginx) et `staleBuild.ts` recharge une fois la
  page, sur l'écran demandé, quand un morceau chargé à la demande a disparu (`vite:preloadError`).
- Éditeurs de code : `components/code/CodeEditor` (Monaco local, chargé à la demande ; grammaire
  Gherkin et autocomplétion dans `monacoSetup.ts`). En test (jsdom), il devient une zone de texte.
- user-event : « {{ » saisit une accolade littérale (`'${{nom}'` pour taper `${nom}`).
- Filtres de liste dans l'URL (`useSearchParams`) ; glisser-déposer avec dnd-kit, ordre calculé par
  `reorder()` et mise à jour optimiste annulée en cas d'erreur (§11.4).
- Droits côté interface (`useCanWriteRequirements`, `useCanContribute`) : confort uniquement, l'API
  reste juge (§2.2).
- Jeton d'accès en mémoire (`useAuthStore`), rafraîchissement par cookie HttpOnly (ADR-0003).
- Textes dans `locales/fr.json` et `en.json` (mêmes clés).
- Tout élément interactif porte un `data-testid` stable (§13.3).
- Tests : `renderRoutes` / `renderElement` (`src/test/render.tsx`), MSW (`src/test/server.ts`) ;
  `src/test/polyfills.ts` corrige l'incompatibilité AbortSignal jsdom / undici du routeur.

### Évolution de l'API
1. Modifier le back-end et ses tests.
2. `cd backend && mvn verify` : `OpenApiExportTest` réécrit `frontend/openapi/traceagile-api.json`.
3. `cd frontend && npm run api:generate` : régénère `src/api/schema.d.ts`.
4. Versionner les deux fichiers (la CI vérifie qu'ils sont à jour).

### Jeu de démonstration (§15.1)
`DemoDataLoader` (profil `demo`, idempotent, vérifié par `DemoDataTest`).
- Lot 0 : utilisateurs `admin` (administrateur système), `po`, `qa1`, `qa2`, `dev`, `viewer`
  (mot de passe `demo`) et projet `SHOP` avec un rôle pour chacun.
- Lot 1 : backlog de SHOP décrit dans `traceagile-api/src/main/resources/demo/shop-requirements.json`
  (3 épics, 8 features, 25 stories toutes avec critères dont 16 en Gherkin, 4 règles métier, 4 ENF ;
  12 stories « Prête »).
- Lot 2 : `demo/shop-tests.json` chargé par `DemoTestsLoader` : 20 tests manuels (dont jeux de
  données — clé `dataSet`, chargée comme jeu nommé « Recette » — et candidats à l'automatisation),
  8 chartes, 14 tests automatisés (UI Playwright, API REST Assured, JUnit 5, data-driven, Gatling ;
  identifiants `@fail` / `@flaky` pour le simulateur du lot 7) et 16 tests BDD générés depuis les critères Gherkin ; 2 tests orphelins ; plusieurs
  stories non couvertes. Tous `READY`.
- Lot 4 : `REL-1` « Version 2.0 », 3 sprints de 2 semaines calés sur la date du jour — `SPR-1` clos
  (une story reportée), `SPR-2` actif, `SPR-3` planifié (`DemoPlanningLoader`, rejoué si aucune release).
- Lot 8 : ordre du chargement — SPR-1 démarré, recette CMP-1 jouée, **puis** SPR-1 clos (son bilan
  figé `RPT-1` a donc des données), SPR-2 démarré, CMP-2 / CMP-3 ; définition « Synthèse qualité »
  (Word) et bilan non figé de SPR-2 (`DemoReportLoader`).
- Lot 9 : atelier Example Mapping sur « Choisir le mode de livraison » (règles, exemples, une question
  ouverte, une résolue ; pas de conversion, elle rendrait ses tests suspects), commentaires, valeurs
  mesurées des ENF « Temps de réponse des pages » et « Disponibilité du tunnel de commande », capture
  jointe à l'anomalie bloquante (`DemoWorkshopLoader`).
- Lot 7 : serveur « Simulateur » appairé dès qu'il répond (jeton émis par le simulateur) ; 3 runs
  passés sur CMP-2 (RUN-1 à RUN-3), deux tests automatisés instables.
- Lot 6 : 5 sessions exploratoires débriefées et approuvées par le PO (2 par charte de CMP-1, la
  première bloquée ; 1 de qa1 dans CMP-2), une session de qa2 à approuver dans CMP-2.
- Lot 5 : `CMP-1` « Recette SPR-1 » terminée (SPR-1 validé à 75 %, une 2ᵉ tentative), `CMP-2`
  « Recette SPR-2 » en cours (« Mes exécutions » de qa1 / qa2), `CMP-3` « Régression 2.0 »
  planifiée ; DEF-1 à DEF-6 de sévérités variées (`DemoCampaignLoader`, rejoué si aucune campagne).
  Campagnes rangées sous « Version 2.0/Recettes de sprint » et « Version 2.0/Régression », dossier
  « Archives » vide (`organize`, appliqué aussi à une base existante sans dossier).
- Lot 3 : la story « Appliquer un code promo » est précisée après coup → ses tests sont
  `NEEDS_UPDATE` et leurs liens suspects (§3.3-7). Sur une base déjà chargée, la démo n'est pas
  rejouée : `docker compose down -v` pour repartir de zéro.
- À compléter à chaque lot (sprints, campagnes…).

### Guide et jeu saucedemo (ADR-0025)
`saucedemo/` est un projet npm autonome : `app-tests/` (vrais tests de www.saucedemo.com, rapport
`results/junit-saucedemo.xml`, un échec attendu `@fail`), `features/` + `support/gherkin.ts` (Gherkin
joué par Playwright), `guide/NN-*.spec.ts` (scénario TraceAgile qui crée le projet `SWAG` et capture
dans `docs/guide/images/` avec `capturer()`). Les clés REQ-n / TC-n sont déterministes sur un projet
neuf : ne pas réordonner les créations sans mettre à jour les tags `@REQ-n` du dépôt et le guide. Les
sorties Playwright vont dans le TEMP (OneDrive verrouille les traces). Après un changement d'écran :
régénérer, puis relire `docs/guide/README.md`.

### Bout en bout (§15.3)
Un fichier `e2e/tests/parcours-N-*.spec.ts` par parcours, étapes en `test.step` lisibles par un
non-développeur ; les données créées portent un suffixe horodaté pour rejouer sur la même base.
Les parties d'un parcours qui dépendent d'un lot futur sont annotées (`test.info().annotations`).
