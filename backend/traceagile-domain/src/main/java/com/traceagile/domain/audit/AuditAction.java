package com.traceagile.domain.audit;

/** NF-16 Nature d'une modification auditée. */
public enum AuditAction {
    CREATED,
    UPDATED,
    STATUS_CHANGED,
    MOVED,
    VERSION_CREATED,
    IMPORTED,
    DELETED
}
