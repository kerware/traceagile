# ADR-0029 — Lignes de jeu de données nommées ; appel d'un test avec un jeu nommé

**Statut** : acceptée

**Contexte.** Un jeu de données (ADR-0013) est un tableau : un nom (« Comptes ») et des lignes de
valeurs. Les lignes n'étaient connues que par leur numéro (« Comptes, ligne 1 »), et un pas qui
appelle un autre cas de test (ADR-0018) recopiait les valeurs voulues dans ses paramètres d'appel.
Revue de la démo SwagLabs : un jeu de données doit avoir un nom, et on doit pouvoir appeler un test
avec le nom du jeu plutôt qu'avec un indice de ligne.

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Nom de ligne | Chaque ligne d'un jeu a un nom (`DataSet.rowNames`, même ordre que `rows`, dans le jsonb `data_sets`). Laissé vide, il prend la première valeur non vide de la ligne (« standard_user »), sinon « Ligne n » ; un nom par défaut déjà pris reçoit un suffixe « (2) ». Deux noms donnés identiques dans un jeu (sans tenir compte de la casse) : 422 `TEST_DATASET_ROW_NAME_DUPLICATED`. Les jeux existants reçoivent leurs noms à la lecture : pas de migration de données. |
| Désignation | On désigne une ligne par « jeu › nom » : `DataSetRow.named(test, jeu, nom)`. L'index reste la clé stockée des éléments de campagne et des exécutions (identifiants `-1`, `-2`, ADR-0022), mais toutes les réponses portent `dataSetRowName`, et l'API accepte le nom (`dataSetRowName` d'un élément de campagne, `rowName` au lancement d'une exécution). L'interface affiche « Comptes › standard_user » partout au lieu de « ligne 1 ». |
| Appel avec un jeu nommé | Un pas d'appel peut désigner un jeu nommé de l'appelé (`callDataSet`, `callRow`, colonnes `manual_steps.call_data_set` / `call_data_row`, migration V18). La référence est contrôlée à l'édition (422 `TEST_CALL_DATASET_UNKNOWN`) et ses valeurs sont **lues à l'exécution** : une correction de la ligne dans l'appelé profite aux appelants. Ordre des valeurs de l'appelé : ses défauts, les valeurs de l'appelant, la ligne nommée, puis `callParameters` (cas particulier). La provenance d'un pas déroulé cite la ligne : « TC-1 Se connecter… (problem_user) ». |
| Interface | Grille des jeux : première colonne « Nom » (indication : le nom par défaut). Pas d'appel : liste « Jeu de données de l'appelé » (« Comptes › standard_user ») au lieu de la recopie des valeurs ; les valeurs de la ligne s'affichent en indication sous les paramètres d'appel. |

**Conséquences.**
- Démo SwagLabs : les lignes de « Comptes » portent le nom du compte ; TC-2 appelle TC-1 avec
  « Comptes › problem_user » (il n'a plus de paramètre propre), TC-13 avec « Comptes ›
  standard_user » et nomme les lignes de son jeu « Produits » (« Sac à dos », « Lampe de vélo »).
- Renommer une ligne appelée casse l'appel : l'exécution le signale (422 `EXECUTION_DATASET_UNKNOWN`).
  La fiche de l'appelé liste ses appelants (« Appelé par ») pour le vérifier avant.
- Correction au passage : `TestCase.checkCall` et la détection de cycle lisent l'appelé par ses
  accesseurs (un proxy Hibernate a des champs vides).
