package com.traceagile.api.campaign;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.api.campaign.CampaignDtos.CreateDefectRequest;
import com.traceagile.api.campaign.CampaignDtos.DefectDetail;
import com.traceagile.api.campaign.CampaignDtos.DefectSummary;
import com.traceagile.api.campaign.CampaignDtos.UpdateDefectRequest;
import com.traceagile.api.web.MergePatch;
import com.traceagile.api.web.Versions;
import com.traceagile.application.defect.DefectService;
import com.traceagile.application.defect.DefectService.DefectCommand;
import com.traceagile.application.defect.DefectService.DefectFilter;
import com.traceagile.application.defect.DefectService.DefectPatch;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.domain.defect.Defect;
import com.traceagile.domain.defect.DefectSeverity;
import com.traceagile.domain.defect.DefectStatus;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.Validator;
import java.net.URI;
import java.util.List;
import java.util.Set;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** §12 Anomalies (§8.6, F-DEF-01, F-DEF-02). */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}")
@Tag(name = "Anomalies")
public class DefectController {

    static final String READ = "hasPermission(#projectKey, 'Project', 'EXECUTION_READ')";
    static final String CREATE = "hasPermission(#projectKey, 'Project', 'EXECUTION_WRITE')";
    /** ADR-0016 le testeur, le développeur (résolution) et le PO (rejet, clôture) font vivre une anomalie. */
    static final String UPDATE = CREATE + " or hasPermission(#projectKey, 'Project', 'AUTOMATED_RUN_LAUNCH')"
            + " or hasPermission(#projectKey, 'Project', 'REQUIREMENT_WRITE')";

    private final DefectService defects;
    private final RequirementService requirements;
    private final CampaignMapper mapper;
    private final ObjectMapper json;
    private final Validator validator;

    public DefectController(DefectService defects, RequirementService requirements, CampaignMapper mapper, ObjectMapper json, Validator validator) {
        this.defects = defects;
        this.requirements = requirements;
        this.mapper = mapper;
        this.json = json;
        this.validator = validator;
    }

    @GetMapping("/defects")
    @PreAuthorize(READ)
    public List<DefectSummary> list(@PathVariable String projectKey, @RequestParam(required = false) Set<DefectStatus> status,
                                    @RequestParam(required = false) Set<DefectSeverity> severity,
                                    @RequestParam(required = false) String requirement, @RequestParam(required = false) String q) {
        return defects.list(projectKey, new DefectFilter(status, severity, requirement, q)).stream().map(mapper::defectSummary).toList();
    }

    @PostMapping("/defects")
    @PreAuthorize(CREATE)
    public ResponseEntity<DefectDetail> create(@PathVariable String projectKey, @Valid @RequestBody CreateDefectRequest r) {
        Defect defect = defects.create(projectKey, new DefectCommand(r.title(), r.description(), r.severity(), r.externalRef(), r.requirementKeys()));
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/defects/" + defect.getKey()))
                .eTag(Versions.etag(defect)).body(mapper.defect(defect));
    }

    @GetMapping("/defects/{key}")
    @PreAuthorize(READ)
    public ResponseEntity<DefectDetail> get(@PathVariable String projectKey, @PathVariable String key) {
        Defect defect = defects.get(projectKey, key);
        return ResponseEntity.ok().eTag(Versions.etag(defect)).body(mapper.defect(defect));
    }

    @PatchMapping(path = "/defects/{key}", consumes = {"application/merge-patch+json", "application/json"})
    @PreAuthorize(UPDATE)
    public ResponseEntity<DefectDetail> update(@PathVariable String projectKey, @PathVariable String key,
                                               @RequestHeader(name = HttpHeaders.IF_MATCH, required = false) String ifMatch,
                                               @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(
                                                       schema = @Schema(implementation = UpdateDefectRequest.class)))
                                               @RequestBody JsonNode body) {
        MergePatch f = MergePatch.of(body, UpdateDefectRequest.class, json, validator);
        Defect defect = defects.update(projectKey, key, new DefectPatch(f.field("title", String.class), f.field("description", String.class),
                f.field("severity", DefectSeverity.class), f.field("status", DefectStatus.class), f.field("externalRef", String.class),
                f.field("requirementKeys", new TypeReference<List<String>>() { })), Versions.parseIfMatch(ifMatch));
        return ResponseEntity.ok().eTag(Versions.etag(defect)).body(mapper.defect(defect));
    }

    /** §13.2 fiche exigence, onglet « Anomalies ». */
    @GetMapping("/requirements/{key}/defects")
    @PreAuthorize(READ)
    public List<DefectSummary> ofRequirement(@PathVariable String projectKey, @PathVariable String key) {
        return defects.ofRequirement(requirements.get(projectKey, key)).stream().map(mapper::defectSummary).toList();
    }
}
