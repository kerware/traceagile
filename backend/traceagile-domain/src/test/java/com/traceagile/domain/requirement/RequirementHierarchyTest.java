package com.traceagile.domain.requirement;

import static com.traceagile.domain.requirement.RequirementType.*;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.BusinessRuleException;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** §3.3-1 Règles de parenté et absence de cycle ; F-REQ-02 déplacement. */
class RequirementHierarchyTest {

    final Project shop = new Project("SHOP", "Boutique", null);

    Requirement req(RequirementType type, String key) {
        return new Requirement(shop, key, type, "Titre " + key, "i");
    }

    @ParameterizedTest(name = "{0} sous {1} → autorisé : {2}")
    @CsvSource({
            // enfant,           parent,             autorisé
            "EPIC,               EPIC,               false",
            "EPIC,               FEATURE,            false",
            "FEATURE,            EPIC,               true",
            "FEATURE,            FEATURE,            false",
            "FEATURE,            USER_STORY,         false",
            "USER_STORY,         FEATURE,            true",
            "USER_STORY,         EPIC,               true",
            "USER_STORY,         USER_STORY,         false",
            "USER_STORY,         BUSINESS_RULE,      false",
            "BUSINESS_RULE,      EPIC,               true",
            "BUSINESS_RULE,      USER_STORY,         true",
            "BUSINESS_RULE,      BUSINESS_RULE,      true",
            "NON_FUNCTIONAL,     FEATURE,            true",
            "NON_FUNCTIONAL,     USER_STORY,         true",
            "TECHNICAL_ENABLER,  FEATURE,            true",
            "TECHNICAL_ENABLER,  EPIC,               true",
            "TECHNICAL_ENABLER,  USER_STORY,         false",
    })
    @DisplayName("§3.3-1 parents autorisés par type")
    void allowedParents(RequirementType child, RequirementType parent, boolean allowed) {
        Requirement p = req(parent, "REQ-1");
        Requirement c = req(child, "REQ-2");
        if (allowed) {
            assertThatCode(() -> c.moveUnder(p)).doesNotThrowAnyException();
            assertThat(c.getParent()).isSameAs(p);
            assertThat(p.getChildren()).contains(c);
        } else {
            assertThatThrownBy(() -> c.moveUnder(p))
                    .isInstanceOf(BusinessRuleException.class)
                    .extracting("code").isEqualTo("REQ_PARENT_INVALID");
        }
    }

    @Test
    @DisplayName("§3.3-1 une EPIC, une FEATURE, une règle, une ENF ou un enabler peuvent être sans parent")
    void rootAllowed() {
        for (RequirementType type : new RequirementType[]{EPIC, FEATURE, BUSINESS_RULE, NON_FUNCTIONAL, TECHNICAL_ENABLER}) {
            assertThat(type.allowsNoParent()).as(type.name()).isTrue();
        }
    }

    @Test
    @DisplayName("§3.3-1 une USER_STORY a obligatoirement un parent FEATURE ou EPIC")
    void storyNeedsParent() {
        Requirement story = req(USER_STORY, "REQ-3");
        assertThatThrownBy(() -> story.moveUnder(null))
                .isInstanceOf(BusinessRuleException.class)
                .extracting("code").isEqualTo("REQ_PARENT_REQUIRED");
        assertThatThrownBy(story::checkHierarchy)
                .extracting("code").isEqualTo("REQ_PARENT_REQUIRED");
    }

    @Test
    @DisplayName("§3.3-1 aucun cycle : une règle ne peut pas descendre sous sa propre descendante")
    void noCycle() {
        Requirement r1 = req(BUSINESS_RULE, "REQ-1");
        Requirement r2 = req(BUSINESS_RULE, "REQ-2");
        Requirement r3 = req(BUSINESS_RULE, "REQ-3");
        r2.moveUnder(r1);
        r3.moveUnder(r2);

        assertThatThrownBy(() -> r1.moveUnder(r3))
                .isInstanceOf(BusinessRuleException.class)
                .extracting("code").isEqualTo("REQ_CYCLE");
        assertThatThrownBy(() -> r1.moveUnder(r1))
                .extracting("code").isEqualTo("REQ_CYCLE");
    }

    @Test
    @DisplayName("F-REQ-02 déplacer retire l'exigence des enfants de l'ancien parent")
    void moveDetachesFromPreviousParent() {
        Requirement epic1 = req(EPIC, "REQ-1");
        Requirement epic2 = req(EPIC, "REQ-2");
        Requirement feature = req(FEATURE, "REQ-3");
        feature.moveUnder(epic1);

        feature.moveUnder(epic2);

        assertThat(epic1.getChildren()).isEmpty();
        assertThat(epic2.getChildren()).containsExactly(feature);
    }

    @Test
    @DisplayName("§3.3-1 le parent appartient au même projet")
    void sameProject() {
        Requirement epic = new Requirement(new Project("BANK", "Banque", null), "REQ-1", EPIC, "Epic", "i");
        Requirement feature = req(FEATURE, "REQ-2");

        assertThatThrownBy(() -> feature.moveUnder(epic))
                .extracting("code").isEqualTo("REQ_PARENT_INVALID");
    }

    @Test
    @DisplayName("§3.3-1 changer le type revérifie le parent et les enfants")
    void changingTypeRechecksHierarchy() {
        Requirement epic = req(EPIC, "REQ-1");
        Requirement feature = req(FEATURE, "REQ-2");
        Requirement story = req(USER_STORY, "REQ-3");
        feature.moveUnder(epic);
        story.moveUnder(feature);

        // Une FEATURE devenue USER_STORY ne peut plus porter de story.
        assertThatThrownBy(() -> feature.changeType(USER_STORY))
                .extracting("code").isEqualTo("REQ_PARENT_INVALID");
        assertThat(feature.getType()).isEqualTo(FEATURE);
        // Une FEATURE avec parent EPIC ne peut pas devenir EPIC.
        assertThatThrownBy(() -> feature.changeType(EPIC))
                .extracting("code").isEqualTo("REQ_PARENT_INVALID");
    }
}
