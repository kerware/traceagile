package com.traceagile.application.reporting;

import com.traceagile.application.automation.AutomatedRunService;
import com.traceagile.application.campaign.CampaignRepository;
import com.traceagile.application.defect.DefectRepository;
import com.traceagile.application.exploratory.ExploratorySessionRepository;
import com.traceagile.application.planning.PlanningService;
import com.traceagile.application.reporting.ReportData.BurnPoint;
import com.traceagile.application.reporting.ReportData.Indicator;
import com.traceagile.application.reporting.ReportData.SprintTrendRow;
import com.traceagile.domain.automation.AutomatedRun;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignStatus;
import com.traceagile.domain.defect.Defect;
import com.traceagile.domain.defect.DefectSeverity;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.exploratory.ExploratorySession;
import com.traceagile.domain.planning.PlanningStatus;
import com.traceagile.domain.planning.Release;
import com.traceagile.domain.planning.Sprint;
import com.traceagile.domain.reporting.ReportScopeType;
import com.traceagile.domain.reporting.ReportSection;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** §9.1 tableau de bord du projet : widgets (F-RPT-01) et graphiques (F-RPT-02), en une requête (ADR-0023). */
@Service
@Transactional(readOnly = true)
public class DashboardService {

    private static final int LAST_RUNS = 10;

    private final PlanningService planning;
    private final ReportCalculator calculator;
    private final CampaignRepository campaigns;
    private final DefectRepository defects;
    private final ExploratorySessionRepository sessions;
    private final AutomatedRunService runs;
    private final Clock clock;

    public DashboardService(PlanningService planning, ReportCalculator calculator, CampaignRepository campaigns, DefectRepository defects,
                            ExploratorySessionRepository sessions, AutomatedRunService runs, Clock clock) {
        this.planning = planning;
        this.calculator = calculator;
        this.campaigns = campaigns;
        this.defects = defects;
        this.sessions = sessions;
        this.runs = runs;
        this.clock = clock;
    }

    public record Dashboard(ActiveSprint activeSprint, Coverage sprintCoverage, Coverage releaseCoverage, LastCampaign lastCampaign,
                            Map<String, Integer> openDefectsBySeverity, WeekSessions weekSessions, List<RunRow> lastRuns,
                            List<BurnPoint> burndown, String releaseKey, List<BurnPoint> burnup, List<RunRow> automatedTrend,
                            List<SprintTrendRow> defectsBySprint) {
    }

    public record ActiveSprint(String key, String name, String goal, String startDate, String endDate, long daysLeft, int donePoints,
                               int committedPoints) {
    }

    public record Coverage(String scope, Indicator design, Indicator validation) {
    }

    public record LastCampaign(String key, String name, String status, int total, Map<String, Integer> byStatus) {
    }

    public record WeekSessions(int sessions, long minutes, int debriefed, int awaitingApproval) {
    }

    /** Run automatisé : comptes et taux de réussite (tests exécutés). */
    public record RunRow(String key, String status, String campaignKey, String requestedAt, int total, int passed, int failed, Double passRate) {
    }

    public Dashboard dashboard(String projectKey, String login) {
        LocalDate today = LocalDate.now(clock);
        List<Sprint> sprints = planning.sprints(projectKey);
        Optional<Sprint> active = sprints.stream().filter(s -> s.getStatus() == PlanningStatus.ACTIVE).findFirst();

        ActiveSprint activeSprint = null;
        Coverage sprintCoverage = null;
        List<BurnPoint> burndown = List.of();
        if (active.isPresent()) {
            Sprint sprint = active.get();
            ReportCalculator.Computed c = calculator.compute(projectKey, ReportScopeType.SPRINT, sprint.getKey(),
                    List.of(ReportSection.DELIVERY, ReportSection.BURNDOWN, ReportSection.COVERAGE), login);
            activeSprint = new ActiveSprint(sprint.getKey(), sprint.getName(), sprint.getGoal(), sprint.getStartDate().toString(),
                    sprint.getEndDate().toString(), Math.max(0, ChronoUnit.DAYS.between(today, sprint.getEndDate())), c.data().delivery().donePoints(),
                    c.data().delivery().committedPoints());
            sprintCoverage = new Coverage(c.scope(), c.data().coverage().design(), c.data().coverage().validation());
            burndown = c.data().burndown().points();
        }

        Optional<Release> release = active.map(Sprint::getRelease)
                .or(() -> planning.releases(projectKey).stream().filter(r -> r.getStatus() != PlanningStatus.CLOSED).findFirst());
        Coverage releaseCoverage = null;
        List<BurnPoint> burnup = List.of();
        List<SprintTrendRow> bySprint = List.of();
        if (release.isPresent()) {
            ReportCalculator.Computed c = calculator.compute(projectKey, ReportScopeType.RELEASE, release.get().getKey(),
                    List.of(ReportSection.BURNDOWN, ReportSection.COVERAGE, ReportSection.SPRINT_TREND), login);
            releaseCoverage = new Coverage(c.scope(), c.data().coverage().design(), c.data().coverage().validation());
            burnup = c.data().burndown().points();
            bySprint = c.data().sprintTrend();
        }

        List<Campaign> all = campaigns.findByProject_KeyOrderByKeyNumberDesc(projectKey);
        LastCampaign lastCampaign = all.stream().filter(c -> c.getStatus() == CampaignStatus.IN_PROGRESS).findFirst()
                .or(() -> all.stream().findFirst())
                .map(DashboardService::lastCampaign).orElse(null);

        Map<String, Integer> openBySeverity = new LinkedHashMap<>();
        List<Defect> projectDefects = defects.findByProject_KeyOrderByKeyNumberDesc(projectKey);
        for (DefectSeverity severity : DefectSeverity.values()) {
            openBySeverity.put(severity.name(), (int) projectDefects.stream().filter(d -> d.getStatus().isOpen() && d.getSeverity() == severity).count());
        }

        Instant weekAgo = Instant.now(clock).minus(7, ChronoUnit.DAYS);
        List<ExploratorySession> week = sessions.findByExecution_Item_Campaign_Project_Key(projectKey).stream()
                .filter(s -> s.getStartedAt() != null && s.getStartedAt().isAfter(weekAgo)).toList();
        WeekSessions weekSessions = new WeekSessions(week.size(), week.stream().mapToLong(s -> s.getDurationMin() == null ? 0 : s.getDurationMin()).sum(),
                (int) week.stream().filter(s -> s.getProof() != null).count(),
                (int) week.stream().filter(s -> s.getProof() != null && s.getApprovedAt() == null).count());

        List<RunRow> lastRuns = runs.ofProject(projectKey).stream().sorted(Comparator.comparing(AutomatedRun::getRequestedAt).reversed())
                .limit(LAST_RUNS).map(this::runRow).toList();
        return new Dashboard(activeSprint, sprintCoverage, releaseCoverage, lastCampaign, openBySeverity, weekSessions,
                lastRuns.stream().limit(5).toList(), burndown, release.map(Release::getKey).orElse(null), burnup, lastRuns.reversed(), bySprint);
    }

    private static LastCampaign lastCampaign(Campaign campaign) {
        Map<String, Integer> byStatus = new LinkedHashMap<>();
        for (ExecutionStatus status : ExecutionStatus.values()) {
            int n = (int) campaign.getItems().stream().filter(i -> i.lastStatus() == status).count();
            if (n > 0) {
                byStatus.put(status.name(), n);
            }
        }
        return new LastCampaign(campaign.getKey(), campaign.getName(), campaign.getStatus().name(), campaign.getItems().size(), byStatus);
    }

    private RunRow runRow(AutomatedRun run) {
        List<Execution> executions = runs.executionsOf(run);
        int passed = (int) executions.stream().filter(e -> e.getStatus() == ExecutionStatus.PASSED).count();
        int failed = (int) executions.stream().filter(e -> e.getStatus() == ExecutionStatus.FAILED || e.getStatus() == ExecutionStatus.ERROR).count();
        int finished = passed + failed;
        return new RunRow(run.getKey(), run.getStatus().name(), run.getCampaign().getKey(), run.getRequestedAt().toString(), executions.size(),
                passed, failed, finished == 0 ? null : Math.round(passed * 1000.0 / finished) / 10.0);
    }
}
