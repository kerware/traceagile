package com.traceagile.api.campaign;

import com.traceagile.api.campaign.CampaignDtos.CampaignRef;
import com.traceagile.api.campaign.CampaignDtos.DefectRef;
import com.traceagile.api.campaign.CampaignDtos.TestRef;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.exploratory.NoteType;
import com.traceagile.domain.exploratory.SessionState;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** DTO des sessions exploratoires (§5.2, §5.3), des chartes proposées (F-EXP-04) et des métriques (§5.4). */
public final class ExploratoryDtos {

    private ExploratoryDtos() {
    }

    public record SessionNoteResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) NoteType type,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Secondes de temps actif depuis le début") long offsetSeconds,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "« mm:ss »") String offsetLabel,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String text,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant notedAt,
            @Schema(description = "F-EXP-07 anomalie créée depuis la note") DefectRef defect) {
    }

    public record TbsResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int testPct,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int bugPct,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int setupPct) {
    }

    public record ProofResponse(
            String past,
            String results,
            String obstacles,
            String outlook,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int feelings,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-EXP-12 pistes de l'Outlook, une par ligne") List<String> outlookItems) {
    }

    public record SessionDetail(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Identifiant de la tentative (ADR-0019)") UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID itemId,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestRef charter,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String missionSentence,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> areas,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> heuristics,
            String setupNotes,
            String targetedRisk,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int timeboxMin,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CampaignRef campaign,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int attempt,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String tester,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) SessionState state,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExecutionStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant startedAt,
            Instant endedAt,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Temps actif à serverTime (pauses exclues)") long elapsedSeconds,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant serverTime,
            Integer durationMin,
            String draft,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<SessionNoteResponse> notes,
            TbsResponse tbs,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> areasCovered,
            ProofResponse proof,
            String debriefedBy,
            Instant debriefedAt,
            String approvedBy,
            Instant approvedAt,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<DefectRef> defects,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "L'utilisateur courant mène la session") boolean owner,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long version) {
    }

    public record SessionSummary(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestRef charter,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CampaignRef campaign,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int attempt,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String tester,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) SessionState state,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExecutionStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant startedAt,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long elapsedSeconds,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int timeboxMin,
            Integer durationMin,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int notes,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int bugs,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Débriefing PROOF saisi") boolean debriefed,
            Integer feelings,
            String approvedBy) {
    }

    /** Merge-patch : {@code paused} met en pause ou reprend ; {@code draft} sauvegarde la note en cours (F-EXP-10). */
    public record SessionPatchRequest(Boolean paused, @Size(max = 5000) String draft) {
    }

    public record SessionNoteRequest(@NotNull NoteType type, @NotBlank @Size(max = 5000) String text) {
    }

    public record FinishSessionRequest(
            @NotNull @Min(0) @Max(100) Integer testPct,
            @NotNull @Min(0) @Max(100) Integer bugPct,
            @NotNull @Min(0) @Max(100) Integer setupPct,
            List<@Size(max = 100) String> areasCovered,
            @NotNull @Schema(description = "PASSED, FAILED ou BLOCKED") ExecutionStatus status) {
    }

    public record DebriefRequest(String past, String results, String obstacles, String outlook, @NotNull Integer feelings) {
    }

    public record FollowUpRequest(@NotEmpty List<@NotBlank @Size(max = 300) String> missions) {
    }

    public record FollowUpResponse(@Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> created) {
    }

    public record CharterProposalResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "CRITERION ou NFR") String source,
            Integer criterionPosition,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String explore,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String with,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String toDiscover,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> areas,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> heuristics,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> requirementKeys) {
    }

    public record HeuristicsResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> suggested,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> custom) {
    }

    public record HeuristicsRequest(@NotNull List<@Size(max = 60) String> custom) {
    }

    public record TbsAverageResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) double testPct,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) double bugPct,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) double setupPct) {
    }

    public record ExploratoryMetricsResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int sessions,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int inProgress,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int awaitingApproval,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int debriefed,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long totalMinutes,
            Double averageMinutes,
            Double averageTimeboxMin,
            Double durationVsTargetPct,
            TbsAverageResponse averageTbs,
            Double defectsPerHour,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int chartersPlanned,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int chartersExecuted,
            Double averageConfidence,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> neverExploredAreas) {
    }
}
