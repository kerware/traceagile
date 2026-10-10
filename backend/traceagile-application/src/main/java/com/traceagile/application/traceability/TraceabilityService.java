package com.traceagile.application.traceability;

import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.planning.ReleaseRepository;
import com.traceagile.application.planning.SprintRepository;
import com.traceagile.application.requirement.RequirementRepository;
import com.traceagile.application.testcase.TestCaseRepository;
import com.traceagile.application.traceability.ExecutionResults.CampaignRef;
import com.traceagile.application.traceability.ExecutionResults.DefectRef;
import com.traceagile.application.traceability.ExecutionResults.LastExecution;
import com.traceagile.application.traceability.ProjectTrace.Row;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.planning.Sprint;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.requirement.CriterionStatus;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.traceability.CoverageCalculator.Coverage;
import com.traceagile.domain.traceability.TraceLink;
import com.traceagile.domain.traceability.VerificationStatus;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Predicate;
import com.traceagile.domain.campaign.Campaign;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §7 lecture de la traçabilité : statut de vérification (§7.3), couverture (§7.2), matrice
 * (F-TRA-04), arbre (F-TRA-05), orphelins (F-TRA-06), analyse d'impact (F-TRA-07). Calcul à la
 * demande sur la vue du projet chargée en une fois (ADR-0014).
 */
@Service
@Transactional(readOnly = true)
public class TraceabilityService {

    // ---------------------------------------------------------------- résultats

    public record MatrixColumn(TestCase test, ExecutionStatus lastResult) {
    }

    public record MatrixRow(Requirement requirement, int depth, boolean leaf, VerificationStatus status) {
    }

    public record MatrixCell(Requirement requirement, TestCase test, TraceLink link, List<Integer> criterionPositions,
                             ExecutionStatus lastResult) {
    }

    public record Matrix(String scope, List<MatrixRow> rows, List<MatrixColumn> columns, List<MatrixCell> cells) {
    }

    public record RequirementCoverage(Requirement requirement, int depth, boolean leaf, VerificationStatus status,
                                      int coveringTests, int executedTests, int passedTests) {
    }

    public record CoverageReport(String scope, Coverage coverage, List<RequirementCoverage> requirements) {
    }

    public record Orphans(List<Requirement> requirementsWithoutTests, List<TestCase> testsWithoutRequirement,
                          List<DefectRef> defectsWithoutRequirement, List<TestCase> automatedNeverExecuted) {
    }

    public record TraceNode(Requirement requirement, VerificationStatus status, List<TraceNode> children) {
    }

    public record CriterionTrace(AcceptanceCriterion criterion, CriterionStatus status, List<TestCase> tests) {
    }

    public record TestTrace(TestCase test, TraceLink link, List<Integer> criterionPositions, LastExecution lastExecution) {
    }

    public record TraceTree(TraceNode node, List<TraceNode> ancestors, List<CriterionTrace> criteria, List<TestTrace> tests,
                            List<DefectRef> defects) {
    }

    public record ImpactedTest(TestCase test, Requirement via, TraceLink link) {
    }

    public record Impact(Requirement requirement, List<ImpactedTest> tests, List<CampaignRef> campaigns) {
    }

    private final RequirementRepository requirements;
    private final TestCaseRepository tests;
    private final TraceLinkRepository links;
    private final ExecutionResults executions;
    private final SprintRepository sprints;
    private final ReleaseRepository releases;

    public TraceabilityService(RequirementRepository requirements, TestCaseRepository tests, TraceLinkRepository links,
                               ExecutionResults executions, SprintRepository sprints, ReleaseRepository releases) {
        this.sprints = sprints;
        this.releases = releases;
        this.requirements = requirements;
        this.tests = tests;
        this.links = links;
        this.executions = executions;
    }

    public ProjectTrace load(String projectKey) {
        return load(projectKey, null);
    }

    /** {@code campaigns} : ne retenir que les exécutions de ces campagnes (périmètre sprint ou release, §7.2) ; {@code null} = toutes. */
    ProjectTrace load(String projectKey, Predicate<Campaign> campaigns) {
        return new ProjectTrace(requirements.findByProject_KeyOrderByRankAsc(projectKey), tests.findByProject_KeyOrderByKeyNumberAsc(projectKey),
                links.findByProject_Key(projectKey),
                campaigns == null ? executions.latest(projectKey) : executions.latestIn(projectKey, campaigns),
                executions.requirementsWithOpenBlockingDefect(projectKey));
    }

    /**
     * §7.2 « dans le périmètre » (ADR-0016) : pour un sprint, les exécutions de ses campagnes ; pour une
     * release, celles de ses campagnes et des campagnes de ses sprints ; sinon toutes.
     */
    public static Predicate<Campaign> executionScope(String scope) {
        if (scope == null || !scope.contains(":")) {
            return null;
        }
        String kind = scope.substring(0, scope.indexOf(':'));
        String value = scope.substring(scope.indexOf(':') + 1);
        return switch (kind) {
            case "sprint" -> c -> c.getSprint() != null && c.getSprint().getKey().equals(value);
            case "release" -> c -> (c.getRelease() != null && c.getRelease().getKey().equals(value))
                    || (c.getSprint() != null && c.getSprint().getRelease() != null && c.getSprint().getRelease().getKey().equals(value));
            default -> null;
        };
    }

    /** §7.3 statut de chaque exigence du projet (backlog, fiche). */
    public Map<UUID, VerificationStatus> statuses(String projectKey) {
        return load(projectKey).statuses();
    }

    /**
     * Périmètre (§7.2) : {@code project} (défaut), {@code requirement:REQ-n} (exigence et
     * descendants : épic, feature), {@code sprint:SPR-n} ou {@code release:REL-n} (exigences de leur
     * périmètre, à plat).
     */
    public List<Row> scoped(ProjectTrace trace, String projectKey, String scope) {
        if (scope == null || scope.isBlank() || scope.equals("project")) {
            return trace.rows();
        }
        int colon = scope.indexOf(':');
        String kind = colon < 0 ? scope : scope.substring(0, colon);
        String value = colon < 0 ? "" : scope.substring(colon + 1);
        return switch (kind) {
            case "requirement", "epic", "feature" -> trace.scope(requirements.findByProject_KeyAndKey(projectKey, value)
                    .orElseThrow(() -> new NotFoundException("REQ_NOT_FOUND", "Exigence « " + value + " » introuvable.")));
            case "sprint" -> trace.only(scopeIds(List.of(sprints.findByProject_KeyAndKey(projectKey, value)
                    .orElseThrow(() -> new NotFoundException("SPRINT_NOT_FOUND", "Sprint « " + value + " » introuvable.")))));
            case "release" -> trace.only(scopeIds(releases.findByProject_KeyAndKey(projectKey, value)
                    .orElseThrow(() -> new NotFoundException("RELEASE_NOT_FOUND", "Release « " + value + " » introuvable."))
                    .getSprints()));
            default -> throw new BusinessRuleException("SCOPE_INVALID",
                    "Périmètre inconnu : « " + scope + " » (project, requirement:REQ-n, sprint:SPR-n, release:REL-n).");
        };
    }

    private static Set<UUID> scopeIds(List<Sprint> sprints) {
        Set<UUID> ids = new LinkedHashSet<>();
        sprints.forEach(s -> s.requirements().forEach(r -> ids.add(r.getId())));
        return ids;
    }

    /** F-PLN-02 couverture de chaque sprint du projet (taux de validation de la feuille de route). */
    public Map<String, Coverage> coverageBySprint(String projectKey) {
        Map<String, Coverage> bySprint = new LinkedHashMap<>();
        for (Sprint sprint : sprints.findByProject_KeyOrderByStartDateAsc(projectKey)) {
            ProjectTrace trace = load(projectKey, executionScope("sprint:" + sprint.getKey()));
            bySprint.put(sprint.getKey(), trace.coverage(trace.only(scopeIds(List.of(sprint)))));
        }
        return bySprint;
    }

    // ---------------------------------------------------------------- F-TRA-04 matrice

    public Matrix matrix(String projectKey, String scope, boolean allTests, Set<TestKind> kinds) {
        ProjectTrace trace = load(projectKey, executionScope(scope));
        List<Row> scoped = scoped(trace, projectKey, scope);
        List<MatrixRow> rows = scoped.stream()
                .map(r -> new MatrixRow(r.requirement(), r.depth(), trace.isLeaf(r.requirement()), trace.status(r.requirement())))
                .toList();
        Set<UUID> linkedTests = new LinkedHashSet<>();
        List<MatrixCell> cells = new ArrayList<>();
        for (Row row : scoped) {
            for (TraceLink link : trace.linksOf(row.requirement())) {
                TestCase test = trace.test(link.getSourceId());
                linkedTests.add(test.getId());
                cells.add(new MatrixCell(row.requirement(), test, link, trace.criterionPositions(test, row.requirement()),
                        trace.result(test.getId())));
            }
        }
        List<MatrixColumn> columns = trace.tests().stream()
                .filter(t -> allTests ? t.getStatus() != TestCaseStatus.OBSOLETE : linkedTests.contains(t.getId()))
                .filter(t -> kinds == null || kinds.isEmpty() || kinds.contains(t.getKind()))
                .map(t -> new MatrixColumn(t, trace.result(t.getId())))
                .toList();
        Set<UUID> shown = new LinkedHashSet<>(columns.stream().map(c -> c.test().getId()).toList());
        return new Matrix(scope == null || scope.isBlank() ? "project" : scope, rows, columns,
                cells.stream().filter(c -> shown.contains(c.test().getId())).toList());
    }

    // ---------------------------------------------------------------- §7.2 couverture

    public CoverageReport coverage(String projectKey, String scope) {
        ProjectTrace trace = load(projectKey, executionScope(scope));
        List<Row> scoped = scoped(trace, projectKey, scope);
        List<RequirementCoverage> details = scoped.stream().map(row -> {
            Requirement r = row.requirement();
            List<TraceLink> covering = trace.coveringLinks(r);
            int executed = (int) covering.stream().map(l -> trace.result(l.getSourceId())).filter(s -> s != null && s.isExecuted()).count();
            int passed = (int) covering.stream().filter(l -> trace.result(l.getSourceId()) == ExecutionStatus.PASSED).count();
            return new RequirementCoverage(r, row.depth(), trace.isLeaf(r), trace.status(r), covering.size(), executed, passed);
        }).toList();
        return new CoverageReport(scope == null || scope.isBlank() ? "project" : scope, trace.coverage(scoped), details);
    }

    // ---------------------------------------------------------------- F-TRA-06 orphelins

    public Orphans orphans(String projectKey) {
        ProjectTrace trace = load(projectKey);
        List<Requirement> uncovered = trace.rows().stream().map(Row::requirement)
                .filter(ProjectTrace::active)
                .filter(trace::isLeaf)
                .filter(r -> trace.coveringLinks(r).isEmpty())
                .toList();
        List<TestCase> active = trace.tests().stream().filter(t -> t.getStatus() != TestCaseStatus.OBSOLETE).toList();
        return new Orphans(uncovered,
                active.stream().filter(t -> trace.requirementLinksOf(t).isEmpty()).toList(),
                executions.defectsWithoutRequirement(projectKey),
                active.stream().filter(t -> t.getKind() == TestKind.AUTOMATED && trace.lastExecution(t) == null).toList());
    }

    // ---------------------------------------------------------------- F-TRA-05 arbre de traçabilité

    public TraceTree traceTree(String projectKey, String key) {
        ProjectTrace trace = load(projectKey);
        Requirement requirement = loaded(trace, projectKey, key);
        List<TraceNode> ancestors = trace.ancestors(requirement).stream()
                .map(a -> new TraceNode(a, trace.status(a), List.of())).toList();
        List<CriterionTrace> criteria = requirement.getCriteria().stream()
                .sorted(Comparator.comparingInt(AcceptanceCriterion::getPosition))
                .map(c -> new CriterionTrace(c, trace.criterionStatus(c), trace.testsOf(c))).toList();
        List<TestTrace> testTraces = trace.linksOf(requirement).stream().map(l -> {
            TestCase test = trace.test(l.getSourceId());
            return new TestTrace(test, l, trace.criterionPositions(test, requirement), trace.lastExecution(test));
        }).toList();
        return new TraceTree(node(trace, requirement), ancestors, criteria, testTraces,
                executions.defectsOf(projectKey, requirement.getId()));
    }

    private TraceNode node(ProjectTrace trace, Requirement requirement) {
        return new TraceNode(requirement, trace.status(requirement), trace.children(requirement).stream().map(c -> node(trace, c)).toList());
    }

    /** F-REQ-12 états calculés des critères d'une exigence. */
    public Map<UUID, CriterionStatus> criterionStatuses(String projectKey, Requirement requirement) {
        ProjectTrace trace = load(projectKey);
        Map<UUID, CriterionStatus> statuses = new LinkedHashMap<>();
        requirement.getCriteria().forEach(c -> statuses.put(c.getId(), trace.criterionStatus(c)));
        return statuses;
    }

    // ---------------------------------------------------------------- F-TRA-07 analyse d'impact

    /** Tests à revoir si l'exigence (ou l'un de ses descendants) change, et campagnes en cours concernées. */
    public Impact impact(String projectKey, String key) {
        ProjectTrace trace = load(projectKey);
        Requirement requirement = loaded(trace, projectKey, key);
        List<ImpactedTest> impacted = new ArrayList<>();
        Set<UUID> testIds = new LinkedHashSet<>();
        for (Row row : trace.scope(requirement)) {
            for (TraceLink link : trace.linksOf(row.requirement())) {
                TestCase test = trace.test(link.getSourceId());
                if (test.getStatus() != TestCaseStatus.OBSOLETE) {
                    impacted.add(new ImpactedTest(test, row.requirement(), link));
                    testIds.add(test.getId());
                }
            }
        }
        impacted.sort(Comparator.comparingInt((ImpactedTest i) -> i.test().getKeyNumber()).thenComparingInt(i -> i.via().getKeyNumber()));
        return new Impact(requirement, impacted, executions.runningCampaignsWith(projectKey, testIds));
    }

    /** F-REQ-19 DoD « tous les tests liés passés ». */
    public boolean allCoveringTestsPassed(Requirement requirement) {
        return load(requirement.getProject().getKey()).allCoveringTestsPassed(requirement);
    }

    private static Requirement loaded(ProjectTrace trace, String projectKey, String key) {
        return trace.rows().stream().map(Row::requirement).filter(r -> r.getKey().equals(key)).findFirst()
                .orElseThrow(() -> new NotFoundException("REQ_NOT_FOUND", "Exigence « " + key + " » introuvable dans " + projectKey + "."));
    }
}
