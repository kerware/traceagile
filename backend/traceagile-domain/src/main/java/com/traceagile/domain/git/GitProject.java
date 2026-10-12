package com.traceagile.domain.git;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.regex.Pattern;

/**
 * ADR-0030 projet d'un dépôt Git déclaré (« saucedemo-e2e » sous « https://github.com/kerware ») :
 * choisi dans les fiches de tests automatisés, il donne l'adresse de clonage et la branche par défaut.
 */
@Entity
@Table(name = "git_projects")
public class GitProject extends AuditableEntity {

    private static final Pattern NAME = Pattern.compile("^[\\w.-]+(/[\\w.-]+)*$");

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "source_id")
    private GitSource source;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(name = "default_branch", length = 200)
    private String defaultBranch;

    @Column(length = 500)
    private String description;

    protected GitProject() {
    }

    public GitProject(GitSource source, String name, String defaultBranch, String description) {
        this.source = source;
        update(name, defaultBranch, description);
    }

    public void update(String name, String defaultBranch, String description) {
        String n = name == null ? "" : name.strip();
        if (n.endsWith(".git")) {
            n = n.substring(0, n.length() - 4);
        }
        if (!NAME.matcher(n).matches()) {
            throw new BusinessRuleException("GIT_PROJECT_NAME_INVALID",
                    "Nom de projet invalide : « " + name + " » (lettres, chiffres, « - », « _ », « . », sous-dossiers avec « / »).");
        }
        this.name = n;
        this.defaultBranch = defaultBranch == null || defaultBranch.isBlank() ? null : defaultBranch.strip();
        this.description = description == null || description.isBlank() ? null : description.strip();
    }

    /** Adresse de clonage, recalculée à chaque fois : elle suit les changements du dépôt. */
    public String cloneUrl() {
        return getSource().cloneUrl(name);
    }

    public String webUrl() {
        return getSource().webUrl(name);
    }

    /** « kerware / saucedemo-e2e ». */
    public String label() {
        return getSource().getName() + " / " + name;
    }

    public GitSource getSource() {
        return source;
    }

    public String getName() {
        return name;
    }

    public String getDefaultBranch() {
        return defaultBranch;
    }

    public String getDescription() {
        return description;
    }
}
