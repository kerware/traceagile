package com.traceagile.domain.reporting;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Project;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** ADR-0023 définitions de rapports configurables et instantanés (F-RPT-04, §9.2 verdict modifiable). */
class ReportDefinitionTest {

    final Project shop = new Project("SHOP", "Boutique", null);

    @Test
    @DisplayName("ADR-0023 définitions intégrées : sections du §9.2 / §9.3 dans l'ordre, non modifiables")
    void builtIns() {
        ReportDefinition sprint = ReportDefinition.sprintReview(shop);
        assertThat(sprint.getSections()).containsExactly(ReportSection.SUMMARY, ReportSection.DELIVERY, ReportSection.COVERAGE,
                ReportSection.EXECUTION, ReportSection.EXPLORATORY, ReportSection.DEFECTS, ReportSection.RISKS, ReportSection.RECOMMENDATION);
        assertThat(sprint.isBuiltIn()).isTrue();
        assertThat(ReportDefinition.releaseReview(shop).getSections()).contains(ReportSection.SPRINT_TREND, ReportSection.REGRESSION, ReportSection.NFR);
        assertThatThrownBy(() -> sprint.update("X", null, ReportScopeType.SPRINT, List.of(ReportSection.SUMMARY), ReportFormat.HTML, true, true))
                .extracting("code").isEqualTo("REPORT_DEFINITION_BUILT_IN");
    }

    @Test
    @DisplayName("ADR-0023 définition personnalisée : nom et sections obligatoires, doublons retirés, section sans objet pour le périmètre refusée")
    void custom() {
        ReportDefinition definition = new ReportDefinition(shop, "  Synthèse qualité ", " ", ReportScopeType.SPRINT,
                List.of(ReportSection.COVERAGE, ReportSection.BURNDOWN, ReportSection.COVERAGE), ReportFormat.DOCX, true, false);
        assertThat(definition.getName()).isEqualTo("Synthèse qualité");
        assertThat(definition.getDescription()).isNull();
        assertThat(definition.getSections()).containsExactly(ReportSection.COVERAGE, ReportSection.BURNDOWN);
        assertThat(definition.getDefaultFormat()).isEqualTo(ReportFormat.DOCX);

        assertThatThrownBy(() -> new ReportDefinition(shop, " ", null, ReportScopeType.SPRINT, List.of(ReportSection.SUMMARY), null, false, false))
                .extracting("code").isEqualTo("REPORT_NAME_REQUIRED");
        assertThatThrownBy(() -> new ReportDefinition(shop, "X", null, ReportScopeType.SPRINT, List.of(), null, false, false))
                .extracting("code").isEqualTo("REPORT_SECTIONS_REQUIRED");
        assertThatThrownBy(() -> new ReportDefinition(shop, "X", null, ReportScopeType.SPRINT, List.of(ReportSection.REGRESSION), null, false, false))
                .extracting("code").isEqualTo("REPORT_SECTION_SCOPE");
        assertThatThrownBy(() -> new ReportDefinition(shop, "X", null, null, List.of(ReportSection.SUMMARY), null, false, false))
                .extracting("code").isEqualTo("REPORT_SCOPE_REQUIRED");
    }

    ReportSnapshot snapshot() {
        return new ReportSnapshot(shop, "RPT-3", "Bilan SPR-2", ReportDefinition.SPRINT_REVIEW, ReportScopeType.SPRINT, "sprint:SPR-2",
                "SPR-2 Sprint 2", ReportSection.SPRINT_REVIEW, true, false, Map.of("summary", Map.of()), Verdict.NO_GO);
    }

    @Test
    @DisplayName("§9.2 le PO remplace le verdict avec un commentaire obligatoire, ou revient au verdict calculé")
    void verdictOverride() {
        ReportSnapshot report = snapshot();
        Instant now = Instant.parse("2026-10-20T10:00:00Z");
        assertThat(report.getKeyNumber()).isEqualTo(3);
        assertThatThrownBy(() -> report.overrideVerdict(Verdict.GO_WITH_RESERVATIONS, " ", "po", now))
                .extracting("code").isEqualTo("VERDICT_COMMENT_REQUIRED");
        report.overrideVerdict(Verdict.GO_WITH_RESERVATIONS, "Anomalie bloquante contournée en production", "po", now);
        assertThat(report.getVerdict()).isEqualTo(Verdict.GO_WITH_RESERVATIONS);
        assertThat(report.getComputedVerdict()).isEqualTo(Verdict.NO_GO);
        assertThat(report.getVerdictBy()).isEqualTo("po");
        report.overrideVerdict(null, null, "po", now);
        assertThat(report.getVerdict()).isEqualTo(Verdict.NO_GO);
        assertThat(report.getVerdictComment()).isNull();
    }

    @Test
    @DisplayName("F-RPT-04 un rapport figé ne se supprime plus et ne se fige pas deux fois ; le verdict reste modifiable")
    void freeze() {
        ReportSnapshot report = snapshot();
        report.ensureDeletable();
        report.freeze("po", Instant.parse("2026-10-25T17:00:00Z"));
        assertThat(report.isFrozen()).isTrue();
        assertThatThrownBy(report::ensureDeletable).extracting("code").isEqualTo("REPORT_FROZEN");
        assertThatThrownBy(() -> report.freeze("po", Instant.now())).extracting("code").isEqualTo("REPORT_ALREADY_FROZEN");
        report.overrideVerdict(Verdict.GO, "Validé en comité", "po", Instant.now());
        assertThat(report.getVerdict()).isEqualTo(Verdict.GO);
    }
}
