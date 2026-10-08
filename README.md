# TraceAgile

Prototype de gestion des exigences agiles et des tests (Spring Boot 3 / Java 21, React 18 /
TypeScript). Spécification : [`SPECIFICATION.md`](SPECIFICATION.md). Conventions et état
d'avancement : [`CLAUDE.md`](CLAUDE.md). Décisions : [`docs/adr/`](docs/adr/README.md).

## Démarrer

```bash
docker compose up --build
```

- Application : http://localhost:3000 — comptes de démonstration `admin`, `po`, `qa1`, `qa2`,
  `dev`, `viewer`, mot de passe `demo`.
- API et Swagger UI : http://localhost:8085/swagger-ui.html
- Simulateur du serveur d'exécution : http://localhost:8090/api/v1/health

## Tester

```bash
cd backend && mvn verify                      # nécessite Docker (Testcontainers)
cd frontend && npm ci && npm run lint && npm run typecheck && npm test
```
