# Spécification — Plateforme de gestion des exigences agiles et des tests

Oct 8, 2026 · @Olivier

## 1. Contexte, objectifs et périmètre

Ce document spécifie **TraceAgile** (nom de code), une application web de gestion des exigences agiles et des tests, à réaliser sous forme de prototype en **Spring Boot 3 / Java 21** et **React 18 / TypeScript**. Il est écrit pour être confié tel quel à Claude Code : chaque section donne les règles métier, les données et les critères d'acceptation nécessaires à l'implémentation.

### 1.1 Problème adressé

Les équipes agiles gèrent leurs exigences dans un outil (Jira, post-it, wiki), leurs tests exploratoires sur papier ou dans des notes, et leurs tests automatisés dans le code. La traçabilité exigence → test → exécution → anomalie est rarement visible, et le bilan d'un sprint ou d'une release se reconstruit à la main.

### 1.2 Objectifs

1. Gérer des exigences agiles hiérarchisées (épic, feature, user story, règle métier, exigence non fonctionnelle) avec leurs critères d'acceptation.
2. Gérer des tests exploratoires (chartes et sessions chronométrées, méthode SBTM).
3. Référencer des tests automatisés de différentes techniques (BDD/Gherkin, script, mots-clés, data-driven, API, UI, performance).
4. Associer exigences et tests (traçabilité bidirectionnelle) et calculer la couverture.
5. Organiser le travail en releases (groupes de sprints) et sprints, y planifier des campagnes de test et les exécuter.
6. Produire des bilans de sprint et de release (avancement, couverture, résultats, anomalies, risques).
7. Préparer le lancement des tests automatisés sur un **serveur d'exécution distant**, développé plus tard, via un contrat d'API défini ici.

### 1.3 Périmètre du prototype

| Inclus | Exclu (versions ultérieures) |
| --- | --- |
| Un seul espace multi-projets, authentification locale (login / mot de passe) | SSO, LDAP, OAuth |
| CRUD complet des exigences, tests, sprints, releases, campagnes | Workflow de validation configurable |
| Exécution manuelle et saisie de sessions exploratoires | Application mobile |
| Lancement des tests automatisés via un **simulateur** du serveur d'exécution | Serveur d'exécution réel (projet séparé) |
| Réception des résultats automatisés (JUnit XML, Cucumber JSON, format natif) | Connecteurs Jira, GitLab, Azure DevOps (prévoir l'interface seulement) |
| Matrice de traçabilité, tableaux de bord, export CSV / PDF du bilan | Gestion fine des droits par champ |
| Historique des modifications (audit) et versions des exigences | Signature électronique, conformité réglementaire |

### 1.4 Principes directeurs

- **L'exigence est la colonne vertébrale** : tout test, toute exécution, toute anomalie se rattache à au moins une exigence ou est signalé comme orphelin.
- **Spécifier par l'exemple** : les critères d'acceptation peuvent être écrits en Gherkin et devenir directement des tests BDD.
- **Exploratoire et automatisé sont égaux** : les deux contribuent à la couverture et au bilan, avec des métriques adaptées à chacun.
- **Découplage de l'exécution** : l'application ne lance jamais un test elle-même, elle délègue à un serveur d'exécution via une API asynchrone.

## 2. Glossaire et rôles

### 2.1 Glossaire

| Terme | Définition dans TraceAgile |
| --- | --- |
| Projet | Conteneur racine : exigences, tests, releases et sprints appartiennent à un projet. |
| Exigence | Élément du backlog : épic, feature, user story, règle métier ou exigence non fonctionnelle (ENF). |
| Critère d'acceptation | Condition vérifiable attachée à une exigence, en texte libre ou en scénario Gherkin. |
| Cas de test | Test réutilisable : manuel scripté, charte exploratoire ou test automatisé. |
| Charte exploratoire | Mission d'exploration : cible, ressources, information recherchée (« Explorer… avec… pour découvrir… »). |
| Session exploratoire | Exécution chronométrée d'une charte par un testeur, avec notes, constats et métriques TBS. |
| Release | Groupe ordonné de sprints menant à une livraison ; correspond au « groupe de sprints ». |
| Sprint | Itération datée ; contient un périmètre d'exigences et une ou plusieurs campagnes. |
| Campagne | Ensemble de tests sélectionnés pour être exécutés dans un sprint ou une release. |
| Exécution | Résultat d'un test dans une campagne (une ligne par test et par tentative). |
| Run automatisé | Demande de lancement envoyée au serveur d'exécution, regroupant un ou plusieurs tests automatisés. |
| Anomalie | Défaut constaté lors d'une exécution ou d'une session, lié au test et aux exigences concernées. |
| Couverture | Part des exigences ayant au moins un test lié (couverture de conception) et au moins une exécution réussie (couverture d'exécution). |

### 2.2 Rôles

Les rôles sont attribués **par projet**. Un utilisateur peut avoir des rôles différents selon le projet.

| Rôle | Exigences | Tests | Sprints / campagnes | Exécution | Administration |
| --- | --- | --- | --- | --- | --- |
| Administrateur | Tout | Tout | Tout | Tout | Utilisateurs, projets, paramètres, serveurs d'exécution |
| Product Owner | Créer, modifier, prioriser, valider | Lire | Créer releases et sprints, définir le périmètre | Lire | — |
| Testeur / QA | Lire, commenter, proposer des critères | Créer, modifier | Créer et gérer les campagnes | Exécuter, saisir sessions, créer anomalies | — |
| Développeur | Lire, commenter | Créer et modifier les tests automatisés | Lire | Lancer des runs automatisés | — |
| Lecteur | Lire | Lire | Lire | Lire | — |

**Règles** : un utilisateur sans rôle sur un projet ne le voit pas. Toute action refusée renvoie HTTP 403 et un message explicite côté interface.

## 3. Modèle de domaine

Toutes les entités portent les champs techniques `id` (UUID), `createdAt`, `createdBy`, `updatedAt`, `updatedBy` et `version` (verrou optimiste JPA). Les entités métier ont aussi une **clé lisible** unique par projet, générée séquentiellement : `REQ-12`, `TC-45`, `SPR-3`, `REL-1`, `CMP-8`, `RUN-102`, `BUG-17`.

### 3.1 Entités et attributs

| Entité | Attributs principaux | Relations |
| --- | --- | --- |
| `Project` | key (3–10 lettres majuscules), name, description, archived | 1–n Requirement, TestCase, Release, Sprint, Campaign |
| `User` | login, email, displayName, passwordHash, active | n–n Project via `ProjectMember(role)` |
| `Requirement` | key, type, title, description (Markdown), userStory {asA, iWant, soThat}, priority, businessValue (1–100), storyPoints, status, riskLevel, category (ENF), tags\[\], externalRef (ex. clé Jira), currentVersion | parent (Requirement, arbre), 1–n AcceptanceCriterion, n–n TestCase via `TraceLink`, n–n Sprint via `SprintScope` |
| `RequirementVersion` | requirementId, versionNumber, snapshot (JSON), changeComment | instantané figé à chaque passage au statut *Prête* ou sur demande |
| `AcceptanceCriterion` | order, format (`TEXT` ou `GHERKIN`), content, status (à vérifier, vérifié, échoué) | appartient à 1 Requirement ; n–n TestCase |
| `TestCase` | key, kind (`MANUAL`, `EXPLORATORY`, `AUTOMATED`), title, description, objective, priority, status, tags\[\], estimatedDurationMin | n–n Requirement, n–n AcceptanceCriterion, sous-objet selon kind |
| `ManualStep` | order, action, expectedResult, testData | appartient à un TestCase `MANUAL` |
| `ExploratoryCharter` | mission (Explorer / Avec / Pour découvrir), areas\[\], heuristics\[\] (ex. SFDIPOT, FEW HICCUPPS), timeboxMin (60, 90 ou 120), setupNotes | 1–1 TestCase `EXPLORATORY` |
| `AutomatedTestDefinition` | technique, framework, language, repositoryUrl, branch, path, testIdentifier, gherkinSource, dataSet (JSON), parameters (JSON), executionTags\[\], environmentRequirements | 1–1 TestCase `AUTOMATED` |
| `Release` | key, name, goal, startDate, endDate, status | 1–n Sprint ordonnés |
| `Sprint` | key, name, goal, startDate, endDate, status, capacityPoints | appartient à 0–1 Release ; n–n Requirement via `SprintScope` ; 1–n Campaign |
| `Campaign` | key, name, scopeType (`SPRINT`, `RELEASE`, `REGRESSION`), environment, buildVersion, status, plannedStart, plannedEnd | 1–n `CampaignItem` |
| `CampaignItem` | testCaseId, testCaseVersion, assignee, order | 1–n Execution |
| `Execution` | attempt, status, startedAt, endedAt, durationMs, comment, executedBy, origin (`MANUAL`, `AUTOMATED`), attachments\[\] | 1–n `StepResult` (manuel) ; 0–1 ExploratorySession ; 0–1 AutomatedRun ; n–n Defect |
| `ExploratorySession` | charterId, tester, startedAt, durationMin, setupPct, testPct, bugPct (TBS), notes (Markdown horodaté), issues\[\], areasCovered\[\], debriefSummary, debriefedBy | produit 0–n Defect |
| `AutomatedRun` | key, executionServerId, status, requestedAt, startedAt, endedAt, environment, buildVersion, externalJobId, logsUrl, reportUrl | regroupe n Execution d'une campagne |
| `ExecutionServer` | name, baseUrl, authType, apiToken (chiffré), capabilities\[\] (techniques supportées), status, lastHeartbeat | — |
| `Defect` | key, title, description, severity, status, externalRef | n–n Execution, n–n Requirement |
| `TraceLink` | sourceType, sourceId, targetType, targetId, linkType (`VERIFIES`, `PARTIALLY_VERIFIES`, `RELATES_TO`) | lien générique pour la traçabilité |
| `AuditEvent` | entityType, entityId, action, actor, timestamp, diff (JSON) | journal en lecture seule |
| `Comment` | entityType, entityId, author, body (Markdown), mentions\[\] | sur exigence, test, exécution, session |
| `Attachment` | entityType, entityId, fileName, mimeType, size, storageKey | fichiers stockés sur disque ou S3 compatible |

### 3.2 Énumérations et cycles de vie

| Énumération | Valeurs |
| --- | --- |
| `RequirementType` | `EPIC`, `FEATURE`, `USER_STORY`, `BUSINESS_RULE`, `NON_FUNCTIONAL`, `TECHNICAL_ENABLER` |
| `RequirementStatus` | `DRAFT` → `TO_REFINE` → `READY` → `IN_SPRINT` → `DONE` → `ACCEPTED`, plus `REJECTED` et `OBSOLETE` |
| `Priority` | `MUST`, `SHOULD`, `COULD`, `WONT` (MoSCoW) |
| `RiskLevel` | `LOW`, `MEDIUM`, `HIGH`, `CRITICAL` |
| `NfrCategory` (ISO 25010) | `PERFORMANCE`, `SECURITY`, `USABILITY`, `RELIABILITY`, `COMPATIBILITY`, `MAINTAINABILITY`, `PORTABILITY`, `ACCESSIBILITY` |
| `TestCaseStatus` | `DRAFT`, `READY`, `NEEDS_UPDATE`, `OBSOLETE` |
| `SprintStatus` / `ReleaseStatus` | `PLANNED`, `ACTIVE`, `CLOSED` |
| `CampaignStatus` | `PLANNED`, `IN_PROGRESS`, `COMPLETED`, `ABORTED` |
| `ExecutionStatus` | `NOT_RUN`, `RUNNING`, `PASSED`, `FAILED`, `BLOCKED`, `SKIPPED`, `ERROR` (erreur technique, distinct d'un échec fonctionnel) |
| `RunStatus` | `QUEUED`, `DISPATCHED`, `RUNNING`, `COMPLETED`, `FAILED`, `CANCELLED`, `TIMEOUT` |
| `DefectSeverity` | `BLOCKER`, `CRITICAL`, `MAJOR`, `MINOR`, `TRIVIAL` |

### 3.3 Règles d'intégrité

1. Une exigence `EPIC` n'a pas de parent ; une `FEATURE` a un parent `EPIC` ou aucun ; une `USER_STORY` a un parent `FEATURE` ou `EPIC` ; `BUSINESS_RULE` et `NON_FUNCTIONAL` peuvent être rattachées à n'importe quel type. Aucun cycle n'est autorisé.
2. Une exigence ne passe à `READY` que si elle a au moins un critère d'acceptation (Definition of Ready minimale, paramétrable par projet).
3. Un sprint ne peut appartenir qu'à une release ; ses dates doivent être comprises dans celles de la release. Deux sprints d'une même release ne se chevauchent pas.
4. Un seul sprint `ACTIVE` par projet à un instant donné.
5. Une exécution référence la **version** du test exécuté ; modifier un test après exécution ne réécrit pas l'historique.
6. La suppression d'une exigence ou d'un test déjà exécuté est interdite : on le passe en `OBSOLETE`.
7. Une modification d'une exigence liée à des tests `READY` passe ces tests à `NEEDS_UPDATE` et le signale dans la matrice de traçabilité (alerte de suspicion).

## 4. Gestion des exigences agiles

### 4.1 Backlog hiérarchique

- **F-REQ-01** Afficher le backlog d'un projet sous deux vues : **arbre** (épic > feature > story, repliable) et **liste** triable et filtrable (type, statut, priorité, sprint, tag, risque, couverture).
- **F-REQ-02** Créer, modifier, dupliquer, déplacer (glisser-déposer dans l'arbre) une exigence. Le déplacement vérifie les règles de parenté (§3.3).
- **F-REQ-03** Prioriser le backlog par glisser-déposer : un champ `rank` (chaîne lexicographique, type LexoRank) stocke l'ordre sans renuméroter toute la liste.
- **F-REQ-04** Recherche plein texte sur clé, titre, description et critères.

### 4.2 Formulaire d'une user story

- **F-REQ-05** Saisie guidée du format « En tant que… je veux… afin de… », avec prévisualisation de la phrase complète.
- **F-REQ-06** Champs : priorité MoSCoW, valeur métier, points d'estimation (suite de Fibonacci : 1, 2, 3, 5, 8, 13, 21), niveau de risque, tags, référence externe.
- **F-REQ-07** Indicateur **INVEST** : une liste de six cases à cocher par le PO ou le testeur (Indépendante, Négociable, Valeur, Estimable, Small, Testable). Une story à 13 points ou plus affiche l'alerte « Story à découper ».
- **F-REQ-08** Description en Markdown avec prévisualisation.

### 4.3 Critères d'acceptation

- **F-REQ-09** Une exigence possède une liste ordonnée de critères, au format `TEXT` ou `GHERKIN`.
- **F-REQ-10** L'éditeur Gherkin offre la coloration syntaxique et la validation (bibliothèque `@cucumber/gherkin` côté front, `io.cucumber:gherkin` côté back). Mots-clés acceptés en français et en anglais (`# language: fr`).
- **F-REQ-11** Action **« Générer un test BDD »** sur un critère Gherkin : crée un `TestCase` `AUTOMATED` de technique `BDD`, pré-rempli avec le scénario, lié à l'exigence et au critère.
- **F-REQ-12** L'état d'un critère est calculé à partir des exécutions des tests liés : *vérifié* si la dernière exécution de chaque test lié est `PASSED`, *échoué* si l'une est `FAILED`, *à vérifier* sinon.

### 4.4 Atelier d'affinage (Example Mapping)

- **F-REQ-13** Vue d'atelier par story, en quatre colonnes de cartes : **Story** (jaune), **Règles** (bleu), **Exemples** (vert, rattachés à une règle), **Questions** (rouge).
- **F-REQ-14** Une règle peut être convertie en exigence `BUSINESS_RULE` enfant ; un exemple en critère d'acceptation Gherkin ; une question reste un commentaire non résolu.
- **F-REQ-15** Tant qu'il reste des questions ouvertes, la story ne peut pas passer à `READY` (avertissement, contournable par le PO).

### 4.5 Exigences non fonctionnelles

- **F-REQ-16** Une ENF porte une catégorie ISO 25010 et des champs mesurables au format Planguage : **échelle** (ex. temps de réponse au 95e percentile), **méthode de mesure**, **seuil minimal**, **cible**, **unité**.
- **F-REQ-17** Une ENF peut être marquée **transverse** : elle s'applique alors à toutes les stories d'une feature ou d'un projet et apparaît dans leur fiche.
- **F-REQ-18** Un test de performance lié à une ENF peut remonter une valeur mesurée ; l'outil la compare au seuil et à la cible.

### 4.6 Definition of Ready et Definition of Done

- **F-REQ-19** Chaque projet définit une DoR et une DoD sous forme de listes de contrôle. Les items automatiques sont vérifiés par l'outil (au moins un critère, estimation renseignée, au moins un test lié, tous les tests liés passés, aucune anomalie bloquante ouverte). Les items manuels sont cochés par l'utilisateur.
- **F-REQ-20** Le passage aux statuts `READY` et `DONE` affiche la liste de contrôle correspondante et les items non satisfaits.

### 4.7 Versions, historique, import

- **F-REQ-21** Une version figée (`RequirementVersion`) est créée automatiquement au passage à `READY` et manuellement à la demande. On peut comparer deux versions (diff côte à côte).
- **F-REQ-22** Onglet historique : liste des `AuditEvent` de l'exigence.
- **F-REQ-23** Import CSV d'exigences (colonnes : type, parent key, title, asA, iWant, soThat, priority, points, tags, acceptance criteria séparés par `||`) et export CSV du backlog filtré.

## 5. Tests exploratoires

Le modèle suit le **Session-Based Test Management** (SBTM, James et Jonathan Bach) : une charte décrit la mission, une session est une exécution chronométrée de cette charte, suivie d'un débriefing.

### 5.1 Chartes

- **F-EXP-01** Créer une charte au format « **Explorer** \<cible> **avec** \<ressources, données, outils> **pour découvrir** \<information recherchée> » (gabarit d'Elisabeth Hendrickson), avec prévisualisation de la phrase.
- **F-EXP-02** Champs complémentaires : zones fonctionnelles, heuristiques suggérées (listes de valeurs : SFDIPOT, FEW HICCUPPS, CRUD, Goldilocks, tours de Whittaker ; extensibles par projet), durée cible (60, 90 ou 120 minutes), notes de préparation, priorité, risque visé.
- **F-EXP-03** Une charte est liée à une ou plusieurs exigences, comme tout cas de test.
- **F-EXP-04** Action « **Générer des chartes** depuis une exigence » : propose une charte par critère d'acceptation et une par ENF transverse applicable, que le testeur valide ou rejette.

### 5.2 Sessions

- **F-EXP-05** Démarrer une session depuis une charte planifiée dans une campagne. L'écran de session affiche la mission, un **chronomètre** (démarrer, pause, reprendre, terminer) et la durée cible.
- **F-EXP-06** Prise de notes horodatée : chaque entrée a un type (`NOTE`, `QUESTION`, `ISSUE`, `BUG`, `IDEA`) et un horodatage relatif au début de session. Raccourcis clavier : `Ctrl+1` à `Ctrl+5` pour le type.
- **F-EXP-07** Une entrée `BUG` peut être convertie en `Defect` en un clic, pré-rempli avec la note, les captures jointes et le lien vers la session et ses exigences.
- **F-EXP-08** Pièces jointes par collage d'image (presse-papier) ou téléversement ; captures associées à la note courante.
- **F-EXP-09** À la fin, le testeur saisit la répartition **TBS** (Test, Bug investigation, Setup) en pourcentages totalisant 100, les zones réellement couvertes et un statut de session : `PASSED` (rien de bloquant), `FAILED` (anomalie significative), `BLOCKED` (mission impossible).
- **F-EXP-10** La sauvegarde des notes est automatique toutes les 10 secondes et à chaque perte de focus ; une session interrompue (fermeture du navigateur) se reprend où elle s'était arrêtée.

### 5.3 Débriefing (PROOF)

- **F-EXP-11** Formulaire de débriefing structuré **PROOF** : Past (ce qui s'est passé), Results (constats), Obstacles, Outlook (ce qui reste à faire), Feelings (confiance du testeur, de 1 à 5).
- **F-EXP-12** L'item *Outlook* peut créer de nouvelles chartes de suivi en un clic.
- **F-EXP-13** Le débriefing est validé par un second utilisateur (PO ou test lead) ; la session passe alors à l'état *débriefée*.

### 5.4 Métriques exploratoires

Calculées par sprint, release et campagne : nombre de sessions, durée totale, durée moyenne par rapport à la cible, répartition TBS moyenne, anomalies par heure de test, chartes planifiées et chartes exécutées, confiance moyenne, zones jamais explorées.

## 6. Tests automatisés et tests manuels scriptés

TraceAgile **référence** les tests automatisés, il ne les stocke pas comme du code exécutable (sauf le Gherkin et les jeux de données). Le code vit dans le dépôt Git du projet ; le test est identifié par un chemin et un identifiant que le serveur d'exécution sait résoudre.

### 6.1 Techniques supportées

| Technique (`technique`) | Frameworks proposés (`framework`) | Identification du test | Champs spécifiques |
| --- | --- | --- | --- |
| `BDD` | Cucumber-JVM, Cucumber-JS, Behave, SpecFlow, Karate | `path` du `.feature` + nom du scénario | `gherkinSource` stocké et versionné dans TraceAgile, exportable vers le dépôt |
| `UNIT` | JUnit 5, Kotest, pytest, Jest, Vitest | classe#méthode, module::fonction | — |
| `UI` | Playwright, Selenium, Cypress, Appium | fichier + titre du test | navigateur(s), résolution |
| `API` | REST Assured, Karate, Postman/Newman, pytest + requests | collection / fichier + nom | URL de base, auth requise |
| `KEYWORD` | Robot Framework | suite + nom du test | liste des mots-clés utilisés (lecture seule) |
| `DATA_DRIVEN` | n'importe lequel des frameworks ci-dessus | identifiant + jeu de données | `dataSet` : tableau JSON éditable en grille ; une exécution par ligne |
| `PERFORMANCE` | Gatling, k6, JMeter | scénario | métriques attendues liées aux ENF (p95, débit, taux d'erreur) |
| `CONTRACT` | Pact, Spring Cloud Contract | contrat consommateur / fournisseur | — |

- **F-AUT-01** La liste des techniques et des frameworks est une donnée de référence modifiable par l'administrateur.
- **F-AUT-02** Un test automatisé déclare les `executionTags` (ex. `smoke`, `regression`, `nightly`) utilisés pour la sélection en campagne et transmis au serveur d'exécution.
- **F-AUT-03** Le champ `environmentRequirements` décrit les prérequis (navigateur, base de données, service simulé) sous forme de paires clé/valeur ; le serveur d'exécution s'en sert pour choisir un agent.

### 6.2 BDD intégré

- **F-AUT-04** Éditeur Gherkin complet (coloration, autocomplétion des étapes déjà utilisées dans le projet, validation syntaxique à la frappe).
- **F-AUT-05** Un fichier `.feature` peut contenir plusieurs scénarios : chacun devient un `TestCase` distinct, regroupés par la feature.
- **F-AUT-06** Les tags Gherkin `@REQ-12` ou `@AC-12-3` créent ou vérifient automatiquement les liens de traçabilité à l'enregistrement. Un tag pointant vers une clé inconnue produit un avertissement.
- **F-AUT-07** Export d'un ou plusieurs scénarios en fichiers `.feature` (zip) et import de fichiers `.feature` existants.

### 6.3 Synchronisation avec le dépôt (préparation)

- **F-AUT-08** Import d'un rapport de découverte (JSON fourni par le serveur d'exécution ou un plugin de build) listant les tests présents dans le dépôt : TraceAgile crée les `TestCase` manquants et signale les tests disparus.
- **F-AUT-09** Prévoir une annotation de lien dans le code, reconnue lors de l'import des résultats : `@Requirement("REQ-12")` en Java/Kotlin, marqueur `@pytest.mark.requirement("REQ-12")` en Python, tag `@REQ-12` dans le titre en JavaScript.

### 6.4 Tests manuels scriptés

- **F-MAN-01** Un test `MANUAL` comporte des pas ordonnés (action, résultat attendu, données) que l'on peut réordonner, dupliquer, et paramétrer par variables `${nom}` alimentées par un jeu de données.
- **F-MAN-02** Un test manuel peut être marqué **candidat à l'automatisation** avec une justification ; une vue liste ces candidats triés par fréquence d'exécution et priorité.

### 6.5 Versionnement des tests

- **F-AUT-10** Chaque modification significative d'un test (pas, Gherkin, jeu de données, identifiant) incrémente sa version. Une exécution référence la version utilisée.

## 7. Traçabilité et couverture

La chaîne tracée est : **Épic → Feature → Story / Règle / ENF → Critère d'acceptation → Cas de test → Exécution → Anomalie**, dans les deux sens.

### 7.1 Création des liens

- **F-TRA-01** Lier un test à une exigence depuis l'une ou l'autre fiche (sélecteur avec recherche), par glisser-déposer dans la vue matrice, ou automatiquement (tags Gherkin, annotations de code, génération depuis un critère).
- **F-TRA-02** Un lien porte un type : `VERIFIES` (couvre entièrement), `PARTIALLY_VERIFIES`, `RELATES_TO` (informatif, ne compte pas dans la couverture).
- **F-TRA-03** Un lien test → exigence peut préciser le ou les critères d'acceptation vérifiés.

### 7.2 Indicateurs de couverture

Pour un périmètre donné (projet, release, sprint, épic, feature) :

| Indicateur | Formule |
| --- | --- |
| Couverture de conception | exigences feuilles ayant ≥ 1 lien `VERIFIES` ou `PARTIALLY_VERIFIES` ÷ exigences feuilles du périmètre |
| Couverture des critères | critères d'acceptation liés à ≥ 1 test ÷ critères du périmètre |
| Couverture d'exécution | exigences dont tous les tests liés ont été exécutés dans le périmètre ÷ exigences couvertes |
| Taux de validation | exigences dont la dernière exécution de chaque test lié est `PASSED` ÷ exigences couvertes |
| Couverture pondérée par le risque | même calcul que la couverture de conception, chaque exigence pesant 1, 2, 4 ou 8 selon son risque |

Une exigence parente (épic, feature) agrège ses enfants : elle est *validée* si tous ses enfants le sont.

### 7.3 Statut de vérification d'une exigence

Calculé à la demande et mis en cache, affiché par une pastille de couleur :

| Statut | Condition |
| --- | --- |
| Non couverte (gris) | aucun test lié |
| Non exécutée (bleu) | tests liés, aucune exécution dans le périmètre |
| En cours (jaune) | au moins une exécution, d'autres non exécutées |
| Validée (vert) | dernière exécution de chaque test lié = `PASSED` |
| En échec (rouge) | au moins un test lié en `FAILED` ou une anomalie bloquante/critique ouverte |
| Bloquée (orange) | au moins un test `BLOCKED`, aucun `FAILED` |
| Suspecte (violet) | exigence modifiée après la dernière exécution d'un test lié |

### 7.4 Vues de traçabilité

- **F-TRA-04** **Matrice** exigences (lignes) × tests (colonnes), filtrable par périmètre ; chaque cellule indique le type de lien et le dernier résultat. Clic sur une cellule vide = création du lien.
- **F-TRA-05** **Arbre de traçabilité** d'une exigence : parents, enfants, critères, tests, dernières exécutions, anomalies.
- **F-TRA-06** **Rapport des orphelins** : exigences sans test, tests sans exigence, anomalies sans exigence, tests automatisés jamais exécutés.
- **F-TRA-07** **Analyse d'impact** : à partir d'une exigence modifiée, liste des tests à revoir et des campagnes en cours concernées.
- **F-TRA-08** Export de la matrice en CSV et en PDF.

## 8. Releases, sprints, campagnes et exécution

### 8.1 Releases (groupes de sprints)

- **F-PLN-01** Créer une release avec nom, objectif, dates, statut. Y ajouter des sprints existants ou en générer : nombre de sprints, durée (1 à 4 semaines), date de début → dates calculées sans chevauchement.
- **F-PLN-02** Vue **feuille de route** : frise chronologique des releases et de leurs sprints, avec pour chaque sprint le taux de validation.
- **F-PLN-03** Clôturer une release fige son bilan (instantané JSON horodaté) ; elle reste consultable en lecture seule.

### 8.2 Sprints

- **F-PLN-04** Créer un sprint (nom, objectif, dates, capacité en points), rattaché ou non à une release.
- **F-PLN-05** **Planification** : écran en deux colonnes, backlog `READY` à gauche, périmètre du sprint à droite, ajout par glisser-déposer. Jauge charge / capacité en points ; alerte au-delà de 100 %.
- **F-PLN-06** Démarrer un sprint le passe à `ACTIVE` et ses stories à `IN_SPRINT`. Clôturer un sprint propose, pour chaque story non `DONE`, de la renvoyer au backlog ou de la reporter sur le sprint suivant.

### 8.3 Campagnes de test

- **F-CMP-01** Créer une campagne rattachée à un sprint ou une release, avec environnement cible (ex. `recette`, `preprod`) et version du build testé.
- **F-CMP-02** **Sélection des tests** par plusieurs moyens cumulables : tous les tests liés aux exigences du sprint ; tests par tag (`smoke`, `regression`) ; tests liés aux exigences modifiées (analyse d'impact) ; sélection manuelle ; reprise des tests en échec d'une campagne précédente.
- **F-CMP-03** **Priorisation par le risque** : ordre proposé = risque de l'exigence × priorité du test, modifiable à la main.
- **F-CMP-04** Affecter chaque test manuel ou exploratoire à un testeur ; les tests automatisés sont affectés au serveur d'exécution.
- **F-CMP-05** Estimation de charge : somme des durées estimées des tests manuels et des timebox des chartes, par testeur.

### 8.4 Exécution manuelle

- **F-EXE-01** Le testeur voit **« Mes tests à exécuter »** filtrés sur la campagne active. L'exécution d'un test manuel affiche les pas un par un avec, pour chacun, statut (`PASSED`, `FAILED`, `BLOCKED`, `SKIPPED`), résultat obtenu et pièces jointes.
- **F-EXE-02** Le statut global se déduit des pas : `FAILED` si un pas échoue, `BLOCKED` si un pas est bloqué et aucun n'échoue, `PASSED` si tous passent. Il reste modifiable avec commentaire obligatoire.
- **F-EXE-03** Sur un pas en échec, bouton **« Créer une anomalie »** pré-rempli (étapes jusqu'au pas en échec, attendu, obtenu, environnement, build, captures).
- **F-EXE-04** Réexécuter un test crée une nouvelle tentative (`attempt + 1`) ; l'historique des tentatives est conservé.
- **F-EXE-05** Exécution des chartes exploratoires : voir §5.2.

### 8.5 Exécution automatisée

- **F-EXE-06** Depuis une campagne, sélectionner des tests automatisés (ou tous) et cliquer **« Lancer sur… »** en choisissant un serveur d'exécution compatible avec leurs techniques. Un `AutomatedRun` est créé au statut `QUEUED`, puis la requête est envoyée au serveur (§10).
- **F-EXE-07** Suivi en temps réel : statut du run et des exécutions, poussé au navigateur par **Server-Sent Events** ; journaux en flux continu si le serveur les fournit.
- **F-EXE-08** Annuler un run en cours (`CANCELLED`).
- **F-EXE-09** Relancer uniquement les tests en échec d'un run.
- **F-EXE-10** **Import manuel de résultats** sans serveur d'exécution : téléverser un rapport JUnit XML, Cucumber JSON, Robot `output.xml` ou Playwright JSON dans une campagne. Les tests sont rapprochés par `testIdentifier` ou par tags d'exigence ; les tests inconnus sont proposés à la création.
- **F-EXE-11** Détection des **tests instables** : un test qui alterne `PASSED`/`FAILED` sur le même build au moins 2 fois dans les 10 dernières exécutions est marqué *flaky* et signalé dans le bilan.

### 8.6 Anomalies

- **F-DEF-01** Gestion simple des anomalies (titre, description, sévérité, statut `OPEN` → `IN_PROGRESS` → `RESOLVED` → `CLOSED`, ou `REJECTED`), liées aux exécutions et aux exigences.
- **F-DEF-02** Champ `externalRef` pour pointer vers l'outil de suivi de l'équipe (Jira, GitLab) ; l'interface d'un connecteur est prévue mais non implémentée.

## 9. Bilans, tableaux de bord et rapports

### 9.1 Tableau de bord du projet

- **F-RPT-01** Widgets : sprint actif (jours restants, points terminés / engagés), couverture de conception et taux de validation du sprint et de la release, résultats de la dernière campagne (anneau par statut), anomalies ouvertes par sévérité, sessions exploratoires de la semaine, derniers runs automatisés.
- **F-RPT-02** Graphiques : **burndown** du sprint (points restants par jour), **burnup** de la release, tendance du taux de réussite des tests automatisés sur les 10 derniers runs, anomalies ouvertes / fermées par sprint.

### 9.2 Bilan de sprint

Généré à la demande pendant le sprint et figé à la clôture. Contenu, dans cet ordre :

1. **Synthèse** : objectif du sprint, verdict proposé (*objectif atteint*, *partiellement atteint*, *non atteint*) calculé selon les règles ci-dessous, modifiable par le PO avec commentaire.
2. **Livraison** : stories engagées, terminées, acceptées, reportées ; vélocité (points `DONE`).
3. **Couverture** : les cinq indicateurs du §7.2 et la liste des exigences non couvertes ou en échec.
4. **Exécution** : répartition par statut et par type de test (manuel, exploratoire, automatisé), tendance des tentatives, tests instables.
5. **Exploratoire** : métriques du §5.4 et principaux constats issus des débriefings.
6. **Anomalies** : créées, résolues, ouvertes par sévérité ; anomalies bloquantes restantes.
7. **Risques résiduels** : exigences à risque `HIGH` ou `CRITICAL` non validées.
8. **Recommandation de mise en production** : *Go*, *Go sous réserve*, *No go*.

Règles par défaut du verdict (paramétrables par projet) :

| Verdict | Condition |
| --- | --- |
| Go | taux de validation ≥ 95 %, aucune anomalie `BLOCKER` ou `CRITICAL` ouverte, aucune exigence `CRITICAL` non validée |
| Go sous réserve | taux de validation ≥ 80 %, aucune anomalie `BLOCKER` ouverte |
| No go | sinon |

### 9.3 Bilan de release

Même structure, agrégée sur tous les sprints de la release, avec en plus : évolution sprint par sprint des indicateurs, campagne de régression finale, couverture des ENF avec valeurs mesurées comparées aux seuils.

### 9.4 Formats

- **F-RPT-03** Affichage web, export **PDF** (génération côté serveur, OpenPDF ou Flying Saucer à partir d'un gabarit HTML Thymeleaf), export **CSV** des données détaillées, export **JSON** de l'instantané.
- **F-RPT-04** Lien permanent vers un bilan figé, partageable avec les utilisateurs du projet.

## 10. Contrat avec le serveur d'exécution distant

Le serveur d'exécution sera un projet séparé. Le prototype implémente le **côté client** de ce contrat, une interface Java `ExecutionServerClient` et un **simulateur** (`mock-execution-server`) qui le respecte, pour tester toute la chaîne sans serveur réel. Le contrat est publié en OpenAPI 3 dans `docs/execution-server-api.yaml`.

### 10.1 Principes

- **Asynchrone** : TraceAgile envoie une demande et reçoit immédiatement un identifiant de job. Les résultats arrivent par **webhook** (rappel HTTP) ; un mode **polling** sert de secours.
- **Idempotent** : chaque demande porte un `runId` TraceAgile ; renvoyer la même demande ne crée pas de second job.
- **Authentifié dans les deux sens** : TraceAgile appelle le serveur avec un jeton Bearer ; le serveur signe ses webhooks en HMAC-SHA256 (en-tête `X-TraceAgile-Signature`) avec un secret partagé.
- **Agnostique** : le serveur reçoit la technique, le framework, le dépôt et les identifiants ; il choisit lui-même l'agent capable d'exécuter.

### 10.2 Endpoints exposés par le serveur d'exécution

| Méthode | Chemin | Rôle |
| --- | --- | --- |
| `GET` | `/api/v1/health` | État et version ; utilisé pour le heartbeat (toutes les 60 s) |
| `GET` | `/api/v1/capabilities` | Techniques, frameworks, environnements et agents disponibles |
| `POST` | `/api/v1/jobs` | Soumettre un job ; réponse `202 Accepted` avec `jobId` |
| `GET` | `/api/v1/jobs/{jobId}` | Statut et résultats partiels (mode polling) |
| `POST` | `/api/v1/jobs/{jobId}/cancel` | Annuler |
| `GET` | `/api/v1/jobs/{jobId}/logs` | Journaux (texte, flux continu facultatif) |
| `GET` | `/api/v1/jobs/{jobId}/artifacts/{name}` | Rapports, captures, vidéos |

### 10.3 Soumission d'un job

```json
{
  "runId": "RUN-102",
  "project": "SHOP",
  "campaign": "CMP-8",
  "environment": "recette",
  "buildVersion": "2.4.0-rc1",
  "callbackUrl": "https://traceagile.example.com/api/v1/execution-callbacks",
  "repository": { "url": "https://git.example.com/shop/tests.git", "branch": "main" },
  "tests": [
    {
      "executionId": "8f1c…",
      "testKey": "TC-45",
      "technique": "BDD",
      "framework": "cucumber-jvm",
      "path": "src/test/resources/features/panier.feature",
      "testIdentifier": "Livraison gratuite au seuil",
      "gherkinSource": "# language: fr\nFonctionnalité: …",
      "dataSet": null,
      "parameters": { "browser": "chromium" },
      "tags": ["smoke", "REQ-12"]
    }
  ],
  "options": { "timeoutMinutes": 30, "parallelism": 4, "retryFailed": 0 }
}
```

### 10.4 Webhooks envoyés à TraceAgile

TraceAgile expose `POST /api/v1/execution-callbacks`. Types d'événements :

| `event` | Contenu |
| --- | --- |
| `JOB_STARTED` | `jobId`, `runId`, `startedAt`, `agent` |
| `TEST_STARTED` | `executionId`, `startedAt` |
| `TEST_FINISHED` | `executionId`, `status`, `durationMs`, `message`, `stackTrace`, `steps[]` (pour BDD : statut par étape), `metrics{}` (performance), `artifacts[]` (nom, type, URL) |
| `JOB_FINISHED` | `status`, `endedAt`, `summary` {total, passed, failed, error, skipped}, `reportUrl`, `logsUrl` |
| `JOB_ERROR` | `errorCode`, `message` (ex. dépôt inaccessible, agent indisponible) |

**Règles côté TraceAgile** : vérifier la signature HMAC, rejeter un événement dont le `runId` est inconnu (404), ignorer un événement déjà traité (clé `eventId`), passer un run en `TIMEOUT` si aucun événement n'est reçu au-delà de `timeoutMinutes` + 5 minutes (tâche planifiée toutes les minutes).

### 10.5 Simulateur

Module Spring Boot séparé (`mock-execution-server`, port 8090) qui implémente les endpoints du §10.2. À la réception d'un job, il attend 1 à 3 s par test puis envoie les webhooks avec un résultat tiré au sort selon une configuration (`passRate: 0.8`, `errorRate: 0.05`, durée aléatoire). Un test dont l'identifiant contient `@fail` échoue toujours, `@flaky` alterne : les démonstrations sont reproductibles.

### 10.6 Compatibilité envisagée

L'interface `ExecutionServerClient` permettra plus tard d'autres implémentations (adaptateur vers un orchestrateur existant comme OpenTestFactory, ou vers un pipeline GitLab CI / GitHub Actions déclenché par API). Le choix de l'implémentation se fait par le champ `type` de `ExecutionServer`.

## 11. Architecture technique

&#91;embedded content: architecture · 4 composants\]

Le front n'appelle que l'API ; l'API délègue l'exécution au serveur distant, qui lui renvoie les résultats par webhooks.

### 11.1 Pile technique

| Couche | Choix | Remarques |
| --- | --- | --- |
| Back-end | Java 21, Spring Boot 3.3+, Maven multi-modules | Spring Web, Spring Data JPA, Spring Security, Validation, Actuator |
| Base de données | PostgreSQL 16 | migrations **Flyway** ; colonnes `jsonb` pour snapshots, jeux de données, paramètres |
| Recherche | PostgreSQL full-text (`tsvector`) | suffisant pour le prototype |
| Mapping | MapStruct | entités ↔ DTO ; jamais d'entité exposée par l'API |
| Sécurité | JWT (access 15 min, refresh 7 jours), BCrypt | rôles par projet évalués avec `@PreAuthorize` et un `ProjectPermissionEvaluator` |
| Temps réel | Server-Sent Events (`SseEmitter`) | statut des runs et des exécutions |
| Client HTTP | Spring `RestClient` + Resilience4j (retry, circuit breaker) | appels au serveur d'exécution |
| Documentation API | springdoc-openapi | Swagger UI sur `/swagger-ui.html` |
| Rapports PDF | Thymeleaf + OpenHTMLtoPDF | gabarits dans `resources/templates/reports` |
| Front-end | React 18, TypeScript, Vite |  |
| UI | Mantine 7 (ou MUI 6) | composants, thème clair / sombre |
| Données front | TanStack Query (cache serveur), Zustand (état local), React Router 6 | client API généré depuis l'OpenAPI (`openapi-typescript` + `openapi-fetch`) |
| Formulaires | React Hook Form + Zod |  |
| Éditeurs | Monaco Editor (Gherkin, JSON), éditeur Markdown (`@uiw/react-md-editor`) | grammaire Gherkin personnalisée pour Monaco |
| Glisser-déposer | dnd-kit | backlog, planification, matrice |
| Graphiques | Recharts | burndown, burnup, tendances |
| Conteneurs | Docker, Docker Compose | fonctionne sur Docker Desktop (Windows, macOS) et Linux |

### 11.2 Structure du dépôt

```text
traceagile/
├── backend/
│   ├── traceagile-domain/        # entités JPA, énumérations, règles métier pures
│   ├── traceagile-application/   # services, cas d'usage, ports (interfaces)
│   ├── traceagile-infrastructure/# repositories, client serveur d'exécution, parsers de rapports, PDF
│   ├── traceagile-api/           # contrôleurs REST, DTO, mappers, sécurité, SSE ; application Spring Boot
│   └── mock-execution-server/    # simulateur (§10.5)
├── frontend/
│   └── src/
│       ├── api/          # client généré + hooks TanStack Query
│       ├── features/     # requirements, tests, exploratory, planning, campaigns, executions, traceability, reports, admin
│       ├── components/   # composants partagés
│       ├── layouts/
│       └── routes/
├── docs/
│   ├── execution-server-api.yaml
│   └── adr/              # décisions d'architecture
├── docker-compose.yml    # postgres, backend, frontend (nginx), mock-execution-server
├── scripts/              # start.ps1, start.sh, seed
└── .github/workflows/ci.yml
```

### 11.3 Organisation du back-end

- **Architecture hexagonale légère** : le domaine ne dépend d'aucun framework web ; l'application définit des ports (`ExecutionServerClient`, `ReportParser`, `ReportRenderer`, `FileStorage`, `IssueTrackerConnector`) implémentés par l'infrastructure.
- **Découpage par fonctionnalité** dans chaque module : `requirement`, `testcase`, `exploratory`, `planning`, `campaign`, `execution`, `traceability`, `reporting`, `administration`.
- **Événements de domaine** (Spring `ApplicationEventPublisher`) : `RequirementChanged` → marquage des tests `NEEDS_UPDATE` ; `ExecutionCompleted` → recalcul du statut de vérification ; `RunStatusChanged` → diffusion SSE.
- **Calculs de couverture** : requêtes SQL agrégées (vues ou requêtes natives), résultat mis en cache (Caffeine, invalidé par les événements ci-dessus).
- **Audit** : listener JPA (`@EntityListeners`) qui écrit les `AuditEvent` avec le diff JSON des champs modifiés.
- **Gestion des erreurs** : `@RestControllerAdvice` renvoyant le format RFC 9457 (`application/problem+json`) avec un code métier (`REQ_PARENT_INVALID`, `SPRINT_DATES_OVERLAP`…).

### 11.4 Organisation du front-end

- Une route par écran (§13), chargement paresseux par fonctionnalité.
- Les clés métier figurent dans les URL : `/projects/SHOP/requirements/REQ-12`.
- Toutes les listes sont paginées côté serveur, avec filtres reflétés dans l'URL (partage de liens filtrés).
- Mise à jour optimiste pour le glisser-déposer (rang du backlog, planification), avec annulation en cas d'erreur.
- Internationalisation `react-i18next`, français par défaut, anglais prévu.

## 12. API REST

Préfixe `/api/v1`. JSON partout, dates en ISO 8601 UTC. Pagination `?page=0&size=50&sort=rank,asc` avec réponse `{ content, page, size, totalElements }`. Les ressources d'un projet sont adressées par la clé du projet et la clé métier (`/projects/SHOP/requirements/REQ-12`). Les mises à jour partielles utilisent `PATCH` (JSON Merge Patch) et l'en-tête `If-Match` porte la version pour le verrou optimiste (réponse `412` en cas de conflit).

| Domaine | Endpoints principaux |
| --- | --- |
| Authentification | `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`, `GET /me` |
| Administration | `GET/POST /users`, `PATCH /users/{id}`, `GET/POST /projects`, `PUT /projects/{key}/members`, `GET/POST/PATCH /execution-servers`, `POST /execution-servers/{id}/test-connection` |
| Exigences | `GET/POST /projects/{p}/requirements` (filtres : `type`, `status`, `priority`, `sprint`, `tag`, `risk`, `verification`, `q`), `GET/PATCH/DELETE /requirements/{key}`, `GET /requirements/tree`, `POST /requirements/{key}/move` {parentKey, beforeKey, afterKey}, `GET/POST /requirements/{key}/versions`, `GET /requirements/{key}/versions/{a}/diff/{b}`, `POST /requirements/import` (CSV), `GET /requirements/export` |
| Critères | `GET/POST /requirements/{key}/acceptance-criteria`, `PATCH/DELETE /acceptance-criteria/{id}`, `POST /acceptance-criteria/{id}/generate-test` |
| Example Mapping | `GET/PUT /requirements/{key}/example-map`, `POST /example-map/cards/{id}/convert` |
| Cas de test | `GET/POST /projects/{p}/test-cases` (filtres : `kind`, `technique`, `status`, `tag`, `requirement`, `orphan`), `GET/PATCH/DELETE /test-cases/{key}`, `GET /test-cases/{key}/versions`, `POST /test-cases/import-feature`, `GET /test-cases/export-feature`, `POST /test-cases/discovery` |
| Gherkin | `POST /gherkin/validate`, `GET /projects/{p}/gherkin/steps` (autocomplétion) |
| Traçabilité | `POST/DELETE /trace-links`, `GET /projects/{p}/traceability/matrix?scope=…`, `GET /requirements/{key}/trace-tree`, `GET /projects/{p}/traceability/orphans`, `GET /requirements/{key}/impact` |
| Couverture | `GET /projects/{p}/coverage?scope=release:REL-1` → les cinq indicateurs + détail par exigence |
| Planification | `GET/POST /projects/{p}/releases`, `PATCH /releases/{key}`, `POST /releases/{key}/generate-sprints`, `POST /releases/{key}/close`, `GET/POST /projects/{p}/sprints`, `PATCH /sprints/{key}`, `PUT /sprints/{key}/scope`, `POST /sprints/{key}/start`, `POST /sprints/{key}/close` |
| Campagnes | `GET/POST /projects/{p}/campaigns`, `PATCH /campaigns/{key}`, `POST /campaigns/{key}/items/select` {strategy, params}, `PATCH /campaign-items/{id}` (assignee, order), `GET /campaigns/{key}/progress` |
| Exécutions | `GET /me/executions?status=NOT_RUN`, `POST /campaign-items/{id}/executions`, `PATCH /executions/{id}`, `PUT /executions/{id}/steps/{order}`, `POST /campaigns/{key}/results/import` (multipart, \`format=junit |
| Sessions | `POST /campaign-items/{id}/sessions`, `PATCH /sessions/{id}`, `POST /sessions/{id}/notes`, `POST /sessions/{id}/finish`, `POST /sessions/{id}/debrief`, `POST /sessions/{id}/debrief/approve` |
| Runs automatisés | `POST /campaigns/{key}/runs` {serverId, itemIds\[\] ou all}, `GET /runs/{key}`, `POST /runs/{key}/cancel`, `POST /runs/{key}/rerun-failed`, `GET /runs/{key}/events` (SSE), `POST /execution-callbacks` (webhook, sans JWT, signature HMAC) |
| Anomalies | `GET/POST /projects/{p}/defects`, `PATCH /defects/{key}`, `POST /executions/{id}/defects` |
| Rapports | `GET /projects/{p}/dashboard`, \`GET /sprints/{key}/report?format=json |
| Transverse | `GET/POST /{entityType}/{key}/comments`, `POST /{entityType}/{key}/attachments` (multipart, 20 Mo max), `GET /attachments/{id}`, `GET /{entityType}/{key}/history` |

## 13. Interface utilisateur

### 13.1 Structure générale

- **Barre supérieure** : sélecteur de projet, recherche globale (clés et titres, raccourci `Ctrl+K`), sprint actif, notifications, menu utilisateur, bascule clair / sombre.
- **Menu latéral** : Tableau de bord, Backlog, Tests, Exploratoire, Planification, Campagnes, Mes exécutions, Traçabilité, Anomalies, Rapports, Administration (selon le rôle).
- **Panneau de détail latéral** : un clic sur un élément d'une liste ouvre sa fiche dans un panneau à droite sans quitter la liste ; un bouton l'ouvre en pleine page.
- **Clés cliquables partout** : toute clé (`REQ-12`, `TC-45`) affichée est un lien avec aperçu au survol.

### 13.2 Écrans

| Route | Écran | Contenu clé |
| --- | --- | --- |
| `/login` | Connexion | login, mot de passe |
| `/projects` | Liste des projets | cartes avec couverture et sprint actif |
| `/p/:key/dashboard` | Tableau de bord | widgets et graphiques du §9.1 |
| `/p/:key/backlog` | Backlog | vue arbre / liste, filtres, glisser-déposer, pastilles de vérification |
| `/p/:key/requirements/:rk` | Fiche exigence | onglets Détail, Critères, Example Mapping, Tests liés, Exécutions, Anomalies, Versions, Historique, Commentaires |
| `/p/:key/tests` | Référentiel de tests | arbre par dossier ou par feature, filtres par type et technique |
| `/p/:key/tests/:tk` | Fiche test | selon le type : pas, charte ou définition automatisée (éditeur Gherkin, grille de données) ; exigences liées ; historique d'exécution |
| `/p/:key/exploratory` | Exploratoire | chartes, sessions à faire et en cours, sessions à débriefer, métriques |
| `/p/:key/sessions/:id` | Session en cours | mission, chronomètre, notes horodatées, captures, fin de session, débriefing PROOF |
| `/p/:key/planning` | Planification | feuille de route des releases, planification de sprint en deux colonnes |
| `/p/:key/campaigns/:ck` | Campagne | sélection des tests, affectation, avancement par statut, lancement de runs |
| `/p/:key/runs/:rk` | Run automatisé | statut en temps réel, tests, journaux, artefacts |
| `/p/:key/my-executions` | Mes exécutions | file des tests à exécuter par le testeur connecté |
| `/p/:key/executions/:id` | Exécution manuelle | pas un par un, statut, résultat obtenu, création d'anomalie |
| `/p/:key/traceability` | Traçabilité | matrice, orphelins, analyse d'impact |
| `/p/:key/defects` | Anomalies | liste et fiche |
| `/p/:key/reports` | Rapports | bilans de sprint et de release, instantanés figés, exports |
| `/admin/*` | Administration | utilisateurs, projets et membres, serveurs d'exécution, référentiels (techniques, frameworks, heuristiques), DoR / DoD, règles de verdict |

### 13.3 Conventions d'ergonomie

- Couleurs de statut identiques dans toute l'application (tableau du §7.3) et toujours doublées d'une icône ou d'un libellé (pas d'information portée par la couleur seule).
- Raccourcis clavier documentés (`?` affiche l'aide) : `N` nouvel élément, `E` éditer, `P` / `F` / `B` passer, échouer, bloquer le pas courant en exécution manuelle.
- Toute suppression demande confirmation ; toute action longue affiche une progression.
- Chaque élément interactif porte un attribut `data-testid` stable pour l'automatisation des tests de l'outil lui-même.

## 14. Exigences non fonctionnelles

Cibles mesurées sur le jeu de démonstration (§15) étendu à 5 000 exigences et 10 000 tests, sur un poste de développement avec Docker.

| Id | Catégorie | Exigence | Seuil | Cible |
| --- | --- | --- | --- | --- |
| NF-01 | Performance | Temps de réponse p95 des API de lecture paginées | 500 ms | 200 ms |
| NF-02 | Performance | Calcul de la matrice de traçabilité d'une release (500 exigences × 1 000 tests) | 3 s | 1 s |
| NF-03 | Performance | Génération du PDF d'un bilan de release | 10 s | 5 s |
| NF-04 | Performance | Délai entre réception d'un webhook et affichage dans le navigateur | 2 s | 500 ms |
| NF-05 | Fiabilité | Aucune perte de notes de session exploratoire après fermeture du navigateur | 10 s de saisie au plus | 0 |
| NF-06 | Fiabilité | Webhook en double ou désordonné traité sans incohérence | 100 % | 100 % |
| NF-07 | Sécurité | Mots de passe BCrypt (coût 12), jetons API des serveurs chiffrés en AES-GCM au repos | obligatoire | — |
| NF-08 | Sécurité | Contrôle d'accès par projet vérifié sur chaque endpoint (tests dédiés) | 100 % des endpoints | — |
| NF-09 | Sécurité | Contenu Markdown assaini avant affichage (DOMPurify), en-têtes CSP, CORS restreint | obligatoire | — |
| NF-10 | Accessibilité | Conformité WCAG 2.1 niveau AA sur les écrans principaux (contrôle axe-core) | aucune violation critique | aucune violation |
| NF-11 | Compatibilité | Dernières versions de Chrome, Edge et Firefox ; largeur minimale 1280 px | — | — |
| NF-12 | Maintenabilité | Couverture de code back-end (JaCoCo) | 70 % des lignes | 80 % |
| NF-13 | Maintenabilité | Analyse statique sans anomalie bloquante (SpotBugs, ESLint, `tsc --strict`) | 0 | 0 |
| NF-14 | Exploitabilité | Démarrage complet par une seule commande (`docker compose up`) | < 3 min | < 1 min |
| NF-15 | Exploitabilité | Journaux structurés JSON, identifiant de corrélation propagé du navigateur au serveur d'exécution (`X-Correlation-Id`) | obligatoire | — |
| NF-16 | Traçabilité | Toute modification d'exigence, de test ou d'exécution est auditée (qui, quand, quoi) | 100 % | — |

## 15. Données de démonstration et stratégie de test du prototype

### 15.1 Jeu de démonstration

Chargé au démarrage avec le profil Spring `demo` (migration Flyway `R__demo_data.sql` ou `CommandLineRunner`), idempotent.

- **Utilisateurs** (mot de passe `demo`) : `admin`, `po` (Product Owner), `qa1` et `qa2` (testeurs), `dev` (développeur), `viewer` (lecteur).
- **Projet `SHOP`** — boutique en ligne : 3 épics (Catalogue, Panier et commande, Compte client), 8 features, 25 user stories avec critères (dont 15 en Gherkin français), 4 règles métier (ex. livraison gratuite dès 50 €), 4 ENF (temps de réponse, sécurité des mots de passe, accessibilité, disponibilité).
- **Tests** : 20 tests manuels scriptés, 8 chartes exploratoires, 30 tests automatisés répartis sur les techniques BDD, UI (Playwright), API (REST Assured), unitaire (JUnit 5), data-driven et performance (Gatling). Au moins 3 exigences volontairement non couvertes et 2 tests orphelins.
- **Planification** : release `REL-1` « Version 2.0 » de 3 sprints de 2 semaines — `SPR-1` clos, `SPR-2` actif, `SPR-3` planifié.
- **Historique** : campagnes et exécutions sur `SPR-1` (taux de validation 85 %), 5 sessions exploratoires débriefées, 6 anomalies de sévérités variées, 2 tests marqués instables. Ainsi bilans, burndown et tendances sont démontrables dès le premier lancement.
- **Serveur d'exécution** : le simulateur déclaré et connecté.

### 15.2 Tests du prototype

| Niveau | Outils | Portée minimale attendue |
| --- | --- | --- |
| Unitaires back-end | JUnit 5, AssertJ, Mockito | règles du §3.3, calculs de couverture (§7.2) et de statut (§7.3), verdict de bilan (§9.2), détection des tests instables, parsers de rapports (un fichier exemple par format) |
| Intégration back-end | `@SpringBootTest`, Testcontainers PostgreSQL, MockMvc | chaque contrôleur : cas nominal, validation (400), accès refusé (403), conflit de version (412) |
| Contrat serveur d'exécution | WireMock côté client ; tests du simulateur contre le fichier OpenAPI | soumission, webhooks signés, doublons, timeout |
| Unitaires front-end | Vitest, React Testing Library, MSW | composants de formulaire, éditeur Gherkin, calculs d'affichage |
| Bout en bout | Playwright (TypeScript) | les 5 parcours du §15.3 |
| Architecture | ArchUnit | le domaine ne dépend ni de Spring Web ni de l'infrastructure |

### 15.3 Parcours de bout en bout de référence

1. Le PO crée une story avec deux critères Gherkin, la passe à `READY`, l'ajoute à `SPR-2`.
2. Le testeur génère un test BDD depuis un critère, crée une charte exploratoire liée, les sélectionne dans une campagne.
3. Le testeur exécute la charte (notes, un `BUG` converti en anomalie, débriefing approuvé par le PO).
4. Le développeur lance un run automatisé sur le simulateur ; les résultats arrivent en temps réel ; un test `@fail` échoue et rend l'exigence rouge dans la matrice.
5. Le PO consulte le bilan de `SPR-2`, constate le verdict *No go* ou *Go sous réserve* et exporte le PDF.

Ces parcours servent aussi de **démonstration** du produit : les scénarios Playwright sont rédigés pour être lisibles par un non-développeur.

## 16. Plan de réalisation pour Claude Code

### 16.1 Consignes à Claude Code

1. Lire tout ce document avant d'écrire du code ; créer `CLAUDE.md` à la racine qui résume conventions, commandes et état d'avancement des lots.
2. Réaliser les lots **dans l'ordre**, un lot par branche et par pull request, chacun laissant l'application démarrable et tous les tests verts.
3. Pour chaque lot : écrire d'abord les tests des règles métier (TDD), puis le code, puis mettre à jour le jeu de démonstration et `CLAUDE.md`.
4. Référencer les identifiants de ce document (`F-REQ-07`, `NF-04`…) dans les noms de tests ou les commentaires, pour tracer la spécification jusqu'au code.
5. En cas d'ambiguïté, choisir l'option la plus simple compatible avec la spécification et la consigner dans `docs/adr/`.
6. Ne pas implémenter ce qui est listé « Exclu » au §1.3.

### 16.2 Lots

| Lot | Contenu | Spécification | Critère de fin |
| --- | --- | --- | --- |
| 0. Socle | Dépôt multi-modules, Docker Compose, Flyway, sécurité JWT, utilisateurs, projets, membres, squelette React (layout, routage, login, client OpenAPI généré), CI GitHub Actions (build, tests, lint) | §2.2, §11, §13.1 | `docker compose up` ; connexion `admin` ; création d'un projet ; CI verte |
| 1. Exigences | Backlog arbre et liste, fiche exigence, critères (texte et Gherkin), ENF, rang, DoR/DoD, versions, audit, import / export CSV | §3, §4 (hors 4.4) | parcours §15.3 étape 1 automatisé |
| 2. Tests | Référentiel de tests, tests manuels, définitions automatisées par technique, éditeur Gherkin Monaco, génération de test depuis un critère, tags `@REQ-` | §6 | création des trois types de test, génération BDD depuis un critère |
| 3. Traçabilité | Liens, statut de vérification, indicateurs de couverture, matrice, orphelins, analyse d'impact, suspicion après modification | §7 | matrice correcte sur le jeu de démonstration ; tests unitaires des formules |
| 4. Planification | Releases, génération de sprints, planification par glisser-déposer, démarrage et clôture | §8.1, §8.2 | release de 3 sprints créée et planifiée depuis l'interface |
| 5. Campagnes et exécution manuelle | Campagnes, stratégies de sélection, affectation, « Mes exécutions », exécution pas à pas, tentatives, anomalies | §8.3, §8.4, §8.6 | un test manuel exécuté en échec crée une anomalie liée |
| 6. Exploratoire | Chartes, génération depuis une exigence, sessions avec chronomètre et notes auto-sauvegardées, TBS, débriefing PROOF et approbation, métriques | §5 | parcours §15.3 étape 3 automatisé |
| 7. Exécution automatisée | Port `ExecutionServerClient`, simulateur, runs, webhooks signés, SSE, annulation, relance des échecs, import de rapports (4 formats), tests instables, timeout | §8.5, §10 | parcours §15.3 étape 4 automatisé |
| 8. Bilans | Tableau de bord, burndown / burnup, bilans de sprint et de release, verdict, instantanés figés, exports PDF / CSV / JSON | §9 | parcours §15.3 étape 5 automatisé |
| 9. Atelier et finitions | Example Mapping, recherche globale `Ctrl+K`, raccourcis, thème sombre, accessibilité, jeu de démonstration complet, vérification des cibles NF-01 à NF-16 | §4.4, §13.3, §14, §15 | les 5 parcours passent ; rapport axe-core sans violation critique |

### 16.3 Prompt de lancement suggéré

```text
Tu vas réaliser le prototype TraceAgile décrit dans le fichier SPECIFICATION.md.
Lis-le entièrement, puis crée CLAUDE.md et réalise uniquement le lot 0 (§16.2).
Travaille en TDD, référence les identifiants de la spécification dans les tests,
et arrête-toi à la fin du lot avec un résumé de ce qui est fait, des choix
consignés en ADR et des commandes pour lancer l'application et les tests.
```

Enchaîner ensuite lot par lot avec : « Réalise le lot N de SPECIFICATION.md, en suivant CLAUDE.md. »
