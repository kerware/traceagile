# ADR-0016 — Campagnes, exécution manuelle et anomalies

**Statut** : acceptée (lot 5)

**Contexte.** Les §8.3, §8.4 et §8.6 fixent les fonctions, mais laissent ouverts plusieurs points :
- l'éligibilité des tests à une campagne ;
- le calcul du score de risque ;
- la gestion des pas « ignorés » ;
- les droits sur les anomalies ;
- la portée des exécutions dans les indicateurs.

Pour chacun, l'option la plus simple a été retenue (§16.1-5).

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Campagne (F-CMP-01) | Périmètre `SPRINT` (un sprint), `RELEASE` (une release) ou `REGRESSION` (aucun), sinon 422 `CAMPAIGN_SCOPE_INVALID`. Les dates prévues reprennent par défaut celles du sprint ou de la release. Cycle : `PLANNED` → `IN_PROGRESS` (démarrage explicite ou première exécution) → `COMPLETED`, ou `ABORTED`. Une campagne terminée ou abandonnée est en lecture seule (`CAMPAIGN_CLOSED`). |
| Sélection (F-CMP-02) | `POST /campaigns/{key}/items/select` avec une stratégie, cumulable avec les sélections précédentes. `SPRINT_REQUIREMENTS` : tests liés (vérifie, vérifie partiellement) aux exigences du sprint de la campagne, des sprints de sa release, ou du sprint donné. `TAG` : tag du test ou tag d'exécution. `IMPACT` : analyse d'impact (F-TRA-07) des exigences données, sinon tests dont un lien est suspect (§3.3-7). `MANUAL` : liste de clés. `FAILED_IN_CAMPAIGN` : tests dont la dernière tentative est `FAILED` ou `ERROR` dans une autre campagne. Seuls les tests **`READY`** sont ajoutés ; les autres sont renvoyés avec un motif (`ALREADY_SELECTED`, `NOT_READY_<statut>`). |
| Version (§3.3-5) | L'élément de campagne retient la version du test à la sélection. Une exécution fige la version **exécutée**, c'est-à-dire la version courante, en copiant ses pas. L'interface signale un test modifié depuis la sélection. |
| Priorisation (F-CMP-03) | Score = poids du risque × poids de la priorité. Risque : 1, 2, 4 ou 8, le plus élevé parmi les exigences couvertes, et 1 sans exigence. Priorité : MUST 4, SHOULD 3, COULD 2, WONT 1. Les nouveaux tests arrivent en fin de campagne, triés par score. L'action « Trier par risque » réordonne tout, et l'ordre reste modifiable à la main (`PUT …/items/order`). |
| Affectation (F-CMP-04) | Tests manuels et chartes : un membre ayant `EXECUTION_WRITE` (`ASSIGNEE_CANNOT_EXECUTE` sinon). Tests automatisés : serveur d'exécution, sans affectation possible (`CAMPAIGN_ITEM_AUTOMATED`). Tout testeur du projet peut exécuter un test, même s'il ne lui est pas affecté. |
| Charge (F-CMP-05) | Par testeur, plus une ligne « non affecté » : somme des durées estimées des tests manuels et des timebox des chartes. Les tests sans durée sont comptés à part ; les automatisés sont exclus. |
| « Mes exécutions » (F-EXE-01) | `GET /projects/{p}/my-executions` (plutôt que `/me/executions` : la permission dépend du projet) : tests affectés à l'utilisateur dans les campagnes `PLANNED` ou `IN_PROGRESS`. |
| Exécution pas à pas (F-EXE-01) | Une tentative manuelle copie les pas du test. Les `${paramètres}` sont résolus par les valeurs par défaut, puis par la ligne du jeu de données choisie à l'exécution (ADR-0013). Un paramètre sans valeur reste `${nom}`. Statut des pas : `PASSED`, `FAILED`, `BLOCKED`, `SKIPPED`, ou `NOT_RUN` pour remettre un pas à jouer. |
| Statut global (F-EXE-02) | `FAILED` si un pas échoue. Sinon `BLOCKED` si un pas est bloqué. Sinon `RUNNING` tant qu'un pas reste à jouer. Sinon `PASSED`, ou `SKIPPED` si tous les pas sont ignorés (un pas ignoré ne compte pas). Fin et durée sont enregistrées dès que le statut est final. Un statut forcé exige un commentaire s'il diffère du statut déduit, et reste ensuite figé. |
| Tentatives (F-EXE-04) | « Réexécuter » crée la tentative n + 1, refusé tant qu'une tentative est en cours (`EXECUTION_IN_PROGRESS`). Seule la dernière tentative d'une campagne ouverte se modifie (`EXECUTION_NOT_LATEST`). Le statut d'un test de campagne est celui de sa dernière tentative. Un test exécuté ne se retire plus de la campagne. |
| Anomalie (F-EXE-03) | `GET /executions/{id}/defect-draft` propose une anomalie. Titre : test et pas en échec. Description Markdown : campagne, environnement, build, jeu de données, étapes jusqu'au pas en échec, attendu, obtenu. Sévérité proposée : MAJOR. Exigences proposées : celles que le test couvre. L'anomalie est liée à l'exécution et à ces exigences. Les captures arrivent avec les pièces jointes (lot 9). |
| Anomalies (F-DEF-01) | `OPEN` → `IN_PROGRESS` / `RESOLVED` / `REJECTED`. `IN_PROGRESS` → `OPEN` / `RESOLVED` / `REJECTED`. `RESOLVED` → `CLOSED` / `OPEN`. `CLOSED` et `REJECTED` → `OPEN` (réouverture). Est « ouverte » une anomalie `OPEN` ou `IN_PROGRESS`, et « bloquante » une anomalie `BLOCKER` ou `CRITICAL`. Création : `EXECUTION_WRITE`. Modification : tout membre sauf le lecteur (le développeur résout, le PO rejette ou clôt). `externalRef` est un texte libre (F-DEF-02 ; connecteur non implémenté). Pas de suppression. |
| Traçabilité | `CampaignExecutionResults` remplace `NoExecutionResults` (ADR-0014). Le statut des exigences (backlog, fiche, matrice du projet) prend la dernière exécution finale toutes campagnes confondues. **Dans un périmètre sprint ou release** (couverture, matrice, feuille de route, bilan de release), seules comptent les exécutions des campagnes de ce sprint ou de cette release, ou des sprints de cette release (§7.2 « dans le périmètre »). Une anomalie bloquante ouverte met l'exigence en échec. |
| DoD (F-REQ-19) | « Aucune anomalie bloquante ouverte » est désormais évalué. |
| Suppression (§3.3-6) | Un test exécuté (`TEST_ALREADY_EXECUTED`) ou sélectionné dans une campagne (`TEST_IN_CAMPAIGN`) ne se supprime pas. Une exigence dont un test lié a été exécuté non plus (`REQ_ALREADY_EXECUTED`) : on la passe à `OBSOLETE`. |
| Candidats (F-MAN-02) | Les résumés de tests portent `executionCount` (toutes tentatives). `sort=executionCount,desc` trie en mémoire (propriété calculée). C'est l'ordre par défaut du filtre « Candidats à l'automatisation ». |
| Hors lot | Sessions exploratoires (lot 6) : dans la démo, une charte reçoit un résultat global sans session. Runs automatisés et import de rapports (lot 7) : la démo enregistre des résultats automatisés « enregistrés », `Execution.recorded`, que réutilisera le lot 7. Pièces jointes (lot 9). |
| Démonstration | `CMP-1` « Recette SPR-1 » est terminée : tout est exécuté. Un test manuel échoue : DEF-1 MAJOR est corrigée et close, puis la 2ᵉ tentative réussit. Un test automatisé ne couvrant qu'une story échoue : DEF-2 CRITICAL reste ouverte. SPR-1 est donc validé à **75 %** (3 stories sur 4), à défaut des 85 % du §15.1, impossibles avec 4 stories. `CMP-2` « Recette SPR-2 » est en cours : tests affectés à qa1 et qa2, quelques exécutions, dont DEF-3 BLOCKER en cours de correction. `CMP-3` « Régression 2.0 » est planifiée (tag `regression`). Il y a aussi DEF-4 mineure, DEF-5 rejetée et DEF-6 sans exigence. |
