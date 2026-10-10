# ADR-0021 — Artefacts d'exécution automatisée : traces système, JUnit XML, Jest JSON, copies d'écran

**Statut** : acceptée (lot 7, demande complémentaire)

**Contexte.** Le protocole du lot 7 ne faisait que référencer par URL le rapport du serveur
d'exécution (ADR-0020). La demande est de récupérer par l'API les traces système, les résultats
aux formats JUnit XML et Jest JSON, et les copies d'écran des tests en échec. La spécification
(§10) ne précise ni les noms, ni les formats, ni le transport.

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Contrat du serveur | `docs/execution-server-api.yaml` : `GET /jobs/{jobId}/artifacts` (liste) et `GET /jobs/{jobId}/artifacts/{name}` (contenu, type MIME d'origine). Schéma `Artifact` : `name`, `type`, `size`, `kind`, `executionId`, `url`. |
| Types d'artefacts | `kind` ∈ `SYSTEM_TRACE`, `JUNIT`, `JEST`, `REPORT`, `SCREENSHOT`, `OTHER`. Quand le serveur ne précise pas le type, TraceAgile le déduit du nom (`junit*.xml`, `*jest*.json`, `*.png`, `*.log`…). |
| Noms normalisés (simulateur) | `system.log` (environnement, agent, build, dépôt, traces de chaque test), `junit.xml`, `jest.json`, `report.json`, et `screenshot-<clé du test>.png` pour chaque test FAILED ou ERROR. |
| Annonce | `TEST_FINISHED.artifacts` porte la copie d'écran de l'échec, liée à la tentative (`executionId`). `JOB_FINISHED.artifacts` porte les artefacts du job. TraceAgile mémorise des **références** (table `run_artifacts`, unicité (run, nom)). À la lecture, il complète la liste avec celle du serveur. |
| Contenu | Il n'est **pas** stocké. `GET /projects/{key}/runs/{rk}/artifacts/{name}` le relit sur le serveur avec le jeton émis par ce serveur (ADR-0020), puis le relaie avec son type MIME, `Content-Disposition` (`inline`, ou `attachment` si `?download=true`) et `X-Content-Type-Options: nosniff`. Les noms contenant `/` ou `..` sont ignorés. |
| Erreurs | Artefact inconnu du run : 404 `ARTIFACT_NOT_FOUND`. Serveur injoignable ou contenu expiré : 422 `ARTIFACT_UNAVAILABLE`. Jeton refusé : `SERVER_UNAUTHORIZED`. |
| Droits | Lecture du projet (`READ`), comme le run. |
| Interface | La page du run affiche une carte « Artefacts » (type, taille, téléchargement). Chaque test en échec a un bouton « Copie d'écran » qui ouvre l'image dans une fenêtre. Le contenu passe par `fetch` avec le jeton Bearer et une URL d'objet, pas par un lien direct. |
| Import Jest | `ReportFormat.JEST` : un résultat par `assertionResults`. Les identifiants essayés sont `fullName`, « describe › … › titre », « dernier describe#titre », « fichier › fullName », puis le titre. `passed` donne PASSED, `failed` donne FAILED, et `pending` / `skipped` / `todo` / `disabled` donnent SKIPPED. Le format est proposé à l'import (nom de fichier contenant « jest »). |

**Conséquences.** Les artefacts suivent la durée de rétention du serveur d'exécution. Une fois
le contenu expiré, la référence reste visible mais le téléchargement renvoie
`ARTIFACT_UNAVAILABLE`. Les vidéos et les pièces jointes stockées dans TraceAgile restent pour le
lot 9.
