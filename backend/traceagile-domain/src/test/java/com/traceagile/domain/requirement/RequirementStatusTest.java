package com.traceagile.domain.requirement;

import static com.traceagile.domain.requirement.RequirementStatus.*;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Project;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/** §3.2 Cycle de vie des exigences ; §3.3-2 Definition of Ready minimale. */
class RequirementStatusTest {

    final Project shop = new Project("SHOP", "Boutique", null);

    @ParameterizedTest(name = "{0} → {1} : {2}")
    @CsvSource({
            "DRAFT,     TO_REFINE, true",
            "DRAFT,     READY,     true",
            "TO_REFINE, READY,     true",
            "TO_REFINE, DRAFT,     true",
            "READY,     IN_SPRINT, true",
            "READY,     TO_REFINE, true",
            "IN_SPRINT, DONE,      true",
            "IN_SPRINT, READY,     true",
            "DONE,      ACCEPTED,  true",
            "DONE,      IN_SPRINT, true",
            "ACCEPTED,  DONE,      true",
            "DRAFT,     REJECTED,  true",
            "REJECTED,  DRAFT,     true",
            "READY,     OBSOLETE,  true",
            "ACCEPTED,  OBSOLETE,  true",
            "DRAFT,     DONE,      false",
            "DRAFT,     IN_SPRINT, false",
            "READY,     ACCEPTED,  false",
            "IN_SPRINT, ACCEPTED,  false",
            "ACCEPTED,  REJECTED,  false",
            "OBSOLETE,  DRAFT,     false",
            "DONE,      DONE,      false",
    })
    @DisplayName("§3.2 transitions autorisées")
    void transitions(RequirementStatus from, RequirementStatus to, boolean allowed) {
        assertThat(from.canMoveTo(to)).isEqualTo(allowed);
    }

    @Test
    @DisplayName("§3.2 transition interdite → REQ_STATUS_TRANSITION_INVALID")
    void invalidTransition() {
        Requirement epic = new Requirement(shop, "REQ-1", RequirementType.EPIC, "Catalogue", "i");

        assertThatThrownBy(() -> epic.changeStatus(DONE))
                .extracting("code").isEqualTo("REQ_STATUS_TRANSITION_INVALID");
    }

    @Test
    @DisplayName("§3.3-2 une exigence ne passe à READY qu'avec au moins un critère d'acceptation")
    void readyRequiresCriterion() {
        Requirement epic = new Requirement(shop, "REQ-1", RequirementType.EPIC, "Catalogue", "i");

        assertThatThrownBy(() -> epic.changeStatus(READY))
                .extracting("code").isEqualTo("REQ_READY_WITHOUT_CRITERIA");

        epic.addCriterion(CriterionFormat.TEXT, "Le catalogue est consultable");
        epic.changeStatus(READY);
        assertThat(epic.getStatus()).isEqualTo(READY);
    }

    @Test
    @DisplayName("§3.3-6 une exigence OBSOLETE ne se modifie plus")
    void obsoleteIsFrozen() {
        Requirement epic = new Requirement(shop, "REQ-1", RequirementType.EPIC, "Catalogue", "i");
        epic.changeStatus(OBSOLETE);

        assertThatThrownBy(() -> epic.rename("Autre"))
                .extracting("code").isEqualTo("REQ_OBSOLETE");
    }
}
