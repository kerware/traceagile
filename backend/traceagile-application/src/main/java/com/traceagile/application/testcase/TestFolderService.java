package com.traceagile.application.testcase;

import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.audit.AuditService;
import com.traceagile.application.common.ConflictException;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.audit.AuditAction;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestFolder;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * ADR-0013 dossiers du référentiel de tests : dossiers explicites (vides possibles) et dossiers
 * implicites portés par les tests. Renommer ou déplacer un dossier reclasse ses tests et sous-dossiers.
 */
@Service
@Transactional
public class TestFolderService {

    private final TestFolderRepository folders;
    private final TestCaseRepository tests;
    private final ProjectRepository projects;
    private final AuditService audit;

    public TestFolderService(TestFolderRepository folders, TestCaseRepository tests, ProjectRepository projects, AuditService audit) {
        this.folders = folders;
        this.tests = tests;
        this.projects = projects;
        this.audit = audit;
    }

    /** Tous les dossiers connus, explicites ou portés par un test, avec leurs ancêtres. */
    @Transactional(readOnly = true)
    public List<String> all(String projectKey) {
        TreeSet<String> paths = new TreeSet<>(String.CASE_INSENSITIVE_ORDER);
        folders.findByProject_KeyOrderByPathAsc(projectKey).forEach(f -> addWithAncestors(paths, f.getPath()));
        tests.findByProject_KeyOrderByKeyNumberAsc(projectKey).forEach(t -> addWithAncestors(paths, t.getFolder()));
        return List.copyOf(paths);
    }

    @Transactional(readOnly = true)
    public List<String> explicit(String projectKey) {
        return folders.findByProject_KeyOrderByPathAsc(projectKey).stream().map(TestFolder::getPath).toList();
    }

    public String create(String projectKey, String path) {
        Project project = projects.findByKey(projectKey)
                .orElseThrow(() -> new NotFoundException("PROJECT_NOT_FOUND", "Projet « " + projectKey + " » introuvable."));
        String normalized = TestFolder.require(path);
        if (all(projectKey).stream().anyMatch(normalized::equalsIgnoreCase)) {
            throw new ConflictException("TEST_FOLDER_EXISTS", "Le dossier « " + normalized + " » existe déjà.");
        }
        return folders.save(new TestFolder(project, normalized)).getPath();
    }

    /** Tests rangés dans le dossier ou ses sous-dossiers. */
    @Transactional(readOnly = true)
    public List<TestCase> testsWithin(String projectKey, String path) {
        String root = TestFolder.require(path);
        return tests.findByProject_KeyOrderByKeyNumberAsc(projectKey).stream().filter(t -> TestFolder.isWithin(t.getFolder(), root)).toList();
    }

    /** Renomme ou déplace une branche : dossiers explicites et dossiers des tests. Renvoie le nombre de tests reclassés. */
    public int move(String projectKey, String from, String to) {
        String source = TestFolder.require(from);
        String target = TestFolder.require(to);
        if (!all(projectKey).contains(source)) {
            throw new NotFoundException("TEST_FOLDER_NOT_FOUND", "Dossier « " + source + " » introuvable.");
        }
        if (TestFolder.isWithin(target, source) && !target.equals(source)) {
            throw new BusinessRuleException("TEST_FOLDER_MOVE_INTO_ITSELF", "Un dossier ne peut pas être déplacé dans l'un de ses sous-dossiers.");
        }
        if (target.equals(source)) {
            return 0;
        }
        List<String> existing = explicit(projectKey);
        for (TestFolder folder : folders.findByProject_KeyOrderByPathAsc(projectKey)) {
            if (TestFolder.isWithin(folder.getPath(), source)) {
                String rebased = TestFolder.rebase(folder.getPath(), source, target);
                if (existing.contains(rebased)) {
                    folders.delete(folder);
                } else {
                    folder.moveTo(rebased);
                }
            }
        }
        List<TestCase> moved = testsWithin(projectKey, source);
        for (TestCase test : moved) {
            Map<String, Object> before = test.snapshot();
            test.relocate(TestFolder.rebase(test.getFolder(), source, target));
            audit.record(test.getProject().getId(), TestCaseService.AUDIT_TYPE, test.getId(), test.getKey(), AuditAction.UPDATED,
                    before, test.snapshot());
        }
        return moved.size();
    }

    /** Supprime un dossier vide (et ses sous-dossiers explicites vides). */
    public void delete(String projectKey, String path) {
        String root = TestFolder.require(path);
        if (!testsWithin(projectKey, root).isEmpty()) {
            throw new BusinessRuleException("TEST_FOLDER_NOT_EMPTY", "Le dossier « " + root + " » contient des tests : déplacez-les d'abord.");
        }
        List<TestFolder> branch = folders.findByProject_KeyOrderByPathAsc(projectKey).stream()
                .filter(f -> TestFolder.isWithin(f.getPath(), root)).toList();
        if (branch.isEmpty()) {
            throw new NotFoundException("TEST_FOLDER_NOT_FOUND", "Dossier « " + root + " » introuvable.");
        }
        branch.forEach(folders::delete);
    }

    private static void addWithAncestors(TreeSet<String> paths, String path) {
        if (path == null) {
            return;
        }
        int slash = -1;
        while ((slash = path.indexOf('/', slash + 1)) > 0) {
            paths.add(path.substring(0, slash));
        }
        paths.add(path);
    }
}
