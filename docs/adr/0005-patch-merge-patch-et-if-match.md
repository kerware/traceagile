# ADR-0005 — PATCH (JSON Merge Patch) et verrou optimiste If-Match

**Statut** : acceptée (lot 0)

**Contexte.** §12 : mises à jour partielles en `PATCH` (JSON Merge Patch) ; `If-Match` porte la
version, réponse 412 en cas de conflit.

**Décision.**
- Les DTO de mise à jour ont des champs nullables ; un champ **absent ou nul reste inchangé**.
  L'effacement explicite d'un champ par une valeur nulle (RFC 7396) n'est pas pris en charge tant
  qu'aucun champ effaçable ne le demande. Types acceptés : `application/merge-patch+json` et
  `application/json`.
- La version JPA est exposée dans l'en-tête `ETag` (`"3"`) et dans le corps (`version`).
- `If-Match` est **facultatif** : présent, il doit égaler la version courante (sinon 412
  `VERSION_CONFLICT`) ; absent, la mise à jour s'applique (le verrou optimiste JPA protège encore
  des écritures concurrentes, également traduites en 412).

**Conséquences.** Le front envoie toujours `If-Match` avec la version qu'il affiche.
