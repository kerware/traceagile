# ADR-0028 — Un test manuel à paramètres prêt a un jeu de données

**Statut** : acceptée

**Contexte.** Un test manuel peut avoir des paramètres (`${nom}` dans ses pas, ou paramètres
déclarés). Sans jeu de données, il se jouait avec les seules valeurs par défaut : on ne savait pas
avec quelles données le test avait été exécuté, et une valeur par défaut oubliée restait affichée
telle quelle (`${nom}`). La revue de la démo SwagLabs a fixé la règle : tout test manuel avec des
paramètres doit avoir au moins un jeu de données.

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Moment du contrôle | Au **passage à « Prêt »** (`TestCase.changeStatus`), comme la règle « au moins un pas » (ADR-0012). Un brouillon peut être enregistré sans jeu de données : on écrit les pas, puis le jeu. |
| Condition | Test **manuel**, au moins un paramètre (détecté ou déclaré), et aucun jeu de données **avec au moins une ligne**. Un jeu vide ne compte pas. |
| Erreur | `BusinessRuleException("TEST_DATASET_REQUIRED")` → 422, message « Un test manuel à paramètres prêt a au moins un jeu de données avec une ligne. » |
| Hors règle | Tests automatisés (leurs paramètres viennent du code ou du jeu facultatif) et chartes exploratoires. Les paramètres d'un **appel** de cas de test sont fixés par le pas d'appel : ils ne comptent que s'ils citent un `${nom}` du test appelant, qui devient alors un de ses paramètres. |
| Tests déjà prêts | Pas de migration : la règle s'applique à la prochaine transition vers « Prêt » (par exemple depuis « À mettre à jour »). |

**Conséquences.**
- Sélectionné dans une campagne, un tel test est décliné sur les lignes de son premier jeu (ADR-0022) :
  ses éléments de campagne portent le suffixe de ligne (`-1`, `-2`…).
- Démo SwagLabs : TC-2 et TC-13 appellent TC-1 avec un jeu nommé (ADR-0029) ; TC-13 a son propre jeu
  « Produits ». La démo SHOP respectait déjà la règle.
