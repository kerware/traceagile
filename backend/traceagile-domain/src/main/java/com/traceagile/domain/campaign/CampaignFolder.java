package com.traceagile.domain.campaign;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.testcase.TestFolder;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/**
 * ADR-0018 dossier de campagnes explicite (vide possible), comme les dossiers de tests (ADR-0013) :
 * le dossier d'une campagne ({@link Campaign#getFolder()}) est un chemin « a/b » qui implique « a ».
 */
@Entity
@Table(name = "campaign_folders")
public class CampaignFolder extends AuditableEntity {

    public static final int MAX_LENGTH = TestFolder.MAX_LENGTH;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @Column(nullable = false, length = MAX_LENGTH)
    private String path;

    protected CampaignFolder() {
    }

    public CampaignFolder(Project project, String path) {
        this.project = project;
        moveTo(path);
    }

    /** Chemin normalisé obligatoire (« Version 2.0 / Sprints » → « Version 2.0/Sprints »). */
    public static String require(String path) {
        String normalized = TestFolder.normalize(path);
        if (normalized == null) {
            throw new BusinessRuleException("CAMPAIGN_FOLDER_PATH_REQUIRED", "Le nom du dossier est obligatoire.");
        }
        if (normalized.length() > MAX_LENGTH) {
            throw new BusinessRuleException("CAMPAIGN_FOLDER_PATH_TOO_LONG", "Le chemin du dossier dépasse " + MAX_LENGTH + " caractères.");
        }
        return normalized;
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
