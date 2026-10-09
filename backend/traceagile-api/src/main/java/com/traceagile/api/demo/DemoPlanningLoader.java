package com.traceagile.api.demo;

import com.traceagile.application.planning.PlanningService;
import com.traceagile.application.planning.PlanningService.CloseAction;
import com.traceagile.application.planning.PlanningService.CloseDecision;
import com.traceagile.application.planning.PlanningService.GenerateCommand;
import com.traceagile.application.planning.PlanningService.ReleaseCommand;
import com.traceagile.application.planning.ReleaseRepository;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.domain.planning.Sprint;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import java.time.Clock;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import org.springframework.stereotype.Component;

/**
 * §15.1 planification de démonstration (lot 4) : release {@code REL-1} « Version 2.0 » de 3 sprints
 * de 2 semaines autour de la date du jour — {@code SPR-1} clos, {@code SPR-2} actif, {@code SPR-3}
 * planifié. Une story de SPR-1 est reportée sur SPR-2. Idempotent (rien si une release existe).
 */
@Component
public class DemoPlanningLoader {

    static final int CAPACITY = 20;

    private final PlanningService planning;
    private final ReleaseRepository releases;
    private final RequirementService requirements;
    private final Clock clock;

    public DemoPlanningLoader(PlanningService planning, ReleaseRepository releases, RequirementService requirements, Clock clock) {
        this.planning = planning;
        this.releases = releases;
        this.requirements = requirements;
        this.clock = clock;
    }

    public void load(String project) {
        if (releases.existsByProject_Key(project)) {
            return;
        }
        LocalDate monday = LocalDate.now(clock).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate start = monday.minusWeeks(2);
        planning.createRelease(project, new ReleaseCommand("Version 2.0", "Commande en ligne de bout en bout : panier, paiement, suivi.",
                start, start.plusWeeks(6).minusDays(1)));
        List<Sprint> sprints = planning.generateSprints(project, "REL-1", new GenerateCommand(3, 2, start, CAPACITY));
        List<Requirement> ready = new ArrayList<>(requirements.backlog(project).stream()
                .filter(r -> r.getType() == RequirementType.USER_STORY && r.getStatus() == RequirementStatus.READY).toList());

        // SPR-1 : clos ; toutes ses stories terminées sauf la dernière, reportée sur SPR-2.
        Sprint first = sprints.get(0);
        List<String> firstScope = take(ready, 4);
        planning.replaceScope(project, first.getKey(), firstScope);
        planning.start(project, first.getKey());
        for (String key : firstScope.subList(0, firstScope.size() - 1)) {
            // Lot 5 : les exécutions de SPR-1 satisferont la DoD ; d'ici là, la démo force DONE.
            requirements.applyPlanningStatus(requirements.get(project, key), RequirementStatus.DONE);
        }
        String carried = firstScope.getLast();
        planning.close(project, first.getKey(), List.of(new CloseDecision(carried, CloseAction.NEXT_SPRINT)));

        // SPR-2 : actif (la story reportée en tête) ; SPR-3 : planifié.
        List<String> secondScope = new ArrayList<>(List.of(carried));
        secondScope.addAll(take(ready, 3));
        planning.replaceScope(project, sprints.get(1).getKey(), secondScope);
        planning.start(project, sprints.get(1).getKey());
        planning.replaceScope(project, sprints.get(2).getKey(), take(ready, 3));
    }

    /** Les premières stories prêtes (rang), dans la limite de la capacité. */
    private static List<String> take(List<Requirement> ready, int max) {
        List<String> keys = new ArrayList<>();
        int load = 0;
        while (!ready.isEmpty() && keys.size() < max) {
            Requirement next = ready.getFirst();
            int points = Objects.requireNonNullElse(next.getStoryPoints(), 0);
            if (!keys.isEmpty() && load + points > CAPACITY) {
                break;
            }
            ready.removeFirst();
            keys.add(next.getKey());
            load += points;
        }
        return keys;
    }
}
