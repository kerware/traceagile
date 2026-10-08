package com.traceagile.api.requirement;

import com.traceagile.api.requirement.RequirementDtos.CreateCriterionRequest;
import com.traceagile.api.requirement.RequirementDtos.CriterionResponse;
import com.traceagile.api.requirement.RequirementDtos.ReorderCriteriaRequest;
import com.traceagile.api.requirement.RequirementDtos.UpdateCriterionRequest;
import com.traceagile.api.web.Versions;
import com.traceagile.application.requirement.AcceptanceCriterionService;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpHeaders;
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
import org.springframework.web.bind.annotation.RestController;

/** §12 Critères d'acceptation (F-REQ-09, F-REQ-10). Le testeur peut en proposer (§2.2). */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}")
@Tag(name = "Exigences")
public class AcceptanceCriterionController {

    private final AcceptanceCriterionService criteria;
    private final RequirementService requirements;
    private final RequirementMapper mapper;

    public AcceptanceCriterionController(AcceptanceCriterionService criteria, RequirementService requirements,
                                         RequirementMapper mapper) {
        this.criteria = criteria;
        this.requirements = requirements;
        this.mapper = mapper;
    }

    @GetMapping("/requirements/{key}/acceptance-criteria")
    @PreAuthorize(RequirementController.READ)
    public List<CriterionResponse> list(@PathVariable String projectKey, @PathVariable String key) {
        return mapper.toCriteria(requirements.get(projectKey, key).getCriteria());
    }

    @PostMapping("/requirements/{key}/acceptance-criteria")
    @PreAuthorize(RequirementController.CONTRIBUTE)
    public ResponseEntity<CriterionResponse> add(@PathVariable String projectKey, @PathVariable String key,
                                                 @Valid @RequestBody CreateCriterionRequest request) {
        AcceptanceCriterion criterion = criteria.add(projectKey, key, request.format(), request.content());
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/acceptance-criteria/" + criterion.getId()))
                .body(mapper.toResponse(criterion));
    }

    @PutMapping("/requirements/{key}/acceptance-criteria/order")
    @PreAuthorize(RequirementController.CONTRIBUTE)
    public List<CriterionResponse> reorder(@PathVariable String projectKey, @PathVariable String key,
                                           @Valid @RequestBody ReorderCriteriaRequest request) {
        return mapper.toCriteria(criteria.reorder(projectKey, key, request.ids()).getCriteria());
    }

    @PatchMapping(path = "/acceptance-criteria/{id}", consumes = {"application/merge-patch+json", "application/json"})
    @PreAuthorize(RequirementController.CONTRIBUTE)
    public ResponseEntity<CriterionResponse> update(@PathVariable String projectKey, @PathVariable UUID id,
                                                    @RequestHeader(name = HttpHeaders.IF_MATCH, required = false) String ifMatch,
                                                    @Valid @RequestBody UpdateCriterionRequest request) {
        AcceptanceCriterion criterion = criteria.update(projectKey, id, request.format(), request.content(),
                Versions.parseIfMatch(ifMatch));
        return ResponseEntity.ok().eTag(Versions.etag(criterion)).body(mapper.toResponse(criterion));
    }

    @DeleteMapping("/acceptance-criteria/{id}")
    @PreAuthorize(RequirementController.CONTRIBUTE)
    public ResponseEntity<Void> delete(@PathVariable String projectKey, @PathVariable UUID id) {
        criteria.delete(projectKey, id);
        return ResponseEntity.noContent().build();
    }
}
