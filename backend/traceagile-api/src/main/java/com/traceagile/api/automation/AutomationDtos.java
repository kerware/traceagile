package com.traceagile.api.automation;

import com.traceagile.api.campaign.CampaignDtos.CampaignRef;
import com.traceagile.api.campaign.CampaignDtos.TestRef;
import com.traceagile.application.automation.ReportImportService.MatchedBy;
import com.traceagile.domain.automation.RunArtifact;
import com.traceagile.domain.automation.RunStatus;
import com.traceagile.domain.automation.ServerStatus;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.testcase.TestTechnique;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** DTO des serveurs d'exécution (§10, ADR-0020), des runs (§8.5) et de l'import de rapports (F-EXE-10). */
public final class AutomationDtos {

    private AutomationDtos() {
    }

    // ---------------------------------------------------------------- serveurs

    public record ServerResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String baseUrl,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String authType,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Jeton émis par le serveur enregistré") boolean paired,
            @Schema(description = "Quatre derniers caractères du jeton (le jeton n'est jamais renvoyé)") String tokenHint,
            String tokenId,
            Instant pairedAt,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ServerStatus status,
            Instant lastHeartbeat,
            String lastError,
            String serverVersion,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<TestTechnique> techniques,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> frameworks,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> environments,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int agents,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean enabled) {
    }

    /** F-EXE-06 choix du serveur au lancement (sans détail d'administration). */
    public record ServerChoice(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ServerStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<TestTechnique> techniques,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean usable) {
    }

    public record CreateServerRequest(@NotBlank @Size(max = 100) String name, @NotBlank @Size(max = 300) String baseUrl) {
    }

    public record UpdateServerRequest(@Size(max = 100) String name, @Size(max = 300) String baseUrl, Boolean enabled) {
    }

    /**
     * ADR-0020 appairage : soit les identifiants de l'administrateur du serveur (TraceAgile demande le
     * jeton, rien n'est conservé), soit le jeton et le secret émis sur le serveur.
     */
    public record PairServerRequest(String adminUser, String adminPassword, String token, String webhookSecret, String tokenId) {
    }

    // ---------------------------------------------------------------- runs

    public record LaunchRunRequest(
            @NotNull UUID serverId,
            @Schema(description = "Éléments de campagne à lancer ; absent ou vide : tous les tests automatisés") List<UUID> itemIds,
            @Min(1) @Max(1440) Integer timeoutMinutes) {
    }

    /** Comptes en direct d'après les tentatives (la synthèse du serveur arrive à la fin). */
    public record RunCounts(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int total,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int pending,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int running,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int passed,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int failed,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int error,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int skipped) {
    }

    public record RunSummaryResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RunStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CampaignRef campaign,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String serverName,
            String requestedBy,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant requestedAt,
            Instant startedAt,
            Instant endedAt,
            String environment,
            String buildVersion,
            String agent,
            String externalJobId,
            String rerunOf,
            String errorCode,
            String errorMessage,
            String reportUrl,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int timeoutMinutes,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RunCounts counts) {
    }

    public record RunExecutionResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID itemId,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestRef test,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestTechnique technique,
            String testIdentifier,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExecutionStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant startedAt,
            Instant endedAt,
            Long durationMs,
            String message,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-EXE-11 test instable") boolean flaky,
            @Schema(description = "ADR-0021 copie d'écran de l'échec (nom de l'artefact)") String screenshot) {
    }

    /** ADR-0021 artefact d'un run : traces système, JUnit XML, Jest JSON, rapport, copie d'écran. */
    public record RunArtifactResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String contentType,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RunArtifact.Kind kind,
            Long size,
            @Schema(description = "Test concerné (copie d'écran)") String testKey) {
    }

    public record RunDetail(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RunSummaryResponse run,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<RunExecutionResponse> executions,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Annulable (non terminé)") boolean cancellable) {
    }

    // ---------------------------------------------------------------- import

    public record ReportImportLine(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String identifier,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExecutionStatus status,
            Long durationMs,
            String message,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> requirementKeys,
            @Schema(description = "Test rapproché (absent : inconnu)") String testKey,
            MatchedBy matchedBy) {
    }

    public record ReportImportResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<ReportImportLine> lines,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> created,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int recorded,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "false : aperçu") boolean applied) {
    }
}
