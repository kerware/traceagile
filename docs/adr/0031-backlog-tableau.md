# ADR-0031 — Vue tableau du backlog

**Statut** : acceptée

**Contexte.** La page Backlog avait deux vues, arbre et liste. Il faut une troisième vue, en
colonnes « À faire », « En cours » et « Terminée », avec toutes les user stories et exigences non
fonctionnelles.

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Contenu | Types `USER_STORY` et `NON_FUNCTIONAL`, par rang. Les exigences rejetées ou obsolètes ne s'affichent pas. |
| Colonnes | À faire = `DRAFT`, `TO_REFINE`, `READY` ; En cours = `IN_SPRINT` ; Terminée = `DONE`, `ACCEPTED` (`BOARD_COLUMNS`). Le statut exact reste affiché sur chaque carte. |
| Chargement | Une requête par colonne sur la liste existante (`type`, `status`, `size` 200, taille maximale de l'API) : aucun nouvel endpoint. Au-delà de 200 cartes, la colonne le signale et renvoie vers la vue Liste. |
| Déplacement | Glisser-déposer (dnd-kit), avec un menu « ⋯ » équivalent pour le clavier. Une colonne vise un statut : À faire → `READY`, En cours → `IN_SPRINT`, Terminée → `DONE`. Le changement passe par la même fenêtre que la fiche (`StatusChangeModal` : transitions autorisées, DoR avant Prête, DoD avant Terminée). Une transition interdite est expliquée, avec les statuts possibles. |
| URL | `?view=board`, comme `?view=list`. |
