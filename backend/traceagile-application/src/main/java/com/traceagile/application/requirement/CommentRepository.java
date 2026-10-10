package com.traceagile.application.requirement;

import com.traceagile.domain.requirement.Comment;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** Port des commentaires d'exigence (ADR-0024). */
public interface CommentRepository {

    List<Comment> findByRequirement_IdOrderByCreatedAtAsc(UUID requirementId);

    Optional<Comment> findByIdAndRequirement_Project_Key(UUID id, String projectKey);

    long countByRequirement_IdAndQuestionTrueAndResolvedAtIsNull(UUID requirementId);

    Comment save(Comment comment);

    void delete(Comment comment);
}
