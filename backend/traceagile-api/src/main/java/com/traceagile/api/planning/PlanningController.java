package com.traceagile.api.planning;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.api.planning.PlanningDtos.CloseSprintRequest;
import com.traceagile.api.planning.PlanningDtos.CreateReleaseRequest;
import com.traceagile.api.planning.PlanningDtos.CreateSprintRequest;
import com.traceagile.api.planning.PlanningDtos.GenerateSprintsRequest;
import com.traceagile.api.planning.PlanningDtos.ReleaseResponse;
import com.traceagile.api.planning.PlanningDtos.ScopeItemResponse;
import com.traceagile.api.planning.PlanningDtos.ScopeRequest;
import com.traceagile.api.planning.PlanningDtos.SprintDetail;
import com.traceagile.api.planning.PlanningDtos.SprintSummary;
import com.traceagile.api.planning.PlanningDtos.UpdateReleaseRequest;
import com.traceagile.api.planning.PlanningDtos.UpdateSprintRequest;
import com.traceagile.api.web.MergePatch;
import com.traceagile.api.web.Versions;
import com.traceagile.application.planning.PlanningService;
import com.traceagile.application.planning.PlanningService.CloseDecision;
import com.traceagile.application.planning.PlanningService.GenerateCommand;
import com.traceagile.application.planning.PlanningService.ReleaseCommand;
import com.traceagile.application.planning.PlanningService.ReleasePatch;
import com.traceagile.application.planning.PlanningService.SprintCommand;
import com.traceagile.application.planning.PlanningService.SprintPatch;
import com.traceagile.application.traceability.TraceabilityService;
import com.traceagile.domain.planning.PlanningStatus;
import com.traceagile.domain.planning.Release;
import com.traceagile.domain.planning.Sprint;
import com.traceagile.domain.planning.SprintScopeItem;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.traceability.CoverageCalculator.Indicator;
import com.traceagile.domain.traceability.VerificationStatus;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.Validator;
import java.net.URI;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** §12 Planification (§8.1 releases, §8.2 sprints). */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}")
@Tag(name = "Planification")
public class PlanningController {

    static final String READ = "hasPermission(#projectKey, 'Project', 'PLANNING_READ')";
    static final String WRITE = "hasPermission(#projectKey, 'Project', 'PLANNING_WRITE')";

    private final PlanningService planning;
    private final TraceabilityService traceability;
    private final ObjectMapper json;
    private final Validator validator;

    public PlanningController(PlanningService planning, TraceabilityService traceability, ObjectMapper json, Validator validator) {
        this.planning = planning;
        this.traceability = traceability;
        this.json = json;
        this.validator = validator;
    }

    // ---------------------------------------------------------------- releases

    /** F-PLN-02 feuille de route : releases, leurs sprints et le taux de validation de chacun. */
    @GetMapping("/releases")
    @PreAuthorize(READ)
    public List<ReleaseResponse> releases(@PathVariable String projectKey) {
        Map<String, Indicator> rates = planning.validationRates(projectKey);
        return planning.releases(projectKey).stream().map(r -> release(r, rates)).toList();
    }

    @GetMapping("/releases/{key}")
    @PreAuthorize(READ)
    public ResponseEntity<ReleaseResponse> release(@PathVariable String projectKey, @PathVariable String key) {
        Release release = planning.release(projectKey, key);
        return ResponseEntity.ok().eTag(Versions.etag(release)).body(release(release, planning.validationRates(projectKey)));
    }

    /** F-PLN-01 création d'une release. */
    @PostMapping("/releases")
    @PreAuthorize(WRITE)
    public ResponseEntity<ReleaseResponse> createRelease(@PathVariable String projectKey, @Valid @RequestBody CreateReleaseRequest request) {
        Release release = planning.createRelease(projectKey,
                new ReleaseCommand(request.name(), request.goal(), request.startDate(), request.endDate()));
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/releases/" + release.getKey()))
                .eTag(Versions.etag(release)).body(release(release, Map.of()));
    }

    @PatchMapping(path = "/releases/{key}", consumes = {"application/merge-patch+json", "application/json"})
    @PreAuthorize(WRITE)
    public ResponseEntity<ReleaseResponse> updateRelease(@PathVariable String projectKey, @PathVariable String key,
                                                         @RequestHeader(name = HttpHeaders.IF_MATCH, required = false) String ifMatch,
                                                         @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(
                                                                 schema = @Schema(implementation = UpdateReleaseRequest.class)))
                                                         @RequestBody JsonNode body) {
        MergePatch f = MergePatch.of(body, UpdateReleaseRequest.class, json, validator);
        Release release = planning.updateRelease(projectKey, key, new ReleasePatch(f.field("name", String.class),
                f.field("goal", String.class), f.field("startDate", LocalDate.class), f.field("endDate", LocalDate.class)),
                Versions.parseIfMatch(ifMatch));
        return ResponseEntity.ok().eTag(Versions.etag(release)).body(release(release, planning.validationRates(projectKey)));
    }

    /** F-PLN-01 génération de sprints consécutifs (1 à 4 semaines). */
    @PostMapping("/releases/{key}/generate-sprints")
    @PreAuthorize(WRITE)
    public ReleaseResponse generateSprints(@PathVariable String projectKey, @PathVariable String key,
                                           @Valid @RequestBody GenerateSprintsRequest request) {
        planning.generateSprints(projectKey, key,
                new GenerateCommand(request.count(), request.durationWeeks(), request.startDate(), request.capacityPoints()));
        return release(planning.release(projectKey, key), planning.validationRates(projectKey));
    }

    /** F-PLN-03 clôture : bilan figé, lecture seule. */
    @PostMapping("/releases/{key}/close")
    @PreAuthorize(WRITE)
    public ReleaseResponse closeRelease(@PathVariable String projectKey, @PathVariable String key) {
        return release(planning.closeRelease(projectKey, key), planning.validationRates(projectKey));
    }

    // ---------------------------------------------------------------- sprints

    @GetMapping("/sprints")
    @PreAuthorize(READ)
    public List<SprintSummary> sprints(@PathVariable String projectKey, @RequestParam(required = false) Set<PlanningStatus> status,
                                       @RequestParam(required = false) String release) {
        Map<String, Indicator> rates = planning.validationRates(projectKey);
        return planning.sprints(projectKey).stream()
                .filter(s -> status == null || status.isEmpty() || status.contains(s.getStatus()))
                .filter(s -> release == null || (s.getRelease() != null && s.getRelease().getKey().equals(release)))
                .map(s -> summary(s, rates)).toList();
    }

    @GetMapping("/sprints/{key}")
    @PreAuthorize(READ)
    public ResponseEntity<SprintDetail> sprint(@PathVariable String projectKey, @PathVariable String key) {
        return detail(projectKey, planning.sprint(projectKey, key));
    }

    /** F-PLN-04 création d'un sprint, rattaché ou non à une release. */
    @PostMapping("/sprints")
    @PreAuthorize(WRITE)
    public ResponseEntity<SprintDetail> createSprint(@PathVariable String projectKey, @Valid @RequestBody CreateSprintRequest request) {
        Sprint sprint = planning.createSprint(projectKey, new SprintCommand(request.name(), request.goal(), request.startDate(),
                request.endDate(), request.capacityPoints(), request.releaseKey()));
        ResponseEntity<SprintDetail> detail = detail(projectKey, sprint);
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/sprints/" + sprint.getKey()))
                .eTag(Versions.etag(sprint)).body(detail.getBody());
    }

    @PatchMapping(path = "/sprints/{key}", consumes = {"application/merge-patch+json", "application/json"})
    @PreAuthorize(WRITE)
    public ResponseEntity<SprintDetail> updateSprint(@PathVariable String projectKey, @PathVariable String key,
                                                     @RequestHeader(name = HttpHeaders.IF_MATCH, required = false) String ifMatch,
                                                     @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(
                                                             schema = @Schema(implementation = UpdateSprintRequest.class)))
                                                     @RequestBody JsonNode body) {
        MergePatch f = MergePatch.of(body, UpdateSprintRequest.class, json, validator);
        Sprint sprint = planning.updateSprint(projectKey, key, new SprintPatch(f.field("name", String.class), f.field("goal", String.class),
                f.field("startDate", LocalDate.class), f.field("endDate", LocalDate.class), f.field("capacityPoints", Integer.class),
                f.field("releaseKey", String.class)), Versions.parseIfMatch(ifMatch));
        return detail(projectKey, sprint);
    }

    /** F-PLN-05 périmètre ordonné (glisser-déposer). */
    @PutMapping("/sprints/{key}/scope")
    @PreAuthorize(WRITE)
    public ResponseEntity<SprintDetail> scope(@PathVariable String projectKey, @PathVariable String key,
                                              @Valid @RequestBody ScopeRequest request) {
        return detail(projectKey, planning.replaceScope(projectKey, key, request.requirementKeys()));
    }

    /** F-PLN-06 démarrage. */
    @PostMapping("/sprints/{key}/start")
    @PreAuthorize(WRITE)
    public ResponseEntity<SprintDetail> start(@PathVariable String projectKey, @PathVariable String key) {
        return detail(projectKey, planning.start(projectKey, key));
    }

    /** F-PLN-06 clôture : décision par story non terminée (BACKLOG par défaut, NEXT_SPRINT). */
    @PostMapping("/sprints/{key}/close")
    @PreAuthorize(WRITE)
    public ResponseEntity<SprintDetail> close(@PathVariable String projectKey, @PathVariable String key,
                                              @Valid @RequestBody(required = false) CloseSprintRequest request) {
        List<CloseDecision> decisions = request == null || request.decisions() == null ? List.of()
                : request.decisions().stream().map(d -> new CloseDecision(d.requirementKey(), d.action())).toList();
        return detail(projectKey, planning.close(projectKey, key, decisions));
    }

    // ---------------------------------------------------------------- outils

    private ResponseEntity<SprintDetail> detail(String projectKey, Sprint sprint) {
        Map<UUID, VerificationStatus> statuses = traceability.statuses(projectKey);
        List<ScopeItemResponse> scope = sprint.getScope().stream().map(item -> scopeItem(item, statuses)).toList();
        SprintDetail body = new SprintDetail(summary(sprint, planning.validationRates(projectKey)), scope,
                planning.nextSprint(sprint).map(Sprint::getKey).orElse(null));
        return ResponseEntity.ok().eTag(Versions.etag(sprint)).body(body);
    }

    private static ScopeItemResponse scopeItem(SprintScopeItem item, Map<UUID, VerificationStatus> statuses) {
        Requirement r = item.getRequirement();
        return new ScopeItemResponse(r.getKey(), r.getTitle(), r.getType(), r.getStatus(), r.getPriority(),
                item.getSprint().getStatus() == PlanningStatus.CLOSED ? item.getCommittedPoints() : r.getStoryPoints(),
                item.getOutcome(), statuses.getOrDefault(r.getId(), VerificationStatus.NOT_COVERED));
    }

    private static SprintSummary summary(Sprint s, Map<String, Indicator> rates) {
        Indicator validation = rates.get(s.getKey());
        return new SprintSummary(s.getKey(), s.getName(), s.getGoal(), s.getStartDate(), s.getEndDate(), s.getStatus(), s.getCapacityPoints(),
                s.getRelease() == null ? null : s.getRelease().getKey(), s.loadPoints(), s.loadPercent(), s.isOverCapacity(), s.donePoints(),
                s.getScope().size(), s.requirements().stream().map(Requirement::getKey).toList(),
                validation == null ? null : validation.percent(), s.getVersion());
    }

    private static ReleaseResponse release(Release r, Map<String, Indicator> rates) {
        return new ReleaseResponse(r.getKey(), r.getName(), r.getGoal(), r.getStartDate(), r.getEndDate(), r.getStatus(), r.getClosedAt(),
                r.getClosingReport(), r.getSprints().stream().map(s -> summary(s, rates)).toList(), r.getVersion());
    }
}
