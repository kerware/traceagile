package com.traceagile.application.audit;

import com.traceagile.domain.audit.AuditEvent;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

/** Port du journal d'audit (NF-16). */
public interface AuditEventRepository {

    AuditEvent save(AuditEvent event);

    Page<AuditEvent> findByEntityTypeAndEntityIdOrderByCreatedAtDesc(String entityType, UUID entityId, Pageable pageable);

    /** ADR-0023 historique de plusieurs entités (dates de passage à DONE pour le burndown). */
    List<AuditEvent> findByEntityTypeAndEntityIdInOrderByCreatedAtAsc(String entityType, Collection<UUID> entityIds);
}
