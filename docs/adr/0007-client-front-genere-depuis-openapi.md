# ADR-0007 — Client front généré depuis l'OpenAPI exporté par un test

**Statut** : acceptée (lot 0)

**Contexte.** §11.1 : client API généré depuis l'OpenAPI (`openapi-typescript` + `openapi-fetch`),
springdoc côté back. Générer depuis une application démarrée compliquerait la CI.

**Décision.**
- `OpenApiExportTest` (module API, base PostgreSQL de test) écrit `/v3/api-docs` dans
  `frontend/openapi/traceagile-api.json`, versionné.
- `npm run api:generate` produit `frontend/src/api/schema.d.ts`, versionné également.
- La CI vérifie que les deux fichiers sont à jour (`git diff --exit-code`).
- Les champs toujours présents des DTO portent `@Schema(requiredMode = REQUIRED)` pour obtenir des
  types TypeScript non optionnels.

**Conséquences.** Toute évolution de l'API se fait en trois temps : code back-end, `mvn verify`
(export), `npm run api:generate`.
