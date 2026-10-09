package com.traceagile.api.campaign;

import com.traceagile.api.campaign.CampaignDtos.AttemptResponse;
import com.traceagile.api.campaign.CampaignDtos.CreateDefectRequest;
import com.traceagile.api.campaign.CampaignDtos.DefectDetail;
import com.traceagile.api.campaign.CampaignDtos.DefectDraftResponse;
import com.traceagile.api.campaign.CampaignDtos.ExecutionDetail;
import com.traceagile.api.campaign.CampaignDtos.ExecutionPatchRequest;
import com.traceagile.api.campaign.CampaignDtos.MyExecutionResponse;
import com.traceagile.api.campaign.CampaignDtos.RequirementExecutionResponse;
import com.traceagile.api.campaign.CampaignDtos.StartExecutionRequest;
import com.traceagile.api.campaign.CampaignDtos.StepResultRequest;
import com.traceagile.application.campaign.CampaignService;
import com.traceagile.application.defect.DefectService;
import com.traceagile.application.defect.DefectService.DefectCommand;
import com.traceagile.application.execution.ExecutionRepository;
import com.traceagile.application.execution.ExecutionService;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.domain.defect.Defect;
import com.traceagile.domain.defect.DefectDraft;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.ExecutionStatus;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** §12 Exécutions (§8.4) : « Mes exécutions », tentatives, saisie pas à pas, anomalie depuis un échec. */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}")
@Tag(name = "Exécutions")
public class ExecutionController {

    static final String READ = "hasPermission(#projectKey, 'Project', 'EXECUTION_READ')";
    static final String WRITE = "hasPermission(#projectKey, 'Project', 'EXECUTION_WRITE')";

    private final ExecutionService executions;
    private final ExecutionRepository executionRepository;
    private final CampaignService campaigns;
    private final DefectService defects;
    private final RequirementService requirements;
    private final TraceLinkService links;
    private final CampaignMapper mapper;

    public ExecutionController(ExecutionService executions, ExecutionRepository executionRepository, CampaignService campaigns,
                               DefectService defects, RequirementService requirements, TraceLinkService links, CampaignMapper mapper) {
        this.executions = executions;
        this.executionRepository = executionRepository;
        this.campaigns = campaigns;
        this.defects = defects;
        this.requirements = requirements;
        this.links = links;
        this.mapper = mapper;
    }

    /** F-EXE-01 « Mes tests à exécuter » dans les campagnes ouvertes ({@code status} : dernière tentative). */
    @GetMapping("/my-executions")
    @PreAuthorize(READ)
    public List<MyExecutionResponse> mine(@PathVariable String projectKey, Authentication authentication,
                                          @RequestParam(required = false) Set<ExecutionStatus> status) {
        return executions.myItems(projectKey, authentication.getName(), status).stream().map(mapper::mine).toList();
    }

    /** F-EXE-01 / F-EXE-04 nouvelle tentative d'un test manuel (jeu de données facultatif). */
    @PostMapping("/campaign-items/{id}/executions")
    @PreAuthorize(WRITE)
    public ResponseEntity<ExecutionDetail> start(@PathVariable String projectKey, @PathVariable UUID id, Authentication authentication,
                                                 @Valid @RequestBody(required = false) StartExecutionRequest request) {
        Execution execution = executions.start(projectKey, id, authentication.getName(),
                request == null ? null : request.dataSetName(), request == null ? null : request.row());
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/executions/" + execution.getId()))
                .body(mapper.execution(execution, List.of()));
    }

    @GetMapping("/campaign-items/{id}/executions")
    @PreAuthorize(READ)
    public List<AttemptResponse> attempts(@PathVariable String projectKey, @PathVariable UUID id) {
        return campaigns.item(projectKey, id).getExecutions().stream().map(mapper::attempt).toList();
    }

    @GetMapping("/executions/{id}")
    @PreAuthorize(READ)
    public ExecutionDetail get(@PathVariable String projectKey, @PathVariable UUID id) {
        Execution execution = executions.get(projectKey, id);
        return mapper.execution(execution, defects.ofExecution(execution));
    }

    /** F-EXE-01 statut et résultat obtenu d'un pas. */
    @PutMapping("/executions/{id}/steps/{position}")
    @PreAuthorize(WRITE)
    public ExecutionDetail step(@PathVariable String projectKey, @PathVariable UUID id, @PathVariable int position,
                                @Valid @RequestBody StepResultRequest request) {
        Execution execution = executions.recordStep(projectKey, id, position, request.status(), request.actualResult());
        return mapper.execution(execution, defects.ofExecution(execution));
    }

    /** F-EXE-02 statut forcé, commentaire obligatoire s'il diffère du statut déduit des pas. */
    @PatchMapping(path = "/executions/{id}", consumes = {"application/merge-patch+json", "application/json"})
    @PreAuthorize(WRITE)
    public ExecutionDetail override(@PathVariable String projectKey, @PathVariable UUID id, @Valid @RequestBody ExecutionPatchRequest request) {
        Execution execution = executions.override(projectKey, id, request.status(), request.comment());
        return mapper.execution(execution, defects.ofExecution(execution));
    }

    /** F-EXE-03 contenu proposé pour l'anomalie. */
    @GetMapping("/executions/{id}/defect-draft")
    @PreAuthorize(READ)
    public DefectDraftResponse draft(@PathVariable String projectKey, @PathVariable UUID id) {
        Execution execution = executions.get(projectKey, id);
        DefectDraft draft = DefectDraft.from(execution);
        List<String> covered = links.requirementsOf(execution.getTestCase()).stream().filter(l -> l.linkType().countsForCoverage())
                .map(l -> l.requirement().getKey()).toList();
        return new DefectDraftResponse(draft.title(), draft.description(), draft.severity(), covered);
    }

    /** F-EXE-03 anomalie liée à l'exécution (et aux exigences vérifiées par le test, par défaut). */
    @PostMapping("/executions/{id}/defects")
    @PreAuthorize(WRITE)
    public ResponseEntity<DefectDetail> createDefect(@PathVariable String projectKey, @PathVariable UUID id,
                                                     @Valid @RequestBody CreateDefectRequest r) {
        Defect defect = defects.createFromExecution(projectKey, id,
                new DefectCommand(r.title(), r.description(), r.severity(), r.externalRef(), r.requirementKeys()));
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/defects/" + defect.getKey())).body(mapper.defect(defect));
    }

    /** §13.2 fiche exigence, onglet « Exécutions » : exécutions des tests liés, de la plus récente à la plus ancienne. */
    @GetMapping("/requirements/{key}/executions")
    @PreAuthorize(READ)
    public List<RequirementExecutionResponse> ofRequirement(@PathVariable String projectKey, @PathVariable String key) {
        List<UUID> testIds = links.testsOf(requirements.get(projectKey, key)).stream().map(l -> l.testCase().getId()).toList();
        if (testIds.isEmpty()) {
            return List.of();
        }
        return executionRepository.findByTestCase_IdInOrderByStartedAtDesc(testIds).stream().map(mapper::requirementExecution).toList();
    }
}
