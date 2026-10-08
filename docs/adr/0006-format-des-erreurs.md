# ADR-0006 — Format des erreurs et codes HTTP

**Statut** : acceptée (lot 0)

**Contexte.** §11.3 : `@RestControllerAdvice` en RFC 9457 (`application/problem+json`) avec un code
métier. §15.2 : 400 validation, 403 accès refusé, 412 conflit de version.

**Décision.** Toute erreur, y compris celles de la chaîne de sécurité, est un `ProblemDetail` avec
la propriété `code` :

| HTTP | Cas | Exemples de `code` |
| --- | --- | --- |
| 400 | validation des DTO (`errors` : message par champ), corps illisible, tri inconnu | `VALIDATION_FAILED`, `MALFORMED_REQUEST`, `INVALID_SORT` |
| 401 | authentification absente ou invalide | `AUTH_REQUIRED`, `AUTH_INVALID_CREDENTIALS`, `AUTH_REFRESH_INVALID` |
| 403 | droit insuffisant (§2.2) | `ACCESS_DENIED` |
| 404 | ressource introuvable | `PROJECT_NOT_FOUND`, `USER_NOT_FOUND` |
| 409 | unicité | `PROJECT_KEY_TAKEN`, `USER_LOGIN_TAKEN` |
| 412 | version périmée | `VERSION_CONFLICT` |
| 422 | règle métier du domaine (§3.3) | `PROJECT_KEY_INVALID`, `MEMBER_DUPLICATED`, puis `REQ_PARENT_INVALID`… |

Le message `detail` est en français et affichable tel quel par l'interface.
