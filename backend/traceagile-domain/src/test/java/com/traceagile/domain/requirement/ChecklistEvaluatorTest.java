package com.traceagile.domain.requirement;

import static com.traceagile.domain.requirement.ChecklistItemResult.Outcome.*;
import static org.assertj.core.api.Assertions.assertThat;

import com.traceagile.domain.administration.Project;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** F-REQ-19 / F-REQ-20 Definition of Ready et Definition of Done. */
class ChecklistEvaluatorTest {

    final Project shop = new Project("SHOP", "Boutique", null);
    final ChecklistItem hasCriterion = new ChecklistItem(shop, ChecklistKind.DOR, 1, "Au moins un critère", ChecklistRule.HAS_ACCEPTANCE_CRITERION);
    final ChecklistItem estimated = new ChecklistItem(shop, ChecklistKind.DOR, 2, "Estimation renseignée", ChecklistRule.ESTIMATED);
    final ChecklistItem understood = new ChecklistItem(shop, ChecklistKind.DOR, 3, "Comprise par l'équipe", null);
    final ChecklistItem testsPassed = new ChecklistItem(shop, ChecklistKind.DOD, 1, "Tests liés passés", ChecklistRule.ALL_LINKED_TESTS_PASSED);

    /** Faits sur les tests et anomalies : indisponibles au lot 1. */
    final VerificationFacts noFacts = new VerificationFacts() {
        @Override
        public Optional<Boolean> hasLinkedTest(Requirement requirement) {
            return Optional.empty();
        }

        @Override
        public Optional<Boolean> allLinkedTestsPassed(Requirement requirement) {
            return Optional.empty();
        }

        @Override
        public Optional<Boolean> hasOpenBlockingDefect(Requirement requirement) {
            return Optional.empty();
        }
    };

    Requirement story() {
        Requirement feature = new Requirement(shop, "REQ-1", RequirementType.FEATURE, "Panier", "a");
        Requirement story = new Requirement(shop, "REQ-2", RequirementType.USER_STORY, "Payer", "b");
        story.moveUnder(feature);
        return story;
    }

    @Test
    @DisplayName("F-REQ-19 items automatiques vérifiés par l'outil, items manuels cochés par l'utilisateur")
    void evaluate() {
        Requirement story = story();
        story.addCriterion(CriterionFormat.TEXT, "A");

        List<ChecklistItemResult> results = ChecklistEvaluator.evaluate(story, List.of(hasCriterion, estimated, understood), noFacts);

        assertThat(results).extracting(ChecklistItemResult::outcome).containsExactly(SATISFIED, UNSATISFIED, UNSATISFIED);
        assertThat(results).extracting(ChecklistItemResult::automatic).containsExactly(true, true, false);
    }

    @Test
    @DisplayName("F-REQ-19 un item manuel coché est satisfait")
    void manualChecked() {
        Requirement story = story();
        story.check(understood, true);

        assertThat(ChecklistEvaluator.evaluate(story, List.of(understood), noFacts))
                .extracting(ChecklistItemResult::outcome).containsExactly(SATISFIED);

        story.check(understood, false);
        assertThat(ChecklistEvaluator.evaluate(story, List.of(understood), noFacts))
                .extracting(ChecklistItemResult::outcome).containsExactly(UNSATISFIED);
    }

    @Test
    @DisplayName("F-REQ-19 l'estimation ne concerne que les stories et enablers")
    void estimationOnlyForStories() {
        Requirement epic = new Requirement(shop, "REQ-3", RequirementType.EPIC, "Catalogue", "c");

        assertThat(ChecklistEvaluator.evaluate(epic, List.of(estimated), noFacts))
                .extracting(ChecklistItemResult::outcome).containsExactly(SATISFIED);
    }

    @Test
    @DisplayName("F-REQ-19 un item sur les tests sans donnée disponible est « non évalué »")
    void notEvaluatedWithoutFacts() {
        assertThat(ChecklistEvaluator.evaluate(story(), List.of(testsPassed), noFacts))
                .extracting(ChecklistItemResult::outcome).containsExactly(NOT_EVALUATED);
    }

    @Test
    @DisplayName("F-REQ-20 seuls les items automatiques insatisfaits bloquent ; les manuels demandent une confirmation")
    void blocking() {
        Requirement story = story();
        List<ChecklistItemResult> results = ChecklistEvaluator.evaluate(story, List.of(hasCriterion, understood, testsPassed), noFacts);

        assertThat(ChecklistEvaluator.blocking(results)).extracting(r -> r.item().getLabel()).containsExactly("Au moins un critère");
        assertThat(ChecklistEvaluator.needingAcknowledgement(results)).extracting(r -> r.item().getLabel()).containsExactly("Comprise par l'équipe");
    }
}
