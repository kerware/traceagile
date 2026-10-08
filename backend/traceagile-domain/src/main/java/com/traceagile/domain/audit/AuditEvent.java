package com.traceagile.domain.audit;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.FieldChange;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.hibernate.annotations.Immutable;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * §3.1 AuditEvent : journal en lecture seule (NF-16 qui, quand, quoi). L'acteur et l'horodatage sont
 * les champs techniques {@code createdBy} / {@code createdAt} (ADR-0010).
 */
@Entity
@Immutable
@Table(name = "audit_events")
public class AuditEvent extends AuditableEntity {

    @Column(name = "project_id", nullable = false, updatable = false)
    private UUID projectId;

    @Column(name = "entity_type", nullable = false, length = 40, updatable = false)
    private String entityType;

    @Column(name = "entity_id", nullable = false, updatable = false)
    private UUID entityId;

    @Column(name = "entity_key", length = 20, updatable = false)
    private String entityKey;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30, updatable = false)
    private AuditAction action;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb", updatable = false)
    private List<FieldChange> diff = new ArrayList<>();

    protected AuditEvent() {
    }

    public AuditEvent(UUID projectId, String entityType, UUID entityId, String entityKey, AuditAction action,
                      List<FieldChange> diff) {
        this.projectId = projectId;
        this.entityType = entityType;
        this.entityId = entityId;
        this.entityKey = entityKey;
        this.action = action;
        this.diff = new ArrayList<>(diff);
    }

    public UUID getProjectId() {
        return projectId;
    }

    public String getEntityType() {
        return entityType;
    }

    public UUID getEntityId() {
        return entityId;
    }

    public String getEntityKey() {
        return entityKey;
    }

    public AuditAction getAction() {
        return action;
    }

    public List<FieldChange> getDiff() {
        return diff;
    }

    public String getActor() {
        return getCreatedBy();
    }

    public Instant getTimestamp() {
        return getCreatedAt();
    }
}
