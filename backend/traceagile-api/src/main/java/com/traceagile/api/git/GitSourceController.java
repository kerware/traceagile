package com.traceagile.api.git;

import com.traceagile.api.git.GitDtos.GitProjectRequest;
import com.traceagile.api.git.GitDtos.GitProjectResponse;
import com.traceagile.api.git.GitDtos.GitSourceRequest;
import com.traceagile.api.git.GitDtos.GitSourceResponse;
import com.traceagile.application.git.GitSourceService;
import com.traceagile.application.git.GitSourceService.SourceCommand;
import com.traceagile.domain.git.GitProject;
import com.traceagile.domain.git.GitSource;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * ADR-0030 Administration › Dépôts Git : dépôts (compte ou organisation, avec ou sans authentification)
 * et leurs projets, déclarés par l'administrateur système. La liste est lisible par tout utilisateur
 * connecté (choix du projet dans une fiche de test), sans les secrets.
 */
@RestController
@Tag(name = "Dépôts Git")
public class GitSourceController {

    static final String ADMIN = "hasRole('SYSTEM_ADMIN')";

    private final GitSourceService git;

    public GitSourceController(GitSourceService git) {
        this.git = git;
    }

    @GetMapping("/api/v1/git-sources")
    @PreAuthorize("isAuthenticated()")
    public List<GitSourceResponse> list() {
        List<GitProject> projects = git.projects();
        return git.list().stream().map(s -> response(s, projects)).toList();
    }

    @PostMapping("/api/v1/git-sources")
    @PreAuthorize(ADMIN)
    public ResponseEntity<GitSourceResponse> create(@Valid @RequestBody GitSourceRequest r) {
        GitSource source = git.create(command(r));
        return ResponseEntity.created(URI.create("/api/v1/git-sources/" + source.getId())).body(response(source, List.of()));
    }

    @PatchMapping("/api/v1/git-sources/{id}")
    @PreAuthorize(ADMIN)
    public GitSourceResponse update(@PathVariable UUID id, @Valid @RequestBody GitSourceRequest r) {
        GitSource source = git.update(id, command(r));
        return response(source, git.projects());
    }

    @DeleteMapping("/api/v1/git-sources/{id}")
    @PreAuthorize(ADMIN)
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        git.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/api/v1/git-sources/{id}/projects")
    @PreAuthorize(ADMIN)
    public ResponseEntity<GitProjectResponse> addProject(@PathVariable UUID id, @Valid @RequestBody GitProjectRequest r) {
        GitProject project = git.addProject(id, r.name(), r.defaultBranch(), r.description());
        return ResponseEntity.created(URI.create("/api/v1/git-projects/" + project.getId())).body(project(project));
    }

    @PatchMapping("/api/v1/git-projects/{id}")
    @PreAuthorize(ADMIN)
    public GitProjectResponse updateProject(@PathVariable UUID id, @Valid @RequestBody GitProjectRequest r) {
        return project(git.updateProject(id, r.name(), r.defaultBranch(), r.description()));
    }

    @DeleteMapping("/api/v1/git-projects/{id}")
    @PreAuthorize(ADMIN)
    public ResponseEntity<Void> deleteProject(@PathVariable UUID id) {
        git.deleteProject(id);
        return ResponseEntity.noContent().build();
    }

    private static SourceCommand command(GitSourceRequest r) {
        return new SourceCommand(r.name(), r.baseUrl(), r.description(), r.authType(), r.username(), r.secret());
    }

    private static GitSourceResponse response(GitSource s, List<GitProject> projects) {
        return new GitSourceResponse(s.getId(), s.getName(), s.getBaseUrl(), s.getAuthType(), s.getUsername(), s.hasSecret(), s.getDescription(),
                projects.stream().filter(p -> p.getSource().getId().equals(s.getId())).map(GitSourceController::project).toList());
    }

    private static GitProjectResponse project(GitProject p) {
        return new GitProjectResponse(p.getId(), p.getSource().getId(), p.getName(), p.label(), p.getDefaultBranch(), p.getDescription(),
                p.cloneUrl(), p.webUrl(), p.getVersion());
    }
}
