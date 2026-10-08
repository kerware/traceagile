# ADR-0011 — Formats : CSV, Gherkin, recherche et rang

**Statut** : acceptée (lot 1)

**CSV (F-REQ-23).**
- Lecture RFC 4180, séparateur « ; » ou « , » détecté sur l'en-tête, BOM ignoré. Écriture en « ; »
  avec BOM UTF-8 pour une ouverture directe dans Excel en français.
- Colonnes de la spec (insensibles à la casse) ; `type` et `title` obligatoires ; colonnes inconnues
  ignorées. L'export ajoute `key` en tête, `status` et `risk` en fin : un export se réimporte.
- Tags séparés par des virgules dans la cellule ; critères séparés par `||`. Un critère est en
  `GHERKIN` s'il commence par un mot-clé Gherkin (français ou anglais), sinon en `TEXT`.
- `parent key` désigne une exigence existante **ou** la valeur de la colonne `key` d'une ligne
  précédente du même fichier (les parents d'abord).
- **Tout ou rien** : la moindre erreur annule l'import (422 `CSV_INVALID`, erreurs par ligne).

**Gherkin (F-REQ-10).**
- Validation côté serveur avec `io.cucumber:gherkin`, exposée par `POST /api/v1/gherkin/validate` et
  appliquée à l'enregistrement d'un critère. Un critère est souvent un scénario seul : l'en-tête
  « Fonctionnalité » est ajouté implicitement et les numéros de ligne sont recalés.
- Sans directive `# language`, le français puis l'anglais sont essayés.
- Côté front, validation à la frappe via cet endpoint (même moteur, pas de divergence) et coloration
  simple en lecture ; l'éditeur Monaco avec grammaire et autocomplétion arrive au lot 2 (F-AUT-04).

**Recherche (F-REQ-04).** Colonne `search_text` (clé, titre, description, story, critères) tenue à
jour par l'entité, `tsvector` français généré par PostgreSQL et index GIN. La requête combine
`websearch_to_tsquery('french', q)` (pluriels, plusieurs mots) et une recherche par sous-chaîne
(début de mot, clé partielle).

**Rang (F-REQ-03).** Chaîne base 36 de type LexoRank, jamais terminée par « 0 » ; la colonne utilise
la collation « C » pour que PostgreSQL trie comme Java. Pas de rééquilibrage dans le prototype (les
rangs s'allongent d'environ un caractère par insertion répétée au même endroit).
