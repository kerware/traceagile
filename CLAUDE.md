# CLAUDE.md — TraceAgile

Prototype de gestion des exigences agiles et des tests. **La spécification fait foi :
[`SPECIFICATION.md`](SPECIFICATION.md)** ; les décisions prises en cas d'ambiguïté sont dans
[`docs/adr/`](docs/adr/README.md).

## Avancement des lots (§16.2)

| Lot | Contenu | État |
| --- | --- | --- |
| 0. Socle | Multi-modules, Docker Compose, Flyway, JWT, utilisateurs, projets, membres, squelette React, CI | **Fait** (branche `lot-0-socle`) |
| 1. Exigences | Backlog, fiche, critères, ENF, rang, DoR/DoD, versions, audit, CSV | **Fait** (branche `lot-1-exigences`) |
| 2. Tests | Référentiel, manuels, automatisés, Gherkin Monaco, génération BDD, tags `@REQ-` | À faire |
| 3. Traçabilité | Liens, statut de vérification, couverture, matrice, orphelins, impact | À faire |
| 4. Planification | Releases, sprints, planification, démarrage / clôture | À faire |
| 5. Campagnes et exécution manuelle | Campagnes, sélection, affectation, exécution pas à pas, anomalies | À faire |
| 6. Exploratoire | Chartes, sessions, TBS, PROOF, métriques | À faire |
| 7. Exécution automatisée | `ExecutionServerClient`, simulateur, webhooks, SSE, import de rapports | À faire |
| 8. Bilans | Tableau de bord, burndown, bilans, verdict, exports | À faire |
| 9. Atelier et finitions | Example Mapping, Ctrl+K, raccourcis, accessibilité, démo complète, NF | À faire |

Reporté (à reprendre dans le lot indiqué) :
- Parcours §15.3 étape 1 : ajout de la story à `SPR-2` → lot 4 (sprints). Le reste est automatisé.
- F-REQ-11 « Générer un test BDD » et éditeur Monaco Gherkin (F-AUT-04) → lot 2.
- F-REQ-12 état calculé des critères, items DoD sur les tests (aujourd'hui « non évalués ») et
  `NEEDS_UPDATE` des tests liés sur `RequirementChanged` (§3.3-7) → lot 3.
- §3.3-6 « suppression interdite si exécutée » et item DoD « aucune anomalie bloquante » → lot 5.
- F-REQ-18 valeur mesurée d'une ENF → lot 7. Commentaires, pièces jointes, Example Mapping → lot 9.
- `docs/execution-server-api.yaml` (contrat §10) → lot 7.
- Seuil JaCoCo bloquant (NF-12), SpotBugs (NF-13), axe-core (NF-10) → lot 9 ; le rapport JaCoCo est
  déjà produit par `mvn verify`.

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
```

Windows : si une JVM échoue avec `Unable to establish loopback connection`, le TEMP en nom court
8.3 est en cause ; le pom passe déjà `-Djdk.net.unixdomain.tmpdir` aux tests.

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
- Tests : unitaires purs (domaine), Mockito (application), `AbstractApiTest` (MockMvc +
  PostgreSQL Testcontainers partagé, base vidée avant chaque test : `truncate … cascade` depuis
  `projects`/`users`, plus les tables sans clé étrangère comme `audit_events`). Chaque contrôleur :
  nominal, 400, 403, 412 si PATCH, 422 pour les règles métier.
- Ports : API **8085**, simulateur 8090, PostgreSQL 5433 (hôte). Voir ADR-0008.

### Front-end
- TypeScript strict, ESLint sans avertissement. Mantine 7, TanStack Query, Zustand, RHF + Zod.
- Appels API uniquement via `api` (`src/api/client.ts`) et des hooks par domaine
  (`src/api/queries.ts`, `src/api/requirements.ts`) ; `unwrap()` transforme les erreurs RFC 9457 en
  `ApiError` (`code`, `fieldErrors`, `problem` pour les détails comme `unmetItems`).
- Un fichier de composant n'exporte que des composants (ESLint react-refresh) : helpers dans
  `model.ts`, `filters.ts`, `permissions.ts`…
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
- À compléter à chaque lot (tests, sprints, campagnes…).

### Bout en bout (§15.3)
Un fichier `e2e/tests/parcours-N-*.spec.ts` par parcours, étapes en `test.step` lisibles par un
non-développeur ; les données créées portent un suffixe horodaté pour rejouer sur la même base.
Les parties d'un parcours qui dépendent d'un lot futur sont annotées (`test.info().annotations`).
