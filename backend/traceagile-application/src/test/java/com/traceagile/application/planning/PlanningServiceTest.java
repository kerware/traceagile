package com.traceagile.application.planning;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.audit.AuditService;
import com.traceagile.application.common.KeyGenerator;
import com.traceagile.application.planning.PlanningService.CloseAction;
import com.traceagile.application.planning.PlanningService.CloseDecision;
import com.traceagile.application.planning.PlanningService.GenerateCommand;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.application.traceability.TraceabilityService;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.planning.PlanningStatus;
import com.traceagile.domain.planning.Release;
import com.traceagile.domain.planning.ScopeOutcome;
import com.traceagile.domain.planning.Sprint;
import com.traceagile.domain.planning.SprintScopeItem;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import java.lang.reflect.Field;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** §8.1 / §8.2 orchestration de la planification : génération, périmètre, démarrage, clôture. */
class PlanningServiceTest {

    static final LocalDate MONDAY = LocalDate.of(2026, 10, 12);
    final Project shop = new Project("SHOP", "Boutique", null);
    final ReleaseRepository releases = mock(ReleaseRepository.class);
    final SprintRepository sprints = mock(SprintRepository.class);
    final RequirementService requirements = mock(RequirementService.class);
    final KeyGenerator keys = mock(KeyGenerator.class);
    final org.springframework.context.ApplicationEventPublisher events = mock(org.springframework.context.ApplicationEventPublisher.class);
    final PlanningService service = new PlanningService(releases, sprints, mock(ProjectRepository.class), requirements,
            mock(TraceabilityService.class), keys, mock(AuditService.class), Clock.fixed(Instant.parse("2026-10-09T10:00:00Z"), ZoneOffset.UTC),
            events);
    final List<Sprint> all = new ArrayList<>();

    static <T extends AuditableEntity> T withId(T entity) {
        try {
            Field id = AuditableEntity.class.getDeclaredField("id");
            id.setAccessible(true);
            id.set(entity, UUID.randomUUID());
            return entity;
        } catch (ReflectiveOperationException e) {
            throw new IllegalStateException(e);
        }
    }

    Requirement ready(String key, int points) {
        Requirement r = withId(new Requirement(shop, key, RequirementType.USER_STORY, key, key));
        r.estimate(points);
        r.addCriterion(CriterionFormat.TEXT, "OK");
        r.changeStatus(RequirementStatus.READY);
        when(requirements.get("SHOP", key)).thenReturn(r);
        return r;
    }

    Sprint sprint(String key, LocalDate start) {
        Sprint sprint = withId(new Sprint(shop, key, key, null, start, start.plusDays(13), 20));
        all.add(sprint);
        when(sprints.findByProject_KeyAndKey("SHOP", key)).thenReturn(Optional.of(sprint));
        return sprint;
    }

    @BeforeEach
    void wiring() {
        AtomicInteger counter = new AtomicInteger();
        when(keys.next(any(), eq("SPR"))).thenAnswer(i -> "SPR-" + counter.incrementAndGet());
        when(sprints.save(any())).thenAnswer(i -> i.getArgument(0));
        when(sprints.findByProject_KeyAndStatusInOrderByStartDateAsc(eq("SHOP"), any())).thenAnswer(i -> {
            Collection<?> statuses = i.getArgument(1);
            return all.stream().filter(s -> statuses.contains(s.getStatus())).toList();
        });
        // Le service d'exigences applique réellement la transition (comportement observable).
        doAnswer(i -> {
            ((Requirement) i.getArgument(0)).changeStatus(i.getArgument(1));
            return null;
        }).when(requirements).applyPlanningStatus(any(), any());
    }

    @Test
    @DisplayName("F-PLN-01 générer 3 sprints de 2 semaines à la suite des sprints existants, en prolongeant la release")
    void generate() {
        Release release = new Release(shop, "REL-1", "V2", null, MONDAY, MONDAY.plusWeeks(4).minusDays(1));
        when(releases.findByProject_KeyAndKey("SHOP", "REL-1")).thenReturn(Optional.of(release));

        List<Sprint> created = service.generateSprints("SHOP", "REL-1", new GenerateCommand(3, 2, null, 25));

        assertThat(created).extracting(Sprint::getKey).containsExactly("SPR-1", "SPR-2", "SPR-3");
        assertThat(created).extracting(Sprint::getName).containsExactly("Sprint 1", "Sprint 2", "Sprint 3");
        assertThat(created.getFirst().getStartDate()).isEqualTo(MONDAY);
        assertThat(release.getEndDate()).isEqualTo(MONDAY.plusWeeks(6).minusDays(1));
        assertThat(service.generateSprints("SHOP", "REL-1", new GenerateCommand(1, 1, null, null)).getFirst().getStartDate())
                .isEqualTo(MONDAY.plusWeeks(6));
    }

    @Test
    @DisplayName("F-PLN-05 une exigence n'est au périmètre que d'un sprint ouvert ; dans un sprint actif, elle passe IN_SPRINT")
    void scope() {
        Sprint s1 = sprint("SPR-1", MONDAY);
        Sprint s2 = sprint("SPR-2", MONDAY.plusWeeks(2));
        Requirement a = ready("REQ-1", 5);
        service.replaceScope("SHOP", "SPR-1", List.of("REQ-1"));
        assertThatThrownBy(() -> service.replaceScope("SHOP", "SPR-2", List.of("REQ-1")))
                .extracting("code").isEqualTo("REQ_ALREADY_PLANNED");

        service.start("SHOP", "SPR-1");
        assertThat(a.getStatus()).isEqualTo(RequirementStatus.IN_SPRINT);
        Requirement b = ready("REQ-2", 3);
        service.replaceScope("SHOP", "SPR-1", List.of("REQ-2"));
        assertThat(b.getStatus()).isEqualTo(RequirementStatus.IN_SPRINT);
        assertThat(a.getStatus()).as("retirée d'un sprint actif").isEqualTo(RequirementStatus.READY);
        assertThat(s2.requirements()).isEmpty();
    }

    @Test
    @DisplayName("§3.3-4 un seul sprint actif par projet")
    void oneActive() {
        sprint("SPR-1", MONDAY);
        sprint("SPR-2", MONDAY.plusWeeks(2));
        service.start("SHOP", "SPR-1");
        assertThatThrownBy(() -> service.start("SHOP", "SPR-2")).extracting("code").isEqualTo("SPRINT_ALREADY_ACTIVE");
    }

    @Test
    @DisplayName("F-PLN-06 clôture : terminées, renvoyées au backlog (défaut) ou reportées sur le sprint suivant ; ADR-0023 bilan à figer (SprintClosed)")
    void close() {
        Sprint s1 = sprint("SPR-1", MONDAY);
        Sprint s2 = sprint("SPR-2", MONDAY.plusWeeks(2));
        Requirement done = ready("REQ-1", 5);
        Requirement back = ready("REQ-2", 3);
        Requirement carried = ready("REQ-3", 8);
        service.replaceScope("SHOP", "SPR-1", List.of("REQ-1", "REQ-2", "REQ-3"));
        service.start("SHOP", "SPR-1");
        done.changeStatus(RequirementStatus.DONE);
        org.mockito.Mockito.verifyNoInteractions(events);

        service.close("SHOP", "SPR-1", List.of(new CloseDecision("REQ-3", CloseAction.NEXT_SPRINT)));

        assertThat(s1.getStatus()).isEqualTo(PlanningStatus.CLOSED);
        assertThat(s1.getScope()).extracting(SprintScopeItem::getOutcome)
                .containsExactly(ScopeOutcome.DONE, ScopeOutcome.RETURNED, ScopeOutcome.CARRIED_OVER);
        assertThat(back.getStatus()).isEqualTo(RequirementStatus.READY);
        assertThat(carried.getStatus()).isEqualTo(RequirementStatus.READY);
        assertThat(s2.requirements()).containsExactly(carried);
        assertThat(s1.donePoints()).isEqualTo(5);
        assertThat(s1.loadPoints()).isEqualTo(16);
        org.mockito.Mockito.verify(events).publishEvent(new PlanningService.SprintClosed("SHOP", "SPR-1"));
    }

    @Test
    @DisplayName("F-PLN-06 reporter sans sprint suivant planifié est refusé ; une décision hors périmètre aussi")
    void closeRules() {
        sprint("SPR-1", MONDAY);
        ready("REQ-1", 5);
        service.replaceScope("SHOP", "SPR-1", List.of("REQ-1"));
        service.start("SHOP", "SPR-1");
        assertThatThrownBy(() -> service.close("SHOP", "SPR-1", List.of(new CloseDecision("REQ-1", CloseAction.NEXT_SPRINT))))
                .extracting("code").isEqualTo("NO_NEXT_SPRINT");
        assertThatThrownBy(() -> service.close("SHOP", "SPR-1", List.of(new CloseDecision("REQ-9", CloseAction.BACKLOG))))
                .extracting("code").isEqualTo("SPRINT_SCOPE_UNKNOWN");
    }
}
