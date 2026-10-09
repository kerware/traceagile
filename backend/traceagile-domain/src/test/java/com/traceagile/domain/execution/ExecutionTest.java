package com.traceagile.domain.execution;

import static com.traceagile.domain.execution.ExecutionStatus.BLOCKED;
import static com.traceagile.domain.execution.ExecutionStatus.FAILED;
import static com.traceagile.domain.execution.ExecutionStatus.NOT_RUN;
import static com.traceagile.domain.execution.ExecutionStatus.PASSED;
import static com.traceagile.domain.execution.ExecutionStatus.SKIPPED;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.campaign.CampaignScope;
import com.traceagile.domain.testcase.DataSet;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.testcase.TestParameter;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/** §8.4 exécution manuelle pas à pas (F-EXE-01 à F-EXE-04), §3.3-5 version exécutée. */
class ExecutionTest {

    final Project shop = new Project("SHOP", "Boutique", null);
    final Instant t0 = Instant.parse("2026-10-09T09:00:00Z");

    CampaignItem item() {
        TestCase test = TestCase.manual(shop, "TC-1", "Ajouter au panier");
        test.addStep("Ouvrir la fiche de ${produit}", "La fiche de ${produit} s'affiche", null);
        test.addStep("Cliquer « Ajouter »", "Le total vaut ${prix}", null);
        test.addStep("Ouvrir le panier", "1 article", null);
        test.setParameters(List.of(new TestParameter("prix", "2,50 €", null)));
        test.setDataSets(List.of(DataSet.of("Recette", List.of(Map.of("produit", "Stylo"), Map.of("produit", "Cahier", "prix", "3,90 €")))));
        test.changeStatus(TestCaseStatus.READY);
        Campaign campaign = new Campaign(shop, "CMP-1", "Régression", CampaignScope.REGRESSION, null, null, "recette", "2.0", null, null);
        return campaign.add(test, 1);
    }

    @ParameterizedTest(name = "{0} → {1}")
    @CsvSource({
            "'PASSED,PASSED,PASSED',   PASSED",
            "'PASSED,FAILED,BLOCKED',  FAILED",
            "'PASSED,BLOCKED,PASSED',  BLOCKED",
            "'PASSED,NOT_RUN,NOT_RUN', RUNNING",
            "'FAILED,NOT_RUN,NOT_RUN', FAILED",
            "'PASSED,SKIPPED,PASSED',  PASSED",
            "'SKIPPED,SKIPPED',        SKIPPED",
    })
    @DisplayName("F-EXE-02 statut global déduit des pas")
    void derive(String steps, ExecutionStatus expected) {
        assertThat(ExecutionRules.derive(java.util.Arrays.stream(steps.split(",")).map(ExecutionStatus::valueOf).toList())).isEqualTo(expected);
    }

    @Test
    @DisplayName("§3.3-5 / ADR-0013 l'exécution fige les pas de la version exécutée, paramètres résolus par la ligne du jeu choisi")
    void snapshot() {
        CampaignItem item = item();
        Execution execution = Execution.manual(item, "qa1", t0, "Recette", 1);

        assertThat(execution.getAttempt()).isEqualTo(1);
        assertThat(execution.getStatus()).isEqualTo(ExecutionStatus.RUNNING);
        assertThat(execution.getTestCaseVersion()).isEqualTo(1);
        assertThat(execution.getParameterValues()).containsEntry("produit", "Cahier").containsEntry("prix", "3,90 €");
        assertThat(execution.getSteps()).extracting(StepResult::getAction)
                .containsExactly("Ouvrir la fiche de Cahier", "Cliquer « Ajouter »", "Ouvrir le panier");
        assertThat(execution.getSteps().get(1).getExpectedResult()).isEqualTo("Le total vaut 3,90 €");

        Execution defaults = Execution.manual(item, "qa1", t0, null, null);
        assertThat(defaults.getAttempt()).as("F-EXE-04 nouvelle tentative").isEqualTo(2);
        assertThat(defaults.getSteps().get(1).getExpectedResult()).isEqualTo("Le total vaut 2,50 €");
        assertThat(defaults.getSteps().getFirst().getAction()).as("paramètre sans valeur : laissé tel quel").isEqualTo("Ouvrir la fiche de ${produit}");
        assertThatThrownBy(() -> Execution.manual(item, "qa1", t0, "Inconnu", 0)).extracting("code").isEqualTo("EXECUTION_DATASET_UNKNOWN");
        assertThatThrownBy(() -> Execution.manual(item, "qa1", t0, "Recette", 5)).extracting("code").isEqualTo("EXECUTION_DATASET_UNKNOWN");
    }

    @Test
    @DisplayName("F-EXE-01 / F-EXE-02 saisie pas à pas ; fin et durée quand le statut est final")
    void steps() {
        Execution execution = Execution.manual(item(), "qa1", t0, null, null);
        execution.recordStep(1, PASSED, null, t0.plusSeconds(30));
        assertThat(execution.getStatus()).isEqualTo(ExecutionStatus.RUNNING);
        execution.recordStep(2, FAILED, "Le total vaut 0 €", t0.plusSeconds(90));
        assertThat(execution.getStatus()).isEqualTo(FAILED);
        assertThat(execution.getEndedAt()).isEqualTo(t0.plusSeconds(90));
        assertThat(execution.getDurationMs()).isEqualTo(90_000);
        assertThat(execution.getSteps().get(1).getActualResult()).isEqualTo("Le total vaut 0 €");
        assertThat(execution.firstFailedStep()).hasValueSatisfying(s -> assertThat(s.getPosition()).isEqualTo(2));
        assertThatThrownBy(() -> execution.recordStep(9, PASSED, null, t0)).extracting("code").isEqualTo("EXECUTION_STEP_UNKNOWN");
        assertThatCode(() -> execution.recordStep(1, NOT_RUN, null, t0)).as("un pas peut être remis à jouer").doesNotThrowAnyException();
    }

    @Test
    @DisplayName("F-EXE-02 statut modifiable avec commentaire obligatoire")
    void override() {
        Execution execution = Execution.manual(item(), "qa1", t0, null, null);
        execution.recordStep(1, BLOCKED, "Serveur indisponible", t0.plusSeconds(10));
        assertThatThrownBy(() -> execution.override(SKIPPED, " ", t0)).extracting("code").isEqualTo("EXECUTION_COMMENT_REQUIRED");
        execution.override(SKIPPED, "Fonction désactivée sur cet environnement", t0.plusSeconds(20));
        assertThat(execution.getStatus()).isEqualTo(SKIPPED);
        assertThat(execution.isStatusOverridden()).isTrue();
        execution.recordStep(2, PASSED, null, t0.plusSeconds(30));
        assertThat(execution.getStatus()).as("le statut forcé est conservé").isEqualTo(SKIPPED);
        assertThatThrownBy(() -> execution.override(ExecutionStatus.RUNNING, "x", t0)).extracting("code").isEqualTo("EXECUTION_STATUS_INVALID");
    }

    @Test
    @DisplayName("F-EXE-10 / lot 7 résultat enregistré sans pas (import, automatisé)")
    void recorded() {
        Execution execution = Execution.recorded(item(), ExecutionOrigin.AUTOMATED, PASSED, "runner", t0, t0.plusSeconds(5), null);
        assertThat(execution.getOrigin()).isEqualTo(ExecutionOrigin.AUTOMATED);
        assertThat(execution.getDurationMs()).isEqualTo(5_000);
        assertThat(execution.getSteps()).isEmpty();
        assertThatThrownBy(() -> execution.recordStep(1, PASSED, null, t0)).extracting("code").isEqualTo("EXECUTION_STEP_UNKNOWN");
    }

    @Test
    @DisplayName("ADR-0013 résolution des ${paramètres}")
    void resolve() {
        assertThat(ParameterResolver.resolve("Payer ${montant} avec ${carte}", Map.of("montant", "12 €")))
                .isEqualTo("Payer 12 € avec ${carte}");
        assertThat(ParameterResolver.resolve(null, Map.of())).isNull();
    }
}
