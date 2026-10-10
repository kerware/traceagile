# ADR-0022 — Un test manuel à jeu de données est sélectionné avec ses lignes

**Statut** : acceptée (correction du lot 5, demandée après la démonstration)

**Contexte.** Avec l'ADR-0018, la sélection d'un test dans une campagne créait un seul élément
sans ligne de jeu de données. Le test se jouait alors avec les valeurs par défaut de ses
paramètres, sauf si quelqu'un pensait à le « décliner ». Dans la démonstration, « Ajouter un
produit au panier » (TC-7, paramètres `${produit}` / `${prix}`) figurait ainsi dans une recette de
sprint sans jeu de données. Or ce test n'a de sens qu'avec un jeu.

**Décision.** À la sélection, quelle que soit la stratégie (sprint, tag, impact, choix manuel,
autre campagne), un test **manuel** qui a au moins un jeu non vide est décliné sur toutes les
lignes de son **premier** jeu, dans l'ordre de déclaration (`Campaign.select`). Les autres tests
sont ajoutés une fois. Après la sélection, les règles de l'ADR-0018 restent valables :
- on peut choisir une autre ligne ou un autre jeu tant que l'élément n'est pas exécuté ;
- on peut revenir explicitement aux valeurs par défaut ;
- la déclinaison reste idempotente.

Un jeu ajouté au test **après** sa sélection ne modifie pas la campagne : la ligne se choisit au
lancement de l'exécution ou par « Décliner ».

**Conséquences.** Une campagne peut contenir plus d'éléments que de tests distincts : la
réponse `added` de la sélection liste les tests, pas les éléments. Une base de démonstration déjà
chargée garde ses anciens éléments ; il faut la recréer (`docker compose down -v`).
