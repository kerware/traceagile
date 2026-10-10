package com.traceagile.api.campaign;

import com.traceagile.application.campaign.CampaignFolderService;
import com.traceagile.domain.campaign.CampaignFolder;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** ADR-0018 dossiers de campagnes (arbre de la page Campagnes). */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}/campaign-folders")
@Tag(name = "Campagnes")
public class CampaignFolderController {

    record CampaignFolderRequest(@NotBlank @Size(max = 300) String path) {
    }

    record MoveCampaignFolderRequest(@NotBlank @Size(max = 300) String from, @NotBlank @Size(max = 300) String to) {
    }

    record CampaignFolderResponse(@Schema(requiredMode = Schema.RequiredMode.REQUIRED) String path) {
    }

    record MoveCampaignFolderResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String path,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Nombre de campagnes reclassées") int movedCampaigns) {
    }

    private final CampaignFolderService folders;

    public CampaignFolderController(CampaignFolderService folders) {
        this.folders = folders;
    }

    /** Tous les dossiers (explicites et portés par les campagnes, avec leurs ancêtres), triés. */
    @GetMapping
    @PreAuthorize(CampaignController.READ)
    public List<String> list(@PathVariable String projectKey) {
        return folders.all(projectKey);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize(CampaignController.WRITE)
    public CampaignFolderResponse create(@PathVariable String projectKey, @Valid @RequestBody CampaignFolderRequest request) {
        return new CampaignFolderResponse(folders.create(projectKey, request.path()));
    }

    /** Renommer ou déplacer un dossier : ses campagnes, même terminées, sont reclassées. */
    @PostMapping("/move")
    @PreAuthorize(CampaignController.WRITE)
    public MoveCampaignFolderResponse move(@PathVariable String projectKey, @Valid @RequestBody MoveCampaignFolderRequest request) {
        int moved = folders.move(projectKey, request.from(), request.to());
        return new MoveCampaignFolderResponse(CampaignFolder.require(request.to()), moved);
    }

    /** Supprime un dossier sans campagne (422 CAMPAIGN_FOLDER_NOT_EMPTY sinon). */
    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize(CampaignController.WRITE)
    public void delete(@PathVariable String projectKey, @RequestParam String path) {
        folders.delete(projectKey, path);
    }
}
