package com.traceagile.domain.traceability;

import static com.traceagile.domain.execution.ExecutionStatus.BLOCKED;
import static com.traceagile.domain.execution.ExecutionStatus.ERROR;
import static com.traceagile.domain.execution.ExecutionStatus.FAILED;
import static com.traceagile.domain.execution.ExecutionStatus.PASSED;
import static com.traceagile.domain.execution.ExecutionStatus.SKIPPED;
import static org.assertj.core.api.Assertions.assertThat;

import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.requirement.CriterionStatus;
import java.util.Arrays;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/** §7.3 statut de vérification d'une exigence ; F-REQ-12 état d'un critère. */
class VerificationRulesTest {

    /** Dernier résultat de chaque test couvrant ; {@code null} = jamais exécuté. */
    static List<ExecutionStatus> results(ExecutionStatus... statuses) {
        return Arrays.asList(statuses);
    }

    @Test
    @DisplayName("§7.3 Non couverte : aucun test lié (VERIFIES / PARTIALLY_VERIFIES)")
    void notCovered() {
        assertThat(VerificationRules.leaf(List.of(), false, false)).isEqualTo(VerificationStatus.NOT_COVERED);
    }

    @Test
    @DisplayName("§7.3 Non exécutée : tests liés, aucune exécution")
    void notRun() {
        assertThat(VerificationRules.leaf(results(null, null), false, false)).isEqualTo(VerificationStatus.NOT_RUN);
        assertThat(VerificationRules.leaf(results(SKIPPED), false, false)).isEqualTo(VerificationStatus.NOT_RUN);
    }

    @Test
    @DisplayName("§7.3 En cours : au moins une exécution, d'autres non exécutées")
    void inProgress() {
        assertThat(VerificationRules.leaf(results(PASSED, null), false, false)).isEqualTo(VerificationStatus.IN_PROGRESS);
    }

    @Test
    @DisplayName("§7.3 Validée : dernière exécution de chaque test lié = PASSED")
    void validated() {
        assertThat(VerificationRules.leaf(results(PASSED, PASSED), false, false)).isEqualTo(VerificationStatus.VALIDATED);
    }

    @Test
    @DisplayName("§7.3 En échec : un test FAILED ou une anomalie bloquante / critique ouverte")
    void failed() {
        assertThat(VerificationRules.leaf(results(PASSED, FAILED, BLOCKED), false, false)).isEqualTo(VerificationStatus.FAILED);
        assertThat(VerificationRules.leaf(results(PASSED), true, false)).isEqualTo(VerificationStatus.FAILED);
    }

    @Test
    @DisplayName("§7.3 Bloquée : un test BLOCKED (ou ERROR, ADR-0014), aucun FAILED")
    void blocked() {
        assertThat(VerificationRules.leaf(results(PASSED, BLOCKED), false, false)).isEqualTo(VerificationStatus.BLOCKED);
        assertThat(VerificationRules.leaf(results(ERROR), false, false)).isEqualTo(VerificationStatus.BLOCKED);
    }

    @Test
    @DisplayName("§7.3 / §3.3-7 Suspecte : exigence modifiée depuis ; l'échec reste prioritaire")
    void suspect() {
        assertThat(VerificationRules.leaf(results(PASSED, PASSED), false, true)).isEqualTo(VerificationStatus.SUSPECT);
        assertThat(VerificationRules.leaf(results((ExecutionStatus) null), false, true)).isEqualTo(VerificationStatus.SUSPECT);
        assertThat(VerificationRules.leaf(results(FAILED), false, true)).isEqualTo(VerificationStatus.FAILED);
    }

    @ParameterizedTest(name = "{0} → {1}")
    @CsvSource({
            "'VALIDATED,VALIDATED',          VALIDATED",
            "'VALIDATED,NOT_RUN',            IN_PROGRESS",
            "'NOT_RUN,NOT_COVERED',          NOT_RUN",
            "'NOT_COVERED,NOT_COVERED',      NOT_COVERED",
            "'VALIDATED,FAILED,SUSPECT',     FAILED",
            "'VALIDATED,SUSPECT,BLOCKED',    SUSPECT",
            "'VALIDATED,BLOCKED',            BLOCKED",
            "'VALIDATED,NOT_COVERED',        IN_PROGRESS",
    })
    @DisplayName("§7.2 une exigence parente agrège ses enfants : validée si tous le sont")
    void aggregate(String children, VerificationStatus expected) {
        List<VerificationStatus> statuses = Arrays.stream(children.split(",")).map(VerificationStatus::valueOf).toList();
        assertThat(VerificationRules.aggregate(statuses)).isEqualTo(expected);
    }

    @Test
    @DisplayName("F-REQ-12 critère : vérifié si chaque test lié a passé, échoué si l'un a échoué, à vérifier sinon")
    void criterion() {
        assertThat(VerificationRules.criterion(results(PASSED, PASSED))).isEqualTo(CriterionStatus.VERIFIED);
        assertThat(VerificationRules.criterion(results(PASSED, FAILED))).isEqualTo(CriterionStatus.FAILED);
        assertThat(VerificationRules.criterion(results(PASSED, null))).isEqualTo(CriterionStatus.TO_VERIFY);
        assertThat(VerificationRules.criterion(List.of())).isEqualTo(CriterionStatus.TO_VERIFY);
    }
}
