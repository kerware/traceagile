package com.traceagile.domain.testcase;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Dossier de tests explicite (ADR-0013) : permet un dossier vide dans l'arbre du référentiel. Les
 * dossiers des tests ({@link TestCase#getFolder()}) restent implicites ; un chemin « a/b » implique « a ».
 */
@Entity
@Table(name = "test_folders")
public class TestFolder extends AuditableEntity {

    public static final int MAX_LENGTH = 300;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @Column(nullable = false, length = MAX_LENGTH)
    private String path;

    protected TestFolder() {
    }

    public TestFolder(Project project, String path) {
        this.project = project;
        moveTo(path);
    }

    /** « Panier / Ajout / » → « Panier/Ajout » ; {@code null} si aucun segment. */
    public static String normalize(String path) {
        if (path == null) {
            return null;
        }
        String normalized = Stream.of(path.split("/")).map(String::strip).filter(s -> !s.isEmpty()).collect(Collectors.joining("/"));
        return normalized.isEmpty() ? null : normalized;
    }

    public static String require(String path) {
        String normalized = normalize(path);
        if (normalized == null) {
            throw new BusinessRuleException("TEST_FOLDER_PATH_REQUIRED", "Le nom du dossier est obligatoire.");
        }
        if (normalized.length() > MAX_LENGTH) {
            throw new BusinessRuleException("TEST_FOLDER_PATH_TOO_LONG", "Le chemin du dossier dépasse " + MAX_LENGTH + " caractères.");
        }
        return normalized;
    }

    /** {@code path} est {@code root} ou l'un de ses sous-dossiers. */
    public static boolean isWithin(String path, String root) {
        return path != null && (path.equals(root) || path.startsWith(root + "/"));
    }

    /** Remplace le préfixe {@code from} de {@code path} par {@code to}. */
    public static String rebase(String path, String from, String to) {
        return to + path.substring(from.length());
    }

    public void moveTo(String path) {
        this.path = require(path);
    }

    public Project getProject() {
        return project;
    }

    public String getPath() {
        return path;
    }
}
