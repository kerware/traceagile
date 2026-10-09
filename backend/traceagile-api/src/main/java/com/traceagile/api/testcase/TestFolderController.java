package com.traceagile.api.testcase;

import com.traceagile.application.testcase.TestFolderService;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestFolder;
import com.traceagile.domain.testcase.TestKind;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** ADR-0013 dossiers du référentiel de tests (menu contextuel de l'arbre). */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}/test-folders")
@Tag(name = "Dossiers de tests")
public class TestFolderController {

    record FolderRequest(@NotBlank @Size(max = 300) String path) {
    }

    record MoveFolderRequest(@NotBlank @Size(max = 300) String from, @NotBlank @Size(max = 300) String to) {
    }

    record FolderResponse(@Schema(requiredMode = Schema.RequiredMode.REQUIRED) String path) {
    }

    record MoveFolderResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String path,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Nombre de tests reclassés") int movedTests) {
    }

    private final TestFolderService folders;
    private final TestPermissions permissions;

    public TestFolderController(TestFolderService folders, TestPermissions permissions) {
        this.folders = folders;
        this.permissions = permissions;
    }

    /** Tous les dossiers (explicites et portés par les tests, avec leurs ancêtres), triés. */
    @GetMapping
    @PreAuthorize(TestPermissions.READ)
    public List<String> list(@PathVariable String projectKey) {
        return folders.all(projectKey);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public FolderResponse create(@PathVariable String projectKey, @Valid @RequestBody FolderRequest request) {
        return new FolderResponse(folders.create(projectKey, request.path()));
    }

    /** Renommer ou déplacer un dossier : il faut pouvoir modifier chacun des tests reclassés (§2.2). */
    @PostMapping("/move")
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public MoveFolderResponse move(@PathVariable String projectKey, Authentication authentication,
                                   @Valid @RequestBody MoveFolderRequest request) {
        folders.testsWithin(projectKey, request.from()).stream().map(TestCase::getKind).distinct()
                .forEach((TestKind kind) -> permissions.checkWrite(authentication, projectKey, kind));
        int moved = folders.move(projectKey, request.from(), request.to());
        return new MoveFolderResponse(TestFolder.require(request.to()), moved);
    }

    /** Supprime un dossier vide (422 TEST_FOLDER_NOT_EMPTY sinon). */
    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public void delete(@PathVariable String projectKey, @RequestParam String path) {
        folders.delete(projectKey, path);
    }
}
