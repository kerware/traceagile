package com.traceagile.application.traceability;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.stereotype.Component;

/**
 * Lot 3 : aucune exécution, anomalie ni campagne n'existe encore (lots 5 et 7). À remplacer par
 * l'adaptateur des exécutions au lot 5 (ADR-0014).
 */
@Component
public class NoExecutionResults implements ExecutionResults {

    @Override
    public Map<UUID, LastExecution> latest(String projectKey) {
        return Map.of();
    }

    @Override
    public Set<UUID> requirementsWithOpenBlockingDefect(String projectKey) {
        return Set.of();
    }

    @Override
    public List<DefectRef> defectsOf(String projectKey, UUID requirementId) {
        return List.of();
    }

    @Override
    public List<DefectRef> defectsWithoutRequirement(String projectKey) {
        return List.of();
    }

    @Override
    public List<CampaignRef> runningCampaignsWith(String projectKey, Collection<UUID> testIds) {
        return List.of();
    }
}
