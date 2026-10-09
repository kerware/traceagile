package com.traceagile.application.traceability;

import com.traceagile.application.audit.AuditService;
import com.traceagile.application.common.ConflictException;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.common.VersionConflictException;
import com.traceagile.application.requirement.AcceptanceCriterionRepository;
import com.traceagile.application.requirement.RequirementRepository;
import com.traceagile.application.testcase.TestCaseRepository;
import com.traceagile.domain.audit.AuditAction;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.testcase.GherkinTags;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.traceability.LinkOrigin;
import com.traceagile.domain.traceability.LinkType;
import com.traceagile.domain.traceability.TraceEntityType;
import com.traceagile.domain.traceability.TraceLink;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §7.1 liens test → exigence et test → critère (F-TRA-01 à F-TRA-03) : saisie depuis la fiche test,
 * la fiche exigence ou la matrice (lot 3), tags Gherkin (F-AUT-06), génération depuis un critère
 * (F-REQ-11), découverte (F-AUT-08). Suspicion après modification de l'exigence (§3.3-7).
 */
@Service
@Transactional
public class TraceLinkService {

    /** Lien à enregistrer depuis la fiche test ; {@code criterionPositions} précise les critères vérifiés. */
    public record LinkDraft(String requirementKey, LinkType linkType, List<Integer> criterionPositions) {
    }

    public record RequirementLink(UUID linkId, Requirement requirement, LinkType linkType, LinkOrigin origin,
                                  List<AcceptanceCriterion> criteria, boolean suspect) {
    }

    public record TestLink(UUID linkId, TestCase testCase, LinkType linkType, LinkOrigin origin, List<Integer> criterionPositions,
                           boolean suspect) {
    }

    /** Lien test → exigence avec ses deux extrémités et les critères précisés (matrice, fiche exigence). */
    public record LinkView(TraceLink link, TestCase test, Requirement requirement, List<Integer> criterionPositions) {
    }

    public static final String AUDIT_TYPE = "TRACE_LINK";

    private final TraceLinkRepository links;
    private final RequirementRepository requirements;
    private final AcceptanceCriterionRepository criteria;
    private final TestCaseRepository tests;
    private final AuditService audit;

    public TraceLinkService(TraceLinkRepository links, RequirementRepository requirements,
                            AcceptanceCriterionRepository criteria, TestCaseRepository tests, AuditService audit) {
        this.links = links;
        this.requirements = requirements;
        this.criteria = criteria;
        this.tests = tests;
        this.audit = audit;
    }

    // ---------------------------------------------------------------- lecture

    /** Exigences vérifiées par un test, avec les critères précisés. */
    @Transactional(readOnly = true)
    public List<RequirementLink> requirementsOf(TestCase test) {
        List<TraceLink> all = links.findBySourceTypeAndSourceId(TraceEntityType.TEST_CASE, test.getId());
        Map<UUID, List<AcceptanceCriterion>> criteriaByRequirement = new HashMap<>();
        List<UUID> criterionIds = all.stream().filter(l -> l.getTargetType() == TraceEntityType.ACCEPTANCE_CRITERION)
                .map(TraceLink::getTargetId).toList();
        if (!criterionIds.isEmpty()) {
            criteria.findByIdIn(criterionIds).forEach(c ->
                    criteriaByRequirement.computeIfAbsent(c.getRequirement().getId(), id -> new ArrayList<>()).add(c));
        }
        List<TraceLink> requirementLinks = all.stream().filter(l -> l.getTargetType() == TraceEntityType.REQUIREMENT).toList();
        Map<UUID, Requirement> byId = requirements.findByIdIn(requirementLinks.stream().map(TraceLink::getTargetId).toList())
                .stream().collect(Collectors.toMap(Requirement::getId, Function.identity()));
        return requirementLinks.stream()
                .filter(l -> byId.containsKey(l.getTargetId()))
                .map(l -> new RequirementLink(l.getId(), byId.get(l.getTargetId()), l.getLinkType(), l.getOrigin(),
                        criteriaByRequirement.getOrDefault(l.getTargetId(), List.of()).stream()
                                .sorted(Comparator.comparingInt(AcceptanceCriterion::getPosition)).toList(), l.isSuspect()))
                .sorted(Comparator.comparingInt(link -> link.requirement().getKeyNumber()))
                .toList();
    }

    /** Tests liés à une exigence (onglet « Tests liés »), avec les critères qu'ils vérifient. */
    @Transactional(readOnly = true)
    public List<TestLink> testsOf(Requirement requirement) {
        List<TraceLink> requirementLinks = links.findByTargetTypeAndTargetId(TraceEntityType.REQUIREMENT, requirement.getId());
        Map<UUID, Integer> positionById = requirement.getCriteria().stream()
                .collect(Collectors.toMap(AcceptanceCriterion::getId, AcceptanceCriterion::getPosition));
        Map<UUID, List<Integer>> positionsByTest = new HashMap<>();
        if (!positionById.isEmpty()) {
            links.findByTargetTypeAndTargetIdIn(TraceEntityType.ACCEPTANCE_CRITERION, positionById.keySet()).forEach(l ->
                    positionsByTest.computeIfAbsent(l.getSourceId(), id -> new ArrayList<>()).add(positionById.get(l.getTargetId())));
        }
        Map<UUID, TestCase> byId = tests.findByIdIn(requirementLinks.stream().map(TraceLink::getSourceId).toList())
                .stream().collect(Collectors.toMap(TestCase::getId, Function.identity()));
        return requirementLinks.stream()
                .filter(l -> byId.containsKey(l.getSourceId()))
                .map(l -> new TestLink(l.getId(), byId.get(l.getSourceId()), l.getLinkType(), l.getOrigin(),
                        positionsByTest.getOrDefault(l.getSourceId(), List.of()).stream().sorted().toList(), l.isSuspect()))
                .sorted(Comparator.comparingInt(link -> link.testCase().getKeyNumber()))
                .toList();
    }

    /** F-REQ-19 item « au moins un test lié » : un lien VERIFIES ou PARTIALLY_VERIFIES. */
    @Transactional(readOnly = true)
    public boolean hasCoveringTest(Requirement requirement) {
        return links.findByTargetTypeAndTargetId(TraceEntityType.REQUIREMENT, requirement.getId()).stream()
                .anyMatch(l -> l.getLinkType().countsForCoverage());
    }

    /** Test d'un lien test → exigence du projet (vérification des droits selon sa nature). */
    @Transactional(readOnly = true)
    public TestCase testOf(String projectKey, UUID linkId) {
        return view(requirementLink(projectKey, linkId)).test();
    }

    // ---------------------------------------------------------------- écriture

    /** F-TRA-01 lien créé depuis la fiche exigence ou la matrice (409 s'il existe déjà). */
    public LinkView link(String projectKey, String testKey, String requirementKey, LinkType type, List<Integer> criterionPositions) {
        TestCase test = tests.findByProject_KeyAndKey(projectKey, testKey)
                .orElseThrow(() -> new NotFoundException("TEST_NOT_FOUND", "Test « " + testKey + " » introuvable."));
        Requirement requirement = requirement(projectKey, requirementKey);
        if (links.findBySourceIdAndTargetId(test.getId(), requirement.getId()).isPresent()) {
            throw new ConflictException("LINK_EXISTS", testKey + " est déjà lié à " + requirementKey + ".");
        }
        TraceLink link = links.save(TraceLink.testToRequirement(test.getProject(), test.getId(), requirement.getId(),
                Objects.requireNonNull(type), LinkOrigin.MANUAL));
        for (Integer position : criterionPositions == null ? List.<Integer>of() : criterionPositions) {
            AcceptanceCriterion criterion = criterionAt(requirement, position);
            if (links.findBySourceIdAndTargetId(test.getId(), criterion.getId()).isEmpty()) {
                links.save(TraceLink.testToCriterion(test.getProject(), test.getId(), criterion.getId(), type, LinkOrigin.MANUAL));
            }
        }
        LinkView view = view(link);
        record(view, AuditAction.CREATED, Map.of(), describe(view));
        return view;
    }

    /** F-TRA-02 changement de type (matrice) ; les liens vers les critères suivent. */
    public LinkView changeType(String projectKey, UUID linkId, LinkType type, Long expectedVersion) {
        TraceLink link = requirementLink(projectKey, linkId);
        VersionConflictException.check(expectedVersion, link.getVersion());
        LinkView before = view(link);
        Map<String, Object> snapshot = describe(before);
        link.setLinkType(Objects.requireNonNull(type));
        criterionLinks(before).forEach(l -> l.setLinkType(type));
        LinkView after = view(link);
        record(after, AuditAction.UPDATED, snapshot, describe(after));
        return after;
    }

    /** Supprime le lien test → exigence et les liens du même test vers les critères de l'exigence. */
    public void unlink(String projectKey, UUID linkId) {
        LinkView view = view(requirementLink(projectKey, linkId));
        criterionLinks(view).forEach(links::delete);
        links.delete(view.link());
        record(view, AuditAction.DELETED, describe(view), Map.of());
    }

    /** §3.3-7 le test a été revu après la modification de l'exigence : l'alerte disparaît. */
    public LinkView review(String projectKey, UUID linkId) {
        LinkView view = view(requirementLink(projectKey, linkId));
        Map<String, Object> before = describe(view);
        view.link().clearSuspicion();
        criterionLinks(view).forEach(TraceLink::clearSuspicion);
        record(view, AuditAction.UPDATED, before, describe(view));
        return view;
    }

    /**
     * §3.3-7 l'exigence a changé : les liens des tests READY ou NEEDS_UPDATE deviennent suspects et
     * les tests READY passent à NEEDS_UPDATE. Renvoie les tests passés à NEEDS_UPDATE.
     */
    public List<TestCase> markSuspect(Requirement requirement, Instant now) {
        List<TraceLink> affected = new ArrayList<>(links.findByTargetTypeAndTargetId(TraceEntityType.REQUIREMENT, requirement.getId()));
        Set<UUID> criterionIds = requirement.getCriteria().stream().map(AcceptanceCriterion::getId).collect(Collectors.toSet());
        if (!criterionIds.isEmpty()) {
            affected.addAll(links.findByTargetTypeAndTargetIdIn(TraceEntityType.ACCEPTANCE_CRITERION, criterionIds));
        }
        Map<UUID, TestCase> byId = tests.findByIdIn(affected.stream().map(TraceLink::getSourceId).collect(Collectors.toSet()))
                .stream().collect(Collectors.toMap(TestCase::getId, Function.identity()));
        List<TestCase> needsUpdate = new ArrayList<>();
        for (TraceLink link : affected) {
            TestCase test = byId.get(link.getSourceId());
            if (test == null || !link.getLinkType().countsForCoverage()
                    || (test.getStatus() != TestCaseStatus.READY && test.getStatus() != TestCaseStatus.NEEDS_UPDATE)) {
                continue;
            }
            link.markSuspect(now);
            if (test.getStatus() == TestCaseStatus.READY && !needsUpdate.contains(test)) {
                needsUpdate.add(test);
            }
        }
        return needsUpdate;
    }

    /** §3.3-7 un test revenu à READY a été revu : ses liens ne sont plus suspects. */
    public void clearSuspicionOf(TestCase test) {
        links.findBySourceTypeAndSourceId(TraceEntityType.TEST_CASE, test.getId()).forEach(TraceLink::clearSuspicion);
    }

    /** F-TRA-01 remplace les liens d'un test par la liste saisie sur sa fiche. */
    public void replace(TestCase test, List<LinkDraft> drafts) {
        Map<UUID, LinkType> wantedRequirements = new LinkedHashMap<>();
        Map<UUID, LinkType> wantedCriteria = new LinkedHashMap<>();
        Map<UUID, Requirement> resolved = new HashMap<>();
        for (LinkDraft draft : drafts) {
            Requirement requirement = requirement(test.getProject().getKey(), draft.requirementKey());
            if (wantedRequirements.put(requirement.getId(), draft.linkType()) != null) {
                throw new BusinessRuleException("LINK_DUPLICATED", "L'exigence " + draft.requirementKey() + " apparaît deux fois.");
            }
            resolved.put(requirement.getId(), requirement);
            for (Integer position : draft.criterionPositions() == null ? List.<Integer>of() : draft.criterionPositions()) {
                wantedCriteria.put(criterionAt(requirement, position).getId(), draft.linkType());
            }
        }
        Set<UUID> kept = new HashSet<>();
        for (TraceLink link : links.findBySourceTypeAndSourceId(TraceEntityType.TEST_CASE, test.getId())) {
            Map<UUID, LinkType> wanted = link.getTargetType() == TraceEntityType.REQUIREMENT ? wantedRequirements : wantedCriteria;
            LinkType type = wanted.get(link.getTargetId());
            if (type == null) {
                links.delete(link);
            } else {
                link.setLinkType(type);
                kept.add(link.getTargetId());
            }
        }
        wantedRequirements.forEach((id, type) -> {
            if (!kept.contains(id)) {
                links.save(TraceLink.testToRequirement(test.getProject(), test.getId(), id, type, LinkOrigin.MANUAL));
            }
        });
        wantedCriteria.forEach((id, type) -> {
            if (!kept.contains(id)) {
                links.save(TraceLink.testToCriterion(test.getProject(), test.getId(), id, type, LinkOrigin.MANUAL));
            }
        });
    }

    /**
     * F-AUT-06 les tags {@code @REQ-n} et {@code @AC-n-m} créent les liens manquants ; un tag inconnu
     * produit un avertissement. Les liens existants ne sont jamais supprimés par cette voie.
     */
    public List<String> applyGherkinTags(TestCase test, String source) {
        GherkinTags tags = GherkinTags.parse(source);
        List<String> warnings = new ArrayList<>();
        for (String key : tags.allRequirementKeys()) {
            Optional<Requirement> requirement = requirements.findByProject_KeyAndKey(test.getProject().getKey(), key);
            if (requirement.isEmpty()) {
                warnings.add("Tag @" + key + " : exigence inconnue dans le projet " + test.getProject().getKey() + ".");
                continue;
            }
            ensureRequirementLink(test, requirement.get(), LinkType.VERIFIES, LinkOrigin.GHERKIN_TAG);
            for (GherkinTags.CriterionTag tag : tags.criteria()) {
                if (tag.requirementKey().equals(key)) {
                    requirement.get().getCriteria().stream().filter(c -> c.getPosition() == tag.position()).findFirst()
                            .ifPresentOrElse(
                                    c -> ensureCriterionLink(test, c, LinkType.VERIFIES, LinkOrigin.GHERKIN_TAG),
                                    () -> warnings.add("Tag @AC-" + key.substring(4) + "-" + tag.position()
                                            + " : " + key + " n'a pas de critère n° " + tag.position() + "."));
                }
            }
        }
        return warnings;
    }

    public void ensureRequirementLink(TestCase test, Requirement requirement, LinkType type, LinkOrigin origin) {
        if (links.findBySourceIdAndTargetId(test.getId(), requirement.getId()).isEmpty()) {
            links.save(TraceLink.testToRequirement(test.getProject(), test.getId(), requirement.getId(), type, origin));
        }
    }

    /** F-TRA-03 lien vers un critère précis (et vers son exigence). */
    public void ensureCriterionLink(TestCase test, AcceptanceCriterion criterion, LinkType type, LinkOrigin origin) {
        ensureRequirementLink(test, criterion.getRequirement(), type, origin);
        if (links.findBySourceIdAndTargetId(test.getId(), criterion.getId()).isEmpty()) {
            links.save(TraceLink.testToCriterion(test.getProject(), test.getId(), criterion.getId(), type, origin));
        }
    }

    public void deleteLinksOf(TestCase test) {
        links.findBySourceTypeAndSourceId(TraceEntityType.TEST_CASE, test.getId()).forEach(links::delete);
    }

    public void deleteLinksTo(TraceEntityType targetType, UUID targetId) {
        links.findByTargetTypeAndTargetId(targetType, targetId).forEach(links::delete);
    }

    private TraceLink requirementLink(String projectKey, UUID id) {
        return links.findById(id)
                .filter(l -> l.getProject().getKey().equals(projectKey) && l.getTargetType() == TraceEntityType.REQUIREMENT)
                .orElseThrow(() -> new NotFoundException("LINK_NOT_FOUND", "Lien introuvable."));
    }

    private LinkView view(TraceLink link) {
        TestCase test = tests.findByIdIn(List.of(link.getSourceId())).stream().findFirst()
                .orElseThrow(() -> new NotFoundException("TEST_NOT_FOUND", "Test du lien introuvable."));
        Requirement requirement = requirements.findByIdIn(List.of(link.getTargetId())).stream().findFirst()
                .orElseThrow(() -> new NotFoundException("REQ_NOT_FOUND", "Exigence du lien introuvable."));
        List<Integer> positions = criterionLinksOf(test, requirement).stream()
                .map(l -> requirement.getCriteria().stream().filter(c -> c.getId().equals(l.getTargetId())).findFirst()
                        .map(AcceptanceCriterion::getPosition).orElse(null))
                .filter(Objects::nonNull).sorted().toList();
        return new LinkView(link, test, requirement, positions);
    }

    private List<TraceLink> criterionLinks(LinkView view) {
        return criterionLinksOf(view.test(), view.requirement());
    }

    private List<TraceLink> criterionLinksOf(TestCase test, Requirement requirement) {
        Set<UUID> criterionIds = requirement.getCriteria().stream().map(AcceptanceCriterion::getId).collect(Collectors.toSet());
        return links.findBySourceTypeAndSourceId(TraceEntityType.TEST_CASE, test.getId()).stream()
                .filter(l -> l.getTargetType() == TraceEntityType.ACCEPTANCE_CRITERION && criterionIds.contains(l.getTargetId()))
                .toList();
    }

    private static Map<String, Object> describe(LinkView view) {
        Map<String, Object> snapshot = new LinkedHashMap<>();
        snapshot.put("test", view.test().getKey());
        snapshot.put("requirement", view.requirement().getKey());
        snapshot.put("linkType", view.link().getLinkType().name());
        snapshot.put("criteria", view.criterionPositions());
        snapshot.put("suspect", view.link().isSuspect());
        return snapshot;
    }

    private void record(LinkView view, AuditAction action, Map<String, Object> before, Map<String, Object> after) {
        audit.record(view.test().getProject().getId(), AUDIT_TYPE, view.link().getId(),
                view.test().getKey() + " → " + view.requirement().getKey(), action, before, after);
    }

    private Requirement requirement(String projectKey, String key) {
        return requirements.findByProject_KeyAndKey(projectKey, key)
                .orElseThrow(() -> new NotFoundException("REQ_NOT_FOUND", "Exigence « " + key + " » introuvable."));
    }

    private static AcceptanceCriterion criterionAt(Requirement requirement, int position) {
        return requirement.getCriteria().stream().filter(c -> c.getPosition() == position).findFirst()
                .orElseThrow(() -> new BusinessRuleException("CRITERION_POSITION_UNKNOWN",
                        requirement.getKey() + " n'a pas de critère n° " + position + "."));
    }
}
