package com.traceagile.application.requirement;

import com.traceagile.application.common.ForbiddenException;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.requirement.RequirementService.CreateRequirementCommand;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.requirement.Comment;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.requirement.ExampleCard;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementType;
import java.time.Clock;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §4.4 atelier d'affinage Example Mapping (F-REQ-13, F-REQ-14) et commentaires d'exigence (§13.2) ;
 * les questions sont des commentaires non résolus (ADR-0024).
 */
@Service
@Transactional
public class WorkshopService {

    private final RequirementService requirements;
    private final AcceptanceCriterionService criteria;
    private final CommentRepository comments;
    private final ExampleCardRepository cards;
    private final Clock clock;

    public WorkshopService(RequirementService requirements, AcceptanceCriterionService criteria, CommentRepository comments,
                           ExampleCardRepository cards, Clock clock) {
        this.requirements = requirements;
        this.criteria = criteria;
        this.comments = comments;
        this.cards = cards;
        this.clock = clock;
    }

    /** Résultat d'une conversion : la carte et l'élément créé. */
    public record Conversion(ExampleCard card, Requirement rule, AcceptanceCriterion criterion) {
    }

    // ---------------------------------------------------------------- commentaires

    @Transactional(readOnly = true)
    public List<Comment> comments(String projectKey, String requirementKey) {
        return comments.findByRequirement_IdOrderByCreatedAtAsc(requirements.get(projectKey, requirementKey).getId());
    }

    public Comment addComment(String projectKey, String requirementKey, String login, String text, boolean question) {
        return comments.save(new Comment(requirements.get(projectKey, requirementKey), login, text, question));
    }

    /** Seul l'auteur modifie son commentaire. */
    public Comment editComment(String projectKey, UUID id, String login, String text) {
        Comment comment = comment(projectKey, id);
        ensureAuthor(comment, login);
        comment.edit(text, Instant.now(clock));
        return comment;
    }

    public void deleteComment(String projectKey, UUID id, String login) {
        Comment comment = comment(projectKey, id);
        ensureAuthor(comment, login);
        comments.delete(comment);
    }

    /** F-REQ-14 / F-REQ-15 résoudre une question (ou la rouvrir). */
    public Comment resolve(String projectKey, UUID id, String login, boolean resolved) {
        Comment comment = comment(projectKey, id);
        comment.resolve(resolved, login, Instant.now(clock));
        return comment;
    }

    private Comment comment(String projectKey, UUID id) {
        return comments.findByIdAndRequirement_Project_Key(id, projectKey)
                .orElseThrow(() -> new NotFoundException("COMMENT_NOT_FOUND", "Commentaire introuvable."));
    }

    private static void ensureAuthor(Comment comment, String login) {
        if (!comment.isAuthor(login)) {
            throw new ForbiddenException("COMMENT_NOT_AUTHOR", "Seul l'auteur peut modifier ou supprimer ce commentaire.");
        }
    }

    // ---------------------------------------------------------------- cartes

    @Transactional(readOnly = true)
    public Requirement story(String projectKey, String requirementKey) {
        return requirements.get(projectKey, requirementKey);
    }

    @Transactional(readOnly = true)
    public List<ExampleCard> cards(String projectKey, String requirementKey) {
        return cards.findByRequirement_IdOrderByPositionAsc(requirements.get(projectKey, requirementKey).getId());
    }

    /** F-REQ-13 nouvelle règle ({@code ruleId} absent) ou nouvel exemple d'une règle, en fin de colonne. */
    public ExampleCard addCard(String projectKey, String requirementKey, ExampleCard.Kind kind, UUID ruleId, String text) {
        Requirement story = requirements.get(projectKey, requirementKey);
        List<ExampleCard> existing = cards.findByRequirement_IdOrderByPositionAsc(story.getId());
        int position = existing.stream().filter(c -> c.getKind() == kind).mapToInt(ExampleCard::getPosition).max().orElse(0) + 1;
        if (kind == ExampleCard.Kind.RULE) {
            return cards.save(ExampleCard.rule(story, text, position));
        }
        ExampleCard rule = ruleId == null ? null : card(projectKey, ruleId);
        return cards.save(ExampleCard.example(story, rule, text, position));
    }

    public ExampleCard editCard(String projectKey, UUID id, String text) {
        ExampleCard card = card(projectKey, id);
        card.edit(text);
        return card;
    }

    /** Supprimer une règle supprime ses exemples (cascade en base). */
    public void deleteCard(String projectKey, UUID id) {
        cards.delete(card(projectKey, id));
    }

    /**
     * F-REQ-14 conversion : une règle devient une exigence BUSINESS_RULE enfant de la story, un exemple
     * un critère d'acceptation Gherkin à compléter.
     */
    public Conversion convert(String projectKey, UUID id) {
        ExampleCard card = card(projectKey, id);
        Requirement story = card.getRequirement();
        card.ensureConvertible();
        if (card.getKind() == ExampleCard.Kind.RULE) {
            Requirement rule = requirements.create(projectKey,
                    new CreateRequirementCommand(RequirementType.BUSINESS_RULE, card.getText(), story.getKey(), null));
            card.markConverted(rule.getKey());
            return new Conversion(card, rule, null);
        }
        AcceptanceCriterion criterion = criteria.add(projectKey, story.getKey(), CriterionFormat.GHERKIN, card.gherkin());
        card.markConverted("Critère " + criterion.getPosition());
        return new Conversion(card, null, criterion);
    }

    @Transactional(readOnly = true)
    public ExampleCard card(String projectKey, UUID id) {
        return cards.findByIdAndRequirement_Project_Key(id, projectKey)
                .orElseThrow(() -> new NotFoundException("EXAMPLE_CARD_NOT_FOUND", "Carte introuvable."));
    }
}
