package com.traceagile.application.traceability;

import com.traceagile.domain.execution.ExecutionStatus;
import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Predicate;
import com.traceagile.domain.campaign.Campaign;

/**
 * Port des faits d'exécution utilisés par la traçabilité (§7.2, §7.3, F-TRA-05 à F-TRA-07). Les
 * exécutions, anomalies et campagnes viennent du lot 5 (adaptateur {@code CampaignExecutionResults}).
 */
public interface ExecutionResults {

    /** Dernière exécution de chaque test du projet ; un test absent n'a jamais été exécuté. */
    Map<UUID, LastExecution> latest(String projectKey);

    /** §7.2 dernière exécution de chaque test dans les campagnes du périmètre (sprint, release). */
    Map<UUID, LastExecution> latestIn(String projectKey, Predicate<Campaign> campaigns);

    /** Exigences liées à une anomalie BLOCKER ou CRITICAL ouverte. */
    Set<UUID> requirementsWithOpenBlockingDefect(String projectKey);

    /** Anomalies ouvertes liées à une exigence (arbre de traçabilité). */
    List<DefectRef> defectsOf(String projectKey, UUID requirementId);

    /** F-TRA-06 anomalies sans exigence. */
    List<DefectRef> defectsWithoutRequirement(String projectKey);

    /** F-TRA-07 campagnes en cours contenant l'un de ces tests. */
    List<CampaignRef> runningCampaignsWith(String projectKey, Collection<UUID> testIds);

    record LastExecution(ExecutionStatus status, Instant executedAt) {
    }

    record DefectRef(String key, String title, String severity, String status) {
    }

    record CampaignRef(String key, String name, String status) {
    }
}
