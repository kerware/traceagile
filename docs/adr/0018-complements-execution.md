# ADR-0018 — Jeux de données en campagne, appel de cas de test, dossiers de campagnes, traçabilité des anomalies

**Statut** : acceptée (lot 5, demandes complémentaires)

**Contexte.** Après le lot 5, cinq besoins ont été exprimés :
- choisir, dans une campagne, le jeu de données avec lequel un test manuel sera exécuté ;
- réutiliser un cas de test comme pas d'un autre ;
- ranger les campagnes dans une arborescence de dossiers ;
- voir sur la fiche d'un test toutes ses exécutions et anomalies ;
- rattacher aux exigences, par la traçabilité, les anomalies trouvées par leurs tests.

La spécification ne fixe aucune de ces règles. Pour chaque point, l'option la plus simple a été retenue (§16.1-5).

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Jeu de données en campagne | Un élément de campagne porte en option une **ligne** de jeu de données (`dataSetName`, `dataSetRow`, base 0). Un même test peut donc figurer plusieurs fois, une fois par ligne. L'unicité porte sur (campagne, test, jeu, ligne), avec un index unique en base. Absent : les valeurs par défaut des paramètres. Seuls les tests manuels ont un jeu à l'exécution. |
| Choix de la ligne | `PATCH /campaign-items/{id}` (`dataSetName`, `dataSetRow`). La ligne ne change plus une fois le test exécuté dans la campagne (`CAMPAIGN_ITEM_EXECUTED`) : on ajoute une autre ligne. Une combinaison déjà présente est refusée (`CAMPAIGN_ITEM_DUPLICATE`), comme un jeu ou une ligne inconnus (`EXECUTION_DATASET_UNKNOWN`). |
| Décliner | `POST /campaign-items/{id}/expand-data-set` : l'élément prend la première ligne libre du jeu (s'il n'y est pas déjà). Chaque ligne absente devient un élément placé juste après, avec la même affectation et le même score. L'opération est idempotente. La sélection d'un test déjà présent reste signalée `ALREADY_SELECTED`. |
| Exécution | La ligne prévue s'impose : ses valeurs remplacent les `${nom}` des pas. Une autre ligne demandée au lancement est refusée (`EXECUTION_DATASET_BOUND`). Sans ligne prévue, le testeur peut encore choisir au lancement (ADR-0016). La copie d'une campagne (ADR-0017) conserve les lignes. |
| Appel d'un cas de test | Un pas manuel peut appeler un autre cas de test (`calledTestKey`). Son action devient facultative (commentaire), et `callParameters` donne la valeur de paramètres de l'appelé : un texte fixe ou un `${nom}` de l'appelant, qui devient alors un paramètre de l'appelant. L'appelé est un test manuel non obsolète du même projet (`TEST_CALL_INVALID`). Un appel qui reviendrait, directement ou non, vers le test est refusé (`TEST_CALL_CYCLE`). Un test appelé ne se supprime pas (`TEST_CALLED`) ; la fiche liste ses appelants (`calledBy`). |
| Déroulé à l'exécution | Au lancement, un appel est remplacé par les pas **courants** de l'appelé, récursivement, numérotés à la suite, avec la chaîne d'appel (`calledFrom` : « TC-6 … › TC-5 … »). Valeurs de l'appelé, par priorité croissante : ses défauts, puis toutes les valeurs de l'appelant (même nom, transmises aux appels imbriqués), puis les valeurs de l'appel. Le pas exécuté est figé (ADR-0016) ; modifier l'appelé ne crée pas de version de l'appelant, mais la suite des appels fait partie de son empreinte (F-AUT-10). |
| Dossiers de campagnes | Même modèle que les dossiers de tests (ADR-0013) : chemin « a/b » porté par la campagne (`folder`) et dossiers explicites, vides possibles (`/campaign-folders` : liste, création, renommage ou déplacement d'une branche, suppression d'un dossier sans campagne). Une campagne se range même terminée (archivage) : seul le champ `folder` reste modifiable sur une campagne close. Une copie reste dans le dossier de sa source. Droits : `CAMPAIGN_READ` et `CAMPAIGN_WRITE`. |
| Interface des dossiers | Page Campagnes : arbre des dossiers à gauche (menu contextuel, comptes), liste filtrée sur le dossier choisi et ses sous-dossiers. Une campagne glissée sur un dossier y est rangée. La fiche campagne propose « Ranger ». |
| Fiche test | Onglets « Exécutions » (`GET /test-cases/{key}/executions` : toutes les tentatives, toutes campagnes, avec la ligne de jeu) et « Anomalies » (`GET /test-cases/{key}/defects` : anomalies liées à ses exécutions). |
| Anomalies d'une exigence | `GET /requirements/{key}/defects` renvoie les anomalies **rattachées**, puis celles **trouvées par traçabilité**, c'est-à-dire liées à une exécution d'un test qui vérifie l'exigence. Chaque anomalie indique `linked` et les tests qui l'ont révélée (`viaTests`). `POST /requirements/{key}/defects/{defectKey}` la rattache (droits de mise à jour d'une anomalie). Seules les anomalies rattachées comptent pour l'item DoD « aucune anomalie bloquante » : la décision reste humaine. |
