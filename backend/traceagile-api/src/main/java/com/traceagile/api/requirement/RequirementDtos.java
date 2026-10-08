package com.traceagile.api.requirement;

import com.traceagile.domain.requirement.ChecklistItemResult;
import com.traceagile.domain.requirement.ChecklistKind;
import com.traceagile.domain.requirement.ChecklistRule;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.requirement.CriterionStatus;
import com.traceagile.domain.requirement.NfrCategory;
import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.domain.requirement.RiskLevel;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/** DTO des exigences (§12 Exigences, Critères) ; aucune entité exposée (§11.1). */
public interface RequirementDtos {


    // ---------------------------------------------------------------- lecture

    /** Ligne de la vue liste et nœud de la vue arbre (F-REQ-01). */
    record RequirementSummary(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementType type,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Priority priority,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RiskLevel riskLevel,
            Integer storyPoints,
            Integer businessValue,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> tags,
            String parentKey,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String rank,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int criteriaCount,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean needsSplitting,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long version) {
    }

    record RequirementTreeNode(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementType type,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Priority priority,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RiskLevel riskLevel,
            Integer storyPoints,
            String parentKey,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String rank,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int criteriaCount,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean needsSplitting,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<RequirementTreeNode> children) {
    }

    record UserStoryResponse(String asA, String iWant, String soThat,
                             @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-REQ-05 phrase complète") String sentence) {
    }

    record PlanguageResponse(String scale, String measurementMethod, String minimumThreshold, String target, String unit) {
    }

    record InvestDto(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean independent,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean negotiable,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean valuable,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean estimable,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean small,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean testable) {
    }

    record RequirementRef(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementType type,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementStatus status) {
    }

    record CriterionResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int position,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CriterionFormat format,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String content,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CriterionStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long version) {
    }

    record RequirementDetail(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementType type,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            String description,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UserStoryResponse userStory,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Priority priority,
            Integer businessValue,
            Integer storyPoints,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-REQ-07 alerte « Story à découper » (13 points ou plus)") boolean needsSplitting,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "§3.2 statuts accessibles depuis le statut courant") List<RequirementStatus> allowedTransitions,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RiskLevel riskLevel,
            NfrCategory category,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) PlanguageResponse planguage,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean transverse,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> tags,
            String externalRef,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int currentVersion,
            RequirementRef parent,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<RequirementRef> children,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) InvestDto invest,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<CriterionResponse> criteria,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-REQ-17 ENF transverses applicables") List<RequirementRef> applicableTransverseNfrs,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long version,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant createdAt,
            String createdBy,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant updatedAt,
            String updatedBy) {
    }

    // ---------------------------------------------------------------- écriture

    /**
     * Champs modifiables (JSON Merge Patch, ADR-0005 / ADR-0009) : absent = inchangé, {@code null} =
     * effacé. Le contrôleur lit le corps brut pour faire la différence ; ce DTO porte la validation
     * et la documentation OpenAPI.
     */
    record RequirementFieldsRequest(
            @Schema(nullable = true) RequirementType type,
            @Schema(nullable = true) @Size(max = 200) String title,
            @Schema(nullable = true) String description,
            @Schema(nullable = true) @Size(max = 500) String asA,
            @Schema(nullable = true) @Size(max = 2000) String iWant,
            @Schema(nullable = true) @Size(max = 2000) String soThat,
            @Schema(nullable = true) Priority priority,
            @Schema(nullable = true) Integer businessValue,
            @Schema(nullable = true) Integer storyPoints,
            @Schema(nullable = true) RiskLevel riskLevel,
            @Schema(nullable = true) NfrCategory category,
            @Schema(nullable = true) @Size(max = 500) String scale,
            @Schema(nullable = true) @Size(max = 500) String measurementMethod,
            @Schema(nullable = true) @Size(max = 100) String minimumThreshold,
            @Schema(nullable = true) @Size(max = 100) String target,
            @Schema(nullable = true) @Size(max = 50) String unit,
            @Schema(nullable = true) Boolean transverse,
            @Schema(nullable = true) List<@Size(max = 50) String> tags,
            @Schema(nullable = true) @Size(max = 100) String externalRef) {
    }

    /** §12 POST /requirements : type et titre obligatoires, parent facultatif, autres champs comme le PATCH. */
    record CreateRequirementRequest(
            @NotNull RequirementType type,
            @NotBlank @Size(max = 200) String title,
            String parentKey,
            String description,
            String asA,
            String iWant,
            String soThat,
            Priority priority,
            Integer businessValue,
            Integer storyPoints,
            RiskLevel riskLevel,
            NfrCategory category,
            String scale,
            String measurementMethod,
            String minimumThreshold,
            String target,
            String unit,
            Boolean transverse,
            List<String> tags,
            String externalRef,
            List<@Valid CreateCriterionRequest> criteria) {
    }

    record MoveRequest(
            @Schema(description = "Nouveau parent ; absent ou null : racine") String parentKey,
            @Schema(description = "Exigence devant laquelle insérer (suivante)") String beforeKey,
            @Schema(description = "Exigence après laquelle insérer (précédente)") String afterKey) {
    }

    record StatusChangeRequest(
            @NotNull RequirementStatus status,
            @Schema(description = "F-REQ-20 confirme le passage malgré des items manuels non cochés") boolean acknowledgeUnmet) {
    }

    record CreateCriterionRequest(@NotNull CriterionFormat format, @NotBlank @Size(max = 10_000) String content) {
    }

    record UpdateCriterionRequest(CriterionFormat format, @Size(max = 10_000) String content) {
    }

    record ReorderCriteriaRequest(@NotNull List<UUID> ids) {
    }

    // ---------------------------------------------------------------- versions, historique

    record FieldChangeResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String field,
            String before,
            String after) {
    }

    record VersionResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int versionNumber,
            String changeComment,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant createdAt,
            String createdBy,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Map<String, String> snapshot) {
    }

    record CreateVersionRequest(@Size(max = 500) String comment) {
    }

    record AuditEventResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String action,
            String actor,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant timestamp,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<FieldChangeResponse> changes) {
    }

    // ---------------------------------------------------------------- DoR / DoD

    record ChecklistItemResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ChecklistKind kind,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int position,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String label,
            ChecklistRule rule,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean automatic) {
    }

    record ProjectChecklistsResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<ChecklistItemResponse> dor,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<ChecklistItemResponse> dod) {
    }

    record ChecklistItemRequest(UUID id, @NotBlank @Size(max = 200) String label, ChecklistRule rule) {
    }

    record ChecklistResultResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String label,
            ChecklistRule rule,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean automatic,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ChecklistItemResult.Outcome outcome) {
    }

    record RequirementChecklistsResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<ChecklistResultResponse> dor,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<ChecklistResultResponse> dod) {
    }

    record CheckRequest(boolean checked) {
    }

    // ---------------------------------------------------------------- Gherkin, import

    record GherkinValidateRequest(@NotNull @Size(max = 100_000) String source) {
    }

    record GherkinErrorResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int line,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int column,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String message) {
    }

    record GherkinValidationResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean valid,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String language,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<GherkinErrorResponse> errors) {
    }

    record ImportResponse(@Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> created) {
    }
}
