package com.traceagile.infrastructure.persistence;

import com.traceagile.application.attachment.AttachmentRepository;
import com.traceagile.domain.attachment.Attachment;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link AttachmentRepository}. */
public interface JpaAttachmentRepository extends JpaRepository<Attachment, UUID>, AttachmentRepository {
}
