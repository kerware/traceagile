package com.traceagile.api.reporting;

import com.traceagile.application.reporting.ReportData;
import com.traceagile.domain.reporting.ReportFormat;
import com.traceagile.domain.reporting.ReportScopeType;
import com.traceagile.domain.reporting.ReportSection;
import com.traceagile.domain.reporting.Verdict;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** DTO des bilans et rapports configurables (§9, ADR-0023). */
public final class ReportDtos {

    private ReportDtos() {
    }

    public record ReportDefinitionResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            String description,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ReportScopeType scopeType,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<ReportSection> sections,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ReportFormat defaultFormat,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean includeCharts,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean includeDetails,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Définition intégrée (§9.2 / §9.3) : non modifiable") boolean builtIn) {
    }

    /** Création ou remplacement complet d'une définition. */
    public record ReportDefinitionRequest(
            @NotBlank @Size(max = 120) String name,
            @Size(max = 2000) String description,
            @NotNull ReportScopeType scopeType,
            @NotEmpty List<ReportSection> sections,
            ReportFormat defaultFormat,
            boolean includeCharts,
            boolean includeDetails) {
    }

    /** Génération d'un rapport : définition, sprint / release visé (rien pour le projet), titre facultatif. */
    public record GenerateReportRequest(
            @NotNull UUID definitionId,
            @Schema(description = "SPR-n ou REL-n selon le périmètre de la définition") String scopeKey,
            @Size(max = 200) String title) {
    }

    public record ReportSummaryResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String definitionName,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ReportScopeType scopeType,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String scope,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String scopeLabel,
            @Schema(description = "Verdict retenu (modifié par le PO ou calculé)") Verdict verdict,
            Verdict computedVerdict,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean frozen,
            Instant frozenAt,
            String frozenBy,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant createdAt,
            String createdBy) {
    }

    public record ReportDetailResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ReportSummaryResponse report,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<ReportSection> sections,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean includeCharts,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean includeDetails,
            Verdict verdictOverride,
            String verdictComment,
            String verdictBy,
            Instant verdictAt,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ReportData data) {
    }

    /** §9.2 verdict modifié par le PO ({@code verdict} absent = revenir au verdict calculé). */
    public record VerdictRequest(Verdict verdict, @Size(max = 2000) String comment) {
    }

    /** §9.2 règles du verdict du projet. */
    public record VerdictRulesDto(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) @NotNull @DecimalMin("0") @DecimalMax("100") Double goMinValidation,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) @NotNull @DecimalMin("0") @DecimalMax("100") Double reservedMinValidation,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean goForbidsCriticalDefects,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean goRequiresCriticalRequirements,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean reservedForbidsBlockerDefects) {
    }
}
