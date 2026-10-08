package com.traceagile.api.requirement;

import com.traceagile.api.requirement.RequirementDtos.ChecklistItemRequest;
import com.traceagile.api.requirement.RequirementDtos.ChecklistItemResponse;
import com.traceagile.api.requirement.RequirementDtos.ProjectChecklistsResponse;
import com.traceagile.application.requirement.ChecklistService;
import com.traceagile.application.requirement.ChecklistService.ItemDraft;
import com.traceagile.domain.requirement.ChecklistKind;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** F-REQ-19 DoR et DoD du projet, paramétrées par son administrateur (§13.2 /admin). */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}/checklists")
@Tag(name = "Exigences")
public class ChecklistController {

    private final ChecklistService checklists;
    private final RequirementMapper mapper;

    public ChecklistController(ChecklistService checklists, RequirementMapper mapper) {
        this.checklists = checklists;
        this.mapper = mapper;
    }

    @GetMapping
    @PreAuthorize("hasPermission(#projectKey, 'Project', 'PROJECT_READ')")
    public ProjectChecklistsResponse get(@PathVariable String projectKey) {
        return new ProjectChecklistsResponse(
                mapper.toItems(checklists.items(projectKey, ChecklistKind.DOR)),
                mapper.toItems(checklists.items(projectKey, ChecklistKind.DOD)));
    }

    /** Remplace la liste ; un item gardé conserve son {@code id} (et les coches posées). */
    @PutMapping("/{kind}")
    @PreAuthorize("hasPermission(#projectKey, 'Project', 'PROJECT_ADMIN')")
    public List<ChecklistItemResponse> replace(@PathVariable String projectKey, @PathVariable ChecklistKind kind,
                                               @RequestBody List<@Valid ChecklistItemRequest> items) {
        return mapper.toItems(checklists.replace(projectKey, kind,
                items.stream().map(i -> new ItemDraft(i.id(), i.label(), i.rule())).toList()));
    }
}
