package com.traceagile.application.audit;

import com.traceagile.domain.audit.AuditAction;
import com.traceagile.domain.audit.AuditEvent;
import com.traceagile.domain.common.FieldChange;
import com.traceagile.domain.common.SnapshotDiff;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * NF-16 Toute modification d'exigence (puis de test et d'exécution) est auditée : qui, quand, quoi.
 * Les services appellent {@link #record} avec les instantanés avant / après (ADR-0010).
 */
@Service
@Transactional
public class AuditService {

    public static final String REQUIREMENT = "REQUIREMENT";

    private final AuditEventRepository events;

    public AuditService(AuditEventRepository events) {
        this.events = events;
    }

    /**
     * Enregistre l'événement. Une simple mise à jour sans différence n'est pas journalisée.
     *
     * @return la différence enregistrée (vide si rien n'a changé)
     */
    public List<FieldChange> record(UUID projectId, String entityType, UUID entityId, String entityKey, AuditAction action,
                                    Map<String, ?> before, Map<String, ?> after) {
        List<FieldChange> diff = SnapshotDiff.between(before, after);
        if (diff.isEmpty() && (action == AuditAction.UPDATED || action == AuditAction.MOVED)) {
            return diff;
        }
        events.save(new AuditEvent(projectId, entityType, entityId, entityKey, action, diff));
        return diff;
    }

    @Transactional(readOnly = true)
    public Page<AuditEvent> history(String entityType, UUID entityId, Pageable pageable) {
        return events.findByEntityTypeAndEntityIdOrderByCreatedAtDesc(entityType, entityId, pageable);
    }
}
