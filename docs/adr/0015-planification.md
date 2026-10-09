# ADR-0015 — Releases, sprints et planification

**Statut** : acceptée (lot 4)

**Contexte.** Les §8.1 et §8.2 décrivent les releases, les sprints et la planification sans fixer
plusieurs règles de gestion. Pour chaque point ouvert, l'option la plus simple a été retenue (§16.1-5).

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Statuts | Une seule énumération `PlanningStatus` (`PLANNED`, `ACTIVE`, `CLOSED`) pour les releases et les sprints, comme au §3.2. Les statuts changent seulement par des actions : une release passe `ACTIVE` quand l'un de ses sprints démarre, et `CLOSED` à sa clôture. |
| Dates (§3.3-3) | Début et fin obligatoires, fin incluse et postérieure ou égale au début. Un sprint d'une release tient dans ses dates et ne chevauche aucun autre sprint de cette release (422 `SPRINT_OUTSIDE_RELEASE`, `SPRINT_OVERLAP`). Replanifier une release qui exclurait un sprint est refusé. Un sprint peut exister hors release, puis y être rattaché ou détaché (`releaseKey` du PATCH). |
| Génération (F-PLN-01) | De 1 à 26 sprints de 1 à 4 semaines, consécutifs : le premier commence à la date donnée, sinon au lendemain du dernier sprint de la release, sinon au début de la release. Chaque sprint est nommé « Sprint n » (n = numéro de sa clé) et reçoit la capacité donnée. Si les sprints dépassent la fin de la release, la release est **prolongée** plutôt que la génération refusée. |
| Périmètre (F-PLN-05) | Entité `SprintScopeItem` (sprint, exigence, position, points engagés, issue). Seules se planifient les exigences `READY` de type story, règle, ENF ou enabler ; épics et features sont des conteneurs. Une exigence n'appartient qu'à **un** sprint ouvert à la fois (`REQ_ALREADY_PLANNED`). `PUT /sprints/{key}/scope` remplace le périmètre dans l'ordre donné : le glisser-déposer envoie la liste entière. |
| Charge | Somme des points des exigences du périmètre ; pourcentage de la capacité ; alerte au-delà de 100 %. Sans capacité, pas de pourcentage. Les points sont figés à la clôture pour les bilans du lot 8. |
| Démarrage (F-PLN-06) | Un seul sprint `ACTIVE` par projet (§3.3-4), vérifié par le service et par un index unique partiel en base. Les exigences `READY` du périmètre passent `IN_SPRINT`. Dans un sprint actif, une exigence ajoutée passe `IN_SPRINT` et une exigence retirée revient `READY` (parcours §15.3 étape 1 : ajout à SPR-2 actif). |
| Transitions « système » | `RequirementService.applyPlanningStatus` change le statut sans réévaluer la DoR (déjà vérifiée au passage à `READY`) ni figer de version. Le changement reste audité et publie `RequirementChanged` ; ce n'est pas un champ de contenu, donc il n'y a pas de suspicion (ADR-0014). |
| Clôture (F-PLN-06) | Seul un sprint actif se clôture. Chaque exigence reçoit une issue. `DONE` : statut `DONE` ou `ACCEPTED`. `DROPPED` : rejetée ou obsolète. Pour les autres, la décision est `BACKLOG` (par défaut) ou `NEXT_SPRINT` ; l'exigence revient `READY`, et en cas de report elle est ajoutée en fin de périmètre du **premier sprint planifié** qui suit (422 `NO_NEXT_SPRINT` s'il n'y en a pas). L'interface propose le report par défaut quand un sprint suivant existe. Un sprint clos est en lecture seule et garde son périmètre avec les issues. |
| Clôture d'une release (F-PLN-03) | Tous ses sprints doivent être clos (`RELEASE_SPRINTS_NOT_CLOSED`). Le bilan figé est un JSON horodaté (`closing_report`) : release, sprints (points engagés et terminés, nombre d'exigences, taux de validation), totaux, et les cinq indicateurs de couverture du périmètre de la release. La release passe en lecture seule. |
| Couverture par périmètre | Les périmètres `sprint:SPR-n` et `release:REL-n` de l'ADR-0014 sont livrés : ce sont les exigences des périmètres de sprint, à plat. Le taux de validation de chaque sprint de la feuille de route (F-PLN-02) est calculé en une fois (`coverageBySprint`). |
| Droits (§2.2) | Lecture : `PLANNING_READ` (tous les rôles). Écriture : `PLANNING_WRITE`, soit le PO et l'administrateur. |
| Suppression | Ni release ni sprint ne se suppriment : ce n'est pas prévu par la spec, et l'historique sert aux bilans. |
| Filtre backlog | `GET /requirements?sprint=SPR-n` (§12). |
| Démonstration (§15.1) | `DemoPlanningLoader`, idempotent, crée `REL-1` « Version 2.0 » : 3 sprints de 2 semaines calés sur la date du jour. `SPR-1` est clos : stories terminées, sauf une reportée sur `SPR-2`. `SPR-2` est actif, `SPR-3` planifié, capacité de 20 points. Le passage à `DONE` des stories de `SPR-1` passe par la transition « système » : leur DoD n'est pas entièrement satisfaite dans la démo (une anomalie critique reste ouverte au lot 5, ADR-0016). |
