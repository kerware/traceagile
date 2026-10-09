package com.traceagile.api.requirement;

import com.traceagile.api.requirement.RequirementDtos.AuditEventResponse;
import com.traceagile.api.requirement.RequirementDtos.CheckRequest;
import com.traceagile.api.requirement.RequirementDtos.CreateRequirementRequest;
import com.traceagile.api.requirement.RequirementDtos.CreateVersionRequest;
import com.traceagile.api.requirement.RequirementDtos.FieldChangeResponse;
import com.traceagile.api.requirement.RequirementDtos.ImportResponse;
import com.traceagile.api.requirement.RequirementDtos.InvestDto;
import com.traceagile.api.requirement.RequirementDtos.MoveRequest;
import com.traceagile.api.requirement.RequirementDtos.RequirementChecklistsResponse;
import com.traceagile.api.requirement.RequirementDtos.RequirementDetail;
import com.traceagile.api.requirement.RequirementDtos.RequirementFieldsRequest;
import com.traceagile.api.requirement.RequirementDtos.RequirementSummary;
import com.traceagile.api.requirement.RequirementDtos.RequirementTreeNode;
import com.traceagile.api.requirement.RequirementDtos.StatusChangeRequest;
import com.traceagile.api.requirement.RequirementDtos.VersionResponse;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.api.web.MergePatch;
import com.traceagile.api.web.PageResponse;
import com.traceagile.api.web.Versions;
import com.traceagile.application.audit.AuditService;
import com.traceagile.application.common.UnprocessableException;
import com.traceagile.application.requirement.ChecklistService;
import com.traceagile.application.requirement.RequirementCsvService;
import com.traceagile.application.requirement.RequirementFilter;
import com.traceagile.application.requirement.RequirementPatch;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.application.traceability.TraceabilityService;
import com.traceagile.api.requirement.RequirementMapper.CriterionStatuses;
import com.traceagile.domain.traceability.VerificationStatus;
import com.traceagile.application.requirement.RequirementService.CreateRequirementCommand;
import com.traceagile.application.requirement.RequirementService.CriterionDraft;
import com.traceagile.application.requirement.RequirementService.MoveCommand;
import com.traceagile.application.requirement.RequirementVersionService;
import com.traceagile.domain.requirement.ChecklistKind;
import com.traceagile.domain.requirement.NfrCategory;
import com.traceagile.domain.requirement.Planguage;
import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.domain.requirement.RiskLevel;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.Validator;
import java.io.IOException;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

/** §12 Exigences d'un projet (§4 hors 4.4). Les droits suivent le §2.2 (ADR-0004). */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}/requirements")
@Tag(name = "Exigences")
public class RequirementController {

    static final String READ = "hasPermission(#projectKey, 'Project', 'REQUIREMENT_READ')";
    static final String WRITE = "hasPermission(#projectKey, 'Project', 'REQUIREMENT_WRITE')";
    /** PO ou testeur : critères, INVEST, items manuels de DoR / DoD (§2.2 « proposer des critères »). */
    static final String CONTRIBUTE = WRITE + " or hasPermission(#projectKey, 'Project', 'ACCEPTANCE_CRITERION_PROPOSE')";

    private final RequirementService requirements;
    private final RequirementVersionService versions;
    private final RequirementCsvService csv;
    private final ChecklistService checklists;
    private final AuditService audit;
    private final RequirementMapper mapper;
    private final ObjectMapper json;
    private final Validator validator;
    private final TraceabilityService traceability;

    public RequirementController(RequirementService requirements, RequirementVersionService versions, RequirementCsvService csv,
                                 ChecklistService checklists, AuditService audit, RequirementMapper mapper,
                                 ObjectMapper json, Validator validator, TraceabilityService traceability) {
        this.traceability = traceability;
        this.json = json;
        this.validator = validator;
        this.requirements = requirements;
        this.versions = versions;
        this.csv = csv;
        this.checklists = checklists;
        this.audit = audit;
        this.mapper = mapper;
    }

    // ---------------------------------------------------------------- backlog

    /** F-REQ-01 vue liste (tri par défaut : rang) ; F-REQ-04 recherche {@code q}. */
    @GetMapping
    @PreAuthorize(READ)
    public PageResponse<RequirementSummary> list(@PathVariable String projectKey,
                                                 @RequestParam(required = false) Set<RequirementType> type,
                                                 @RequestParam(required = false) Set<RequirementStatus> status,
                                                 @RequestParam(required = false) Set<Priority> priority,
                                                 @RequestParam(required = false) Set<RiskLevel> risk,
                                                 @RequestParam(required = false) String tag,
                                                 @RequestParam(required = false) String q,
                                                 @ParameterObject Pageable pageable) {
        RequirementFilter filter = new RequirementFilter(type, status, priority, risk, tag, q);
        Map<UUID, VerificationStatus> statuses = traceability.statuses(projectKey);
        return PageResponse.of(requirements.search(projectKey, filter, pageable),
                r -> mapper.toSummary(r, statuses.getOrDefault(r.getId(), VerificationStatus.NOT_COVERED)));
    }

    /** F-REQ-01 vue arbre. */
    @GetMapping("/tree")
    @PreAuthorize(READ)
    public List<RequirementTreeNode> tree(@PathVariable String projectKey) {
        return mapper.toTree(requirements.backlog(projectKey), traceability.statuses(projectKey));
    }

    @PostMapping
    @PreAuthorize(WRITE)
    public ResponseEntity<RequirementDetail> create(@PathVariable String projectKey, @Valid @RequestBody CreateRequirementRequest request) {
        RequirementPatch.Builder details = RequirementPatch.builder()
                .description(request.description())
                .userStory(request.asA(), request.iWant(), request.soThat())
                .priority(request.priority())
                .businessValue(request.businessValue())
                .storyPoints(request.storyPoints())
                .riskLevel(request.riskLevel())
                .category(request.category())
                .planguage(new Planguage(request.scale(), request.measurementMethod(), request.minimumThreshold(),
                        request.target(), request.unit()))
                .tags(request.tags())
                .externalRef(request.externalRef());
        if (request.transverse() != null) {
            details.transverse(request.transverse());
        }
        List<CriterionDraft> criteria = request.criteria() == null ? List.of()
                : request.criteria().stream().map(c -> new CriterionDraft(c.format(), c.content())).toList();
        Requirement requirement = requirements.create(projectKey,
                new CreateRequirementCommand(request.type(), request.title(), request.parentKey(), details.build(), criteria));
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/requirements/" + requirement.getKey()))
                .eTag(Versions.etag(requirement))
                .body(detail(requirement));
    }

    // ---------------------------------------------------------------- fiche

    @GetMapping("/{key}")
    @PreAuthorize(READ)
    public ResponseEntity<RequirementDetail> get(@PathVariable String projectKey, @PathVariable String key) {
        return withEtag(requirements.get(projectKey, key));
    }

    /** §12 PATCH merge-patch avec If-Match (ADR-0005, ADR-0009). */
    @PatchMapping(path = "/{key}", consumes = {"application/merge-patch+json", "application/json"})
    @PreAuthorize(WRITE)
    public ResponseEntity<RequirementDetail> update(@PathVariable String projectKey, @PathVariable String key,
                                                    @RequestHeader(name = HttpHeaders.IF_MATCH, required = false) String ifMatch,
                                                    @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(
                                                            schema = @Schema(implementation = RequirementFieldsRequest.class)))
                                                    @RequestBody JsonNode body) {
        MergePatch fields = MergePatch.of(body, RequirementFieldsRequest.class, json, validator);
        RequirementPatch patch = new RequirementPatch(
                fields.field("type", RequirementType.class), fields.field("title", String.class),
                fields.field("description", String.class), fields.field("asA", String.class),
                fields.field("iWant", String.class), fields.field("soThat", String.class),
                fields.field("priority", Priority.class), fields.field("businessValue", Integer.class),
                fields.field("storyPoints", Integer.class), fields.field("riskLevel", RiskLevel.class),
                fields.field("category", NfrCategory.class), fields.field("scale", String.class),
                fields.field("measurementMethod", String.class), fields.field("minimumThreshold", String.class),
                fields.field("target", String.class), fields.field("unit", String.class),
                fields.field("transverse", Boolean.class), fields.field("tags", new TypeReference<List<String>>() { }),
                fields.field("externalRef", String.class), null);
        return withEtag(requirements.update(projectKey, key, patch, Versions.parseIfMatch(ifMatch)));
    }

    @DeleteMapping("/{key}")
    @PreAuthorize(WRITE)
    public ResponseEntity<Void> delete(@PathVariable String projectKey, @PathVariable String key) {
        requirements.delete(projectKey, key);
        return ResponseEntity.noContent().build();
    }

    /** F-REQ-02 / F-REQ-03 glisser-déposer dans l'arbre ou la liste. */
    @PostMapping("/{key}/move")
    @PreAuthorize(WRITE)
    public ResponseEntity<RequirementDetail> move(@PathVariable String projectKey, @PathVariable String key,
                                                  @RequestBody MoveRequest request) {
        return withEtag(requirements.move(projectKey, key,
                new MoveCommand(request.parentKey(), request.beforeKey(), request.afterKey())));
    }

    @PostMapping("/{key}/duplicate")
    @PreAuthorize(WRITE)
    public ResponseEntity<RequirementDetail> duplicate(@PathVariable String projectKey, @PathVariable String key) {
        Requirement copy = requirements.duplicate(projectKey, key);
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/requirements/" + copy.getKey()))
                .body(detail(copy));
    }

    /** §3.2 changement de statut avec contrôle de la DoR / DoD (F-REQ-20). */
    @PostMapping("/{key}/status")
    @PreAuthorize(WRITE)
    public ResponseEntity<RequirementDetail> changeStatus(@PathVariable String projectKey, @PathVariable String key,
                                                          @Valid @RequestBody StatusChangeRequest request) {
        return withEtag(requirements.changeStatus(projectKey, key, request.status(), request.acknowledgeUnmet()));
    }

    /** F-REQ-07 cases INVEST, cochées par le PO ou le testeur. */
    @PutMapping("/{key}/invest")
    @PreAuthorize(CONTRIBUTE)
    public ResponseEntity<RequirementDetail> invest(@PathVariable String projectKey, @PathVariable String key,
                                                    @RequestBody InvestDto request) {
        RequirementPatch patch = RequirementPatch.builder().invest(mapper.toInvest(request)).build();
        return withEtag(requirements.update(projectKey, key, patch, null));
    }

    // ---------------------------------------------------------------- DoR / DoD

    @GetMapping("/{key}/checklists")
    @PreAuthorize(READ)
    public RequirementChecklistsResponse checklists(@PathVariable String projectKey, @PathVariable String key) {
        return evaluate(requirements.get(projectKey, key));
    }

    @PutMapping("/{key}/checklists/{itemId}")
    @PreAuthorize(CONTRIBUTE)
    public RequirementChecklistsResponse check(@PathVariable String projectKey, @PathVariable String key,
                                               @PathVariable UUID itemId, @RequestBody CheckRequest request) {
        return evaluate(requirements.check(projectKey, key, itemId, request.checked()));
    }

    private RequirementChecklistsResponse evaluate(Requirement requirement) {
        return new RequirementChecklistsResponse(
                mapper.toResults(checklists.evaluate(requirement, ChecklistKind.DOR)),
                mapper.toResults(checklists.evaluate(requirement, ChecklistKind.DOD)));
    }

    // ---------------------------------------------------------------- versions, historique

    @GetMapping("/{key}/versions")
    @PreAuthorize(READ)
    public List<VersionResponse> versions(@PathVariable String projectKey, @PathVariable String key) {
        return versions.list(projectKey, key).stream().map(mapper::toResponse).toList();
    }

    @PostMapping("/{key}/versions")
    @PreAuthorize(WRITE)
    public ResponseEntity<VersionResponse> freeze(@PathVariable String projectKey, @PathVariable String key,
                                                  @Valid @RequestBody(required = false) CreateVersionRequest request) {
        var version = versions.freeze(projectKey, key, request == null ? null : request.comment());
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/requirements/" + key + "/versions/"
                + version.getVersionNumber())).body(mapper.toResponse(version));
    }

    @GetMapping("/{key}/versions/{number}")
    @PreAuthorize(READ)
    public VersionResponse version(@PathVariable String projectKey, @PathVariable String key, @PathVariable int number) {
        return mapper.toResponse(versions.get(projectKey, key, number));
    }

    /** F-REQ-21 comparaison de deux versions (diff côte à côte côté interface). */
    @GetMapping("/{key}/versions/{from}/diff/{to}")
    @PreAuthorize(READ)
    public List<FieldChangeResponse> diff(@PathVariable String projectKey, @PathVariable String key,
                                          @PathVariable int from, @PathVariable int to) {
        return mapper.toChanges(versions.diff(projectKey, key, from, to));
    }

    /** F-REQ-22 historique : AuditEvent de l'exigence, du plus récent au plus ancien. */
    @GetMapping("/{key}/history")
    @PreAuthorize(READ)
    public PageResponse<AuditEventResponse> history(@PathVariable String projectKey, @PathVariable String key,
                                                    @ParameterObject Pageable pageable) {
        Requirement requirement = requirements.get(projectKey, key);
        return PageResponse.of(audit.history(AuditService.REQUIREMENT, requirement.getId(), pageable), mapper::toResponse);
    }

    // ---------------------------------------------------------------- import / export (F-REQ-23)

    @PostMapping(path = "/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize(WRITE)
    public ImportResponse importCsv(@PathVariable String projectKey, @RequestPart("file") MultipartFile file) throws IOException {
        if (file.getSize() > 5 * 1024 * 1024) {
            throw new UnprocessableException("CSV_TOO_LARGE", "Le fichier dépasse 5 Mo.");
        }
        return new ImportResponse(csv.importCsv(projectKey, new String(file.getBytes(), StandardCharsets.UTF_8)));
    }

    @GetMapping(path = "/export", produces = "text/csv")
    @PreAuthorize(READ)
    public ResponseEntity<String> exportCsv(@PathVariable String projectKey,
                                            @RequestParam(required = false) Set<RequirementType> type,
                                            @RequestParam(required = false) Set<RequirementStatus> status,
                                            @RequestParam(required = false) Set<Priority> priority,
                                            @RequestParam(required = false) Set<RiskLevel> risk,
                                            @RequestParam(required = false) String tag,
                                            @RequestParam(required = false) String q) {
        String body = csv.exportCsv(projectKey, new RequirementFilter(type, status, priority, risk, tag, q));
        return ResponseEntity.ok()
                .contentType(new MediaType("text", "csv", StandardCharsets.UTF_8))
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        ContentDisposition.attachment().filename(projectKey + "-backlog.csv").build().toString())
                .body(body);
    }

    // ---------------------------------------------------------------- outils

    private ResponseEntity<RequirementDetail> withEtag(Requirement requirement) {
        return ResponseEntity.ok().eTag(Versions.etag(requirement)).body(detail(requirement));
    }

    private RequirementDetail detail(Requirement requirement) {
        String projectKey = requirement.getProject().getKey();
        return mapper.toDetail(requirement, requirements.applicableTransverseNfrs(requirement),
                traceability.statuses(projectKey).getOrDefault(requirement.getId(), VerificationStatus.NOT_COVERED),
                new CriterionStatuses(traceability.criterionStatuses(projectKey, requirement)));
    }
}
