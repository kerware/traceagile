package com.traceagile.api.traceability;

import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.requirement.CriterionStatus;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.domain.requirement.RiskLevel;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestTechnique;
import com.traceagile.domain.traceability.LinkOrigin;
import com.traceagile.domain.traceability.LinkType;
import com.traceagile.domain.traceability.VerificationStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** §12 Traçabilité et couverture (§7). */
public final class TraceabilityDtos {

    private TraceabilityDtos() {
    }

    // ---------------------------------------------------------------- liens (F-TRA-01 / F-TRA-02)

    public record CreateLinkRequest(@NotBlank String testKey, @NotBlank String requirementKey, @NotNull LinkType linkType,
                                    List<Integer> criterionPositions) {
    }

    public record UpdateLinkRequest(@NotNull LinkType linkType) {
    }

    public record TraceLinkResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String testKey,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String requirementKey,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LinkType linkType,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LinkOrigin origin,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<Integer> criterionPositions,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean suspect,
            Instant suspectSince,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long version) {
    }

    // ---------------------------------------------------------------- références

    public record RequirementItem(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementType type,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RiskLevel riskLevel) {
    }

    public record TestItem(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestKind kind,
            TestTechnique technique,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestCaseStatus status,
            @Schema(description = "Dernier résultat ; absent = jamais exécuté") ExecutionStatus lastResult) {
    }

    public record DefectItem(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String severity,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String status) {
    }

    public record CampaignItem(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String status) {
    }

    // ---------------------------------------------------------------- F-TRA-04 matrice

    public record MatrixRequirement(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementType type,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementStatus status,
            String parentKey,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int depth,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean leaf,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) VerificationStatus verificationStatus) {
    }

    public record MatrixCell(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String requirementKey,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String testKey,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID linkId,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LinkType linkType,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LinkOrigin origin,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<Integer> criterionPositions,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean suspect,
            ExecutionStatus lastResult,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long version) {
    }

    public record MatrixResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String scope,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<MatrixRequirement> requirements,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<TestItem> tests,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<MatrixCell> cells) {
    }

    // ---------------------------------------------------------------- §7.2 couverture

    public record IndicatorResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) double numerator,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) double denominator,
            @Schema(description = "Pourcentage ; absent si le périmètre est vide") Double percent) {
    }

    public record RequirementCoverageResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementType type,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int depth,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean leaf,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RiskLevel riskLevel,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) VerificationStatus verificationStatus,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int coveringTests,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int executedTests,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int passedTests) {
    }

    public record CoverageResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String scope,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Couverture de conception") IndicatorResponse design,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Couverture des critères") IndicatorResponse criteria,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Couverture d'exécution") IndicatorResponse execution,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Taux de validation") IndicatorResponse validation,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Couverture pondérée par le risque") IndicatorResponse riskWeighted,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<RequirementCoverageResponse> requirements) {
    }

    // ---------------------------------------------------------------- F-TRA-06 orphelins

    public record OrphansResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<RequirementItem> requirementsWithoutTests,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<TestItem> testsWithoutRequirement,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<DefectItem> defectsWithoutRequirement,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<TestItem> automatedNeverExecuted) {
    }

    // ---------------------------------------------------------------- F-TRA-05 arbre

    public record TraceNodeResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementType type,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) VerificationStatus verificationStatus,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<TraceNodeResponse> children) {
    }

    public record CriterionTraceResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int position,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CriterionFormat format,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String content,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CriterionStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> testKeys) {
    }

    public record TestTraceResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestItem test,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID linkId,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LinkType linkType,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LinkOrigin origin,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean suspect,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<Integer> criterionPositions,
            Instant lastExecutedAt) {
    }

    public record TraceTreeResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TraceNodeResponse requirement,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<TraceNodeResponse> ancestors,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<CriterionTraceResponse> criteria,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<TestTraceResponse> tests,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<DefectItem> defects) {
    }

    // ---------------------------------------------------------------- F-TRA-07 impact

    public record ImpactedTestResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestItem test,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Exigence par laquelle le test est lié") RequirementItem via,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID linkId,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LinkType linkType,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean suspect) {
    }

    public record ImpactResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementItem requirement,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<ImpactedTestResponse> tests,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Campagnes en cours concernées (lot 5)") List<CampaignItem> campaigns) {
    }
}
