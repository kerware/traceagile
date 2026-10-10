# ADR-0024 — Atelier Example Mapping, commentaires, pièces jointes, recherche, raccourcis, finitions

**Statut** : acceptée (lot 9)

**Contexte.** Le lot 9 (§16.2) regroupe plusieurs sujets :
- Example Mapping (§4.4) ;
- recherche `Ctrl+K`, raccourcis et thème sombre (§13.1, §13.3) ;
- accessibilité ;
- un jeu de démonstration complet ;
- la vérification des cibles NF-01 à NF-16.

Il hérite aussi des reports des lots précédents (CLAUDE.md) :
- commentaires ;
- pièces jointes (F-EXE-01, F-EXE-03, F-EXP-08) ;
- valeur mesurée d'une ENF (F-REQ-18) ;
- filtre `verification` du backlog ;
- SpotBugs, seuil JaCoCo, axe-core.

La spécification ne précise pas les modèles de données correspondants.

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Commentaires | Un `Comment` est porté par une exigence (onglet « Commentaires » du §13.2). Il a un auteur, un texte Markdown assaini et un indicateur `question`. Une question est **ouverte** tant qu'elle n'est pas résolue ; la résolution note qui l'a résolue et quand. Commenter : droit `REQUIREMENT_COMMENT`. Modifier ou supprimer : l'auteur seulement. Résoudre : `REQUIREMENT_COMMENT`. |
| Example Mapping (F-REQ-13) | Une `ExampleCard` appartient à une story. Elle a une colonne (`RULE`, `EXAMPLE`), un texte, une position, et une règle parente pour un exemple. La colonne « Story » affiche la story elle-même. La colonne « Questions » affiche ses commentaires `question` : une carte question **est** une question non résolue (F-REQ-14). Modifier l'atelier : droit `ACCEPTANCE_CRITERION_PROPOSE` ou `REQUIREMENT_WRITE` (PO, testeur, administrateur). |
| Conversions (F-REQ-14) | Une règle devient une exigence `BUSINESS_RULE` enfant de la story (titre = texte de la règle). Un exemple devient un critère d'acceptation au format Gherkin : `Scénario: <texte>` suivi de squelettes `Soit` / `Quand` / `Alors` à compléter. La carte garde la clé ou la position de l'élément créé et ne se convertit pas deux fois. |
| Questions ouvertes (F-REQ-15) | Les questions ouvertes s'ajoutent aux items non satisfaits de la DoR au passage à `READY`. On retrouve le comportement existant : avertissement, contournable par `acknowledgeUnmet`, donc par le PO. |
| Pièces jointes (F-EXE-01, F-EXE-03, F-EXP-08) | Port `FileStorage` (§11.3), adaptateur disque (volume Docker `attachments`). Une `Attachment` est rattachée à une exigence, un pas d'exécution, une anomalie ou une note de session. Limites : 10 Mo par fichier ; images, PDF, texte, journaux, JSON et XML seulement. Le contenu est servi avec `nosniff` et en pièce jointe, sauf les images. Une anomalie créée depuis une exécution reprend les captures des pas jusqu'au pas en échec (F-EXE-03). |
| Valeur mesurée d'une ENF (F-REQ-18) | Le champ `metrics{}` de `TEST_FINISHED` donne une mesure (`NfrMeasurement`, avec test et run d'origine) pour chaque ENF vérifiée par le test : on retient la métrique dont le nom finit par l'unité de l'ENF (`p95Ms` pour `ms`), sinon la première. Une saisie manuelle est aussi possible (droit `TEST_WRITE`). On compare au seuil et à la cible : le sens se déduit de leur ordre (cible < seuil : plus petit est meilleur) ; avec une seule des deux valeurs, une unité de durée (ms, s, min, h) signifie « plus petit est meilleur ». Résultat : `TARGET_MET`, `THRESHOLD_MET` ou `NOT_MET`. Les bilans affichent la dernière mesure. |
| Recherche globale (`Ctrl+K`) | `GET /projects/{p}/search?q=` cherche dans les exigences, tests, campagnes, anomalies, runs et rapports, par clé exacte ou préfixe, puis par titre contenant. 20 résultats au plus, triés par type puis par pertinence. Côté front : une fenêtre de type « spotlight » au clavier. |
| Aperçu au survol | `GET /projects/{p}/items/{key}` renvoie le type, le titre, le statut et le lien d'une clé. Le composant `KeyLink` (lien et aperçu `HoverCard`) remplace les clés affichées dans les listes principales et rend cliquables les clés citées dans le Markdown. |
| Raccourcis (§13.3) | `?` : aide. `Ctrl+K` / `/` : recherche. `N` : nouvel élément sur les listes (backlog, tests, campagnes, anomalies, rapports). `E` : éditer sur les fiches (exigence, test). `P` / `F` / `B` : passer, échouer ou bloquer le pas courant d'une exécution manuelle. Raccourcis inactifs pendant la saisie dans un champ. |
| Barre supérieure (§13.1) | Sprint actif du projet (lien vers la planification) et notifications : tests à exécuter qui me sont affectés, sessions à approuver (PO), anomalies bloquantes ouvertes, runs en échec depuis 24 h. Les notifications sont calculées à la demande, sans stockage ni envoi. |
| Accessibilité (NF-10) | Contrôle axe-core (`@axe-core/playwright`, WCAG 2.1 A/AA) des écrans principaux dans les tests bout en bout. Aucune violation `critical` ou `serious` n'est tolérée. |
| Qualité (NF-12, NF-13) | `jacoco:check` bloquant à 70 % de lignes couvertes sur les modules métier (domaine, application, infrastructure, api). SpotBugs (seuil « High ») bloquant ; les faux positifs sont exclus explicitement et justifiés dans `spotbugs-exclude.xml`. |
| Statuts de vérification (NF-01) | Le banc a montré qu'une page du backlog rechargeait toute la traçabilité du projet. Elle émettait aussi deux requêtes par test : les `@OneToOne` inverses de `TestCase` ne se chargent pas paresseusement. Corrections : `left join fetch` sur les chargements de tests en masse ; `default_batch_fetch_size` à 100 ; statuts calculés **sur les seuls sous-arbres** de la page ou de la fiche (`TraceabilityService.statusesOf`), avec un test d'équivalence face au calcul complet. Le calcul complet reste utilisé pour l'arbre et le filtre `verification`. Pas de cache : aucune invalidation à maintenir. |
| Performances (NF-01 à NF-03) | Un banc `PerformanceBenchmarkTest` (profil Maven `perf`, hors build courant) génère 5 000 exigences et 10 000 tests, puis mesure les lectures paginées (p95), la matrice d'une release (500 × 1 000) et le PDF d'un bilan de release. Les résultats et la vérification de chaque NF sont consignés dans `docs/nf-verification.md`. |

**Hors périmètre (reportés « si besoin » par les lots précédents, non retenus)**
- Glisser-déposer des campagnes dans l'arbre.
- Choix de la ligne de jeu de données d'un run automatisé.
- Annotations autres que `@REQ-n`.
- Périmètre « campagne » des rapports.
- Traduction des documents produits par le serveur.

**Conséquences.**
- Un volume Docker de plus pour les pièces jointes.
- Une question ouverte bloque `READY` comme un item de DoR non satisfait.
