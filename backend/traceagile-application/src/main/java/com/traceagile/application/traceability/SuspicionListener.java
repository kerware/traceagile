package com.traceagile.application.traceability;

import com.traceagile.application.audit.AuditService;
import com.traceagile.application.requirement.RequirementChanged;
import com.traceagile.application.requirement.RequirementRepository;
import com.traceagile.application.testcase.TestCaseService;
import com.traceagile.domain.audit.AuditAction;
import com.traceagile.domain.testcase.TestCase;
import java.time.Clock;
import java.util.Map;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * §3.3-7 une modification du contenu d'une exigence liée à des tests READY passe ces tests à
 * NEEDS_UPDATE et rend leurs liens suspects (alerte dans la matrice). Synchrone : même transaction
 * que la modification de l'exigence.
 */
@Component
public class SuspicionListener {

    private final RequirementRepository requirements;
    private final TraceLinkService links;
    private final AuditService audit;
    private final Clock clock;

    public SuspicionListener(RequirementRepository requirements, TraceLinkService links, AuditService audit, Clock clock) {
        this.requirements = requirements;
        this.links = links;
        this.audit = audit;
        this.clock = clock;
    }

    @EventListener
    @Transactional
    public void on(RequirementChanged event) {
        if (!event.contentChanged()) {
            return;
        }
        requirements.findByProject_KeyAndKey(event.projectKey(), event.requirementKey()).ifPresent(requirement -> {
            for (TestCase test : links.markSuspect(requirement, clock.instant())) {
                Map<String, Object> before = test.snapshot();
                test.markNeedsUpdate();
                audit.record(test.getProject().getId(), TestCaseService.AUDIT_TYPE, test.getId(), test.getKey(),
                        AuditAction.STATUS_CHANGED, before, test.snapshot());
            }
        });
    }
}
