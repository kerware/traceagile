package com.traceagile.domain.requirement;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;

/**
 * §13.2 commentaire d'une exigence (ADR-0024). Une {@code question} reste ouverte tant qu'elle n'est
 * pas résolue : c'est une carte « Question » de l'atelier Example Mapping (F-REQ-14) et elle bloque le
 * passage à READY sans acquittement (F-REQ-15).
 */
@Entity
@Table(name = "comments")
public class Comment extends AuditableEntity {

    public static final int MAX_LENGTH = 5000;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requirement_id")
    private Requirement requirement;

    @Column(nullable = false, length = 50)
    private String author;

    @Column(nullable = false, columnDefinition = "text")
    private String text;

    @Column(nullable = false)
    private boolean question;

    @Column(name = "resolved_at")
    private Instant resolvedAt;

    @Column(name = "resolved_by", length = 50)
    private String resolvedBy;

    @Column(name = "edited_at")
    private Instant editedAt;

    protected Comment() {
    }

    public Comment(Requirement requirement, String author, String text, boolean question) {
        this.requirement = requirement;
        this.author = author;
        this.text = require(text);
        this.question = question;
    }

    private static String require(String text) {
        String value = text == null ? "" : text.strip();
        if (value.isEmpty()) {
            throw new BusinessRuleException("COMMENT_TEXT_REQUIRED", "Le commentaire est vide.");
        }
        if (value.length() > MAX_LENGTH) {
            throw new BusinessRuleException("COMMENT_TOO_LONG", "Le commentaire dépasse " + MAX_LENGTH + " caractères.");
        }
        return value;
    }

    public boolean isAuthor(String login) {
        return author.equals(login);
    }

    /** Modification du texte (par son auteur, vérifié par le service). */
    public void edit(String text, Instant now) {
        this.text = require(text);
        this.editedAt = now;
    }

    /** F-REQ-14 / F-REQ-15 résolution d'une question ({@code false} : la rouvrir). */
    public void resolve(boolean resolved, String login, Instant now) {
        if (!question) {
            throw new BusinessRuleException("COMMENT_NOT_A_QUESTION", "Seule une question se résout.");
        }
        this.resolvedAt = resolved ? now : null;
        this.resolvedBy = resolved ? login : null;
    }

    public boolean isOpenQuestion() {
        return question && resolvedAt == null;
    }

    public Requirement getRequirement() {
        return requirement;
    }

    public String getAuthor() {
        return author;
    }

    public String getText() {
        return text;
    }

    public boolean isQuestion() {
        return question;
    }

    public Instant getResolvedAt() {
        return resolvedAt;
    }

    public String getResolvedBy() {
        return resolvedBy;
    }

    public Instant getEditedAt() {
        return editedAt;
    }
}
