package com.traceagile.infrastructure.persistence;

import com.traceagile.application.requirement.CommentRepository;
import com.traceagile.domain.requirement.Comment;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link CommentRepository}. */
public interface JpaCommentRepository extends JpaRepository<Comment, UUID>, CommentRepository {
}
