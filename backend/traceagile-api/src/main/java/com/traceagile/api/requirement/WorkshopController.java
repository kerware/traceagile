package com.traceagile.api.requirement;

import com.traceagile.application.administration.ProjectService;
import com.traceagile.application.requirement.WorkshopService;
import com.traceagile.domain.administration.Permission;
import com.traceagile.domain.requirement.Comment;
import com.traceagile.domain.requirement.ExampleCard;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.UserStory;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** §4.4 atelier Example Mapping (F-REQ-13, F-REQ-14) et §13.2 commentaires d'une exigence (ADR-0024). */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}")
@Tag(name = "Atelier et commentaires")
public class WorkshopController {

    static final String COMMENT = "hasPermission(#projectKey, 'Project', 'REQUIREMENT_COMMENT')";

    private final WorkshopService workshop;
    private final ProjectService projects;

    public WorkshopController(WorkshopService workshop, ProjectService projects) {
        this.workshop = workshop;
        this.projects = projects;
    }

    public record CommentResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String author,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Markdown") String text,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean question,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "F-REQ-15 question non résolue") boolean open,
            Instant resolvedAt,
            String resolvedBy,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant createdAt,
            Instant editedAt) {
    }

    public record CommentRequest(@NotBlank @Size(max = Comment.MAX_LENGTH) String text, boolean question) {
    }

    public record CommentEditRequest(@NotBlank @Size(max = Comment.MAX_LENGTH) String text) {
    }

    public record ResolveRequest(boolean resolved) {
    }

    public record ExampleCardRequest(@NotNull ExampleCard.Kind kind, UUID ruleId, @NotBlank @Size(max = ExampleCard.MAX_LENGTH) String text) {
    }

    public record ExampleCardEditRequest(@NotBlank @Size(max = ExampleCard.MAX_LENGTH) String text) {
    }

    public record ExampleCardResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExampleCard.Kind kind,
            UUID ruleId,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String text,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int position,
            @Schema(description = "F-REQ-14 clé de la règle métier créée ou « Critère n »") String convertedTo) {
    }

    /** Règle (bleue) et ses exemples (verts). */
    public record ExampleRuleResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExampleCardResponse rule,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<ExampleCardResponse> examples) {
    }

    /** F-REQ-13 les quatre colonnes : story (jaune), règles, exemples, questions (rouges). */
    public record ExampleMapResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String storyKey,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String storyTitle,
            String asA,
            String iWant,
            String soThat,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<ExampleRuleResponse> rules,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<CommentResponse> questions,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int openQuestions) {
    }

    public record ConversionResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ExampleCardResponse card,
            @Schema(description = "Règle métier créée") String requirementKey,
            @Schema(description = "Critère créé") Integer criterionPosition) {
    }

    // ---------------------------------------------------------------- commentaires

    @GetMapping("/requirements/{key}/comments")
    @PreAuthorize(RequirementController.READ)
    public List<CommentResponse> comments(@PathVariable String projectKey, @PathVariable String key) {
        return workshop.comments(projectKey, key).stream().map(WorkshopController::comment).toList();
    }

    @PostMapping("/requirements/{key}/comments")
    @PreAuthorize(COMMENT)
    @ResponseStatus(HttpStatus.CREATED)
    public CommentResponse addComment(@PathVariable String projectKey, @PathVariable String key, @Valid @RequestBody CommentRequest r,
                                      Authentication authentication) {
        return comment(workshop.addComment(projectKey, key, authentication.getName(), r.text(), r.question()));
    }

    @PutMapping("/comments/{id}")
    @PreAuthorize(COMMENT)
    public CommentResponse editComment(@PathVariable String projectKey, @PathVariable UUID id, @Valid @RequestBody CommentEditRequest r,
                                       Authentication authentication) {
        return comment(workshop.editComment(projectKey, id, authentication.getName(), r.text()));
    }

    @DeleteMapping("/comments/{id}")
    @PreAuthorize(COMMENT)
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteComment(@PathVariable String projectKey, @PathVariable UUID id, Authentication authentication) {
        workshop.deleteComment(projectKey, id, authentication.getName());
    }

    /** F-REQ-14 / F-REQ-15 résoudre (ou rouvrir) une question. */
    @PostMapping("/comments/{id}/resolve")
    @PreAuthorize(COMMENT)
    public CommentResponse resolve(@PathVariable String projectKey, @PathVariable UUID id, @RequestBody ResolveRequest r, Authentication authentication) {
        return comment(workshop.resolve(projectKey, id, authentication.getName(), r.resolved()));
    }

    // ---------------------------------------------------------------- Example Mapping

    @GetMapping("/requirements/{key}/example-map")
    @PreAuthorize(RequirementController.READ)
    public ExampleMapResponse exampleMap(@PathVariable String projectKey, @PathVariable String key) {
        List<ExampleCard> cards = workshop.cards(projectKey, key);
        List<Comment> questions = workshop.comments(projectKey, key).stream().filter(Comment::isQuestion).toList();
        Requirement story = cards.isEmpty() ? null : cards.getFirst().getRequirement();
        return map(projectKey, key, story, cards, questions);
    }

    @PostMapping("/requirements/{key}/example-cards")
    @PreAuthorize(RequirementController.CONTRIBUTE)
    @ResponseStatus(HttpStatus.CREATED)
    public ExampleCardResponse addCard(@PathVariable String projectKey, @PathVariable String key, @Valid @RequestBody ExampleCardRequest r) {
        return card(workshop.addCard(projectKey, key, r.kind(), r.ruleId(), r.text()));
    }

    @PutMapping("/example-cards/{id}")
    @PreAuthorize(RequirementController.CONTRIBUTE)
    public ExampleCardResponse editCard(@PathVariable String projectKey, @PathVariable UUID id, @Valid @RequestBody ExampleCardEditRequest r) {
        return card(workshop.editCard(projectKey, id, r.text()));
    }

    @DeleteMapping("/example-cards/{id}")
    @PreAuthorize(RequirementController.CONTRIBUTE)
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteCard(@PathVariable String projectKey, @PathVariable UUID id) {
        workshop.deleteCard(projectKey, id);
    }

    /**
     * F-REQ-14 conversion : un exemple en critère Gherkin (qui peut proposer des critères), une règle en
     * exigence BUSINESS_RULE enfant (qui peut écrire des exigences, vérifié ici → 403).
     */
    @PostMapping("/example-cards/{id}/convert")
    @PreAuthorize(RequirementController.CONTRIBUTE)
    @ResponseStatus(HttpStatus.CREATED)
    public ConversionResponse convert(@PathVariable String projectKey, @PathVariable UUID id, Authentication authentication) {
        if (workshop.card(projectKey, id).getKind() == ExampleCard.Kind.RULE
                && !projects.isAllowed(authentication.getName(), projectKey, Permission.REQUIREMENT_WRITE)) {
            throw new AccessDeniedException("Créer une règle métier demande le droit d'écrire les exigences.");
        }
        WorkshopService.Conversion c = workshop.convert(projectKey, id);
        return new ConversionResponse(card(c.card()), c.rule() == null ? null : c.rule().getKey(),
                c.criterion() == null ? null : c.criterion().getPosition());
    }

    // ---------------------------------------------------------------- correspondances

    private ExampleMapResponse map(String projectKey, String key, Requirement loaded, List<ExampleCard> cards, List<Comment> questions) {
        Requirement story = loaded != null ? loaded : workshop.story(projectKey, key);
        UserStory us = story.getUserStory() == null ? UserStory.EMPTY : story.getUserStory();
        List<ExampleRuleResponse> rules = cards.stream().filter(c -> c.getKind() == ExampleCard.Kind.RULE)
                .map(rule -> new ExampleRuleResponse(card(rule), cards.stream()
                        .filter(c -> c.getKind() == ExampleCard.Kind.EXAMPLE && c.getRule().getId().equals(rule.getId()))
                        .map(WorkshopController::card).toList()))
                .toList();
        return new ExampleMapResponse(story.getKey(), story.getTitle(), us.asA(), us.iWant(), us.soThat(), rules,
                questions.stream().map(WorkshopController::comment).toList(), (int) questions.stream().filter(Comment::isOpenQuestion).count());
    }

    static CommentResponse comment(Comment c) {
        return new CommentResponse(c.getId(), c.getAuthor(), c.getText(), c.isQuestion(), c.isOpenQuestion(), c.getResolvedAt(), c.getResolvedBy(),
                c.getCreatedAt(), c.getEditedAt());
    }

    static ExampleCardResponse card(ExampleCard c) {
        return new ExampleCardResponse(c.getId(), c.getKind(), c.getRule() == null ? null : c.getRule().getId(), c.getText(), c.getPosition(),
                c.getConvertedTo());
    }
}
