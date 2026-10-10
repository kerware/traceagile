package com.traceagile.infrastructure.attachment;

import com.traceagile.application.attachment.AttachmentTargets;
import com.traceagile.domain.attachment.Attachment;
import jakarta.persistence.EntityManager;
import java.util.UUID;
import org.springframework.stereotype.Component;

/** ADR-0024 existence d'un porteur de pièce jointe dans un projet (une requête par type). */
@Component
public class JpaAttachmentTargets implements AttachmentTargets {

    private final EntityManager em;

    public JpaAttachmentTargets(EntityManager em) {
        this.em = em;
    }

    @Override
    public boolean exists(String projectKey, Attachment.Target target, UUID id) {
        String jpql = switch (target) {
            case REQUIREMENT -> "select count(r) from Requirement r where r.id = :id and r.project.key = :p";
            case DEFECT -> "select count(d) from Defect d where d.id = :id and d.project.key = :p";
            case EXECUTION_STEP -> "select count(s) from StepResult s where s.id = :id and s.execution.item.campaign.project.key = :p";
            case SESSION_NOTE -> "select count(n) from SessionNote n where n.id = :id and n.session.execution.item.campaign.project.key = :p";
        };
        return em.createQuery(jpql, Long.class).setParameter("id", id).setParameter("p", projectKey).getSingleResult() > 0;
    }
}
