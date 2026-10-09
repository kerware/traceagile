package com.traceagile.domain.traceability;

import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.requirement.RiskLevel;
import java.util.List;

/** §7.2 indicateurs de couverture d'un périmètre (fonctions pures, testées unitairement). */
public final class CoverageCalculator {

    private CoverageCalculator() {
    }

    /**
     * Faits d'une exigence feuille du périmètre : niveau de risque et dernier résultat de chaque test
     * couvrant (VERIFIES ou PARTIALLY_VERIFIES ; {@code null} = jamais exécuté).
     */
    public record LeafFacts(RiskLevel risk, List<ExecutionStatus> coveringResults) {

        public boolean covered() {
            return !coveringResults.isEmpty();
        }

        public boolean allExecuted() {
            return covered() && coveringResults.stream().allMatch(VerificationRules::executed);
        }

        public boolean allPassed() {
            return covered() && coveringResults.stream().allMatch(r -> r == ExecutionStatus.PASSED);
        }

        /** Poids 1, 2, 4, 8 ; une exigence sans risque renseigné pèse 1 (ADR-0014). */
        public int weight() {
            return risk == null ? 1 : risk.weight();
        }
    }

    /** Ratio ; {@code percent} est {@code null} si le dénominateur est nul. */
    public record Indicator(double numerator, double denominator) {

        public Double percent() {
            return denominator == 0 ? null : Math.round(numerator * 10_000 / denominator) / 100.0;
        }
    }

    public record Coverage(Indicator design, Indicator criteria, Indicator execution, Indicator validation, Indicator riskWeighted) {
    }

    public static Coverage compute(List<LeafFacts> leaves, int linkedCriteria, int criteria) {
        List<LeafFacts> covered = leaves.stream().filter(LeafFacts::covered).toList();
        return new Coverage(
                new Indicator(covered.size(), leaves.size()),
                new Indicator(linkedCriteria, criteria),
                new Indicator(covered.stream().filter(LeafFacts::allExecuted).count(), covered.size()),
                new Indicator(covered.stream().filter(LeafFacts::allPassed).count(), covered.size()),
                new Indicator(covered.stream().mapToInt(LeafFacts::weight).sum(), leaves.stream().mapToInt(LeafFacts::weight).sum()));
    }
}
