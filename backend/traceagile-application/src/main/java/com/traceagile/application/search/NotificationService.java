package com.traceagile.application.search;

import com.traceagile.application.automation.AutomatedRunService;
import com.traceagile.application.campaign.CampaignRepository;
import com.traceagile.application.defect.DefectRepository;
import com.traceagile.application.exploratory.ExploratorySessionRepository;
import com.traceagile.application.planning.PlanningService;
import com.traceagile.domain.automation.AutomatedRun;
import com.traceagile.domain.automation.RunStatus;
import com.traceagile.domain.campaign.CampaignStatus;
import com.traceagile.domain.defect.DefectSeverity;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.planning.PlanningStatus;
import java.time.Clock;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.EnumSet;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §13.1 barre supérieure : sprint actif et notifications calculées à la demande, sans stockage ni
 * envoi (ADR-0024).
 */
@Service
@Transactional(readOnly = true)
public class NotificationService {

    private final PlanningService planning;
    private final CampaignRepository campaigns;
    private final ExploratorySessionRepository sessions;
    private final DefectRepository defects;
    private final AutomatedRunService runs;
    private final Clock clock;

    public NotificationService(PlanningService planning, CampaignRepository campaigns, ExploratorySessionRepository sessions, DefectRepository defects,
                               AutomatedRunService runs, Clock clock) {
        this.planning = planning;
        this.campaigns = campaigns;
        this.sessions = sessions;
        this.defects = defects;
        this.runs = runs;
        this.clock = clock;
    }

    /**
     * @param myTests           tests qui me sont affectés, pas encore exécutés, dans une campagne ouverte
     * @param sessionsToApprove sessions débriefées en attente d'approbation (le PO les approuve)
     * @param blockingDefects   anomalies BLOCKER ou CRITICAL ouvertes
     * @param failedRuns        runs en échec (ou avec des tests en échec) depuis 24 h
     */
    public record Notifications(String activeSprintKey, String activeSprintName, int myTests, int sessionsToApprove, int blockingDefects,
                                int failedRuns) {
    }

    public Notifications of(String projectKey, String login) {
        var active = planning.sprints(projectKey).stream().filter(s -> s.getStatus() == PlanningStatus.ACTIVE).findFirst();
        int myTests = (int) campaigns.findByProject_KeyAndStatusIn(projectKey, EnumSet.of(CampaignStatus.PLANNED, CampaignStatus.IN_PROGRESS)).stream()
                .flatMap(c -> c.getItems().stream())
                .filter(i -> i.getAssignee() != null && i.getAssignee().getLogin().equals(login) && i.lastStatus() == ExecutionStatus.NOT_RUN)
                .count();
        int toApprove = (int) sessions.findByExecution_Item_Campaign_Project_Key(projectKey).stream()
                .filter(s -> s.getProof() != null && s.getApprovedAt() == null).count();
        int blocking = (int) defects.findByProject_KeyOrderByKeyNumberDesc(projectKey).stream()
                .filter(d -> d.getStatus().isOpen() && (d.getSeverity() == DefectSeverity.BLOCKER || d.getSeverity() == DefectSeverity.CRITICAL))
                .count();
        Instant since = Instant.now(clock).minus(24, ChronoUnit.HOURS);
        int failedRuns = (int) runs.ofProject(projectKey).stream().filter(r -> r.getRequestedAt().isAfter(since)).filter(this::failed).count();
        return new Notifications(active.map(s -> s.getKey()).orElse(null), active.map(s -> s.getName()).orElse(null), myTests, toApprove, blocking,
                failedRuns);
    }

    private boolean failed(AutomatedRun run) {
        return run.getStatus() == RunStatus.FAILED || run.getStatus() == RunStatus.TIMEOUT
                || runs.executionsOf(run).stream().anyMatch(e -> e.getStatus() == ExecutionStatus.FAILED || e.getStatus() == ExecutionStatus.ERROR);
    }
}
