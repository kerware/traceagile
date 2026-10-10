package com.traceagile.application.execution;

import com.traceagile.application.campaign.CampaignRepository;
import com.traceagile.application.defect.DefectRepository;
import com.traceagile.application.traceability.ExecutionResults;
import com.traceagile.domain.campaign.CampaignStatus;
import com.traceagile.domain.defect.Defect;
import com.traceagile.domain.execution.Execution;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Predicate;
import com.traceagile.domain.campaign.Campaign;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Lot 5 : faits d'exécution de la traçabilité (ADR-0014, ADR-0016). Dernier résultat final de chaque
 * test, toutes campagnes du projet confondues ; anomalies ; campagnes en cours.
 */
@Component
@Transactional(readOnly = true)
public class CampaignExecutionResults implements ExecutionResults {

    private final ExecutionRepository executions;
    private final DefectRepository defects;
    private final CampaignRepository campaigns;

    public CampaignExecutionResults(ExecutionRepository executions, DefectRepository defects, CampaignRepository campaigns) {
        this.executions = executions;
        this.defects = defects;
        this.campaigns = campaigns;
    }

    @Override
    public Map<UUID, LastExecution> latest(String projectKey) {
        return latestIn(projectKey, campaign -> true);
    }

    @Override
    public Map<UUID, LastExecution> latestOf(Collection<UUID> testIds) {
        Map<UUID, LastExecution> latest = new HashMap<>();
        if (testIds.isEmpty()) {
            return latest;
        }
        // tri décroissant : la première exécution finie rencontrée pour un test est la dernière
        for (Execution execution : executions.findByTestCase_IdInOrderByStartedAtDesc(testIds)) {
            if (execution.isFinal()) {
                latest.putIfAbsent(execution.getTestCase().getId(), new LastExecution(execution.getStatus(),
                        execution.getEndedAt() == null ? execution.getStartedAt() : execution.getEndedAt()));
            }
        }
        return latest;
    }

    @Override
    public Map<UUID, LastExecution> latestIn(String projectKey, Predicate<Campaign> campaigns) {
        Map<UUID, LastExecution> latest = new HashMap<>();
        for (Execution execution : executions.findByTestCase_Project_KeyOrderByStartedAtAsc(projectKey)) {
            if (execution.isFinal() && campaigns.test(execution.getItem().getCampaign())) {
                latest.put(execution.getTestCase().getId(), new LastExecution(execution.getStatus(),
                        execution.getEndedAt() == null ? execution.getStartedAt() : execution.getEndedAt()));
            }
        }
        return latest;
    }

    @Override
    public Set<UUID> requirementsWithOpenBlockingDefect(String projectKey) {
        return defects.findByProject_KeyOrderByKeyNumberDesc(projectKey).stream().filter(Defect::isOpenBlocking)
                .flatMap(d -> d.getRequirements().stream()).map(r -> r.getId()).collect(Collectors.toSet());
    }

    @Override
    public List<DefectRef> defectsOf(String projectKey, UUID requirementId) {
        return defects.findByRequirements_IdOrderByKeyNumberDesc(requirementId).stream().map(CampaignExecutionResults::ref).toList();
    }

    @Override
    public List<DefectRef> defectsWithoutRequirement(String projectKey) {
        return defects.findByProject_KeyOrderByKeyNumberDesc(projectKey).stream()
                .filter(d -> d.getRequirements().isEmpty() && d.getStatus().isOpen())
                .map(CampaignExecutionResults::ref).toList();
    }

    @Override
    public List<CampaignRef> runningCampaignsWith(String projectKey, Collection<UUID> testIds) {
        return campaigns.findByProject_KeyAndStatusIn(projectKey, Set.of(CampaignStatus.PLANNED, CampaignStatus.IN_PROGRESS)).stream()
                .filter(c -> c.getItems().stream().anyMatch(i -> testIds.contains(i.getTestCase().getId())))
                .map(c -> new CampaignRef(c.getKey(), c.getName(), c.getStatus().name())).toList();
    }

    private static DefectRef ref(Defect defect) {
        return new DefectRef(defect.getKey(), defect.getTitle(), defect.getSeverity().name(), defect.getStatus().name());
    }
}
