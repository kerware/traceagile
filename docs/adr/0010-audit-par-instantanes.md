# ADR-0010 — Audit par instantanés applicatifs plutôt que listener JPA

**Statut** : acceptée (lot 1)

**Contexte.** §11.3 propose un listener JPA (`@EntityListeners`) écrivant les `AuditEvent` avec le
diff JSON des champs modifiés (NF-16). Un listener JPA ne voit ni les collections modifiées (critères,
tags) comme un changement de l'exigence, ni l'intention (déplacement, changement de statut), et ne
doit pas persister d'autres entités pendant le flush.

**Décision.**
- Chaque entité auditée fournit un **instantané** de ses champs métier (`Requirement.snapshot()`,
  critères compris). Les services prennent l'instantané avant et après la modification et appellent
  `AuditService.record(…)`, qui enregistre la différence (`SnapshotDiff`) avec une action
  (`CREATED`, `UPDATED`, `STATUS_CHANGED`, `MOVED`, `VERSION_CREATED`, `DELETED`).
- L'acteur et l'horodatage sont les champs techniques `createdBy` / `createdAt` de l'événement
  (renseignés par l'audit Spring Data).
- Le même instantané sert aux versions figées (F-REQ-21), stockées en `jsonb`. Comme `jsonb` ne
  conserve pas l'ordre des clés, l'ordre canonique est rétabli à la lecture
  (`Requirement.SNAPSHOT_FIELDS`).
- La table `audit_events` n'a pas de clé étrangère : l'historique survit à la suppression.

**Conséquences.** Un service qui modifie une entité auditée doit appeler l'audit ; c'est vérifié
par les tests d'API (onglet Historique). Les lots suivants appliquent la même méthode aux tests et
aux exécutions.
