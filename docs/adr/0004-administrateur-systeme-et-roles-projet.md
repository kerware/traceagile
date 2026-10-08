# ADR-0004 — Administrateur système et rôles par projet

**Statut** : acceptée (lot 0)

**Contexte.** §2.2 attribue les rôles **par projet**, mais la colonne « Administration » du rôle
Administrateur (utilisateurs, projets, serveurs d'exécution) est globale. Il faut aussi pouvoir
créer le premier projet.

**Décision.**
- `User.systemAdmin` désigne l'**administrateur système** : il gère utilisateurs et projets
  (`/users`, `POST /projects`, plus tard serveurs d'exécution et référentiels) et a tous les droits
  sur tous les projets, même sans en être membre.
- Les rôles par projet sont `ADMINISTRATOR`, `PRODUCT_OWNER`, `TESTER`, `DEVELOPER`, `VIEWER`. Leurs
  droits traduisent le tableau §2.2 en permissions élémentaires (`Permission`), testées par
  `ProjectRolePermissionsTest`. L'administrateur **du projet** gère les membres de ce projet.
- Un utilisateur sans rôle ne voit pas le projet dans `GET /projects`. Un accès direct renvoie
  **403**, y compris pour une clé inexistante, pour ne pas révéler l'existence d'un projet ;
  l'administrateur système reçoit 404 sur une clé inexistante.
- Un endpoint de projet déclare `@PreAuthorize("hasPermission(#key, 'Project', 'PERMISSION')")` ;
  `EndpointSecurityTest` échoue si un endpoint n'a pas de règle (NF-08).

**Conséquences.** Deux niveaux d'administration, distingués dans l'interface (« Administrateur
système » et « Administrateur » du projet).
