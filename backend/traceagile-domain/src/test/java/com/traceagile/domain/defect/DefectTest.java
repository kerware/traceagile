package com.traceagile.domain.defect;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignScope;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import java.time.Instant;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/** §8.6 anomalies (F-DEF-01, F-DEF-02) ; F-EXE-03 anomalie pré-remplie depuis un pas en échec. */
class DefectTest {

    final Project shop = new Project("SHOP", "Boutique", null);

    @Test
    @DisplayName("F-DEF-01 une anomalie a un titre et une sévérité ; statut initial OPEN ; référence externe (F-DEF-02)")
    void create() {
        Defect defect = new Defect(shop, "DEF-1", "Total faux", "…", DefectSeverity.CRITICAL);
        assertThat(defect.getStatus()).isEqualTo(DefectStatus.OPEN);
        assertThat(defect.isOpenBlocking()).isTrue();
        defect.setExternalRef(" JIRA-42 ");
        assertThat(defect.getExternalRef()).isEqualTo("JIRA-42");
        assertThatThrownBy(() -> new Defect(shop, "DEF-2", " ", null, DefectSeverity.MINOR)).extracting("code").isEqualTo("DEFECT_TITLE_REQUIRED");
    }

    @ParameterizedTest(name = "{0} → {1} : {2}")
    @CsvSource({
            "OPEN,        IN_PROGRESS, true",
            "OPEN,        REJECTED,    true",
            "IN_PROGRESS, RESOLVED,    true",
            "RESOLVED,    CLOSED,      true",
            "RESOLVED,    OPEN,        true",
            "CLOSED,      OPEN,        true",
            "OPEN,        CLOSED,      false",
            "REJECTED,    RESOLVED,    false",
    })
    @DisplayName("F-DEF-01 OPEN → IN_PROGRESS → RESOLVED → CLOSED, ou REJECTED ; réouverture")
    void transitions(DefectStatus from, DefectStatus to, boolean allowed) {
        assertThat(from.canMoveTo(to)).isEqualTo(allowed);
    }

    @Test
    @DisplayName("ADR-0016 « ouverte » = OPEN ou IN_PROGRESS ; « bloquante » = BLOCKER ou CRITICAL")
    void openBlocking() {
        Defect defect = new Defect(shop, "DEF-1", "Paiement impossible", null, DefectSeverity.BLOCKER);
        defect.changeStatus(DefectStatus.IN_PROGRESS);
        assertThat(defect.isOpenBlocking()).isTrue();
        defect.changeStatus(DefectStatus.RESOLVED);
        assertThat(defect.isOpenBlocking()).isFalse();
        assertThatThrownBy(() -> defect.changeStatus(DefectStatus.IN_PROGRESS)).extracting("code").isEqualTo("DEFECT_STATUS_TRANSITION_INVALID");
        assertThat(new Defect(shop, "DEF-2", "Libellé", null, DefectSeverity.MAJOR).isOpenBlocking()).isFalse();
    }

    @Test
    @DisplayName("F-EXE-03 brouillon : étapes jusqu'au pas en échec, attendu, obtenu, environnement, build")
    void draft() {
        TestCase test = TestCase.manual(shop, "TC-7", "Payer par carte");
        test.addStep("Ouvrir le panier", "Le panier s'affiche", null);
        test.addStep("Payer", "Paiement accepté", "carte 4970…");
        test.addStep("Voir la confirmation", "Numéro de commande", null);
        test.changeStatus(TestCaseStatus.READY);
        Campaign campaign = new Campaign(shop, "CMP-3", "Régression", CampaignScope.REGRESSION, null, null, "recette", "2.0.1", null, null);
        Instant t0 = Instant.parse("2026-10-09T09:00:00Z");
        Execution execution = Execution.manual(campaign.add(test, 1), "qa1", t0, null, null);
        execution.recordStep(1, ExecutionStatus.PASSED, null, t0);
        execution.recordStep(2, ExecutionStatus.FAILED, "Erreur 500", t0);

        DefectDraft draft = DefectDraft.from(execution);

        assertThat(draft.title()).isEqualTo("TC-7 Payer par carte : échec au pas 2 (Payer)");
        assertThat(draft.severity()).isEqualTo(DefectSeverity.MAJOR);
        assertThat(draft.description())
                .contains("CMP-3", "recette", "2.0.1", "tentative 1")
                .contains("1. Ouvrir le panier", "2. Payer (données : carte 4970…)")
                .contains("**Attendu** : Paiement accepté", "**Obtenu** : Erreur 500")
                .doesNotContain("Voir la confirmation");
    }
}
