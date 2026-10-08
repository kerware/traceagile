# ADR-0012 — Référentiel de tests : natures, versions, BDD, découverte

**Statut** : acceptée (lot 2)

**Contexte.** Le §6 et le §3.1 laissent plusieurs points ouverts sur les tests. Option la plus simple
retenue pour chacun (§16.1-5).

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Nature | Fixée à la création (`MANUAL`, `EXPLORATORY`, `AUTOMATED`) ; elle détermine le sous-objet (pas, charte ou définition automatisée). Un champ propre à une autre nature est refusé (422 `TEST_FIELD_KIND_MISMATCH`). |
| Priorité | Même échelle MoSCoW que les exigences (la spec ne précise pas celle des tests). |
| Statut | `DRAFT ⇄ READY ⇄ NEEDS_UPDATE`, `OBSOLETE` terminal. `READY` exige un test **exécutable** : au moins un pas, une mission « Explorer… pour découvrir… », ou un identifiant (et une source Gherkin en BDD). |
| Droits (§2.2) | Le testeur crée et modifie tous les tests ; le développeur seulement les automatisés. L'endpoint vérifie l'un ou l'autre droit (`@PreAuthorize`), puis `TestPermissions` vérifie la nature du test. |
| Techniques (F-AUT-01) | Les huit techniques du §6.1 sont fixes (elles portent des champs propres) ; les **frameworks** sont une donnée de référence globale modifiable par l'administrateur système (`/admin/references`). Le framework d'un test reste du texte libre. |
| Champs propres à une technique | Dans `parameters` (JSON) : navigateurs et résolution (UI), URL de base et authentification (API), métriques attendues `expected.{p95Ms, throughputRps, errorRatePct}` (PERFORMANCE). `dataSet` pour DATA_DRIVEN ; `keywords` (KEYWORD) rempli par la découverte, en lecture seule. |
| Versions (F-AUT-10) | Version 1 à la création ; une modification **significative** l'incrémente et fige un instantané : pas et jeu de données (manuel), mission, zones et durée (charte), technique, framework, chemin, identifiant, Gherkin et jeu de données (automatisé). Le titre, les tags ou la priorité ne changent pas la version. |
| Liens de traçabilité | `TraceLink` arrive dès le lot 2, car F-REQ-11, F-AUT-06 et F-EXP-03 en ont besoin : test → exigence et test → critère (F-TRA-03), un lien par paire, avec son origine (saisi, tag Gherkin, généré, découverte). La fiche test remplace la liste complète ; les tags Gherkin et la découverte **ajoutent** les liens manquants sans jamais en retirer. Matrice, couverture et suspicion restent au lot 3. |
| DoR / DoD | L'item « au moins un test lié » est désormais évalué (lien `VERIFIES` ou `PARTIALLY_VERIFIES`). |
| BDD (F-AUT-05) | Un test par scénario. Sa `gherkinSource` est un document `.feature` complet à un seul scénario : en-tête de la fonctionnalité (langue, tags, description, contexte) puis le scénario. Les scénarios d'une `Règle:` sont repris sans la règle. Le test est identifié par `path` (fichier) et `testIdentifier` (nom du scénario). |
| Génération (F-REQ-11) | Un test par scénario du critère, dans une fonctionnalité nommée d'après l'exigence, tagué `@REQ-n @AC-n-m`, chemin `src/test/resources/features/req-n-titre.feature`, premier framework BDD de référence, lié à l'exigence et au critère. |
| Import / export (F-AUT-07) | Import de `.feature` ou d'un zip ; un scénario connu (même chemin, même nom) est mis à jour, sinon créé ; tout ou rien si un fichier est invalide. L'export regroupe les scénarios par chemin, avec l'en-tête du premier test du fichier. |
| Découverte (F-AUT-08 / F-AUT-09) | Rapport JSON `{repositoryUrl, branch, tests: [{technique, framework, language, path, testIdentifier, title, tags, requirements, keywords}]}`. Correspondance par chemin et identifiant dans le même dépôt ; les tests créés sont `READY` ; les tests absents du rapport sont **signalés** (`missingInRepository`), pas supprimés (les BDD, stockés dans TraceAgile, sont exclus). Les exigences citées par annotation dans le code arrivent dans `requirements`. |
| Éditeur (F-AUT-04) | Monaco servi par l'application (pas de CDN : CSP), chargé à la demande ; grammaire Gherkin fr / en, autocomplétion des étapes du projet (`GET /gherkin/steps`), marqueurs d'erreur issus de `POST /gherkin/validate`. Dans jsdom, `CodeEditor` se replie sur une zone de texte. |
