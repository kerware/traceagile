# ADR-0013 — Paramètres, jeux de données nommés, dossiers de tests et menus contextuels

**Statut** : acceptée (corrections des lots 0 à 2). Remplace, dans l'ADR-0012, ce qui concerne
`dataSet` et le jeu de données manuel.

**Contexte.** Demandes après la livraison du lot 2 :
- gérer des paramètres dans les tests manuels et automatisés, détectés automatiquement dans les pas
  sous la forme `${nom-parametre}` ;
- gérer plusieurs jeux de données ;
- ajouter un test ou un dossier depuis un nœud de l'arbre, par un menu contextuel.

La spec (F-MAN-01, §6.1 DATA_DRIVEN) ne prévoit qu'un jeu de données anonyme par test. Pour chaque
point, l'option la plus simple compatible avec la demande a été retenue (§16.1-5).

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Paramètre | `TestParameter {name, defaultValue, description}` porté par le **cas de test** (toutes natures), en `jsonb`. Nom : lettres sans accent, chiffres, `_`, `-`, `.` (60 caractères au plus). Erreurs : `TEST_PARAMETER_NAME_INVALID`, `TEST_PARAMETER_DUPLICATED`. |
| Détection (F-MAN-01) | Dans un test manuel, chaque `${nom}` d'une action, d'un résultat attendu ou d'une donnée est un paramètre. Il n'est pas stocké tant qu'il n'a ni valeur par défaut, ni description, ni colonne de jeu de données. L'API renvoie la liste fusionnée : d'abord les paramètres détectés, dans l'ordre des pas, puis les autres paramètres déclarés. Chaque élément porte `detected`. Un paramètre déclaré absent des pas est conservé ; l'interface le marque « non utilisé ». |
| Jeux de données | `DataSet {name, rows}`, liste ordonnée sur le cas de test. Le nom est obligatoire et unique sans tenir compte de la casse. Une ligne ne peut pas être vide. Les valeurs sont scalaires (texte, nombre, booléen). Erreurs : `TEST_DATASET_NAME_REQUIRED`, `TEST_DATASET_DUPLICATED`, `TEST_DATASET_ROW_EMPTY`, `TEST_DATASET_VALUE_INVALID`. Une cellule vide signifie « valeur par défaut ». |
| Cohérence | Une colonne de jeu de données qui n'est pas encore un paramètre est déclarée automatiquement. Supprimer un paramètre retire sa colonne de tous les jeux. L'interface ne permet pas de supprimer un paramètre détecté : il faut d'abord retirer le `${nom}` des pas. |
| Configuration technique | L'ancien JSON libre `parameters` de la définition automatisée (navigateurs, URL de base, métriques…) devient `configuration` dans l'API ; la colonne en base est inchangée. Il ne faut pas le confondre avec les paramètres métier. |
| Versions (F-AUT-10) | Paramètres et jeux de données sont des modifications **significatives** pour toutes les natures. |
| Migration `V4` | `test_cases.parameters` et `test_cases.data_sets` (`jsonb`, défaut `[]`). L'ancien jeu unique (manuel ou automatisé) devient `[{name: "Jeu de données 1", rows}]` ; ses colonnes deviennent des paramètres. Les colonnes `manual_data_set` et `automated_test_definitions.data_set` sont supprimées. |
| Exécution | Choisir un jeu de données dans une campagne relève des lots 5 et 7 (`dataSet` du job, §10.3). |
| Dossiers explicites | Table `test_folders (project, path)`. Elle permet d'avoir des dossiers **vides** ; les dossiers des tests restent implicites, et « a/b » implique « a ». `GET /test-folders` renvoie tous les dossiers, triés, avec leurs ancêtres. `GET /test-cases/tree` ajoute les dossiers explicites vides. |
| Opérations sur les dossiers | `POST /test-folders {path}` : 409 `TEST_FOLDER_EXISTS` si le dossier existe déjà. `POST /test-folders/move {from, to}` renomme ou déplace une branche : dossiers explicites et dossiers des tests, y compris `OBSOLETE`, car reclasser un test ne le modifie pas. Chaque test reclassé est audité. Un déplacement vers un de ses propres sous-dossiers est refusé (422 `TEST_FOLDER_MOVE_INTO_ITSELF`). `DELETE /test-folders?path=` ne supprime qu'un dossier sans test (422 `TEST_FOLDER_NOT_EMPTY`). Un `POST /move` a été préféré à un `PATCH` : un chemin n'a pas de version, donc pas d'`If-Match`. |
| Droits (§2.2) | Créer ou supprimer un dossier : l'un des droits d'écriture sur les tests. Déplacer un dossier : il faut pouvoir modifier **chacun** des tests reclassés, donc un développeur ne déplace pas un dossier qui contient des tests manuels. |
| Menus contextuels | Ouverts par un clic droit sur la ligne ou par le bouton « ⋯ », accessible au clavier. Les entrées dépendent des droits. **Arbre des tests**, racine : nouveau test, nouveau dossier. Dossier : nouveau test ici, nouveau sous-dossier, renommer ou déplacer, supprimer (désactivé si le dossier n'est pas vide). Test : ouvrir, pleine page, ranger dans un dossier, supprimer. **Arbre du backlog** : ouvrir, pleine page, ajouter une exigence enfant (type proposé : épic → feature, feature → user story) et ajouter un test lié (création pré-liée à l'exigence). |
| Défilement | `@uiw/react-md-editor` mémorisait le `overflow` du `body` pendant le verrou du panneau latéral, puis le réécrivait (`hidden`) au démontage : la page ne défilait plus. L'éditeur est désormais monté avec `overflow={false}`, et Monaco ne capture plus la molette en bout de défilement. Non-régression : `e2e/tests/ergonomie-defilement.spec.ts`. |
