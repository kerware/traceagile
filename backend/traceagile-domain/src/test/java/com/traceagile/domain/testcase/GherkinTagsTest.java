package com.traceagile.domain.testcase;

import static org.assertj.core.api.Assertions.assertThat;

import com.traceagile.domain.testcase.GherkinTags.CriterionTag;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** F-AUT-06 tags Gherkin de traçabilité @REQ-12 et @AC-12-3. */
class GherkinTagsTest {

    @Test
    @DisplayName("F-AUT-06 extrait les tags @REQ-n et @AC-n-m, sans doublon, dans l'ordre")
    void parse() {
        GherkinTags tags = GherkinTags.parse("""
                @REQ-12 @smoke
                Fonctionnalité: Panier
                  @AC-12-3 @REQ-12 @REQ-7
                  Scénario: seuil
                    Étant donné un panier mentionnant REQ-99 sans arobase
                """);

        assertThat(tags.requirementKeys()).containsExactly("REQ-12", "REQ-7");
        assertThat(tags.criteria()).containsExactly(new CriterionTag("REQ-12", 3));
    }

    @Test
    @DisplayName("F-AUT-06 un critère référencé implique son exigence")
    void criterionImpliesRequirement() {
        GherkinTags tags = GherkinTags.parse("@AC-5-1\nScénario: x");

        assertThat(tags.allRequirementKeys()).containsExactly("REQ-5");
    }

    @Test
    @DisplayName("F-AUT-06 source vide : aucun tag")
    void empty() {
        assertThat(GherkinTags.parse(null).allRequirementKeys()).isEmpty();
    }
}
