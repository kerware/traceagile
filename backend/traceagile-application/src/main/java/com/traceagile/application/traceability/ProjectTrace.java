package com.traceagile.application.traceability;

import com.traceagile.application.traceability.ExecutionResults.LastExecution;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.requirement.CriterionStatus;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.traceability.CoverageCalculator;
import com.traceagile.domain.traceability.CoverageCalculator.Coverage;
import com.traceagile.domain.traceability.CoverageCalculator.LeafFacts;
import com.traceagile.domain.traceability.TraceEntityType;
import com.traceagile.domain.traceability.TraceLink;
import com.traceagile.domain.traceability.VerificationRules;
import com.traceagile.domain.traceability.VerificationStatus;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Vue de traçabilité d'un projet, chargée une fois par requête : exigences (ordre de l'arbre), tests,
 * liens, derniers résultats et anomalies bloquantes. Les statuts (§7.3) sont mémorisés pendant la requête.
 */
public final class ProjectTrace {

    /** Exigence dans l'ordre de l'arbre, avec sa profondeur. */
    public record Row(Requirement requirement, int depth) {
    }

    private final List<Row> rows = new ArrayList<>();
    private final Map<UUID, Requirement> requirementsById;
    private final Map<UUID, List<Requirement>> childrenById = new HashMap<>();
    private final Map<UUID, TestCase> testsById;
    private final Map<UUID, List<TraceLink>> linksByRequirement = new HashMap<>();
    private final Map<UUID, List<TraceLink>> linksByCriterion = new HashMap<>();
    private final Map<UUID, List<TraceLink>> requirementLinksByTest = new HashMap<>();
    private final Map<UUID, LastExecution> latest;
    private final Set<UUID> blocking;
    private final Map<UUID, VerificationStatus> statuses = new HashMap<>();

    ProjectTrace(List<Requirement> backlogByRank, List<TestCase> tests, List<TraceLink> links, Map<UUID, LastExecution> latest,
                 Set<UUID> blocking) {
        this.requirementsById = backlogByRank.stream().collect(Collectors.toMap(Requirement::getId, Function.identity()));
        this.testsById = tests.stream().collect(Collectors.toMap(TestCase::getId, Function.identity()));
        this.latest = latest;
        this.blocking = blocking;
        List<Requirement> roots = new ArrayList<>();
        for (Requirement requirement : backlogByRank) {
            Requirement parent = requirement.getParent();
            if (parent == null || !requirementsById.containsKey(parent.getId())) {
                roots.add(requirement);
            } else {
                childrenById.computeIfAbsent(parent.getId(), id -> new ArrayList<>()).add(requirement);
            }
        }
        roots.forEach(root -> walk(root, 0));
        for (TraceLink link : links) {
            if (!testsById.containsKey(link.getSourceId())) {
                continue;
            }
            if (link.getTargetType() == TraceEntityType.REQUIREMENT && requirementsById.containsKey(link.getTargetId())) {
                linksByRequirement.computeIfAbsent(link.getTargetId(), id -> new ArrayList<>()).add(link);
                requirementLinksByTest.computeIfAbsent(link.getSourceId(), id -> new ArrayList<>()).add(link);
            } else if (link.getTargetType() == TraceEntityType.ACCEPTANCE_CRITERION) {
                linksByCriterion.computeIfAbsent(link.getTargetId(), id -> new ArrayList<>()).add(link);
            }
        }
    }

    private void walk(Requirement requirement, int depth) {
        rows.add(new Row(requirement, depth));
        children(requirement).forEach(child -> walk(child, depth + 1));
    }

    // ---------------------------------------------------------------- structure

    public List<Row> rows() {
        return rows;
    }

    /** Exigence et descendants, dans l'ordre de l'arbre ; {@code null} = tout le projet. */
    public List<Row> scope(Requirement root) {
        if (root == null) {
            return rows;
        }
        int start = -1;
        for (int i = 0; i < rows.size(); i++) {
            if (rows.get(i).requirement().getId().equals(root.getId())) {
                start = i;
                break;
            }
        }
        if (start < 0) {
            return List.of();
        }
        int depth = rows.get(start).depth();
        List<Row> scoped = new ArrayList<>(List.of(rows.get(start)));
        for (int i = start + 1; i < rows.size() && rows.get(i).depth() > depth; i++) {
            scoped.add(rows.get(i));
        }
        return scoped;
    }

    /** Périmètre d'un sprint ou d'une release : ces exigences, dans l'ordre de l'arbre, à plat. */
    public List<Row> only(java.util.Collection<UUID> ids) {
        return rows.stream().filter(r -> ids.contains(r.requirement().getId())).map(r -> new Row(r.requirement(), 0)).toList();
    }

    public List<Requirement> children(Requirement requirement) {
        return childrenById.getOrDefault(requirement.getId(), List.of());
    }

    /** Enfants qui comptent : ni rejetés ni obsolètes. */
    private List<Requirement> activeChildren(Requirement requirement) {
        return children(requirement).stream().filter(ProjectTrace::active).toList();
    }

    public static boolean active(Requirement requirement) {
        return requirement.getStatus() != RequirementStatus.OBSOLETE && requirement.getStatus() != RequirementStatus.REJECTED;
    }

    /** §7.2 exigence feuille : aucun enfant actif. */
    public boolean isLeaf(Requirement requirement) {
        return activeChildren(requirement).isEmpty();
    }

    public List<Requirement> ancestors(Requirement requirement) {
        List<Requirement> chain = new ArrayList<>();
        Requirement parent = requirement.getParent();
        while (parent != null && requirementsById.containsKey(parent.getId())) {
            Requirement loaded = requirementsById.get(parent.getId());
            chain.add(0, loaded);
            parent = loaded.getParent();
        }
        return chain;
    }

    public Requirement requirement(UUID id) {
        return requirementsById.get(id);
    }

    public TestCase test(UUID id) {
        return testsById.get(id);
    }

    public List<TestCase> tests() {
        return testsById.values().stream().sorted(Comparator.comparingInt(TestCase::getKeyNumber)).toList();
    }

    // ---------------------------------------------------------------- liens et résultats

    public List<TraceLink> linksOf(Requirement requirement) {
        return linksByRequirement.getOrDefault(requirement.getId(), List.of()).stream()
                .sorted(Comparator.comparingInt(l -> testsById.get(l.getSourceId()).getKeyNumber())).toList();
    }

    /** Liens VERIFIES / PARTIALLY_VERIFIES vers des tests non obsolètes. */
    public List<TraceLink> coveringLinks(Requirement requirement) {
        return linksOf(requirement).stream()
                .filter(l -> l.getLinkType().countsForCoverage())
                .filter(l -> testsById.get(l.getSourceId()).getStatus() != TestCaseStatus.OBSOLETE)
                .toList();
    }

    public List<TraceLink> requirementLinksOf(TestCase test) {
        return requirementLinksByTest.getOrDefault(test.getId(), List.of());
    }

    /** Positions des critères de l'exigence vérifiés par ce test. */
    public List<Integer> criterionPositions(TestCase test, Requirement requirement) {
        return requirement.getCriteria().stream()
                .filter(c -> linksByCriterion.getOrDefault(c.getId(), List.of()).stream().anyMatch(l -> l.getSourceId().equals(test.getId())))
                .map(AcceptanceCriterion::getPosition).sorted().toList();
    }

    public List<TestCase> testsOf(AcceptanceCriterion criterion) {
        return linksByCriterion.getOrDefault(criterion.getId(), List.of()).stream()
                .filter(l -> l.getLinkType().countsForCoverage())
                .map(l -> testsById.get(l.getSourceId()))
                .filter(t -> t.getStatus() != TestCaseStatus.OBSOLETE)
                .sorted(Comparator.comparingInt(TestCase::getKeyNumber)).toList();
    }

    public LastExecution lastExecution(TestCase test) {
        return latest.get(test.getId());
    }

    public ExecutionStatus result(UUID testId) {
        LastExecution last = latest.get(testId);
        return last == null ? null : last.status();
    }

    private List<ExecutionStatus> coveringResults(Requirement requirement) {
        return coveringLinks(requirement).stream().map(l -> result(l.getSourceId())).toList();
    }

    // ---------------------------------------------------------------- statuts

    /** §7.3 statut de vérification ; une exigence parente agrège ses enfants actifs. */
    public VerificationStatus status(Requirement requirement) {
        VerificationStatus known = statuses.get(requirement.getId());
        if (known != null) {
            return known;
        }
        List<TraceLink> covering = coveringLinks(requirement);
        VerificationStatus own = VerificationRules.leaf(coveringResults(requirement), blocking.contains(requirement.getId()),
                covering.stream().anyMatch(TraceLink::isSuspect));
        List<Requirement> children = activeChildren(requirement);
        VerificationStatus status;
        if (children.isEmpty()) {
            status = own;
        } else {
            List<VerificationStatus> parts = new ArrayList<>(children.stream().map(this::status).toList());
            if (!covering.isEmpty()) {
                parts.add(own);
            }
            status = VerificationRules.aggregate(parts);
        }
        statuses.put(requirement.getId(), status);
        return status;
    }

    public Map<UUID, VerificationStatus> statuses() {
        return rows.stream().collect(Collectors.toMap(r -> r.requirement().getId(), r -> status(r.requirement())));
    }

    /** F-REQ-12 état calculé d'un critère. */
    public CriterionStatus criterionStatus(AcceptanceCriterion criterion) {
        return VerificationRules.criterion(testsOf(criterion).stream().map(t -> result(t.getId())).toList());
    }

    /** F-REQ-19 item DoD « tous les tests liés passés » (faux sans test couvrant). */
    public boolean allCoveringTestsPassed(Requirement requirement) {
        List<ExecutionStatus> results = coveringResults(requirement);
        return !results.isEmpty() && results.stream().allMatch(r -> r == ExecutionStatus.PASSED);
    }

    // ---------------------------------------------------------------- couverture

    public LeafFacts leafFacts(Requirement requirement) {
        return new LeafFacts(requirement.getRiskLevel(), coveringResults(requirement));
    }

    /** §7.2 les cinq indicateurs pour les exigences actives du périmètre. */
    public Coverage coverage(List<Row> scoped) {
        List<Requirement> active = scoped.stream().map(Row::requirement).filter(ProjectTrace::active).toList();
        List<LeafFacts> leaves = active.stream().filter(this::isLeaf).map(this::leafFacts).toList();
        List<AcceptanceCriterion> criteria = active.stream().flatMap(r -> r.getCriteria().stream()).toList();
        int linked = (int) criteria.stream().filter(c -> !testsOf(c).isEmpty()).count();
        return CoverageCalculator.compute(leaves, linked, criteria.size());
    }
}
