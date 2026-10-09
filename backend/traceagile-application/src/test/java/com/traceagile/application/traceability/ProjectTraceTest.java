package com.traceagile.application.traceability;

import static org.assertj.core.api.Assertions.assertThat;

import com.traceagile.application.traceability.ExecutionResults.LastExecution;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.requirement.CriterionStatus;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.domain.requirement.RiskLevel;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.traceability.CoverageCalculator.Coverage;
import com.traceagile.domain.traceability.CoverageCalculator.Indicator;
import com.traceagile.domain.traceability.LinkOrigin;
import com.traceagile.domain.traceability.LinkType;
import com.traceagile.domain.traceability.TraceLink;
import com.traceagile.domain.traceability.VerificationStatus;
import java.lang.reflect.Field;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** §7.2 / §7.3 vue de traçabilité d'un projet : arbre, statuts agrégés, couverture d'un périmètre. */
class ProjectTraceTest {

    final Project shop = new Project("SHOP", "Boutique", null);
    Requirement epic;
    Requirement feature;
    Requirement s1;
    Requirement s2;
    Requirement obsolete;
    TestCase t1;
    TestCase t2;
    final List<TraceLink> links = new ArrayList<>();

    static <T extends AuditableEntity> T withId(T entity) {
        try {
            Field id = AuditableEntity.class.getDeclaredField("id");
            id.setAccessible(true);
            id.set(entity, UUID.randomUUID());
            return entity;
        } catch (ReflectiveOperationException e) {
            throw new IllegalStateException(e);
        }
    }

    Requirement requirement(String key, RequirementType type, Requirement parent, String rank) {
        Requirement r = withId(new Requirement(shop, key, type, key, rank));
        if (parent != null) {
            r.moveUnder(parent);
        }
        return r;
    }

    @BeforeEach
    void backlog() {
        epic = requirement("REQ-1", RequirementType.EPIC, null, "a");
        feature = requirement("REQ-2", RequirementType.FEATURE, epic, "b");
        s1 = requirement("REQ-3", RequirementType.USER_STORY, feature, "c");
        s1.setRiskLevel(RiskLevel.HIGH);
        withId(s1.addCriterion(CriterionFormat.TEXT, "Le produit est ajouté"));
        withId(s1.addCriterion(CriterionFormat.TEXT, "Le total est recalculé"));
        s2 = requirement("REQ-4", RequirementType.USER_STORY, feature, "d");
        obsolete = requirement("REQ-5", RequirementType.USER_STORY, feature, "e");
        obsolete.changeStatus(RequirementStatus.OBSOLETE);
        t1 = withId(TestCase.manual(shop, "TC-1", "Ajouter"));
        t2 = withId(TestCase.manual(shop, "TC-2", "Lien informatif"));
        links.add(TraceLink.testToRequirement(shop, t1.getId(), s1.getId(), LinkType.VERIFIES, LinkOrigin.MANUAL));
        links.add(TraceLink.testToCriterion(shop, t1.getId(), s1.getCriteria().getFirst().getId(), LinkType.VERIFIES, LinkOrigin.MANUAL));
        links.add(TraceLink.testToRequirement(shop, t2.getId(), s2.getId(), LinkType.RELATES_TO, LinkOrigin.MANUAL));
    }

    ProjectTrace trace(Map<UUID, LastExecution> latest) {
        return new ProjectTrace(List.of(epic, feature, s1, s2, obsolete), List.of(t1, t2), links, latest, Set.of());
    }

    @Test
    @DisplayName("F-TRA-04 lignes dans l'ordre de l'arbre avec leur profondeur ; périmètre = exigence et descendants")
    void rows() {
        ProjectTrace trace = trace(Map.of());
        assertThat(trace.rows()).extracting(r -> r.requirement().getKey() + "@" + r.depth())
                .containsExactly("REQ-1@0", "REQ-2@1", "REQ-3@2", "REQ-4@2", "REQ-5@2");
        assertThat(trace.scope(feature)).hasSize(4);
        assertThat(trace.isLeaf(feature)).isFalse();
        assertThat(trace.isLeaf(s1)).isTrue();
    }

    @Test
    @DisplayName("§7.3 RELATES_TO ne couvre pas ; le parent agrège ses enfants actifs (l'obsolète est ignoré)")
    void statuses() {
        ProjectTrace trace = trace(Map.of(t1.getId(), new LastExecution(ExecutionStatus.PASSED, Instant.now())));
        assertThat(trace.status(s1)).isEqualTo(VerificationStatus.VALIDATED);
        assertThat(trace.status(s2)).isEqualTo(VerificationStatus.NOT_COVERED);
        assertThat(trace.status(feature)).isEqualTo(VerificationStatus.IN_PROGRESS);
        assertThat(trace.status(epic)).isEqualTo(VerificationStatus.IN_PROGRESS);
    }

    @Test
    @DisplayName("§3.3-7 un lien suspect rend l'exigence et ses parents suspects")
    void suspect() {
        links.getFirst().markSuspect(Instant.now());
        ProjectTrace trace = trace(Map.of(t1.getId(), new LastExecution(ExecutionStatus.PASSED, Instant.now())));
        assertThat(trace.status(s1)).isEqualTo(VerificationStatus.SUSPECT);
        assertThat(trace.status(epic)).isEqualTo(VerificationStatus.SUSPECT);
    }

    @Test
    @DisplayName("F-REQ-12 état calculé des critères ; F-REQ-19 « tous les tests liés passés »")
    void criteria() {
        ProjectTrace never = trace(Map.of());
        AcceptanceCriterion first = s1.getCriteria().getFirst();
        assertThat(never.criterionStatus(first)).isEqualTo(CriterionStatus.TO_VERIFY);
        assertThat(never.allCoveringTestsPassed(s1)).isFalse();

        ProjectTrace failed = trace(Map.of(t1.getId(), new LastExecution(ExecutionStatus.FAILED, Instant.now())));
        assertThat(failed.criterionStatus(first)).isEqualTo(CriterionStatus.FAILED);
        assertThat(failed.criterionStatus(s1.getCriteria().get(1))).isEqualTo(CriterionStatus.TO_VERIFY);

        ProjectTrace passed = trace(Map.of(t1.getId(), new LastExecution(ExecutionStatus.PASSED, Instant.now())));
        assertThat(passed.criterionStatus(first)).isEqualTo(CriterionStatus.VERIFIED);
        assertThat(passed.allCoveringTestsPassed(s1)).isTrue();
    }

    @Test
    @DisplayName("§7.2 couverture d'un périmètre : feuilles actives, critères, poids du risque")
    void coverage() {
        Coverage coverage = trace(Map.of()).coverage(trace(Map.of()).scope(feature));
        assertThat(coverage.design()).isEqualTo(new Indicator(1, 2));
        assertThat(coverage.criteria()).isEqualTo(new Indicator(1, 2));
        assertThat(coverage.execution()).isEqualTo(new Indicator(0, 1));
        // REQ-3 HIGH (4) couverte ; REQ-4 MEDIUM par défaut (2) non couverte.
        assertThat(coverage.riskWeighted()).isEqualTo(new Indicator(4, 6));
    }
}
