package com.traceagile.api.planning;

import com.traceagile.application.planning.PlanningService.CloseAction;
import com.traceagile.domain.planning.PlanningStatus;
import com.traceagile.domain.planning.ScopeOutcome;
import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.domain.traceability.VerificationStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/** §12 Planification : releases et sprints (§8.1, §8.2). */
public final class PlanningDtos {

    private PlanningDtos() {
    }

    // ---------------------------------------------------------------- lecture

    public record SprintSummary(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            String goal,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LocalDate startDate,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LocalDate endDate,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) PlanningStatus status,
            Integer capacityPoints,
            String releaseKey,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-PLN-05 charge en points du périmètre") int loadPoints,
            @Schema(description = "Charge / capacité en % ; absent sans capacité") Integer loadPercent,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean overCapacity,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Points des stories terminées (sprint clos)") int donePoints,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int requirementCount,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Clés des exigences du périmètre (ordre)") List<String> requirementKeys,
            @Schema(description = "F-PLN-02 taux de validation du périmètre (%), absent si rien n'est couvert") Double validationRate,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long version) {
    }

    public record ReleaseResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            String goal,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LocalDate startDate,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LocalDate endDate,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) PlanningStatus status,
            Instant closedAt,
            @Schema(description = "F-PLN-03 bilan figé à la clôture") Map<String, Object> closingReport,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<SprintSummary> sprints,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long version) {
    }

    public record ScopeItemResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementType type,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Priority priority,
            Integer storyPoints,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ScopeOutcome outcome,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) VerificationStatus verificationStatus) {
    }

    public record SprintDetail(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) SprintSummary sprint,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<ScopeItemResponse> scope,
            @Schema(description = "F-PLN-06 sprint qui recevrait les stories reportées") String nextSprintKey) {
    }

    // ---------------------------------------------------------------- écriture

    public record CreateReleaseRequest(@NotBlank @Size(max = 120) String name, @Size(max = 1000) String goal,
                                       @NotNull LocalDate startDate, @NotNull LocalDate endDate) {
    }

    /** Merge-patch : absent = inchangé. */
    public record UpdateReleaseRequest(@Size(max = 120) String name, @Size(max = 1000) String goal, LocalDate startDate, LocalDate endDate) {
    }

    public record GenerateSprintsRequest(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) @Min(1) @Max(26) int count,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) @Min(1) @Max(4) int durationWeeks,
            @Schema(description = "Défaut : lendemain du dernier sprint de la release, sinon son début") LocalDate startDate,
            @Min(0) @Max(1000) Integer capacityPoints) {
    }

    public record CreateSprintRequest(@NotBlank @Size(max = 120) String name, @Size(max = 1000) String goal,
                                      @NotNull LocalDate startDate, @NotNull LocalDate endDate,
                                      @Min(0) @Max(1000) Integer capacityPoints, String releaseKey) {
    }

    /** Merge-patch : absent = inchangé ; {@code releaseKey: null} détache le sprint de sa release. */
    public record UpdateSprintRequest(@Size(max = 120) String name, @Size(max = 1000) String goal, LocalDate startDate, LocalDate endDate,
                                      @Min(0) @Max(1000) Integer capacityPoints, String releaseKey) {
    }

    public record ScopeRequest(@NotNull List<@NotBlank String> requirementKeys) {
    }

    public record CloseDecisionRequest(@NotBlank String requirementKey, @NotNull CloseAction action) {
    }

    public record CloseSprintRequest(List<@Valid CloseDecisionRequest> decisions) {
    }
}
