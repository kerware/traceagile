package com.traceagile.domain.traceability;

import static com.traceagile.domain.execution.ExecutionStatus.FAILED;
import static com.traceagile.domain.execution.ExecutionStatus.PASSED;
import static org.assertj.core.api.Assertions.assertThat;

import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.requirement.RiskLevel;
import com.traceagile.domain.traceability.CoverageCalculator.Coverage;
import com.traceagile.domain.traceability.CoverageCalculator.Indicator;
import com.traceagile.domain.traceability.CoverageCalculator.LeafFacts;
import java.util.Arrays;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** §7.2 les cinq indicateurs de couverture (critère de fin du lot 3 : tests unitaires des formules). */
class CoverageCalculatorTest {

    static LeafFacts leaf(RiskLevel risk, ExecutionStatus... coveringResults) {
        return new LeafFacts(risk, Arrays.asList(coveringResults));
    }

    /**
     * Cinq exigences feuilles :
     * A (LOW) non couverte ; B (MEDIUM) 1 test jamais exécuté ; C (HIGH) 2 tests PASSED ;
     * D (CRITICAL) PASSED + FAILED ; E (sans risque) PASSED + jamais exécuté.
     */
    final List<LeafFacts> leaves = List.of(
            leaf(RiskLevel.LOW),
            leaf(RiskLevel.MEDIUM, (ExecutionStatus) null),
            leaf(RiskLevel.HIGH, PASSED, PASSED),
            leaf(RiskLevel.CRITICAL, PASSED, FAILED),
            leaf(null, PASSED, null));

    final Coverage coverage = CoverageCalculator.compute(leaves, 6, 10);

    @Test
    @DisplayName("§7.2 couverture de conception = feuilles avec ≥ 1 lien VERIFIES / PARTIALLY_VERIFIES ÷ feuilles")
    void design() {
        assertThat(coverage.design()).isEqualTo(new Indicator(4, 5));
        assertThat(coverage.design().percent()).isEqualTo(80.0);
    }

    @Test
    @DisplayName("§7.2 couverture des critères = critères liés à ≥ 1 test ÷ critères")
    void criteria() {
        assertThat(coverage.criteria()).isEqualTo(new Indicator(6, 10));
    }

    @Test
    @DisplayName("§7.2 couverture d'exécution = exigences dont tous les tests liés ont été exécutés ÷ exigences couvertes")
    void execution() {
        assertThat(coverage.execution()).isEqualTo(new Indicator(2, 4));
    }

    @Test
    @DisplayName("§7.2 taux de validation = exigences dont chaque test lié a PASSED en dernier ÷ exigences couvertes")
    void validation() {
        assertThat(coverage.validation()).isEqualTo(new Indicator(1, 4));
    }

    @Test
    @DisplayName("§7.2 couverture pondérée par le risque : poids 1, 2, 4, 8 (sans risque : 1, ADR-0014)")
    void riskWeighted() {
        // couvertes : B 2 + C 4 + D 8 + E 1 = 15 ; total : 1 + 2 + 4 + 8 + 1 = 16
        assertThat(coverage.riskWeighted()).isEqualTo(new Indicator(15, 16));
        assertThat(coverage.riskWeighted().percent()).isEqualTo(93.75);
    }

    @Test
    @DisplayName("§7.2 périmètre vide : indicateurs sans pourcentage (pas de division par zéro)")
    void empty() {
        Coverage none = CoverageCalculator.compute(List.of(), 0, 0);
        assertThat(none.design().percent()).isNull();
        assertThat(none.validation().percent()).isNull();
    }
}
