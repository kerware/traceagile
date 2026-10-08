# ADR-0009 — Précisions sur les règles métier des exigences

**Statut** : acceptée (lot 1)

**Contexte.** Le §3 et le §4 laissent plusieurs points ouverts. Option la plus simple retenue pour
chacun (§16.1-5).

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Parenté (§3.3-1) | Une `USER_STORY` a **obligatoirement** un parent `FEATURE` ou `EPIC` (la spec n'écrit pas « ou aucun », contrairement à la feature). `TECHNICAL_ENABLER`, non cité, suit la story mais peut être à la racine. Le parent est dans le même projet ; un changement de type revérifie parent et enfants. |
| Cycle de vie (§3.2) | Avancer d'un cran, revenir d'un cran ; `DRAFT → READY` direct autorisé ; `REJECTED` depuis DRAFT, TO_REFINE, READY ; `OBSOLETE` depuis tout statut, et terminal : une exigence obsolète ne se modifie plus. `IN_SPRINT` reste accessible à la main jusqu'au lot 4, qui l'automatise au démarrage du sprint. |
| Changement de statut | Endpoint dédié `POST …/requirements/{key}/status {status, acknowledgeUnmet}` plutôt qu'un champ du PATCH, pour porter la confirmation de la DoR / DoD. |
| DoR / DoD (§3.3-2, F-REQ-19/20) | Listes par projet, initialisées à la création du projet (événement `ProjectCreated`). Un item **automatique** insatisfait **bloque** (422 `CHECKLIST_NOT_SATISFIED`) ; un item **manuel** non coché demande une **confirmation** (422 `CHECKLIST_ACKNOWLEDGEMENT_REQUIRED` sans `acknowledgeUnmet`). Le « au moins un critère » du §3.3-2 est en plus une règle du domaine, indépendante du paramétrage. Les items sur les tests et anomalies sont « non évalués » (ne bloquent pas) jusqu'aux lots 3 et 5. |
| ENF transverse (F-REQ-17) | Une ENF transverse s'applique aux user stories descendantes de **son parent** ; sans parent, à tout le projet. |
| Merge-patch (complète ADR-0005) | Pour les exigences, `null` **efface** le champ et un champ absent est conservé : le contrôleur lit le corps JSON brut (`MergePatch`), car Jackson confond les deux avec `Optional`. |
| Déplacement (F-REQ-02/03) | `POST …/move {parentKey, beforeKey, afterKey}` : l'exigence est insérée **après** `afterKey` et **avant** `beforeKey` ; `parentKey` absent = racine. Le rang est global au projet, l'arbre trie les frères par rang. |
| Suppression (§3.3-6) | Refusée si l'exigence a des enfants ; la règle « jamais exécutée » s'ajoutera au lot 5. |
| Critères proposés par le testeur (§2.2) | Le testeur crée et modifie les critères comme le PO (pas de circuit de validation, exclu au §1.3) ; il coche aussi INVEST et les items manuels. |
| Adressage | Toutes les ressources sont sous `/api/v1/projects/{p}/…` (clé métier unique par projet) ; les critères sous `/projects/{p}/acceptance-criteria/{id}`. |
| Parcours §15.3 étape 1 | Automatisé jusqu'au passage à `READY` ; l'ajout à `SPR-2` viendra avec les sprints au lot 4. |
| Hors lot 1 | F-REQ-11 (générer un test BDD) au lot 2 ; F-REQ-12 (état calculé des critères) au lot 3 ; F-REQ-18 (valeur mesurée d'une ENF) au lot 7 ; commentaires et pièces jointes à un lot ultérieur. |
