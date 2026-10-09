package com.traceagile.domain.planning;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

/** §8.1 releases, §8.2 sprints, §3.3-3 et §3.3-4. */
class PlanningTest {

    final Project shop = new Project("SHOP", "Boutique", null);
    static final LocalDate MONDAY = LocalDate.of(2026, 10, 12);

    Release release() {
        return new Release(shop, "REL-1", "Version 2.0", "Paiement en ligne", MONDAY, MONDAY.plusWeeks(6).minusDays(1));
    }

    Sprint sprint(String key, LocalDate start, LocalDate end) {
        return new Sprint(shop, key, "Sprint " + key.substring(4), null, start, end, 20);
    }

    Requirement story(String key, int points, RequirementStatus status) {
        Requirement r = new Requirement(shop, key, RequirementType.USER_STORY, "Story " + key, "a" + key);
        r.estimate(points);
        r.addCriterion(com.traceagile.domain.requirement.CriterionFormat.TEXT, "OK");
        if (status != RequirementStatus.DRAFT) {
            r.changeStatus(RequirementStatus.READY);
        }
        if (status == RequirementStatus.IN_SPRINT) {
            r.changeStatus(RequirementStatus.IN_SPRINT);
        }
        return r;
    }

    @Test
    @DisplayName("F-PLN-01 une release a un nom et des dates cohérentes ; statut initial PLANNED")
    void releaseRules() {
        assertThat(release().getStatus()).isEqualTo(PlanningStatus.PLANNED);
        assertThatThrownBy(() -> new Release(shop, "REL-1", " ", null, MONDAY, MONDAY)).extracting("code").isEqualTo("RELEASE_NAME_REQUIRED");
        assertThatThrownBy(() -> new Release(shop, "REL-1", "V2", null, MONDAY, MONDAY.minusDays(1)))
                .extracting("code").isEqualTo("PLANNING_DATES_INVALID");
        assertThatThrownBy(() -> new Release(shop, "REL-1", "V2", null, null, MONDAY)).extracting("code").isEqualTo("PLANNING_DATES_REQUIRED");
    }

    @ParameterizedTest
    @ValueSource(ints = {1, 2, 3, 4})
    @DisplayName("F-PLN-01 génération : N sprints de 1 à 4 semaines, dates calculées sans chevauchement")
    void schedule(int weeks) {
        List<LocalDate[]> slots = SprintSchedule.generate(MONDAY, 3, weeks);
        assertThat(slots).hasSize(3);
        assertThat(slots.get(0)[0]).isEqualTo(MONDAY);
        assertThat(slots.get(0)[1]).isEqualTo(MONDAY.plusWeeks(weeks).minusDays(1));
        assertThat(slots.get(1)[0]).isEqualTo(slots.get(0)[1].plusDays(1));
        assertThat(slots.get(2)[1]).isEqualTo(MONDAY.plusWeeks(3L * weeks).minusDays(1));
    }

    @Test
    @DisplayName("F-PLN-01 génération : durée hors 1 à 4 semaines ou nombre nul refusés")
    void scheduleRules() {
        assertThatThrownBy(() -> SprintSchedule.generate(MONDAY, 3, 5)).extracting("code").isEqualTo("SPRINT_DURATION_INVALID");
        assertThatThrownBy(() -> SprintSchedule.generate(MONDAY, 0, 2)).extracting("code").isEqualTo("SPRINT_COUNT_INVALID");
    }

    @Test
    @DisplayName("§3.3-3 un sprint d'une release est compris dans ses dates et ne chevauche pas un autre sprint")
    void attach() {
        Release release = release();
        Sprint s1 = sprint("SPR-1", MONDAY, MONDAY.plusDays(13));
        release.attach(s1);
        assertThat(s1.getRelease()).isSameAs(release);
        assertThat(release.getSprints()).containsExactly(s1);

        assertThatThrownBy(() -> release.attach(sprint("SPR-2", MONDAY.plusDays(13), MONDAY.plusDays(20))))
                .extracting("code").isEqualTo("SPRINT_OVERLAP");
        assertThatThrownBy(() -> release.attach(sprint("SPR-3", MONDAY.minusDays(7), MONDAY.minusDays(1))))
                .extracting("code").isEqualTo("SPRINT_OUTSIDE_RELEASE");
        assertThatThrownBy(() -> release.reschedule(MONDAY.plusDays(1), MONDAY.plusWeeks(6)))
                .extracting("code").isEqualTo("SPRINT_OUTSIDE_RELEASE");
    }

    @Test
    @DisplayName("ADR-0015 générer au-delà de la fin de la release l'étend")
    void extend() {
        Release release = release();
        release.extendTo(MONDAY.plusWeeks(8));
        assertThat(release.getEndDate()).isEqualTo(MONDAY.plusWeeks(8));
        release.extendTo(MONDAY.plusWeeks(1));
        assertThat(release.getEndDate()).isEqualTo(MONDAY.plusWeeks(8));
    }

    @Test
    @DisplayName("F-PLN-05 périmètre : stories prêtes (pas d'épic ni de feature) ; charge en points et alerte au-delà de 100 %")
    void scope() {
        Sprint sprint = sprint("SPR-1", MONDAY, MONDAY.plusDays(13));
        sprint.replaceScope(List.of(story("REQ-1", 8, RequirementStatus.READY), story("REQ-2", 13, RequirementStatus.READY)));
        assertThat(sprint.loadPoints()).isEqualTo(21);
        assertThat(sprint.loadPercent()).isEqualTo(105);
        assertThat(sprint.isOverCapacity()).isTrue();

        assertThatThrownBy(() -> sprint.replaceScope(List.of(story("REQ-3", 3, RequirementStatus.DRAFT))))
                .extracting("code").isEqualTo("SPRINT_SCOPE_NOT_READY");
        Requirement epic = new Requirement(shop, "REQ-9", RequirementType.EPIC, "Épic", "z");
        assertThatThrownBy(() -> sprint.replaceScope(List.of(epic))).extracting("code").isEqualTo("SPRINT_SCOPE_TYPE_INVALID");
    }

    @Test
    @DisplayName("F-PLN-06 démarrer : PLANNED → ACTIVE ; clôturer : ACTIVE → CLOSED, puis lecture seule")
    void lifecycle() {
        Sprint sprint = sprint("SPR-1", MONDAY, MONDAY.plusDays(13));
        assertThatThrownBy(sprint::close).extracting("code").isEqualTo("SPRINT_STATUS_INVALID");
        sprint.start();
        assertThat(sprint.getStatus()).isEqualTo(PlanningStatus.ACTIVE);
        assertThatThrownBy(sprint::start).extracting("code").isEqualTo("SPRINT_STATUS_INVALID");
        sprint.close();
        assertThat(sprint.getStatus()).isEqualTo(PlanningStatus.CLOSED);
        assertThatThrownBy(() -> sprint.rename("Autre")).extracting("code").isEqualTo("SPRINT_CLOSED");
        assertThatThrownBy(() -> sprint.replaceScope(List.of())).extracting("code").isEqualTo("SPRINT_CLOSED");
    }

    @Test
    @DisplayName("F-PLN-06 issue d'une story à la clôture : terminée, renvoyée au backlog ou reportée")
    void outcomes() {
        Sprint sprint = sprint("SPR-1", MONDAY, MONDAY.plusDays(13));
        Requirement done = story("REQ-1", 3, RequirementStatus.READY);
        Requirement late = story("REQ-2", 5, RequirementStatus.READY);
        sprint.replaceScope(List.of(done, late));
        sprint.start();
        sprint.close();
        sprint.recordOutcome(done, ScopeOutcome.DONE);
        sprint.recordOutcome(late, ScopeOutcome.CARRIED_OVER);
        assertThat(sprint.getScope()).extracting(SprintScopeItem::getOutcome).containsExactly(ScopeOutcome.DONE, ScopeOutcome.CARRIED_OVER);
        assertThat(sprint.donePoints()).isEqualTo(3);
    }

    @Test
    @DisplayName("F-PLN-03 clôturer une release fige son bilan ; tous ses sprints doivent être clos")
    void closeRelease() {
        Release release = release();
        Sprint s1 = sprint("SPR-1", MONDAY, MONDAY.plusDays(13));
        release.attach(s1);
        assertThatThrownBy(() -> release.close(Instant.now(), Map.of())).extracting("code").isEqualTo("RELEASE_SPRINTS_NOT_CLOSED");
        s1.start();
        release.activate();
        assertThat(release.getStatus()).isEqualTo(PlanningStatus.ACTIVE);
        s1.close();
        release.close(Instant.parse("2026-11-30T17:00:00Z"), Map.of("validationRate", 85));
        assertThat(release.getStatus()).isEqualTo(PlanningStatus.CLOSED);
        assertThat(release.getClosingReport()).containsEntry("validationRate", 85);
        assertThatThrownBy(() -> release.rename("V3")).extracting("code").isEqualTo("RELEASE_CLOSED");
        assertThatThrownBy(() -> release.attach(sprint("SPR-2", MONDAY.plusDays(14), MONDAY.plusDays(20))))
                .extracting("code").isEqualTo("RELEASE_CLOSED");
    }
}
