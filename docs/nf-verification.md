# Vérification des exigences non fonctionnelles (§14)

Lot 9, ADR-0024. Mesures du 10/10/2026 sur un poste de développement Windows 11, avec Docker Desktop.
Le volume de référence du §14 est de 5 000 exigences et 10 000 tests.

## Synthèse

| Id | Exigence | Seuil / cible | Résultat | Moyen de vérification |
| --- | --- | --- | --- | --- |
| NF-01 | p95 des lectures paginées | 500 ms / 200 ms | **45 ms** (backlog), 66 ms (tests), 14 ms (recherche backlog), 20 ms (Ctrl+K) | Banc `PerformanceBenchmarkTest` (profil `perf`), 60 appels après chauffe |
| NF-02 | Matrice d'une release (500 × 1 000) | 3 s / 1 s | **394 ms** au pire (229 ms au mieux) | Banc, 5 appels |
| NF-03 | PDF du bilan de release | 10 s / 5 s | **1,9 s** au pire | Banc, 3 appels |
| NF-04 | Webhook reçu → navigateur | 2 s / 500 ms | **p95 30 ms** (médiane 20 ms, 12 tests) | Script de mesure : un run de 12 tests sur le simulateur ; SSE comparé à l'horodatage de fin de chaque test |
| NF-05 | Pas de perte des notes de session | ≤ 10 s de saisie | **≤ 10 s** | Brouillon enregistré toutes les 10 s et à la perte du focus (F-EXP-10, test `exploratory.test.tsx`) |
| NF-06 | Webhook en double ou désordonné | 100 % | **100 %** | Doublon ignoré par `eventId` ; une tentative ou un run terminés ne changent plus (TEST_STARTED tardif, second TEST_FINISHED contradictoire) — `AutomatedRunApiTest` (`outOfOrderWebhooks` et critère de fin du lot 7) |
| NF-07 | BCrypt coût 12, jetons AES-GCM | obligatoire | **Conforme** | `BCryptPasswordHasher` (coût 12) ; `AesGcmSecretCipher` et ses tests |
| NF-08 | Contrôle d'accès sur chaque endpoint | 100 % | **100 %** | `EndpointSecurityTest` (toute méthode de contrôleur porte `@PreAuthorize`, sauf les exemptions justifiées) ; cas 403 dans chaque test d'API |
| NF-09 | Markdown assaini, CSP, CORS restreint | obligatoire | **Conforme** | `rehype-sanitize` sur tout rendu Markdown, y compris les commentaires (rôle de DOMPurify) ; CSP dans `frontend/nginx.conf` ; aucune origine CORS autorisée (API servie sur la même origine que le front) ; pièces jointes en `nosniff` et `CSP: sandbox` |
| NF-10 | WCAG 2.1 AA (axe-core) | aucune violation critique | **Aucune violation critique ni sérieuse** sur les 15 écrans principaux, en clair et en sombre | `e2e/tests/accessibilite.spec.ts` |
| NF-11 | Chrome, Edge, Firefox ; 1280 px | — | Chromium testé automatiquement ; Edge (même moteur) et Firefox à vérifier à la main | Playwright (Chromium) |
| NF-12 | Couverture back-end (lignes) | 70 % / 80 % | **93,9 %** | `mvn verify` : agrégat JaCoCo de tous les modules métier, seuil bloquant à 70 % (`coverage-total.csv`) |
| NF-13 | Analyse statique sans anomalie bloquante | 0 | **0** | SpotBugs au seuil « High », bloquant (une exclusion justifiée) ; ESLint sans avertissement ; `tsc --strict` |
| NF-14 | Démarrage en une commande | < 3 min / < 1 min | **18 s** (images déjà construites ; API prête en 5,7 s) | `docker compose up -d` chronométré jusqu'à l'état « healthy » et la réponse du front |
| NF-15 | Journaux JSON, `X-Correlation-Id` propagé | obligatoire | **Conforme** | Journaux ECS (`logging.structured`) ; `CorrelationIdFilter` ; en-tête transmis au serveur d'exécution (`HttpExecutionServerClient`, testé) |
| NF-16 | Audit des modifications | 100 % | **Conforme** | `AuditService` sur exigences, tests et exécutions ; onglet Historique ; tests d'API |

## Détails

### Performances (NF-01 à NF-03)

Commande :

```bash
cd backend
mvn -Pperf -pl traceagile-api test -Dtest=PerformanceBenchmarkTest -Dsurefire.failIfNoSpecifiedTests=false
```

Le banc génère le jeu de référence :
- 50 features et 4 950 stories, dont 500 dans `SPR-1` de `REL-1` ;
- 10 000 tests manuels, dont 1 000 couvrent les stories de la release ;
- un lien par test.

Les appels traversent toute la pile Spring (sécurité JWT, sérialisation) via MockMvc, sans le réseau.

**Écart trouvé et corrigé.** La première mesure du backlog paginé donnait **7,7 s** au p95. Deux causes :
- chaque page rechargeait toute la traçabilité du projet pour colorer 50 pastilles ;
- les `@OneToOne` inverses de `TestCase` (charte, définition automatisée) déclenchaient deux requêtes par test, soit 4 016 requêtes pour un appel.

Corrections (ADR-0024) :
- `left join fetch` sur les chargements de tests en masse ;
- `default_batch_fetch_size` à 100 ;
- statuts calculés sur les seuls sous-arbres affichés (`TraceabilityService.statusesOf`), avec un test qui vérifie leur équivalence avec le calcul complet.

Résultat : 16 requêtes par appel et 45 ms au p95.

Diagnostic rapide (requêtes SQL d'un appel) : ajouter `-Dperf.scale=0.2 -Dperf.diagnostic=true`.

### Accessibilité (NF-10)

Écrans contrôlés :
- connexion, projets, tableau de bord ;
- backlog et fiche exigence, tests et fiche test ;
- exploratoire, planification ;
- campagnes et campagne, mes exécutions ;
- traçabilité, anomalies ;
- rapports et rapport.

Le tableau de bord et le backlog sont aussi contrôlés en thème sombre.

Corrections apportées :
- teintes de texte et nuances des boutons (contraste ≥ 4,5:1) et `autoContrast` sur les éléments pleins ;
- rôles ARIA des arbres (`tree` / `group` / `treeitem`) ;
- noms des barres de progression ;
- liens soulignés dans le texte ;
- icônes décoratives de l'éditeur Markdown masquées.

Le document affiché dans l'`iframe` d'un rapport (export HTML isolé) n'est pas analysé : axe ne peut pas entrer dans un `srcdoc` d'origine opaque.

### Délai webhook → navigateur (NF-04)

Script : `nf04.mjs` (non versionné), reproductible avec la pile Docker démarrée.

Déroulé :
1. connexion de `dev` ;
2. run des 12 tests automatisés de CMP-2 sur le simulateur ;
3. écoute du flux SSE du run, comme le navigateur ;
4. à chaque événement, relecture du run.

Le délai mesuré est l'écart entre la fin d'un test, horodatée par le simulateur, et la réception de l'événement.
