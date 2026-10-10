package com.traceagile.api.testcase;

import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestTechnique;
import com.traceagile.domain.traceability.LinkOrigin;
import com.traceagile.domain.traceability.LinkType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/** DTO du référentiel de tests (§12 Cas de test, Gherkin, Traçabilité). */
public interface TestCaseDtos {

    // ---------------------------------------------------------------- lecture

    record TestCaseSummary(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestKind kind,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestCaseStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Priority priority,
            TestTechnique technique,
            String framework,
            String folder,
            String featureName,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> tags,
            Integer estimatedDurationMin,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int currentVersion,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean automationCandidate,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean missingInRepository,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-MAN-02 nombre d'exécutions (toutes tentatives)") long executionCount,
            @Schema(description = "F-EXE-11 test instable") Boolean flaky) {
    }

    /** §13.2 référentiel « par dossier » ou « par feature ». */
    record TestCaseGroup(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Dossier ou fonctionnalité ; vide = non classé") String name,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<TestCaseSummary> tests) {
    }

    record StepResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int position,
            @Schema(description = "Facultative pour un pas d'appel") String action,
            String expectedResult,
            String testData,
            @Schema(description = "ADR-0018 cas de test appelé par ce pas") CalledTestRef calledTest,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "ADR-0018 valeurs des paramètres de l'appelé") Map<String, String> callParameters) {
    }

    record CalledTestRef(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestCaseStatus status) {
    }

    record CharterResponse(
            String explore,
            String with,
            String toDiscover,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-EXP-01") String missionSentence,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> areas,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> heuristics,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int timeboxMin,
            String setupNotes,
            String targetedRisk) {
    }

    record AutomationResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestTechnique technique,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String framework,
            String language,
            String repositoryUrl,
            String branch,
            String path,
            String testIdentifier,
            String featureName,
            String gherkinSource,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Configuration technique libre (JSON)") Map<String, Object> configuration,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> executionTags,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Map<String, String> environmentRequirements,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> keywords,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean missingInRepository) {
    }

    /** ADR-0013 paramètre d'un test ; {@code detected} : présent dans les pas ({@code ${nom}}). */
    record ParameterResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            String defaultValue,
            String description,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean detected) {
    }

    /** ADR-0013 jeu de données nommé : une ligne par exécution, valeurs scalaires. */
    record DataSetDto(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) @NotBlank @Size(max = 100) String name,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) @NotNull List<Map<String, Object>> rows) {
    }

    record ParameterRequest(@NotBlank @Size(max = 60) String name, @Size(max = 500) String defaultValue,
                            @Size(max = 500) String description) {
    }

    record RequirementLinkResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID linkId,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String requirementKey,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String requirementTitle,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementType requirementType,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) RequirementStatus requirementStatus,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LinkType linkType,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LinkOrigin origin,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<Integer> criterionPositions,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "§3.3-7 exigence modifiée depuis la revue du test") boolean suspect) {
    }

    record TestCaseDetail(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestKind kind,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            String description,
            String objective,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Priority priority,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestCaseStatus status,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<TestCaseStatus> allowedTransitions,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> tags,
            Integer estimatedDurationMin,
            String folder,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int currentVersion,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean automationCandidate,
            @Schema(description = "F-EXE-11 test instable") Boolean flaky,
            String automationJustification,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<StepResponse> steps,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "ADR-0013 paramètres déclarés et détectés (${nom} des pas)") List<ParameterResponse> parameters,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<DataSetDto> dataSets,
            CharterResponse charter,
            AutomationResponse automation,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<RequirementLinkResponse> requirements,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-AUT-06 tags Gherkin inconnus…") List<String> warnings,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long version,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant createdAt,
            String createdBy,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant updatedAt,
            String updatedBy,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "ADR-0018 tests dont un pas appelle celui-ci") List<String> calledBy) {
    }

    /** Onglet « Tests liés » d'une exigence. */
    record LinkedTestResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID linkId,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestKind kind,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestCaseStatus status,
            TestTechnique technique,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LinkType linkType,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) LinkOrigin origin,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<Integer> criterionPositions,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "§3.3-7 exigence modifiée depuis la revue du test") boolean suspect) {
    }

    record TestVersionResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int versionNumber,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant createdAt,
            String createdBy,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Map<String, String> snapshot) {
    }

    // ---------------------------------------------------------------- écriture

    /** F-MAN-01 pas ; ADR-0018 {@code calledTestKey} : appel d'un autre cas de test (action alors facultative). */
    record StepRequest(String action, String expectedResult, String testData, String calledTestKey, Map<String, String> callParameters) {
    }

    record LinkRequest(@NotBlank String requirementKey, @NotNull LinkType linkType, List<Integer> criterionPositions) {
    }

    /**
     * Champs modifiables d'un test (JSON Merge Patch : absent = inchangé, {@code null} = effacé). Les
     * champs propres à une nature (pas, charte, automatisation) sont refusés sur une autre nature.
     */
    record TestCaseFieldsRequest(
            @Size(max = 200) String title,
            String description,
            String objective,
            Priority priority,
            List<@Size(max = 50) String> tags,
            @Min(1) @Max(10_000) Integer estimatedDurationMin,
            @Size(max = 300) String folder,
            Boolean automationCandidate,
            @Size(max = 1000) String automationJustification,
            List<@Valid StepRequest> steps,
            List<@Valid ParameterRequest> parameters,
            List<@Valid DataSetDto> dataSets,
            @Size(max = 500) String explore,
            @Size(max = 500) String with,
            @Size(max = 500) String toDiscover,
            List<String> areas,
            List<String> heuristics,
            Integer timeboxMin,
            String setupNotes,
            @Size(max = 500) String targetedRisk,
            TestTechnique technique,
            @Size(max = 60) String framework,
            @Size(max = 40) String language,
            @Size(max = 500) String repositoryUrl,
            @Size(max = 200) String branch,
            @Size(max = 500) String path,
            @Size(max = 500) String testIdentifier,
            String gherkinSource,
            Map<String, Object> configuration,
            List<String> executionTags,
            Map<String, String> environmentRequirements) {
    }

    /** §12 POST /test-cases : mêmes champs que le PATCH, plus la nature et les exigences liées. */
    @Schema(allOf = TestCaseFieldsRequest.class)
    record CreateTestCaseRequest(
            @NotNull TestKind kind,
            @NotBlank @Size(max = 200) String title,
            TestTechnique technique,
            @Size(max = 60) String framework,
            List<@Valid LinkRequest> links,
            List<@Valid StepRequest> steps) {
    }

    record TestStatusRequest(@NotNull TestCaseStatus status) {
    }

    record FeatureImportResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> created,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> updated,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> warnings) {
    }

    record DiscoveryResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> created,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> updated,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> disappeared,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<String> warnings) {
    }

    record StepUsageResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String text,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long count) {
    }

    record FrameworkResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) TestTechnique technique,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int position) {
    }
}
