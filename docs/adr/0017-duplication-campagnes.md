# ADR-0017 — Dupliquer une campagne ou la générer depuis les résultats d'une autre

**Statut** : acceptée (lot 5, demande complémentaire)

**Contexte.** La spécification ne prévoit, pour réutiliser une campagne, que la stratégie de
sélection « échecs d'une campagne précédente » (F-CMP-02). Deux besoins ont été exprimés en plus :
dupliquer une campagne, et générer une nouvelle campagne avec les tests d'une campagne existante,
choisis selon leur dernier résultat.

**Décisions.**

| Sujet | Décision |
| --- | --- |
| Point d'entrée | `POST /campaigns/{key}/copy` (droit `CAMPAIGN_WRITE`) crée une **nouvelle** campagne `PLANNED` et renvoie 201 : tests repris (`copied`), tests ignorés (`skipped`) et le détail de la campagne. La duplication et la génération sont la même opération ; seul le filtre change. |
| Filtre | `statuses` absent ou vide : tous les tests (duplication). Sinon, seuls les tests dont la **dernière tentative** a l'un de ces statuts (`NOT_RUN` pour les tests jamais exécutés). L'interface propose les échecs (`FAILED`, `ERROR`) par défaut quand la source en a, et affiche le nombre de tests par statut. |
| Source | N'importe quelle campagne, y compris terminée ou abandonnée : c'est le cas d'usage principal (rejouer les échecs d'une recette close). La source n'est pas modifiée. |
| Champs repris | Nom obligatoire. Périmètre, sprint ou release, environnement et build : repris de la source s'ils sont absents. Les dates prévues sont reprises si le périmètre est inchangé, sinon déduites du sprint ou de la release cible comme à la création (F-CMP-01). Les règles de création s'appliquent (`CAMPAIGN_SCOPE_INVALID`). |
| Éléments | Même ordre et même score de risque que la source, sans exécution. Seuls les tests `READY` sont repris ; les autres sont signalés `NOT_READY_<statut>`, comme à la sélection. La version figée est la version **courante** du test, pas celle de la source : on exécute le test tel qu'il est aujourd'hui. |
| Affectations | Conservées par défaut (`keepAssignees`), seulement si le testeur a encore le droit d'exécuter dans le projet et si le test n'est pas exécuté par le serveur (F-CMP-04). |
| Sélection | La stratégie `FAILED_IN_CAMPAIGN` est renommée `FROM_CAMPAIGN` et accepte les mêmes `statuses` (défaut : `FAILED`, `ERROR`) pour ajouter ces tests à une campagne existante. |
| Audit | Création de la campagne, puis une mise à jour avec ses éléments. |
