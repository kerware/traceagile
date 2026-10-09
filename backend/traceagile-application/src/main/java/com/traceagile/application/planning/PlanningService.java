package com.traceagile.application.planning;

import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.audit.AuditService;
import com.traceagile.application.common.KeyGenerator;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.common.VersionConflictException;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.application.traceability.TraceabilityService;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.audit.AuditAction;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.planning.PlanningStatus;
import com.traceagile.domain.planning.Release;
import com.traceagile.domain.planning.ScopeOutcome;
import com.traceagile.domain.planning.Sprint;
import com.traceagile.domain.planning.Sprint.ScopeChange;
import com.traceagile.domain.planning.SprintSchedule;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.traceability.CoverageCalculator.Coverage;
import com.traceagile.domain.traceability.CoverageCalculator.Indicator;
import java.time.Clock;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §8.1 releases et §8.2 sprints : création, génération (F-PLN-01), feuille de route (F-PLN-02),
 * clôture d'une release (F-PLN-03), sprints (F-PLN-04), planification (F-PLN-05), démarrage et
 * clôture d'un sprint (F-PLN-06).
 */
@Service
@Transactional
public class PlanningService {

    public static final String AUDIT_RELEASE = "RELEASE";
    public static final String AUDIT_SPRINT = "SPRINT";
    static final Set<PlanningStatus> OPEN = EnumSet.of(PlanningStatus.PLANNED, PlanningStatus.ACTIVE);
    static final Set<RequirementStatus> FINISHED = EnumSet.of(RequirementStatus.DONE, RequirementStatus.ACCEPTED);
    static final Set<RequirementStatus> DROPPED = EnumSet.of(RequirementStatus.REJECTED, RequirementStatus.OBSOLETE);

    public record ReleaseCommand(String name, String goal, LocalDate startDate, LocalDate endDate) {
    }

    /** Merge-patch : {@code null} = inchangé, {@link Optional#empty()} = effacé. */
    public record ReleasePatch(Optional<String> name, Optional<String> goal, Optional<LocalDate> startDate, Optional<LocalDate> endDate) {
    }

    public record SprintCommand(String name, String goal, LocalDate startDate, LocalDate endDate, Integer capacityPoints, String releaseKey) {
    }

    public record SprintPatch(Optional<String> name, Optional<String> goal, Optional<LocalDate> startDate, Optional<LocalDate> endDate,
                              Optional<Integer> capacityPoints, Optional<String> releaseKey) {
    }

    public record GenerateCommand(int count, int weeks, LocalDate startDate, Integer capacityPoints) {
    }

    public enum CloseAction { BACKLOG, NEXT_SPRINT }

    public record CloseDecision(String requirementKey, CloseAction action) {
    }

    private final ReleaseRepository releases;
    private final SprintRepository sprints;
    private final ProjectRepository projects;
    private final RequirementService requirements;
    private final TraceabilityService traceability;
    private final KeyGenerator keys;
    private final AuditService audit;
    private final Clock clock;

    public PlanningService(ReleaseRepository releases, SprintRepository sprints, ProjectRepository projects, RequirementService requirements,
                           TraceabilityService traceability, KeyGenerator keys, AuditService audit, Clock clock) {
        this.releases = releases;
        this.sprints = sprints;
        this.projects = projects;
        this.requirements = requirements;
        this.traceability = traceability;
        this.keys = keys;
        this.audit = audit;
        this.clock = clock;
    }

    // ---------------------------------------------------------------- lecture

    @Transactional(readOnly = true)
    public List<Release> releases(String projectKey) {
        return releases.findByProject_KeyOrderByStartDateAsc(projectKey);
    }

    @Transactional(readOnly = true)
    public Release release(String projectKey, String key) {
        return releases.findByProject_KeyAndKey(projectKey, key)
                .orElseThrow(() -> new NotFoundException("RELEASE_NOT_FOUND", "Release « " + key + " » introuvable."));
    }

    @Transactional(readOnly = true)
    public List<Sprint> sprints(String projectKey) {
        return sprints.findByProject_KeyOrderByStartDateAsc(projectKey);
    }

    @Transactional(readOnly = true)
    public Sprint sprint(String projectKey, String key) {
        return sprints.findByProject_KeyAndKey(projectKey, key)
                .orElseThrow(() -> new NotFoundException("SPRINT_NOT_FOUND", "Sprint « " + key + " » introuvable."));
    }

    /** F-PLN-06 sprint qui reçoit les stories reportées : le premier sprint planifié après celui-ci. */
    @Transactional(readOnly = true)
    public Optional<Sprint> nextSprint(Sprint sprint) {
        return sprints.findByProject_KeyAndStatusInOrderByStartDateAsc(sprint.getProject().getKey(), Set.of(PlanningStatus.PLANNED)).stream()
                .filter(s -> !s.getKey().equals(sprint.getKey()))
                .filter(s -> !s.getStartDate().isBefore(sprint.getStartDate()))
                .findFirst();
    }

    /** F-PLN-02 taux de validation (§7.2) de chaque sprint, calculé en une fois. */
    @Transactional(readOnly = true)
    public Map<String, Indicator> validationRates(String projectKey) {
        Map<String, Indicator> rates = new LinkedHashMap<>();
        traceability.coverageBySprint(projectKey).forEach((key, coverage) -> rates.put(key, coverage.validation()));
        return rates;
    }

    // ---------------------------------------------------------------- releases (F-PLN-01, F-PLN-03)

    public Release createRelease(String projectKey, ReleaseCommand command) {
        Project project = project(projectKey);
        Release release = releases.save(new Release(project, keys.next(project, "REL"), command.name(), command.goal(),
                command.startDate(), command.endDate()));
        audit.record(project.getId(), AUDIT_RELEASE, release.getId(), release.getKey(), AuditAction.CREATED, Map.of(), snapshot(release));
        return release;
    }

    public Release updateRelease(String projectKey, String key, ReleasePatch patch, Long expectedVersion) {
        Release release = release(projectKey, key);
        VersionConflictException.check(expectedVersion, release.getVersion());
        Map<String, Object> before = snapshot(release);
        if (patch.name() != null) {
            release.rename(patch.name().orElse(null));
        }
        if (patch.goal() != null) {
            release.setGoal(patch.goal().orElse(null));
        }
        if (patch.startDate() != null || patch.endDate() != null) {
            release.reschedule(merge(patch.startDate(), release.getStartDate()), merge(patch.endDate(), release.getEndDate()));
        }
        audit.record(release.getProject().getId(), AUDIT_RELEASE, release.getId(), key, AuditAction.UPDATED, before, snapshot(release));
        return release;
    }

    /**
     * F-PLN-01 génère des sprints consécutifs : à partir de la date donnée, sinon du lendemain du
     * dernier sprint de la release, sinon de son début. La release est prolongée si besoin (ADR-0015).
     */
    public List<Sprint> generateSprints(String projectKey, String key, GenerateCommand command) {
        Release release = release(projectKey, key);
        Map<String, Object> before = snapshot(release);
        LocalDate start = command.startDate() != null ? command.startDate()
                : release.getSprints().isEmpty() ? release.getStartDate()
                : release.getSprints().getLast().getEndDate().plusDays(1);
        List<LocalDate[]> slots = SprintSchedule.generate(start, command.count(), command.weeks());
        release.extendTo(slots.getLast()[1]);
        List<Sprint> created = new ArrayList<>();
        for (LocalDate[] slot : slots) {
            String sprintKey = keys.next(release.getProject(), "SPR");
            Sprint sprint = new Sprint(release.getProject(), sprintKey, "Sprint " + sprintKey.substring(4), null, slot[0], slot[1],
                    command.capacityPoints());
            release.attach(sprint);
            created.add(sprints.save(sprint));
            audit.record(release.getProject().getId(), AUDIT_SPRINT, sprint.getId(), sprintKey, AuditAction.CREATED, Map.of(), snapshot(sprint));
        }
        audit.record(release.getProject().getId(), AUDIT_RELEASE, release.getId(), key, AuditAction.UPDATED, before, snapshot(release));
        return created;
    }

    /** F-PLN-03 clôture : bilan figé (sprints, points, couverture du périmètre de la release). */
    public Release closeRelease(String projectKey, String key) {
        Release release = release(projectKey, key);
        Map<String, Object> before = snapshot(release);
        Map<String, Coverage> bySprint = traceability.coverageBySprint(projectKey);
        Coverage coverage = traceability.coverage(projectKey, "release:" + key).coverage();
        Map<String, Object> report = new LinkedHashMap<>();
        report.put("closedAt", clock.instant().toString());
        report.put("release", Map.of("key", key, "name", release.getName(), "goal", Objects.toString(release.getGoal(), ""),
                "startDate", release.getStartDate().toString(), "endDate", release.getEndDate().toString()));
        List<Map<String, Object>> sprintReports = new ArrayList<>();
        for (Sprint sprint : release.getSprints()) {
            Map<String, Object> s = new LinkedHashMap<>();
            s.put("key", sprint.getKey());
            s.put("name", sprint.getName());
            s.put("startDate", sprint.getStartDate().toString());
            s.put("endDate", sprint.getEndDate().toString());
            s.put("capacityPoints", sprint.getCapacityPoints());
            s.put("committedPoints", sprint.loadPoints());
            s.put("donePoints", sprint.donePoints());
            s.put("stories", sprint.getScope().size());
            Coverage c = bySprint.get(sprint.getKey());
            s.put("validationRate", c == null ? null : c.validation().percent());
            sprintReports.add(s);
        }
        report.put("sprints", sprintReports);
        report.put("committedPoints", release.getSprints().stream().mapToInt(Sprint::loadPoints).sum());
        report.put("donePoints", release.getSprints().stream().mapToInt(Sprint::donePoints).sum());
        // Pourcentages absents (périmètre vide) : null, donc pas de Map.of.
        Map<String, Object> indicators = new LinkedHashMap<>();
        indicators.put("design", percent(coverage.design()));
        indicators.put("criteria", percent(coverage.criteria()));
        indicators.put("execution", percent(coverage.execution()));
        indicators.put("validation", percent(coverage.validation()));
        indicators.put("riskWeighted", percent(coverage.riskWeighted()));
        report.put("coverage", indicators);
        release.close(clock.instant(), report);
        audit.record(release.getProject().getId(), AUDIT_RELEASE, release.getId(), key, AuditAction.STATUS_CHANGED, before, snapshot(release));
        return release;
    }

    // ---------------------------------------------------------------- sprints (F-PLN-04)

    public Sprint createSprint(String projectKey, SprintCommand command) {
        Project project = project(projectKey);
        Sprint sprint = new Sprint(project, keys.next(project, "SPR"), command.name(), command.goal(), command.startDate(),
                command.endDate(), command.capacityPoints());
        if (command.releaseKey() != null) {
            release(projectKey, command.releaseKey()).attach(sprint);
        }
        Sprint saved = sprints.save(sprint);
        audit.record(project.getId(), AUDIT_SPRINT, saved.getId(), saved.getKey(), AuditAction.CREATED, Map.of(), snapshot(saved));
        return saved;
    }

    public Sprint updateSprint(String projectKey, String key, SprintPatch patch, Long expectedVersion) {
        Sprint sprint = sprint(projectKey, key);
        VersionConflictException.check(expectedVersion, sprint.getVersion());
        Map<String, Object> before = snapshot(sprint);
        if (patch.name() != null) {
            sprint.rename(patch.name().orElse(null));
        }
        if (patch.goal() != null) {
            sprint.setGoal(patch.goal().orElse(null));
        }
        if (patch.capacityPoints() != null) {
            sprint.setCapacityPoints(patch.capacityPoints().orElse(null));
        }
        if (patch.releaseKey() != null) {
            String target = patch.releaseKey().orElse(null);
            String current = sprint.getRelease() == null ? null : sprint.getRelease().getKey();
            if (!Objects.equals(target, current)) {
                sprint.detachFromRelease();
                if (target != null) {
                    release(projectKey, target).attach(sprint);
                }
            }
        }
        if (patch.startDate() != null || patch.endDate() != null) {
            sprint.reschedule(merge(patch.startDate(), sprint.getStartDate()), merge(patch.endDate(), sprint.getEndDate()));
        }
        audit.record(sprint.getProject().getId(), AUDIT_SPRINT, sprint.getId(), key, AuditAction.UPDATED, before, snapshot(sprint));
        return sprint;
    }

    /**
     * F-PLN-05 périmètre ordonné (glisser-déposer). Une exigence n'est que dans un sprint ouvert à la
     * fois ; dans un sprint actif, une exigence ajoutée passe IN_SPRINT et une exigence retirée revient READY.
     */
    public Sprint replaceScope(String projectKey, String key, List<String> requirementKeys) {
        Sprint sprint = sprint(projectKey, key);
        Map<String, Object> before = snapshot(sprint);
        List<Requirement> wanted = new ArrayList<>();
        for (String requirementKey : requirementKeys) {
            wanted.add(requirements.get(projectKey, requirementKey));
        }
        List<Sprint> others = sprints.findByProject_KeyAndStatusInOrderByStartDateAsc(projectKey, OPEN).stream()
                .filter(s -> !s.getKey().equals(key)).toList();
        for (Requirement requirement : wanted) {
            for (Sprint other : others) {
                if (other.requirements().stream().anyMatch(r -> r.getId().equals(requirement.getId()))) {
                    throw new BusinessRuleException("REQ_ALREADY_PLANNED",
                            requirement.getKey() + " est déjà au périmètre de " + other.getKey() + ".");
                }
            }
        }
        ScopeChange change = sprint.replaceScope(wanted);
        if (sprint.getStatus() == PlanningStatus.ACTIVE) {
            change.added().forEach(r -> requirements.applyPlanningStatus(r, RequirementStatus.IN_SPRINT));
            change.removed().stream().filter(r -> r.getStatus() == RequirementStatus.IN_SPRINT)
                    .forEach(r -> requirements.applyPlanningStatus(r, RequirementStatus.READY));
        }
        audit.record(sprint.getProject().getId(), AUDIT_SPRINT, sprint.getId(), key, AuditAction.UPDATED, before, snapshot(sprint));
        return sprint;
    }

    /** F-PLN-06 démarrage : un seul sprint actif par projet (§3.3-4) ; les stories prêtes passent IN_SPRINT. */
    public Sprint start(String projectKey, String key) {
        Sprint sprint = sprint(projectKey, key);
        Map<String, Object> before = snapshot(sprint);
        sprints.findByProject_KeyAndStatusInOrderByStartDateAsc(projectKey, Set.of(PlanningStatus.ACTIVE)).stream()
                .filter(s -> !s.getKey().equals(key)).findFirst().ifPresent(active -> {
                    throw new BusinessRuleException("SPRINT_ALREADY_ACTIVE",
                            "Le sprint " + active.getKey() + " est déjà actif : clôturez-le avant d'en démarrer un autre.");
                });
        sprint.start();
        if (sprint.getRelease() != null) {
            sprint.getRelease().activate();
        }
        sprint.requirements().stream().filter(r -> r.getStatus() == RequirementStatus.READY)
                .forEach(r -> requirements.applyPlanningStatus(r, RequirementStatus.IN_SPRINT));
        audit.record(sprint.getProject().getId(), AUDIT_SPRINT, sprint.getId(), key, AuditAction.STATUS_CHANGED, before, snapshot(sprint));
        return sprint;
    }

    /**
     * F-PLN-06 clôture : chaque story non terminée est renvoyée au backlog (défaut) ou reportée sur
     * le sprint suivant ; les issues restent au périmètre du sprint clos (ADR-0015).
     */
    public Sprint close(String projectKey, String key, List<CloseDecision> decisions) {
        Sprint sprint = sprint(projectKey, key);
        Map<String, Object> before = snapshot(sprint);
        Map<String, CloseAction> actions = new LinkedHashMap<>();
        for (CloseDecision decision : decisions == null ? List.<CloseDecision>of() : decisions) {
            if (sprint.requirements().stream().noneMatch(r -> r.getKey().equals(decision.requirementKey()))) {
                throw new BusinessRuleException("SPRINT_SCOPE_UNKNOWN", decision.requirementKey() + " n'est pas au périmètre de " + key + ".");
            }
            actions.put(decision.requirementKey(), decision.action() == null ? CloseAction.BACKLOG : decision.action());
        }
        Optional<Sprint> next = nextSprint(sprint);
        if (actions.containsValue(CloseAction.NEXT_SPRINT) && next.isEmpty()) {
            throw new BusinessRuleException("NO_NEXT_SPRINT", "Aucun sprint planifié ne suit " + key + " : créez-en un ou renvoyez les stories au backlog.");
        }
        sprint.close();
        for (Requirement requirement : sprint.requirements()) {
            ScopeOutcome outcome;
            if (FINISHED.contains(requirement.getStatus())) {
                outcome = ScopeOutcome.DONE;
            } else if (DROPPED.contains(requirement.getStatus())) {
                outcome = ScopeOutcome.DROPPED;
            } else {
                if (requirement.getStatus() == RequirementStatus.IN_SPRINT) {
                    requirements.applyPlanningStatus(requirement, RequirementStatus.READY);
                }
                if (actions.getOrDefault(requirement.getKey(), CloseAction.BACKLOG) == CloseAction.NEXT_SPRINT) {
                    next.orElseThrow().append(requirement);
                    outcome = ScopeOutcome.CARRIED_OVER;
                } else {
                    outcome = ScopeOutcome.RETURNED;
                }
            }
            sprint.recordOutcome(requirement, outcome);
        }
        audit.record(sprint.getProject().getId(), AUDIT_SPRINT, sprint.getId(), key, AuditAction.STATUS_CHANGED, before, snapshot(sprint));
        return sprint;
    }

    // ---------------------------------------------------------------- outils

    private Project project(String projectKey) {
        return projects.findByKey(projectKey)
                .orElseThrow(() -> new NotFoundException("PROJECT_NOT_FOUND", "Projet « " + projectKey + " » introuvable."));
    }

    private static <T> T merge(Optional<T> field, T current) {
        return field == null ? current : field.orElse(null);
    }

    private static Double percent(Indicator indicator) {
        return indicator.percent();
    }

    static Map<String, Object> snapshot(Release release) {
        Map<String, Object> s = new LinkedHashMap<>();
        s.put("name", release.getName());
        s.put("goal", release.getGoal());
        s.put("startDate", release.getStartDate().toString());
        s.put("endDate", release.getEndDate().toString());
        s.put("status", release.getStatus().name());
        s.put("sprints", release.getSprints().stream().map(Sprint::getKey).toList());
        return s;
    }

    static Map<String, Object> snapshot(Sprint sprint) {
        Map<String, Object> s = new LinkedHashMap<>();
        s.put("name", sprint.getName());
        s.put("goal", sprint.getGoal());
        s.put("startDate", sprint.getStartDate().toString());
        s.put("endDate", sprint.getEndDate().toString());
        s.put("capacityPoints", sprint.getCapacityPoints());
        s.put("release", sprint.getRelease() == null ? null : sprint.getRelease().getKey());
        s.put("status", sprint.getStatus().name());
        s.put("scope", sprint.requirements().stream().map(Requirement::getKey).toList());
        return s;
    }
}
