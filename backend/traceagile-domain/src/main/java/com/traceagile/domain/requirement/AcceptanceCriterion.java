package com.traceagile.domain.requirement;

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

/** §3.1 AcceptanceCriterion : condition vérifiable, en texte libre ou en Gherkin (F-REQ-09). */
@Entity
@Table(name = "acceptance_criteria")
public class AcceptanceCriterion extends AuditableEntity {

    static final int MAX_LENGTH = 10_000;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requirement_id")
    private Requirement requirement;

    @Column(nullable = false)
    private int position;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private CriterionFormat format;

    @Column(nullable = false, columnDefinition = "text")
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private CriterionStatus status = CriterionStatus.TO_VERIFY;

    protected AcceptanceCriterion() {
    }

    AcceptanceCriterion(Requirement requirement, int position, CriterionFormat format, String content) {
        this.requirement = requirement;
        this.position = position;
        rewrite(format, content);
    }

    /** Le contenu Gherkin est validé syntaxiquement par l'application avant l'appel (F-REQ-10). */
    public void rewrite(CriterionFormat format, String content) {
        if (content == null || content.isBlank()) {
            throw new BusinessRuleException("CRITERION_CONTENT_REQUIRED", "Le critère d'acceptation est vide.");
        }
        if (content.length() > MAX_LENGTH) {
            throw new BusinessRuleException("CRITERION_CONTENT_TOO_LONG", "Le critère dépasse " + MAX_LENGTH + " caractères.");
        }
        this.format = format == null ? CriterionFormat.TEXT : format;
        this.content = content.strip();
    }

    public Requirement getRequirement() {
        return requirement;
    }

    public int getPosition() {
        return position;
    }

    void setPosition(int position) {
        this.position = position;
    }

    public CriterionFormat getFormat() {
        return format;
    }

    public String getContent() {
        return content;
    }

    public CriterionStatus getStatus() {
        return status;
    }

    /** Résumé lisible pour les instantanés et l'historique. */
    String describe() {
        return "[" + format + "] " + content;
    }
}
