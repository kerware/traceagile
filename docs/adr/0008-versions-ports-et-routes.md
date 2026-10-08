# ADR-0008 — Versions, ports et routes du front

**Statut** : acceptée (lot 0)

**Décisions.**
- **Spring Boot 3.5.x** (dernière ligne 3.x ; la spécification demande Boot 3.3+, Boot 4 est donc
  écarté), Java 21. Journaux JSON au format ECS natif de Boot 3.5 (NF-15), avec le `correlationId`
  du MDC alimenté par `CorrelationIdFilter` (`X-Correlation-Id` repris du navigateur ou généré).
- **Front** : React 18.3, Mantine 7, React Router 6, TanStack Query 5, Zustand 5, React Hook Form +
  Zod 3, i18next (français par défaut). Lignes majeures stables et compatibles React 18.
- **Ports** : API 8085 (8080 est souvent occupé sur les postes de développement), front 3000
  (nginx, qui relaie `/api`), simulateur 8090 (§10.5), PostgreSQL publié sur 5433 pour éviter un
  conflit avec une instance locale.
- **Routes** : celles du tableau §13.2 (`/p/:key/...`), qui fait foi face à l'exemple du §11.4
  (`/projects/SHOP/requirements/REQ-12`). Les écrans des lots suivants existent déjà comme
  emplacements réservés indiquant leur lot.
- **Jeu de démonstration** : profil Spring `demo` (activé par Docker Compose), chargé par un
  `ApplicationRunner` idempotent et complété à chaque lot.

**Conséquences.** Changer un port impose de modifier `application.yml`, `vite.config.ts`,
`nginx.conf` et `docker-compose.yml` (listés dans `CLAUDE.md`).
