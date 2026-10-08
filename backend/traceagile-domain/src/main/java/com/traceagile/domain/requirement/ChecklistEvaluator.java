package com.traceagile.domain.requirement;

import com.traceagile.domain.requirement.ChecklistItemResult.Outcome;
import java.util.List;
import java.util.Optional;

/**
 * F-REQ-19 / F-REQ-20 Évaluation de la DoR / DoD d'une exigence. Un item automatique insatisfait
 * bloque le changement de statut ; un item manuel non coché demande une confirmation (ADR-0009).
 */
public final class ChecklistEvaluator {

    private ChecklistEvaluator() {
    }

    public static List<ChecklistItemResult> evaluate(Requirement requirement, List<ChecklistItem> items, VerificationFacts facts) {
        return items.stream().map(item -> new ChecklistItemResult(item, outcome(requirement, item, facts))).toList();
    }

    public static List<ChecklistItemResult> blocking(List<ChecklistItemResult> results) {
        return results.stream().filter(r -> r.automatic() && r.outcome() == Outcome.UNSATISFIED).toList();
    }

    public static List<ChecklistItemResult> needingAcknowledgement(List<ChecklistItemResult> results) {
        return results.stream().filter(r -> !r.automatic() && r.outcome() == Outcome.UNSATISFIED).toList();
    }

    private static Outcome outcome(Requirement requirement, ChecklistItem item, VerificationFacts facts) {
        if (!item.isAutomatic()) {
            return requirement.isChecked(item) ? Outcome.SATISFIED : Outcome.UNSATISFIED;
        }
        return switch (item.getRule()) {
            case HAS_ACCEPTANCE_CRITERION -> of(!requirement.getCriteria().isEmpty());
            case ESTIMATED -> of(!requirement.getType().isEstimable() || requirement.getStoryPoints() != null);
            case HAS_LINKED_TEST -> of(facts.hasLinkedTest(requirement));
            case ALL_LINKED_TESTS_PASSED -> of(facts.allLinkedTestsPassed(requirement));
            case NO_BLOCKING_DEFECT_OPEN -> of(facts.hasOpenBlockingDefect(requirement).map(open -> !open));
        };
    }

    private static Outcome of(boolean satisfied) {
        return satisfied ? Outcome.SATISFIED : Outcome.UNSATISFIED;
    }

    private static Outcome of(Optional<Boolean> satisfied) {
        return satisfied.map(ChecklistEvaluator::of).orElse(Outcome.NOT_EVALUATED);
    }
}
