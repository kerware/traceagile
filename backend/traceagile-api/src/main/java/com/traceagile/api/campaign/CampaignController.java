package com.traceagile.api.campaign;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.api.campaign.CampaignDtos.CampaignDetail;
import com.traceagile.api.campaign.CampaignDtos.CampaignSummary;
import com.traceagile.api.campaign.CampaignDtos.CopyCampaignRequest;
import com.traceagile.api.campaign.CampaignDtos.ExpandDataSetRequest;
import com.traceagile.api.campaign.CampaignDtos.CopyCampaignResponse;
import com.traceagile.api.campaign.CampaignDtos.CreateCampaignRequest;
import com.traceagile.api.campaign.CampaignDtos.ItemPatchRequest;
import com.traceagile.api.campaign.CampaignDtos.ItemResponse;
import com.traceagile.api.campaign.CampaignDtos.OrderRequest;
import com.traceagile.api.campaign.CampaignDtos.ProgressResponse;
import com.traceagile.api.campaign.CampaignDtos.SelectRequest;
import com.traceagile.api.campaign.CampaignDtos.SelectionResponse;
import com.traceagile.api.campaign.CampaignDtos.SkippedResponse;
import com.traceagile.api.campaign.CampaignDtos.UpdateCampaignRequest;
import com.traceagile.api.campaign.CampaignDtos.UserRef;
import com.traceagile.api.web.MergePatch;
import com.traceagile.api.web.Versions;
import com.traceagile.application.campaign.CampaignService;
import com.traceagile.application.campaign.CampaignService.CampaignCommand;
import com.traceagile.application.campaign.CampaignService.CampaignPatch;
import com.traceagile.application.campaign.CampaignService.CopyCommand;
import com.traceagile.application.campaign.CampaignService.CopyResult;
import com.traceagile.application.campaign.CampaignService.SelectionParams;
import com.traceagile.application.campaign.CampaignService.SelectionResult;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.campaign.CampaignStatus;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.Validator;
import java.net.URI;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** §12 Campagnes (§8.3) : création, sélection, priorisation, affectation, avancement. */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}")
@Tag(name = "Campagnes")
public class CampaignController {

    static final String READ = "hasPermission(#projectKey, 'Project', 'CAMPAIGN_READ')";
    static final String WRITE = "hasPermission(#projectKey, 'Project', 'CAMPAIGN_WRITE')";

    private final CampaignService campaigns;
    private final CampaignMapper mapper;
    private final ObjectMapper json;
    private final Validator validator;

    public CampaignController(CampaignService campaigns, CampaignMapper mapper, ObjectMapper json, Validator validator) {
        this.campaigns = campaigns;
        this.mapper = mapper;
        this.json = json;
        this.validator = validator;
    }

    @GetMapping("/campaigns")
    @PreAuthorize(READ)
    public List<CampaignSummary> list(@PathVariable String projectKey, @RequestParam(required = false) Set<CampaignStatus> status) {
        return campaigns.list(projectKey).stream().filter(c -> status == null || status.isEmpty() || status.contains(c.getStatus()))
                .map(mapper::summary).toList();
    }

    /** F-CMP-01 création (dates par défaut : celles du sprint ou de la release). */
    @PostMapping("/campaigns")
    @PreAuthorize(WRITE)
    public ResponseEntity<CampaignDetail> create(@PathVariable String projectKey, @Valid @RequestBody CreateCampaignRequest r) {
        Campaign campaign = campaigns.create(projectKey, new CampaignCommand(r.name(), r.scopeType(), r.sprintKey(), r.releaseKey(),
                r.environment(), r.buildVersion(), r.plannedStart(), r.plannedEnd(), r.folder()));
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/campaigns/" + campaign.getKey()))
                .eTag(Versions.etag(campaign)).body(mapper.detail(campaign));
    }

    @GetMapping("/campaigns/{key}")
    @PreAuthorize(READ)
    public ResponseEntity<CampaignDetail> get(@PathVariable String projectKey, @PathVariable String key) {
        Campaign campaign = campaigns.get(projectKey, key);
        return ResponseEntity.ok().eTag(Versions.etag(campaign)).body(mapper.detail(campaign));
    }

    @PatchMapping(path = "/campaigns/{key}", consumes = {"application/merge-patch+json", "application/json"})
    @PreAuthorize(WRITE)
    public ResponseEntity<CampaignDetail> update(@PathVariable String projectKey, @PathVariable String key,
                                                 @RequestHeader(name = HttpHeaders.IF_MATCH, required = false) String ifMatch,
                                                 @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(
                                                         schema = @Schema(implementation = UpdateCampaignRequest.class)))
                                                 @RequestBody JsonNode body) {
        MergePatch f = MergePatch.of(body, UpdateCampaignRequest.class, json, validator);
        Campaign campaign = campaigns.update(projectKey, key, new CampaignPatch(f.field("name", String.class), f.field("environment", String.class),
                f.field("buildVersion", String.class), f.field("plannedStart", LocalDate.class), f.field("plannedEnd", LocalDate.class),
                f.field("folder", String.class)),
                Versions.parseIfMatch(ifMatch));
        return ResponseEntity.ok().eTag(Versions.etag(campaign)).body(mapper.detail(campaign));
    }

    @PostMapping("/campaigns/{key}/start")
    @PreAuthorize(WRITE)
    public CampaignDetail start(@PathVariable String projectKey, @PathVariable String key) {
        return mapper.detail(campaigns.start(projectKey, key));
    }

    @PostMapping("/campaigns/{key}/complete")
    @PreAuthorize(WRITE)
    public CampaignDetail complete(@PathVariable String projectKey, @PathVariable String key) {
        return mapper.detail(campaigns.complete(projectKey, key));
    }

    @PostMapping("/campaigns/{key}/abort")
    @PreAuthorize(WRITE)
    public CampaignDetail abort(@PathVariable String projectKey, @PathVariable String key) {
        return mapper.detail(campaigns.abort(projectKey, key));
    }

    @GetMapping("/campaigns/{key}/progress")
    @PreAuthorize(READ)
    public ProgressResponse progress(@PathVariable String projectKey, @PathVariable String key) {
        return mapper.summary(campaigns.get(projectKey, key)).progress();
    }

    /** F-CMP-02 sélection cumulable : SPRINT_REQUIREMENTS, TAG, IMPACT, MANUAL, FROM_CAMPAIGN. */
    @PostMapping("/campaigns/{key}/items/select")
    @PreAuthorize(WRITE)
    public SelectionResponse select(@PathVariable String projectKey, @PathVariable String key, @Valid @RequestBody SelectRequest r) {
        SelectionResult result = campaigns.select(projectKey, key, r.strategy(),
                new SelectionParams(r.sprintKey(), r.tag(), r.testKeys(), r.requirementKeys(), r.campaignKey(), r.statuses()));
        return new SelectionResponse(result.added(), result.skipped().stream().map(s -> new SkippedResponse(s.testKey(), s.reason())).toList(),
                mapper.detail(result.campaign()));
    }

    /** ADR-0017 dupliquer une campagne, ou en générer une selon les derniers résultats de ses tests. */
    @PostMapping("/campaigns/{key}/copy")
    @PreAuthorize(WRITE)
    public ResponseEntity<CopyCampaignResponse> copy(@PathVariable String projectKey, @PathVariable String key,
                                                     @Valid @RequestBody CopyCampaignRequest r) {
        CopyResult result = campaigns.copy(projectKey, key, new CopyCommand(r.name(), r.scopeType(), r.sprintKey(), r.releaseKey(),
                r.environment(), r.buildVersion(), r.statuses(), r.keepAssignees() == null || r.keepAssignees()));
        Campaign campaign = result.campaign();
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/campaigns/" + campaign.getKey()))
                .eTag(Versions.etag(campaign))
                .body(new CopyCampaignResponse(result.copied(),
                        result.skipped().stream().map(s -> new SkippedResponse(s.testKey(), s.reason())).toList(), mapper.detail(campaign)));
    }

    /** F-CMP-03 ordre proposé : score de risque décroissant. */
    @PostMapping("/campaigns/{key}/items/sort-by-risk")
    @PreAuthorize(WRITE)
    public CampaignDetail sortByRisk(@PathVariable String projectKey, @PathVariable String key) {
        return mapper.detail(campaigns.sortByRisk(projectKey, key));
    }

    /** F-CMP-03 ordre modifié à la main. */
    @PutMapping("/campaigns/{key}/items/order")
    @PreAuthorize(WRITE)
    public CampaignDetail reorder(@PathVariable String projectKey, @PathVariable String key, @Valid @RequestBody OrderRequest r) {
        return mapper.detail(campaigns.reorder(projectKey, key, r.itemIds()));
    }

    /** F-CMP-04 affectation ({@code assignee: null} = désaffecter) ; ADR-0018 ligne de jeu de données. */
    @PatchMapping(path = "/campaign-items/{id}", consumes = {"application/merge-patch+json", "application/json"})
    @PreAuthorize(WRITE)
    public ItemResponse updateItem(@PathVariable String projectKey, @PathVariable UUID id,
                                   @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(
                                           schema = @Schema(implementation = ItemPatchRequest.class)))
                                   @RequestBody JsonNode body) {
        MergePatch f = MergePatch.of(body, ItemPatchRequest.class, json, validator);
        var assignee = f.field("assignee", String.class);
        var dataSetName = f.field("dataSetName", String.class);
        var dataSetRow = f.field("dataSetRow", Integer.class);
        CampaignItem item = campaigns.item(projectKey, id);
        if (dataSetName != null || dataSetRow != null) {
            // champ absent : valeur actuelle ; nouveau jeu sans ligne : première ligne
            String name = dataSetName != null ? dataSetName.orElse(null) : item.getDataSetName();
            Integer row = dataSetRow != null ? dataSetRow.orElse(null) : dataSetName != null || name == null ? null : item.getDataSetRow();
            item = campaigns.bindDataSet(projectKey, id, name, row);
        }
        if (assignee != null) {
            item = campaigns.assign(projectKey, id, assignee.orElse(null));
        }
        return mapper.item(item);
    }

    /** ADR-0018 décliner le test sur toutes les lignes d'un jeu de données (une ligne de campagne par ligne du jeu). */
    @PostMapping("/campaign-items/{id}/expand-data-set")
    @PreAuthorize(WRITE)
    public CampaignDetail expandDataSet(@PathVariable String projectKey, @PathVariable UUID id, @Valid @RequestBody ExpandDataSetRequest r) {
        return mapper.detail(campaigns.expandDataSet(projectKey, id, r.dataSetName()));
    }

    @DeleteMapping("/campaign-items/{id}")
    @PreAuthorize(WRITE)
    public ResponseEntity<Void> removeItem(@PathVariable String projectKey, @PathVariable UUID id) {
        campaigns.removeItem(projectKey, id);
        return ResponseEntity.noContent().build();
    }

    /** F-CMP-04 membres qui peuvent exécuter (choix de l'affectation). */
    @GetMapping("/testers")
    @PreAuthorize(READ)
    public List<UserRef> testers(@PathVariable String projectKey) {
        return campaigns.testers(projectKey).stream().map(mapper::user).toList();
    }
}
