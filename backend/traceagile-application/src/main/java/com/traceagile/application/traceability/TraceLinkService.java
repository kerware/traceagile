package com.traceagile.application.traceability;

import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.requirement.AcceptanceCriterionRepository;
import com.traceagile.application.requirement.RequirementRepository;
import com.traceagile.application.testcase.TestCaseRepository;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.testcase.GherkinTags;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.traceability.LinkOrigin;
import com.traceagile.domain.traceability.LinkType;
import com.traceagile.domain.traceability.TraceEntityType;
import com.traceagile.domain.traceability.TraceLink;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §7.1 liens test → exigence et test → critère (F-TRA-01 à F-TRA-03). Au lot 2 : saisie depuis la
 * fiche test, tags Gherkin (F-AUT-06), génération depuis un critère (F-REQ-11), découverte (F-AUT-08).
 */
@Service
@Transactional
public class TraceLinkService {

    /** Lien à enregistrer depuis la fiche test ; {@code criterionPositions} précise les critères vérifiés. */
    public record LinkDraft(String requirementKey, LinkType linkType, List<Integer> criterionPositions) {
    }

    public record RequirementLink(Requirement requirement, LinkType linkType, LinkOrigin origin, List<AcceptanceCriterion> criteria) {
    }

    public record TestLink(TestCase testCase, LinkType linkType, LinkOrigin origin, List<Integer> criterionPositions) {
    }

    private final TraceLinkRepository links;
    private final RequirementRepository requirements;
    private final AcceptanceCriterionRepository criteria;
    private final TestCaseRepository tests;

    public TraceLinkService(TraceLinkRepository links, RequirementRepository requirements,
                            AcceptanceCriterionRepository criteria, TestCaseRepository tests) {
        this.links = links;
        this.requirements = requirements;
        this.criteria = criteria;
        this.tests = tests;
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
                .map(l -> new RequirementLink(byId.get(l.getTargetId()), l.getLinkType(), l.getOrigin(),
                        criteriaByRequirement.getOrDefault(l.getTargetId(), List.of()).stream()
                                .sorted(Comparator.comparingInt(AcceptanceCriterion::getPosition)).toList()))
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
                .map(l -> new TestLink(byId.get(l.getSourceId()), l.getLinkType(), l.getOrigin(),
                        positionsByTest.getOrDefault(l.getSourceId(), List.of()).stream().sorted().toList()))
                .sorted(Comparator.comparingInt(link -> link.testCase().getKeyNumber()))
                .toList();
    }

    /** F-REQ-19 item « au moins un test lié » : un lien VERIFIES ou PARTIALLY_VERIFIES. */
    @Transactional(readOnly = true)
    public boolean hasCoveringTest(Requirement requirement) {
        return links.findByTargetTypeAndTargetId(TraceEntityType.REQUIREMENT, requirement.getId()).stream()
                .anyMatch(l -> l.getLinkType().countsForCoverage());
    }

    // ---------------------------------------------------------------- écriture

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
