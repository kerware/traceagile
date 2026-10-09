# ADR-0014 — Traçabilité et couverture avant les exécutions

**Statut** : acceptée (lot 3)

**Contexte.** Le §7 calcule des statuts et des indicateurs à partir des exécutions, des anomalies,
des campagnes, des releases et des sprints. Les releases et les sprints arrivent au lot 4, le reste
aux lots 5 et 7. Le lot 3 doit pourtant livrer des formules justes et testées, ainsi qu'une matrice
correcte sur le jeu de démonstration. Pour chaque point ouvert, l'option la plus simple a été
retenue (§16.1-5).

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Faits d'exécution | Port `ExecutionResults` (application) : dernière exécution de chaque test, exigences ayant une anomalie BLOCKER ou CRITICAL ouverte, anomalies d'une exigence ou sans exigence, campagnes en cours d'un test. Au lot 3, l'adaptateur `NoExecutionResults` répond « rien ». Il sera remplacé au lot 5. `ExecutionStatus` (§3.2) est déjà dans le domaine. Un test est **exécuté** si son dernier résultat est `PASSED`, `FAILED`, `BLOCKED` ou `ERROR` ; `SKIPPED`, `NOT_RUN` et `RUNNING` ne comptent pas. |
| Statut de vérification (§7.3) | Les conditions du §7.3 se recouvrent. Ordre de priorité retenu : non couverte, en échec, suspecte, bloquée, puis validée, en cours ou non exécutée. `ERROR` (erreur technique) compte comme bloqué : on ne peut pas conclure. Seuls les liens `VERIFIES` / `PARTIALLY_VERIFIES` vers des tests non `OBSOLETE` comptent. |
| Agrégation (§7.2) | Une exigence parente agrège ses enfants **actifs** (ni `OBSOLETE` ni `REJECTED`), ainsi que son propre statut si elle a des tests directs. Elle est en échec, suspecte ou bloquée dès qu'un enfant l'est. Elle est validée si tous le sont, non couverte si aucun n'est couvert, non exécutée si rien n'a été exécuté, en cours sinon. |
| Suspicion (§3.3-7) | Portée par le lien : `trace_links.suspect_since`. Elle est déclenchée par l'événement `RequirementChanged` quand un champ de **contenu** change : type, titre, description, user story, critères, catégorie, Planguage. Le statut, le rang, la priorité, l'estimation, le risque et les tags ne la déclenchent pas. Elle ne concerne que les liens couvrants de tests `READY` ou `NEEDS_UPDATE`, et les tests `READY` passent à `NEEDS_UPDATE`. Elle est levée par la revue (`POST /trace-links/{id}/review`) ou quand le test revient à `READY`. Au lot 5 s'ajoutera la règle du §7.3 : « exigence modifiée après la dernière exécution ». |
| Formules (§7.2) | `CoverageCalculator`, fonctions pures testées unitairement. Une **feuille** est une exigence active sans enfant actif. Un critère est lié s'il a un lien couvrant vers un test non obsolète. Le poids du risque vaut 1, 2, 4 ou 8 ; une exigence sans risque compte 1, mais le risque vaut `MEDIUM` par défaut. Un périmètre vide donne un pourcentage absent, pas 0. |
| Périmètre | `project` (défaut) ou `requirement:REQ-n` : l'exigence et ses descendants (épic, feature…). `release:` et `sprint:` renvoient 422 `SCOPE_NOT_AVAILABLE` jusqu'au lot 4. Un autre périmètre renvoie 422 `SCOPE_INVALID`. |
| Calcul | À la demande. Le projet (exigences, tests, liens, résultats) est chargé une fois par requête dans `ProjectTrace`, et les statuts y sont mémorisés pendant la requête. Pas de cache inter-requêtes au prototype : le volume reste faible. Un cache invalidé par les événements sera ajouté si les cibles de performance (§14) l'exigent. |
| Matrice (F-TRA-04) | Lignes : les exigences du périmètre dans l'ordre de l'arbre, avec leur profondeur et leur statut. Colonnes : par défaut, les tests liés au périmètre ; avec `tests=all`, tous les tests non obsolètes, pour lier d'un clic. Filtre `kind`. Une cellule correspond à un lien test → exigence ; les critères précisés y figurent en positions. Un clic sur une case vide crée un lien `VERIFIES`, que l'on peut ensuite changer, revoir ou supprimer. |
| Liens (F-TRA-01, F-TRA-02) | `POST`, `PATCH` (avec `If-Match` facultatif), `DELETE` et `POST …/review` sur `/projects/{p}/trace-links`. Créer ou modifier un lien revient à modifier le test : droits du testeur, ou du développeur pour un test automatisé (§2.2). Le PO, qui ne fait que lire les tests, ne lie pas. Supprimer un lien supprime aussi les liens du même test vers les critères de l'exigence. Chaque opération est auditée (`TRACE_LINK`). |
| Critères (F-REQ-12) | État calculé à la lecture d'après les tests liés au critère. La colonne `acceptance_criteria.status` du lot 1 n'est plus lue. |
| DoD (F-REQ-19) | « Tous les tests liés passés » est évalué : faux s'il n'y a aucun test couvrant ou si l'un d'eux n'a pas réussi lors de sa dernière exécution. « Aucune anomalie bloquante » reste non évalué jusqu'au lot 5. |
| Orphelins (F-TRA-06) | Exigences feuilles actives sans lien couvrant ; tests non obsolètes sans aucun lien vers une exigence ; tests automatisés jamais exécutés (tous, jusqu'au lot 7) ; anomalies sans exigence (vide jusqu'au lot 5). |
| Impact (F-TRA-07) | Tests non obsolètes liés, quel que soit le type de lien, à l'exigence et à ses descendants, avec l'exigence de rattachement et l'alerte de suspicion. Les campagnes en cours viennent du port, donc rien jusqu'au lot 5. |
| Export (F-TRA-08) | CSV au format de l'ADR-0011, avec une colonne par test. Cellule : `V`, `PV` ou `R`, suivi de `!` si le lien est suspect et du dernier résultat. PDF : bibliothèque OpenPDF, A4 paysage, tests répartis par tranches de 18 colonnes, cellules colorées. |
| Démonstration | `DemoTestsLoader` précise la story « Appliquer un code promo » après la rédaction de ses tests. Ses tests passent à `NEEDS_UPDATE` et leurs liens deviennent suspects. `DemoDataTest` vérifie la matrice : une ligne par exigence, une cellule par lien, les colonnes égales aux tests liés, suspicion sur cette seule story. |
