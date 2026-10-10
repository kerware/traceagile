package com.traceagile.api.campaign;

import com.traceagile.application.campaign.CampaignService.Strategy;
import com.traceagile.domain.campaign.CampaignScope;
import com.traceagile.domain.campaign.CampaignStatus;
import com.traceagile.domain.defect.DefectSeverity;
import com.traceagile.domain.defect.DefectStatus;
import com.traceagile.domain.execution.ExecutionOrigin;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestTechnique;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/** §12 Campagnes (§8.3), exécutions (§8.4) et anomalies (§8.6). */
public final class CampaignDtos {

    private CampaignDtos() {
    }

    // ---------------------------------------------------------------- références

    public record UserRef(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String login,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String displayName) {
    }

    public record TestRef(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestKind kind,
            TestTechnique technique,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestCaseStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Priority priority,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int currentVersion,
            @Schema(description = "Durée estimée (manuel) ou timebox (charte), en minutes") Integer durationMin) {
    }

    public record CampaignRef(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            String environment,
            String buildVersion,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CampaignStatus status) {
    }

    public record DataSetRef(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int rows) {
    }

    public record DefectRef(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) DefectSeverity severity,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) DefectStatus status) {
    }

    // ---------------------------------------------------------------- campagnes

    public record ProgressResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int total,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Statut de la dernière tentative de chaque test")
            Map<ExecutionStatus, Integer> byStatus,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int executed,
            Double executedPercent,
            @Schema(description = "Réussis / exécutés (%)") Double passRate) {
    }

    public record CampaignSummary(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CampaignScope scopeType,
            String sprintKey,
            String releaseKey,
            String environment,
            String buildVersion,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CampaignStatus status,
            LocalDate plannedStart,
            LocalDate plannedEnd,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ProgressResponse progress,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long version,
            @Schema(description = "ADR-0018 dossier « a/b » ; absent = racine") String folder) {
    }

    public record ItemResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int position,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestRef test,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Version du test à la sélection") int testCaseVersion,
            UserRef assignee,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-CMP-04 test automatisé : serveur d'exécution") boolean executedByServer,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-CMP-03 risque × priorité") int riskScore,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExecutionStatus lastStatus,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int attempts,
            UUID latestExecutionId,
            Instant lastExecutedAt,
            @Schema(description = "ADR-0018 jeu de données prévu (absent : valeurs par défaut)") String dataSetName,
            @Schema(description = "Ligne du jeu, base 0") Integer dataSetRow,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Valeurs de la ligne prévue") Map<String, String> dataSetValues,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<DataSetRef> dataSets) {
    }

    public record WorkloadResponse(
            UserRef assignee,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int manualMinutes,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int exploratoryMinutes,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int tests,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Tests manuels sans durée estimée") int unestimated) {
    }

    public record CampaignDetail(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CampaignSummary campaign,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<ItemResponse> items,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-CMP-05") List<WorkloadResponse> workload) {
    }

    public record CreateCampaignRequest(@NotBlank @Size(max = 120) String name, @NotNull CampaignScope scopeType, String sprintKey,
                                        String releaseKey, @Size(max = 60) String environment, @Size(max = 60) String buildVersion,
                                        LocalDate plannedStart, LocalDate plannedEnd, @Size(max = 300) String folder) {
    }

    /** Merge-patch : absent = inchangé, {@code null} = effacé ; {@code folder} modifiable même campagne terminée. */
    public record UpdateCampaignRequest(@Size(max = 120) String name, @Size(max = 60) String environment, @Size(max = 60) String buildVersion,
                                        LocalDate plannedStart, LocalDate plannedEnd, @Size(max = 300) String folder) {
    }

    /** F-CMP-02 sélection cumulable : paramètres selon la stratégie. */
    public record SelectRequest(@NotNull Strategy strategy, String sprintKey, String tag, List<String> testKeys,
                                List<String> requirementKeys, String campaignKey,
                                @Schema(description = "FROM_CAMPAIGN : derniers résultats retenus (défaut : FAILED, ERROR)") Set<ExecutionStatus> statuses) {
    }

    /**
     * ADR-0017 copie d'une campagne : champs absents repris de la source ; {@code statuses} absent ou
     * vide = tous les tests (duplication), sinon les tests dont la dernière tentative a ce statut.
     */
    public record CopyCampaignRequest(@NotBlank @Size(max = 120) String name, CampaignScope scopeType, String sprintKey, String releaseKey,
                                      @Size(max = 60) String environment, @Size(max = 60) String buildVersion,
                                      Set<ExecutionStatus> statuses,
                                      @Schema(description = "Conserver les testeurs affectés (défaut : oui)") Boolean keepAssignees) {
    }

    public record CopyCampaignResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> copied,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<SkippedResponse> skipped,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CampaignDetail campaign) {
    }

    public record SkippedResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String testKey,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "ALREADY_SELECTED, NOT_READY_<statut>") String reason) {
    }

    public record SelectionResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> added,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<SkippedResponse> skipped,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CampaignDetail campaign) {
    }

    public record OrderRequest(@NotNull List<UUID> itemIds) {
    }

    /** F-CMP-04 merge-patch : {@code assignee: null} désaffecte. */
    /** F-CMP-04 affectation ; ADR-0018 ligne de jeu de données ({@code dataSetName: null} = valeurs par défaut). */
    public record ItemPatchRequest(String assignee, @Size(max = 100) String dataSetName, @Min(0) Integer dataSetRow) {
    }

    public record ExpandDataSetRequest(@NotBlank @Size(max = 100) String dataSetName) {
    }

    // ---------------------------------------------------------------- exécutions

    public record StepResultResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int position,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String action,
            String expectedResult,
            String testData,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExecutionStatus status,
            String actualResult,
            @Schema(description = "ADR-0018 test appelé d'où vient ce pas") String calledFrom) {
    }

    public record AttemptResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int attempt,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExecutionStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant startedAt,
            Instant endedAt,
            String executedBy,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExecutionOrigin origin,
            String dataSetName,
            Integer dataSetRow) {
    }

    public record ExecutionDetail(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID itemId,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestRef test,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CampaignRef campaign,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int attempt,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int testCaseVersion,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExecutionStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-EXE-02 statut déduit des pas") ExecutionStatus derivedStatus,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean statusOverridden,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant startedAt,
            Instant endedAt,
            Long durationMs,
            String comment,
            String executedBy,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExecutionOrigin origin,
            String dataSetName,
            Integer dataSetRow,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Map<String, String> parameterValues,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<StepResultResponse> steps,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<DefectRef> defects,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-EXE-04 toutes les tentatives du test dans la campagne") List<AttemptResponse> attempts,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Dernière tentative d'une campagne ouverte") boolean editable,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<DataSetRef> dataSets) {
    }

    public record StartExecutionRequest(@Size(max = 100) String dataSetName, @Min(0) Integer row) {
    }

    public record StepResultRequest(@NotNull ExecutionStatus status, @Size(max = 4000) String actualResult) {
    }

    public record ExecutionPatchRequest(@NotNull ExecutionStatus status, @Size(max = 2000) String comment) {
    }

    public record MyExecutionResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID itemId,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CampaignRef campaign,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestRef test,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int position,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExecutionStatus lastStatus,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int attempts,
            UUID latestExecutionId,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<DataSetRef> dataSets,
            @Schema(description = "ADR-0018 jeu de données prévu dans la campagne") String dataSetName,
            Integer dataSetRow) {
    }

    public record DefectDraftResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String description,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) DefectSeverity severity,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Exigences couvertes par le test (liées par défaut)") List<String> requirementKeys) {
    }

    /** Fiche exigence, onglet « Exécutions ». */
    public record RequirementExecutionResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestRef test,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) CampaignRef campaign,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int attempt,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExecutionStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant startedAt,
            Instant endedAt,
            String executedBy,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExecutionOrigin origin,
            String dataSetName,
            Integer dataSetRow) {
    }

    // ---------------------------------------------------------------- anomalies

    public record DefectRequirementRef(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title) {
    }

    public record DefectExecutionRef(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String testKey,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String campaignKey,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int attempt,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExecutionStatus status) {
    }

    public record DefectSummary(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) DefectSeverity severity,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) DefectStatus status,
            String externalRef,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> requirementKeys,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int executionCount,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant createdAt,
            String createdBy,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long version) {
    }

    /** ADR-0018 anomalie vue depuis une exigence : rattachée ou trouvée par les exécutions des tests liés. */
    public record RequirementDefectResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) DefectSummary defect,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean linked,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Tests liés à l'exigence dont une exécution a révélé l'anomalie")
            List<String> viaTests) {
    }

    public record DefectDetail(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) DefectSummary defect,
            String description,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<DefectStatus> allowedTransitions,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<DefectRequirementRef> requirements,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<DefectExecutionRef> executions) {
    }

    public record CreateDefectRequest(@NotBlank @Size(max = 200) String title, String description, @NotNull DefectSeverity severity,
                                      @Size(max = 100) String externalRef, List<String> requirementKeys) {
    }

    /** Merge-patch. */
    public record UpdateDefectRequest(@Size(max = 200) String title, String description, DefectSeverity severity, DefectStatus status,
                                      @Size(max = 100) String externalRef, List<String> requirementKeys) {
    }
}
