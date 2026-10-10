# ADR-0023 — Bilans, tableau de bord et générateur de rapports configurables

**Statut** : acceptée (lot 8)

**Contexte.** Le §9 décrit :
- le tableau de bord (F-RPT-01, F-RPT-02) ;
- les bilans de sprint et de release, avec leur verdict ;
- les formats (F-RPT-03) : web, PDF, CSV, JSON ;
- un lien permanent vers un bilan figé (F-RPT-04).

En plus, l'utilisateur demande un **générateur de rapports configurables**, avec plusieurs formats de
sortie (HTML, PDF, Word…). La spécification ne dit pas :
- ce qu'est un rapport configurable ;
- qui peut produire un rapport ;
- comment le verdict « objectif atteint / partiel / non atteint » s'articule avec Go / No go ;
- comment les graphiques passent dans les formats bureautiques.

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Définition de rapport | Une `ReportDefinition` du projet porte un nom, une description, un type de périmètre (`SPRINT`, `RELEASE`, `PROJECT`), la **liste ordonnée des sections** (choisies parmi `ReportSection`), un format par défaut, et deux options : graphiques et listes détaillées. Deux définitions intégrées, « Bilan de sprint » et « Bilan de release », reprennent l'ordre du §9.2 et du §9.3. Elles ne se modifient ni ne se suppriment, mais on peut les dupliquer. |
| Sections | Les 8 sections du §9.2 : synthèse, livraison, couverture, exécution, exploratoire, anomalies, risques résiduels, recommandation. Les sections du §9.3 : évolution par sprint, régression finale, ENF. Et des sections en plus : burndown / burnup, matrice d'exigences (statut, tests, dernier résultat), liste des anomalies, résultats détaillés des tests. Une section qui ne s'applique pas au périmètre (évolution par sprint pour un sprint, par exemple) est simplement omise. |
| Instantané | Générer un rapport crée un `ReportSnapshot` `RPT-n`. Il contient le titre, le périmètre, les sections et les **données calculées** (`jsonb`). Les exports se font à partir de ces données : le document ne change pas si le projet évolue. « Figer » rend l'instantané définitif (plus de suppression) et lui donne un lien permanent `/p/:key/reports/RPT-n` (F-RPT-04). |
| Clôture de sprint | La clôture d'un sprint génère et fige son bilan avec la définition intégrée (§9.2 « figé à la clôture »). |
| À la demande | `GET /sprints/{key}/report?format=…` et `GET /releases/{key}/report?format=…` (§12) calculent le bilan intégré sans rien stocker. |
| Verdict | `VerdictRules` du projet, par défaut celles du §9.2 : Go si validation ≥ 95 %, aucune anomalie BLOCKER ou CRITICAL ouverte et aucune exigence CRITICAL non validée ; Go sous réserve si validation ≥ 80 % et aucune BLOCKER ouverte ; No go sinon. Ces règles sont paramétrables par l'administrateur du projet. Le verdict de la synthèse en découle : Go = objectif atteint, Go sous réserve = partiellement atteint, No go = non atteint. La recommandation (section 8) reprend Go / Go sous réserve / No go. Le PO (droit `REQUIREMENT_WRITE`) peut le remplacer avec un commentaire obligatoire, y compris sur un bilan figé : le verdict relève de son jugement, les données restent figées. |
| Formats | `HTML`, `PDF`, `DOCX` (Word), `XLSX` (Excel), `MARKDOWN`, `CSV`, `JSON`. Un modèle de document intermédiaire (`ReportDocument` : titres, paragraphes, indicateurs, tableaux, graphiques) est rendu par un `ReportRenderer` par format, conformément au port du §11.3. HTML et PDF utilisent le même gabarit Thymeleaf (`templates/reports/report.html`) ; le PDF passe par OpenHTMLtoPDF (§11.1). Word et Excel passent par Apache POI. Le CSV met bout à bout les tableaux de chaque section. Le JSON est l'instantané. |
| Graphiques | HTML et PDF dessinent les graphiques en barres CSS : pas de JavaScript ni d'image, et pas de police système dans l'image Docker. Word et Excel ont de vrais graphiques natifs (POI XDDF), modifiables par l'utilisateur. En Markdown et en CSV, un graphique devient un tableau. |
| Langue | Les documents produits par le serveur sont en français. Leur traduction relève du lot 9. |
| Droits | Lire et exporter : tout membre (`PROJECT_READ`). Créer ou modifier une définition, générer, figer, supprimer un instantané non figé : nouvelle permission `REPORT_WRITE`, donnée à l'administrateur, au PO et au testeur. Remplacer le verdict : `REQUIREMENT_WRITE`. Règles de verdict : `PROJECT_ADMIN`. |
| Burndown | Points restants par jour : points engagés moins les points des stories passées à DONE ou ACCEPTED ce jour-là ou avant. Les dates viennent du journal d'audit (statut). Une ligne idéale va des points engagés à 0. Le burnup de la release cumule, par sprint, les points terminés face au total engagé. |
| Tableau de bord | `GET /projects/{p}/dashboard` renvoie en une fois tous les widgets du F-RPT-01 et les séries du F-RPT-02 : burndown du sprint actif, burnup de la release courante, taux de réussite des 10 derniers runs, anomalies ouvertes ou fermées par sprint. |

**Conséquences.**
- Pas de périmètre « campagne » pour l'instant : les indicateurs du §7.2 sont définis par exigence.
- Les valeurs mesurées des ENF (F-REQ-18) ne sont pas encore saisies. La section ENF montre le seuil et le statut de vérification ; la colonne « mesuré » reste vide.
- La démonstration ajoute un bilan figé de SPR-1 et une définition personnalisée « Synthèse qualité ».
