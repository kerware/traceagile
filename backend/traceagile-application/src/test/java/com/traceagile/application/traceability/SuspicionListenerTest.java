package com.traceagile.application.traceability;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.traceagile.application.audit.AuditService;
import com.traceagile.application.requirement.RequirementChanged;
import com.traceagile.application.requirement.RequirementRepository;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** §3.3-7 modification d'une exigence liée à des tests READY. */
class SuspicionListenerTest {

    final RequirementRepository requirements = mock(RequirementRepository.class);
    final TraceLinkService links = mock(TraceLinkService.class);
    final AuditService audit = mock(AuditService.class);
    final SuspicionListener listener = new SuspicionListener(requirements, links, audit,
            Clock.fixed(Instant.parse("2026-10-09T10:00:00Z"), ZoneOffset.UTC));
    final Project shop = new Project("SHOP", "Boutique", null);

    @Test
    @DisplayName("ADR-0014 un changement de statut, de rang ou de priorité ne rend rien suspect")
    void ignoresNonContentChanges() {
        listener.on(new RequirementChanged("SHOP", "REQ-3", Set.of("status", "priority", "rank")));
        verifyNoInteractions(requirements, links, audit);
    }

    @Test
    @DisplayName("§3.3-7 une modification du contenu passe les tests READY liés à NEEDS_UPDATE")
    void contentChangeMarksTests() {
        Requirement story = new Requirement(shop, "REQ-3", RequirementType.USER_STORY, "Ajouter", "a");
        TestCase test = TestCase.manual(shop, "TC-1", "Ajouter");
        test.addStep("Ouvrir", "OK", null);
        test.changeStatus(TestCaseStatus.READY);
        when(requirements.findByProject_KeyAndKey("SHOP", "REQ-3")).thenReturn(Optional.of(story));
        when(links.markSuspect(any(), any())).thenReturn(List.of(test));

        listener.on(new RequirementChanged("SHOP", "REQ-3", Set.of("description")));

        assertThat(test.getStatus()).isEqualTo(TestCaseStatus.NEEDS_UPDATE);
    }
}
