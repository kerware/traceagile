package com.traceagile.api.administration;

import com.traceagile.api.administration.AdministrationDtos.CreateProjectRequest;
import com.traceagile.api.administration.AdministrationDtos.MemberRequest;
import com.traceagile.api.administration.AdministrationDtos.MemberResponse;
import com.traceagile.api.administration.AdministrationDtos.ProjectResponse;
import com.traceagile.api.web.PageResponse;
import com.traceagile.application.administration.CreateProjectCommand;
import com.traceagile.application.administration.MemberAssignment;
import com.traceagile.application.administration.ProjectService;
import com.traceagile.application.administration.UserAdministrationService;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.administration.User;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** §12 Projets et membres ; §2.2 visibilité et droits par projet. */
@RestController
@RequestMapping("/api/v1/projects")
@Tag(name = "Administration")
public class ProjectController {

    private final ProjectService projects;
    private final UserAdministrationService users;
    private final AdministrationMapper mapper;

    public ProjectController(ProjectService projects, UserAdministrationService users, AdministrationMapper mapper) {
        this.projects = projects;
        this.users = users;
        this.mapper = mapper;
    }

    /** §2.2 Seuls les projets où l'utilisateur a un rôle (tous pour l'administrateur système). */
    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public PageResponse<ProjectResponse> list(@ParameterObject Pageable pageable, Authentication authentication) {
        User current = users.getByLogin(authentication.getName());
        return PageResponse.of(projects.listVisible(current, pageable), project -> toResponse(project, current));
    }

    @PostMapping
    @PreAuthorize("hasRole('SYSTEM_ADMIN')")
    public ResponseEntity<ProjectResponse> create(@Valid @RequestBody CreateProjectRequest request, Authentication authentication) {
        Project project = projects.create(new CreateProjectCommand(request.key(), request.name(), request.description()));
        return ResponseEntity.created(URI.create("/api/v1/projects/" + project.getKey()))
                .body(toResponse(project, users.getByLogin(authentication.getName())));
    }

    @GetMapping("/{key}")
    @PreAuthorize("hasPermission(#key, 'Project', 'PROJECT_READ')")
    public ProjectResponse get(@PathVariable String key, Authentication authentication) {
        return toResponse(projects.get(key), users.getByLogin(authentication.getName()));
    }

    @GetMapping("/{key}/members")
    @PreAuthorize("hasPermission(#key, 'Project', 'PROJECT_READ')")
    public List<MemberResponse> members(@PathVariable String key) {
        return mapper.toMemberResponses(projects.get(key).getMembers());
    }

    /** §12 PUT /projects/{key}/members : remplace la liste complète des membres. */
    @PutMapping("/{key}/members")
    @PreAuthorize("hasPermission(#key, 'Project', 'PROJECT_ADMIN')")
    public List<MemberResponse> replaceMembers(@PathVariable String key, @RequestBody List<@Valid MemberRequest> members) {
        Project project = projects.replaceMembers(key,
                members.stream().map(m -> new MemberAssignment(m.login(), m.role())).toList());
        return mapper.toMemberResponses(project.getMembers());
    }

    private ProjectResponse toResponse(Project project, User current) {
        return mapper.toResponse(project, project.roleOf(current).orElse(null));
    }
}
