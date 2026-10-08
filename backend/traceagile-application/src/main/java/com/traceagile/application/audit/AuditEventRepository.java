package com.traceagile.application.audit;

import com.traceagile.domain.audit.AuditEvent;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

/** Port du journal d'audit (NF-16). */
public interface AuditEventRepository {

    AuditEvent save(AuditEvent event);

    Page<AuditEvent> findByEntityTypeAndEntityIdOrderByCreatedAtDesc(String entityType, UUID entityId, Pageable pageable);
}
