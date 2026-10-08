package com.traceagile.domain.requirement;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.List;

/**
 * F-REQ-19 Item de la DoR ou de la DoD d'un projet. Avec une {@link ChecklistRule}, il est vérifié
 * par l'outil ; sans règle, il est coché à la main sur chaque exigence.
 */
@Entity
@Table(name = "checklist_items")
public class ChecklistItem extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 3)
    private ChecklistKind kind;

    @Column(nullable = false)
    private int position;

    @Column(nullable = false, length = 200)
    private String label;

    @Enumerated(EnumType.STRING)
    @Column(length = 40)
    private ChecklistRule rule;

    protected ChecklistItem() {
    }

    public ChecklistItem(Project project, ChecklistKind kind, int position, String label, ChecklistRule rule) {
        if (label == null || label.isBlank()) {
            throw new BusinessRuleException("CHECKLIST_LABEL_REQUIRED", "Le libellé de l'item est obligatoire.");
        }
        this.project = project;
        this.kind = kind;
        this.position = position;
        this.label = label.strip();
        this.rule = rule;
    }

    /** Listes par défaut d'un nouveau projet (§4.6). */
    public static List<ChecklistItem> defaults(Project project) {
        return List.of(
                new ChecklistItem(project, ChecklistKind.DOR, 1, "Au moins un critère d'acceptation", ChecklistRule.HAS_ACCEPTANCE_CRITERION),
                new ChecklistItem(project, ChecklistKind.DOR, 2, "Estimation renseignée", ChecklistRule.ESTIMATED),
                new ChecklistItem(project, ChecklistKind.DOR, 3, "Story comprise et acceptée par l'équipe", null),
                new ChecklistItem(project, ChecklistKind.DOD, 1, "Au moins un test lié", ChecklistRule.HAS_LINKED_TEST),
                new ChecklistItem(project, ChecklistKind.DOD, 2, "Tous les tests liés passés", ChecklistRule.ALL_LINKED_TESTS_PASSED),
                new ChecklistItem(project, ChecklistKind.DOD, 3, "Aucune anomalie bloquante ouverte", ChecklistRule.NO_BLOCKING_DEFECT_OPEN),
                new ChecklistItem(project, ChecklistKind.DOD, 4, "Code revu et intégré", null));
    }

    public void update(int position, String label, ChecklistRule rule) {
        if (label == null || label.isBlank()) {
            throw new BusinessRuleException("CHECKLIST_LABEL_REQUIRED", "Le libellé de l'item est obligatoire.");
        }
        this.position = position;
        this.label = label.strip();
        this.rule = rule;
    }

    public Project getProject() {
        return project;
    }

    public ChecklistKind getKind() {
        return kind;
    }

    public int getPosition() {
        return position;
    }

    public String getLabel() {
        return label;
    }

    public ChecklistRule getRule() {
        return rule;
    }

    public boolean isAutomatic() {
        return rule != null;
    }
}
