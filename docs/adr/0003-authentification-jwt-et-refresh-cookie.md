# ADR-0003 — Jeton d'accès JWT et jeton de rafraîchissement en cookie

**Statut** : acceptée (lot 0)

**Contexte.** §11.1 : JWT, accès 15 min, rafraîchissement 7 jours, BCrypt. §12 : `POST /auth/login`,
`/auth/refresh`, `/auth/logout`. La spécification ne dit pas où vivent les jetons côté navigateur ni
comment la déconnexion invalide un jeton.

**Décision.**
- **Jeton d'accès** : JWT HS256 signé avec `traceagile.security.jwt-secret` (≥ 32 octets, variable
  `TRACEAGILE_JWT_SECRET`), 15 min, revendications `sub` (login), `uid`, `adm` (administrateur
  système). Validé par Spring Security Resource Server. Le front le garde **en mémoire** (Zustand).
- **Jeton de rafraîchissement** : valeur aléatoire opaque (256 bits), 7 jours, stockée **hachée**
  (SHA-256) dans `refresh_tokens`, avec **rotation** à chaque usage et révocation à la déconnexion.
  Il circule uniquement dans le cookie `traceagile_refresh` : `HttpOnly`, `SameSite=Strict`,
  `Path=/api/v1/auth`, `Secure` configurable (`TRACEAGILE_COOKIE_SECURE`).
- CSRF désactivé : les endpoints métier exigent l'en-tête `Authorization`, jamais envoyé
  automatiquement par le navigateur ; le cookie est `SameSite=Strict` et limité à `/api/v1/auth`.
- Au rechargement de page, le front appelle `/auth/refresh` pour restaurer la session ; sur un 401,
  le client API tente un rafraîchissement unique puis rejoue la requête.

**Conséquences.** Un jeton d'accès reste valable jusqu'à 15 min après la désactivation d'un
utilisateur ; les droits par projet, eux, sont réévalués à chaque requête (utilisateur actif requis).
