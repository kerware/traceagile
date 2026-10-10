package com.traceagile.application.reporting;

import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.audit.AuditEventRepository;
import com.traceagile.application.audit.AuditService;
import com.traceagile.application.campaign.CampaignRepository;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.defect.DefectRepository;
import com.traceagile.application.exploratory.ExploratoryService;
import com.traceagile.application.exploratory.ExploratorySessionRepository;
import com.traceagile.application.planning.PlanningService;
import com.traceagile.application.reporting.ReportData.BurnChart;
import com.traceagile.application.reporting.ReportData.BurnPoint;
import com.traceagile.application.reporting.ReportData.CoverageSection;
import com.traceagile.application.reporting.ReportData.DayRow;
import com.traceagile.application.reporting.ReportData.BlockingDefect;
import com.traceagile.application.reporting.ReportData.DefectRow;
import com.traceagile.application.reporting.ReportData.DefectSection;
import com.traceagile.application.reporting.ReportData.Delivery;
import com.traceagile.application.reporting.ReportData.ExecutionSection;
import com.traceagile.application.reporting.ReportData.ExploratorySection;
import com.traceagile.application.reporting.ReportData.Finding;
import com.traceagile.application.reporting.ReportData.Header;
import com.traceagile.application.reporting.ReportData.Indicator;
import com.traceagile.application.reporting.ReportData.KindRow;
import com.traceagile.application.reporting.ReportData.NfrRow;
import com.traceagile.application.reporting.ReportData.Recommendation;
import com.traceagile.application.reporting.ReportData.RegressionSection;
import com.traceagile.application.reporting.ReportData.UnmetRequirement;
import com.traceagile.application.reporting.ReportData.RequirementRow;
import com.traceagile.application.reporting.ReportData.RiskItem;
import com.traceagile.application.reporting.ReportData.SprintTrendRow;
import com.traceagile.application.reporting.ReportData.StoryRow;
import com.traceagile.application.reporting.ReportData.Summary;
import com.traceagile.application.reporting.ReportData.FlakyTest;
import com.traceagile.application.reporting.ReportData.TestResultRow;
import com.traceagile.application.requirement.RequirementRepository;
import com.traceagile.application.traceability.TraceabilityService;
import com.traceagile.application.traceability.TraceabilityService.CoverageReport;
import com.traceagile.application.traceability.TraceabilityService.RequirementCoverage;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.audit.AuditEvent;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.campaign.CampaignScope;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.common.FieldChange;
import com.traceagile.domain.defect.Defect;
import com.traceagile.domain.defect.DefectSeverity;
import com.traceagile.domain.defect.DefectStatus;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.exploratory.ExploratoryMetrics;
import com.traceagile.domain.exploratory.ExploratorySession;
import com.traceagile.domain.planning.Release;
import com.traceagile.domain.planning.ScopeOutcome;
import com.traceagile.domain.planning.Sprint;
import com.traceagile.domain.planning.SprintScopeItem;
import com.traceagile.domain.reporting.Burndown;
import com.traceagile.domain.reporting.ReportScopeType;
import com.traceagile.domain.reporting.ReportSection;
import com.traceagile.domain.reporting.VerdictRules;
import com.traceagile.domain.requirement.Planguage;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.domain.requirement.RiskLevel;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.traceability.CoverageCalculator;
import com.traceagile.domain.traceability.VerificationStatus;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.UUID;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §9.2 / §9.3 / ADR-0023 calcul des sections d'un rapport sur un périmètre (sprint, release, projet).
 * Seules les sections demandées (et applicables au périmètre) sont calculées.
 */
@Service
public class ReportCalculator {

    private static final Set<RequirementStatus> DONE = EnumSet.of(RequirementStatus.DONE, RequirementStatus.ACCEPTED);
    private static final int MAX_FINDINGS = 10;

    private final ProjectRepository projects;
    private final PlanningService planning;
    private final TraceabilityService traceability;
    private final CampaignRepository campaigns;
    private final ExploratoryService exploratory;
    private final ExploratorySessionRepository sessions;
    private final DefectRepository defects;
    private final RequirementRepository requirements;
    private final AuditEventRepository audit;
    private final Clock clock;

    public ReportCalculator(ProjectRepository projects, PlanningService planning, TraceabilityService traceability, CampaignRepository campaigns,
                            ExploratoryService exploratory, ExploratorySessionRepository sessions, DefectRepository defects,
                            RequirementRepository requirements, AuditEventRepository audit, Clock clock) {
        this.projects = projects;
        this.planning = planning;
        this.traceability = traceability;
        this.campaigns = campaigns;
        this.exploratory = exploratory;
        this.sessions = sessions;
        this.defects = defects;
        this.requirements = requirements;
        this.audit = audit;
        this.clock = clock;
    }

    /** Résultat : données, verdict calculé (§9.2) et libellé du périmètre. */
    public record Computed(ReportData data, VerdictRules.Evaluation evaluation, String scope, String scopeLabel) {
    }

    /** Périmètre résolu : sprints concernés, campagnes et exigences « dans le périmètre » (§7.2). */
    private record Scope(ReportScopeType type, String value, String label, String goal, LocalDate start, LocalDate end, String status,
                         List<Sprint> sprints, Release release, Predicate<Campaign> campaigns) {
    }

    @Transactional(readOnly = true)
    public Computed compute(String projectKey, ReportScopeType type, String key, List<ReportSection> sections, String login) {
        Project project = projects.findByKey(projectKey)
                .orElseThrow(() -> new NotFoundException("PROJECT_NOT_FOUND", "Projet « " + projectKey + " » introuvable."));
        Scope scope = resolve(projectKey, type, key);
        Set<ReportSection> wanted = sections.stream().filter(s -> s.appliesTo(type)).collect(Collectors.toCollection(() -> EnumSet.noneOf(ReportSection.class)));

        CoverageReport coverage = traceability.coverage(projectKey, scope.value());
        List<Campaign> scopedCampaigns = campaigns.findByProject_KeyOrderByKeyNumberDesc(projectKey).stream().filter(scope.campaigns()).toList();
        List<Defect> scopedDefects = defectsOf(projectKey, coverage, scopedCampaigns, type);
        List<RiskItem> risks = risks(coverage);
        VerdictRules.Evaluation evaluation = project.getVerdictRules().evaluate(new VerdictRules.Facts(coverage.coverage().validation().percent(),
                count(scopedDefects, DefectSeverity.BLOCKER), count(scopedDefects, DefectSeverity.CRITICAL),
                (int) risks.stream().filter(r -> r.risk().equals(RiskLevel.CRITICAL.name())).count()));
        Delivery delivery = wanted.contains(ReportSection.DELIVERY) || wanted.contains(ReportSection.SUMMARY) ? delivery(scope) : null;

        Header header = new Header(project.getKey(), project.getName(), scope.value(), scope.label(), scope.goal(), text(scope.start()),
                text(scope.end()), scope.status(), Instant.now(clock).toString(), login);
        int openDefects = (int) scopedDefects.stream().filter(d -> d.getStatus().isOpen()).count();
        ReportData data = new ReportData(header,
                wanted.contains(ReportSection.SUMMARY) ? new Summary(scope.goal(), evaluation.verdict().objective().name(), evaluation.verdict().name(),
                        coverage.coverage().validation().percent(), delivery.donePoints(), openDefects,
                        count(scopedDefects, DefectSeverity.BLOCKER) + count(scopedDefects, DefectSeverity.CRITICAL)) : null,
                wanted.contains(ReportSection.DELIVERY) ? delivery : null,
                wanted.contains(ReportSection.BURNDOWN) ? burnChart(scope) : null,
                wanted.contains(ReportSection.COVERAGE) ? coverageSection(coverage) : null,
                wanted.contains(ReportSection.EXECUTION) ? execution(scopedCampaigns) : null,
                wanted.contains(ReportSection.EXPLORATORY) ? exploratorySection(projectKey, scope) : null,
                wanted.contains(ReportSection.DEFECTS) ? defectSection(scopedDefects) : null,
                wanted.contains(ReportSection.RISKS) ? risks : null,
                wanted.contains(ReportSection.SPRINT_TREND) ? sprintTrend(projectKey, scope) : null,
                wanted.contains(ReportSection.REGRESSION) ? regression(projectKey, scope) : null,
                wanted.contains(ReportSection.NFR) ? nfr(projectKey, coverage) : null,
                wanted.contains(ReportSection.REQUIREMENTS) ? requirementRows(coverage) : null,
                wanted.contains(ReportSection.DEFECT_LIST) ? scopedDefects.stream().map(ReportCalculator::defectRow).toList() : null,
                wanted.contains(ReportSection.TEST_RESULTS) ? testResults(scopedCampaigns) : null,
                wanted.contains(ReportSection.RECOMMENDATION) ? new Recommendation(evaluation.verdict().name(), evaluation.reasons()) : null);
        return new Computed(data, evaluation, scope.value(), scope.label());
    }

    // ---------------------------------------------------------------- périmètre

    private Scope resolve(String projectKey, ReportScopeType type, String key) {
        return switch (type) {
            case SPRINT -> {
                Sprint sprint = planning.sprint(projectKey, required(key, "sprint"));
                yield new Scope(type, type.scope(sprint.getKey()), sprint.getKey() + " — " + sprint.getName(), sprint.getGoal(),
                        sprint.getStartDate(), sprint.getEndDate(), sprint.getStatus().name(), List.of(sprint), null,
                        TraceabilityService.executionScope(type.scope(sprint.getKey())));
            }
            case RELEASE -> {
                Release release = planning.release(projectKey, required(key, "release"));
                List<Sprint> sprints = release.getSprints().stream().sorted(Comparator.comparing(Sprint::getStartDate)).toList();
                yield new Scope(type, type.scope(release.getKey()), release.getKey() + " — " + release.getName(), release.getGoal(),
                        release.getStartDate(), release.getEndDate(), release.getStatus().name(), sprints, release,
                        TraceabilityService.executionScope(type.scope(release.getKey())));
            }
            case PROJECT -> {
                Project project = projects.findByKey(projectKey).orElseThrow();
                List<Sprint> sprints = planning.sprints(projectKey).stream().sorted(Comparator.comparing(Sprint::getStartDate)).toList();
                yield new Scope(type, "project", project.getKey() + " — " + project.getName(), project.getDescription(), null, null, null,
                        sprints, null, c -> true);
            }
        };
    }

    private static String required(String key, String what) {
        if (key == null || key.isBlank()) {
            throw new BusinessRuleException("REPORT_SCOPE_KEY_REQUIRED", "Choisissez le " + what + " du rapport.");
        }
        return key;
    }

    // ---------------------------------------------------------------- §9.2-2 livraison, burndown

    private Delivery delivery(Scope scope) {
        List<StoryRow> stories = new ArrayList<>();
        int committedPoints = 0;
        int donePoints = 0;
        int done = 0;
        int accepted = 0;
        Map<ScopeOutcome, Integer> outcomes = new HashMap<>();
        for (Sprint sprint : scope.sprints()) {
            for (SprintScopeItem item : sprint.getScope()) {
                Requirement requirement = item.getRequirement();
                int points = points(item);
                committedPoints += points;
                boolean finished = item.getOutcome() == ScopeOutcome.DONE || (item.getOutcome() == ScopeOutcome.PLANNED && DONE.contains(requirement.getStatus()));
                if (finished) {
                    done++;
                    donePoints += points;
                }
                if (requirement.getStatus() == RequirementStatus.ACCEPTED) {
                    accepted++;
                }
                outcomes.merge(item.getOutcome(), 1, Integer::sum);
                stories.add(new StoryRow(requirement.getKey(), requirement.getTitle(), points, requirement.getStatus().name(),
                        item.getOutcome().name(), sprint.getKey()));
            }
        }
        return new Delivery(stories.size(), committedPoints, done, donePoints, accepted, outcomes.getOrDefault(ScopeOutcome.CARRIED_OVER, 0),
                outcomes.getOrDefault(ScopeOutcome.RETURNED, 0), outcomes.getOrDefault(ScopeOutcome.DROPPED, 0), stories);
    }

    private static int points(SprintScopeItem item) {
        Integer points = item.getCommittedPoints() != null ? item.getCommittedPoints() : item.getRequirement().getStoryPoints();
        return points == null ? 0 : points;
    }

    /** F-RPT-02 burndown d'un sprint (jours) ou burnup d'une release (sprints). */
    private BurnChart burnChart(Scope scope) {
        if (scope.type() == ReportScopeType.SPRINT) {
            Sprint sprint = scope.sprints().getFirst();
            int committed = sprint.getScope().stream().mapToInt(ReportCalculator::points).sum();
            List<Burndown.Day> days = Burndown.of(sprint.getStartDate(), sprint.getEndDate(), LocalDate.now(clock), committed, doneDates(sprint));
            return new BurnChart("BURNDOWN", days.stream()
                    .map(d -> new BurnPoint(d.date().toString(), d.remaining() == null ? null : d.remaining().doubleValue(), d.ideal())).toList());
        }
        int total = scope.sprints().stream().flatMap(s -> s.getScope().stream()).mapToInt(ReportCalculator::points).sum();
        List<BurnPoint> points = new ArrayList<>();
        double cumulated = 0;
        for (Sprint sprint : scope.sprints()) {
            cumulated += delivery(new Scope(ReportScopeType.SPRINT, null, null, null, null, null, null, List.of(sprint), null, c -> false)).donePoints();
            points.add(new BurnPoint(sprint.getKey(), sprint.getStatus().name().equals("PLANNED") ? null : cumulated, (double) total));
        }
        return new BurnChart("BURNUP", points);
    }

    /** Points terminés par jour : dernier passage de chaque story à DONE / ACCEPTED (journal d'audit). */
    public Map<LocalDate, Integer> doneDates(Sprint sprint) {
        Map<UUID, SprintScopeItem> byRequirement = sprint.getScope().stream()
                .filter(i -> i.getOutcome() == ScopeOutcome.DONE || DONE.contains(i.getRequirement().getStatus()))
                .collect(Collectors.toMap(i -> i.getRequirement().getId(), i -> i, (a, b) -> a, LinkedHashMap::new));
        Map<UUID, LocalDate> doneOn = new HashMap<>();
        if (!byRequirement.isEmpty()) {
            for (AuditEvent event : audit.findByEntityTypeAndEntityIdInOrderByCreatedAtAsc(AuditService.REQUIREMENT, byRequirement.keySet())) {
                for (FieldChange change : event.getDiff()) {
                    if (change.field().equals("status") && change.after() != null && isDone(change.after().toString())
                            && (change.before() == null || !isDone(change.before().toString()))) {
                        doneOn.put(event.getEntityId(), LocalDate.ofInstant(event.getTimestamp(), ZoneOffset.UTC));
                    }
                }
            }
        }
        Map<LocalDate, Integer> result = new TreeMap<>();
        byRequirement.forEach((id, item) -> result.merge(doneOn.getOrDefault(id, sprint.getStartDate()), points(item), Integer::sum));
        return result;
    }

    private static boolean isDone(String status) {
        return status.equals(RequirementStatus.DONE.name()) || status.equals(RequirementStatus.ACCEPTED.name());
    }

    // ---------------------------------------------------------------- §9.2-3 couverture, §9.2-7 risques

    private static CoverageSection coverageSection(CoverageReport report) {
        CoverageCalculator.Coverage c = report.coverage();
        return new CoverageSection(indicator(c.design()), indicator(c.criteria()), indicator(c.execution()), indicator(c.validation()),
                indicator(c.riskWeighted()),
                report.requirements().stream().filter(RequirementCoverage::leaf).filter(r -> r.status() == VerificationStatus.NOT_COVERED)
                        .map(ReportCalculator::ref).toList(),
                report.requirements().stream().filter(r -> r.status() == VerificationStatus.FAILED || r.status() == VerificationStatus.BLOCKED)
                        .map(ReportCalculator::ref).toList());
    }

    private static Indicator indicator(CoverageCalculator.Indicator i) {
        return new Indicator(i.numerator(), i.denominator(), i.percent());
    }

    private static UnmetRequirement ref(RequirementCoverage r) {
        return new UnmetRequirement(r.requirement().getKey(), r.requirement().getTitle(), r.status().name());
    }

    private static List<RiskItem> risks(CoverageReport report) {
        return report.requirements().stream()
                .filter(r -> r.requirement().getRiskLevel() == RiskLevel.HIGH || r.requirement().getRiskLevel() == RiskLevel.CRITICAL)
                .filter(r -> r.status() != VerificationStatus.VALIDATED)
                .sorted(Comparator.comparing((RequirementCoverage r) -> r.requirement().getRiskLevel()).reversed())
                .map(r -> new RiskItem(r.requirement().getKey(), r.requirement().getTitle(), r.requirement().getRiskLevel().name(), r.status().name()))
                .toList();
    }

    private static List<RequirementRow> requirementRows(CoverageReport report) {
        return report.requirements().stream().map(r -> new RequirementRow(r.requirement().getKey(), r.requirement().getTitle(),
                r.requirement().getType().name(), r.requirement().getRiskLevel() == null ? null : r.requirement().getRiskLevel().name(),
                r.coveringTests(), r.executedTests(), r.passedTests(), r.status().name())).toList();
    }

    // ---------------------------------------------------------------- §9.2-4 exécution

    private static ExecutionSection execution(List<Campaign> scoped) {
        List<CampaignItem> items = scoped.stream().flatMap(c -> c.getItems().stream()).toList();
        Map<String, Integer> byStatus = new LinkedHashMap<>();
        for (ExecutionStatus status : ExecutionStatus.values()) {
            int n = (int) items.stream().filter(i -> i.lastStatus() == status).count();
            if (n > 0) {
                byStatus.put(status.name(), n);
            }
        }
        List<KindRow> byKind = new ArrayList<>();
        for (TestKind kind : TestKind.values()) {
            List<CampaignItem> ofKind = items.stream().filter(i -> i.getTestCase().getKind() == kind).toList();
            if (ofKind.isEmpty()) {
                continue;
            }
            int passed = countStatus(ofKind, EnumSet.of(ExecutionStatus.PASSED));
            int failed = countStatus(ofKind, EnumSet.of(ExecutionStatus.FAILED, ExecutionStatus.ERROR));
            int notRun = countStatus(ofKind, EnumSet.of(ExecutionStatus.NOT_RUN));
            byKind.add(new KindRow(kind.name(), ofKind.size(), passed, failed, notRun, ofKind.size() - passed - failed - notRun));
        }
        List<Execution> attempts = items.stream().flatMap(i -> i.getExecutions().stream()).filter(e -> e.getStartedAt() != null).toList();
        Map<LocalDate, List<Execution>> byDay = attempts.stream()
                .collect(Collectors.groupingBy(e -> LocalDate.ofInstant(e.getStartedAt(), ZoneOffset.UTC), TreeMap::new, Collectors.toList()));
        List<DayRow> days = byDay.entrySet().stream().map(e -> new DayRow(e.getKey().toString(), e.getValue().size(),
                (int) e.getValue().stream().filter(x -> x.getStatus() == ExecutionStatus.PASSED).count(),
                (int) e.getValue().stream().filter(x -> x.getStatus() == ExecutionStatus.FAILED || x.getStatus() == ExecutionStatus.ERROR).count()))
                .toList();
        List<FlakyTest> flaky = items.stream().map(CampaignItem::getTestCase).filter(TestCase::isFlaky).distinct()
                .sorted(Comparator.comparingInt(TestCase::getKeyNumber)).map(t -> new FlakyTest(t.getKey(), t.getTitle())).toList();
        return new ExecutionSection(items.size(), attempts.size(), byStatus, byKind, days, flaky);
    }

    private static int countStatus(Collection<CampaignItem> items, Set<ExecutionStatus> statuses) {
        return (int) items.stream().filter(i -> statuses.contains(i.lastStatus())).count();
    }

    private static List<TestResultRow> testResults(List<Campaign> scoped) {
        List<TestResultRow> rows = new ArrayList<>();
        for (Campaign campaign : scoped.reversed()) {
            for (CampaignItem item : campaign.getItems()) {
                Execution last = item.getExecutions().stream().max(Comparator.comparingInt(Execution::getAttempt)).orElse(null);
                rows.add(new TestResultRow(campaign.getKey(), item.getTestCase().getKey(), item.getTestCase().getTitle(),
                        item.getTestCase().getKind().name(), item.lastStatus().name(), last == null ? null : last.getExecutedBy(),
                        last == null || last.getStartedAt() == null ? null : LocalDate.ofInstant(last.getStartedAt(), ZoneOffset.UTC).toString()));
            }
        }
        return rows;
    }

    // ---------------------------------------------------------------- §9.2-5 exploratoire

    private ExploratorySection exploratorySection(String projectKey, Scope scope) {
        ExploratoryMetrics m = exploratory.metrics(projectKey, scope.value());
        List<Finding> findings = sessions.findByExecution_Item_Campaign_Project_Key(projectKey).stream()
                .filter(s -> scope.campaigns().test(s.getExecution().getItem().getCampaign()))
                .filter(s -> s.getProof() != null)
                .sorted(Comparator.comparing(ExploratorySession::getStartedAt).reversed())
                .limit(MAX_FINDINGS)
                .map(s -> new Finding(s.getExecution().getTestCase().getTitle(), s.getTester(), s.getProof().results(), s.getProof().obstacles()))
                .toList();
        return new ExploratorySection(m.sessions(), m.debriefed(), m.totalMinutes(), m.averageMinutes(),
                m.averageTbs() == null ? null : m.averageTbs().testPct(), m.averageTbs() == null ? null : m.averageTbs().bugPct(),
                m.averageTbs() == null ? null : m.averageTbs().setupPct(), m.defectsPerHour(), m.chartersPlanned(), m.chartersExecuted(),
                m.averageConfidence(), m.neverExploredAreas(), findings);
    }

    // ---------------------------------------------------------------- §9.2-6 anomalies

    /** Anomalies du périmètre : liées à une exigence du périmètre ou trouvées dans une de ses campagnes. */
    private List<Defect> defectsOf(String projectKey, CoverageReport coverage, List<Campaign> scoped, ReportScopeType type) {
        List<Defect> all = defects.findByProject_KeyOrderByKeyNumberDesc(projectKey);
        if (type == ReportScopeType.PROJECT) {
            return all;
        }
        Set<UUID> requirementIds = coverage.requirements().stream().map(r -> r.requirement().getId()).collect(Collectors.toSet());
        Set<UUID> campaignIds = scoped.stream().map(Campaign::getId).collect(Collectors.toSet());
        return all.stream().filter(d -> d.getRequirements().stream().anyMatch(r -> requirementIds.contains(r.getId()))
                || d.getExecutions().stream().anyMatch(e -> campaignIds.contains(e.getItem().getCampaign().getId()))).toList();
    }

    private static int count(List<Defect> defects, DefectSeverity severity) {
        return (int) defects.stream().filter(d -> d.getStatus().isOpen() && d.getSeverity() == severity).count();
    }

    private static DefectSection defectSection(List<Defect> scoped) {
        Map<String, Integer> openBySeverity = new LinkedHashMap<>();
        for (DefectSeverity severity : DefectSeverity.values()) {
            openBySeverity.put(severity.name(), count(scoped, severity));
        }
        List<BlockingDefect> blocking = scoped.stream().filter(d -> d.getStatus().isOpen())
                .filter(d -> d.getSeverity() == DefectSeverity.BLOCKER || d.getSeverity() == DefectSeverity.CRITICAL)
                .map(d -> new BlockingDefect(d.getKey(), d.getTitle(), d.getSeverity().name(), d.getStatus().name())).toList();
        int resolved = (int) scoped.stream().filter(d -> d.getStatus() == DefectStatus.RESOLVED || d.getStatus() == DefectStatus.CLOSED).count();
        int open = (int) scoped.stream().filter(d -> d.getStatus().isOpen()).count();
        return new DefectSection(scoped.size(), resolved, open, openBySeverity, blocking);
    }

    private static DefectRow defectRow(Defect d) {
        return new DefectRow(d.getKey(), d.getTitle(), d.getSeverity().name(), d.getStatus().name(),
                d.getRequirements().stream().map(Requirement::getKey).sorted().collect(Collectors.joining(", ")),
                LocalDate.ofInstant(d.getCreatedAt(), ZoneOffset.UTC).toString());
    }

    // ---------------------------------------------------------------- §9.3 release

    private List<SprintTrendRow> sprintTrend(String projectKey, Scope scope) {
        Map<String, CoverageCalculator.Coverage> bySprint = traceability.coverageBySprint(projectKey);
        List<Defect> all = defects.findByProject_KeyOrderByKeyNumberDesc(projectKey);
        List<SprintTrendRow> rows = new ArrayList<>();
        for (Sprint sprint : scope.sprints()) {
            Delivery d = delivery(new Scope(ReportScopeType.SPRINT, null, null, null, null, null, null, List.of(sprint), null, c -> false));
            CoverageCalculator.Coverage coverage = bySprint.get(sprint.getKey());
            LocalDate start = sprint.getStartDate();
            LocalDate end = sprint.getEndDate();
            int created = (int) all.stream().filter(x -> within(x.getCreatedAt(), start, end)).count();
            int closed = (int) all.stream().filter(x -> x.getStatus() == DefectStatus.RESOLVED || x.getStatus() == DefectStatus.CLOSED)
                    .filter(x -> within(x.getUpdatedAt(), start, end)).count();
            rows.add(new SprintTrendRow(sprint.getKey(), sprint.getName(), sprint.getStatus().name(), d.committedPoints(), d.donePoints(),
                    coverage == null ? null : coverage.validation().percent(), created, closed));
        }
        return rows;
    }

    private static boolean within(Instant instant, LocalDate start, LocalDate end) {
        if (instant == null) {
            return false;
        }
        LocalDate date = LocalDate.ofInstant(instant, ZoneOffset.UTC);
        return !date.isBefore(start) && !date.isAfter(end);
    }

    /** Dernière campagne de régression de la release (ou planifiée dans ses dates). */
    private RegressionSection regression(String projectKey, Scope scope) {
        Release release = scope.release();
        return campaigns.findByProject_KeyOrderByKeyNumberDesc(projectKey).stream()
                .filter(c -> c.getScopeType() == CampaignScope.REGRESSION)
                .filter(c -> (c.getRelease() != null && c.getRelease().getId().equals(release.getId()))
                        || (c.getRelease() == null && c.getPlannedEnd() != null && !c.getPlannedEnd().isBefore(release.getStartDate())
                        && !c.getPlannedEnd().isAfter(release.getEndDate().plusDays(7))))
                .findFirst()
                .map(c -> {
                    List<CampaignItem> items = c.getItems();
                    int passed = countStatus(items, EnumSet.of(ExecutionStatus.PASSED));
                    int failed = countStatus(items, EnumSet.of(ExecutionStatus.FAILED, ExecutionStatus.ERROR));
                    int notRun = countStatus(items, EnumSet.of(ExecutionStatus.NOT_RUN));
                    int executed = items.size() - notRun;
                    return new RegressionSection(c.getKey(), c.getName(), c.getStatus().name(), items.size(), passed, failed, notRun,
                            executed == 0 ? null : Math.round(passed * 1000.0 / executed) / 10.0);
                })
                .orElse(null);
    }

    /** §9.3 ENF du périmètre et ENF transverses du projet. */
    private List<NfrRow> nfr(String projectKey, CoverageReport coverage) {
        Map<UUID, VerificationStatus> statuses = traceability.statuses(projectKey);
        Map<UUID, Requirement> nfrs = new LinkedHashMap<>();
        coverage.requirements().stream().map(RequirementCoverage::requirement).filter(r -> r.getType() == RequirementType.NON_FUNCTIONAL)
                .forEach(r -> nfrs.put(r.getId(), r));
        requirements.findByProject_KeyAndTypeAndTransverseTrue(projectKey, RequirementType.NON_FUNCTIONAL).forEach(r -> nfrs.putIfAbsent(r.getId(), r));
        return nfrs.values().stream().sorted(Comparator.comparingInt(Requirement::getKeyNumber)).map(r -> {
            Planguage p = r.getPlanguage() == null ? Planguage.EMPTY : r.getPlanguage();
            String unit = p.unit() == null ? "" : " " + p.unit();
            VerificationStatus status = statuses.get(r.getId());
            return new NfrRow(r.getKey(), r.getTitle(), r.getCategory() == null ? null : r.getCategory().name(),
                    p.minimumThreshold() == null ? null : p.minimumThreshold() + unit, p.target() == null ? null : p.target() + unit, null,
                    status == null ? null : status.name());
        }).toList();
    }

    // ---------------------------------------------------------------- outils

    private static String text(LocalDate date) {
        return date == null ? null : date.toString();
    }
}
