package com.traceagile.application.attachment;

import com.traceagile.domain.attachment.Attachment;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** Port des pièces jointes (ADR-0024). */
public interface AttachmentRepository {

    List<Attachment> findByProject_KeyAndTargetTypeAndTargetIdOrderByCreatedAtAsc(String projectKey, Attachment.Target targetType, UUID targetId);

    List<Attachment> findByTargetTypeAndTargetIdInOrderByCreatedAtAsc(Attachment.Target targetType, Collection<UUID> targetIds);

    Optional<Attachment> findByIdAndProject_Key(UUID id, String projectKey);

    boolean existsByStorageKey(String storageKey);

    Attachment save(Attachment attachment);

    void delete(Attachment attachment);
}
