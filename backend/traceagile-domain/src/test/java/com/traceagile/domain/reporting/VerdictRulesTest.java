package com.traceagile.domain.reporting;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.reporting.VerdictRules.Facts;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/** §9.2 règles par défaut du verdict de bilan ; paramétrage par projet (ADR-0023). */
class VerdictRulesTest {

    @ParameterizedTest(name = "validation {0} %, BLOCKER {1}, CRITICAL {2}, exigences CRITICAL non validées {3} → {4}")
    @CsvSource({
            "100, 0, 0, 0, GO",
            "95, 0, 0, 0, GO",
            "94.9, 0, 0, 0, GO_WITH_RESERVATIONS",
            "100, 0, 1, 0, GO_WITH_RESERVATIONS",
            "100, 0, 0, 1, GO_WITH_RESERVATIONS",
            "80, 0, 2, 0, GO_WITH_RESERVATIONS",
            "79.9, 0, 0, 0, NO_GO",
            "100, 1, 0, 0, NO_GO",
            ", 0, 0, 0, NO_GO"})
    @DisplayName("§9.2 Go ≥ 95 % sans BLOCKER/CRITICAL ni exigence CRITICAL non validée ; Go sous réserve ≥ 80 % sans BLOCKER ; No go sinon")
    void defaults(Double validation, int blockers, int criticals, int criticalRequirements, Verdict expected) {
        assertThat(VerdictRules.DEFAULT.evaluate(new Facts(validation, blockers, criticals, criticalRequirements)).verdict()).isEqualTo(expected);
    }

    @Test
    @DisplayName("§9.2 la synthèse déduit l'objectif du verdict ; les motifs expliquent pourquoi ce n'est pas Go")
    void objectiveAndReasons() {
        VerdictRules.Evaluation evaluation = VerdictRules.DEFAULT.evaluate(new Facts(75.0, 1, 0, 2));
        assertThat(evaluation.verdict().objective()).isEqualTo(SprintObjective.NOT_ACHIEVED);
        assertThat(evaluation.reasons()).containsExactly("taux de validation 75 % < 95 %", "1 anomalie(s) BLOCKER ouverte(s)",
                "2 exigence(s) CRITICAL non validée(s)");
        assertThat(Verdict.GO_WITH_RESERVATIONS.objective()).isEqualTo(SprintObjective.PARTIALLY_ACHIEVED);
        assertThat(Verdict.GO.objective()).isEqualTo(SprintObjective.ACHIEVED);
    }

    @Test
    @DisplayName("ADR-0023 règles paramétrables : seuils et conditions ; seuils entre 0 et 100, « sous réserve » ≤ « Go »")
    void custom() {
        VerdictRules lenient = new VerdictRules(90, 60, false, false, true);
        assertThat(lenient.evaluate(new Facts(91.0, 0, 3, 1)).verdict()).isEqualTo(Verdict.GO);
        assertThat(lenient.evaluate(new Facts(61.0, 0, 0, 0)).verdict()).isEqualTo(Verdict.GO_WITH_RESERVATIONS);
        assertThatThrownBy(() -> new VerdictRules(80, 90, true, true, true)).extracting("code").isEqualTo("VERDICT_RULES_INVALID");
        assertThatThrownBy(() -> new VerdictRules(120, 90, true, true, true)).extracting("code").isEqualTo("VERDICT_RULES_INVALID");
    }
}
