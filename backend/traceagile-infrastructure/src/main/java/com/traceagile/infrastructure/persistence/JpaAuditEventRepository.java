package com.traceagile.infrastructure.persistence;

import com.traceagile.application.audit.AuditEventRepository;
import com.traceagile.domain.audit.AuditEvent;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link AuditEventRepository}. */
public interface JpaAuditEventRepository extends JpaRepository<AuditEvent, UUID>, AuditEventRepository {
}
