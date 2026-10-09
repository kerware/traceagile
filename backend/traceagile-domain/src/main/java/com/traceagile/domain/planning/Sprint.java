package com.traceagile.domain.planning;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/**
 * §3.1 Sprint (F-PLN-04) : dates, capacité en points, release facultative, périmètre ordonné
 * (F-PLN-05). F-PLN-06 cycle PLANNED → ACTIVE → CLOSED ; un sprint clos est en lecture seule.
 */
@Entity
@Table(name = "sprints")
public class Sprint extends AuditableEntity {

    /** ADR-0015 types planifiables : tout sauf épic et feature (conteneurs). */
    public static final Set<RequirementType> PLANNABLE = Set.of(RequirementType.USER_STORY, RequirementType.TECHNICAL_ENABLER,
            RequirementType.BUSINESS_RULE, RequirementType.NON_FUNCTIONAL);

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @Column(name = "sprint_key", nullable = false, length = 20, updatable = false)
    private String key;

    @Column(name = "key_number", nullable = false, updatable = false)
    private int keyNumber;

    @Column(nullable = false, length = 120)
    private String name;

    @Column(length = 1000)
    private String goal;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date", nullable = false)
    private LocalDate endDate;

    @Column(name = "capacity_points")
    private Integer capacityPoints;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private PlanningStatus status = PlanningStatus.PLANNED;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "release_id")
    private Release release;

    @OneToMany(mappedBy = "sprint", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("position ASC")
    private List<SprintScopeItem> scope = new ArrayList<>();

    protected Sprint() {
    }

    public Sprint(Project project, String key, String name, String goal, LocalDate startDate, LocalDate endDate, Integer capacityPoints) {
        this.project = Objects.requireNonNull(project);
        this.key = Objects.requireNonNull(key);
        this.keyNumber = Integer.parseInt(key.substring(key.lastIndexOf('-') + 1));
        rename(name);
        setGoal(goal);
        SprintSchedule.checkDates(startDate, endDate);
        this.startDate = startDate;
        this.endDate = endDate;
        setCapacityPoints(capacityPoints);
    }

    private void ensureOpen() {
        if (status == PlanningStatus.CLOSED) {
            throw new BusinessRuleException("SPRINT_CLOSED", "Le sprint " + key + " est clos : il est en lecture seule.");
        }
    }

    public void rename(String name) {
        ensureOpen();
        if (name == null || name.isBlank()) {
            throw new BusinessRuleException("SPRINT_NAME_REQUIRED", "Le nom du sprint est obligatoire.");
        }
        this.name = name.strip();
    }

    public void setGoal(String goal) {
        ensureOpen();
        this.goal = goal == null || goal.isBlank() ? null : goal.strip();
    }

    public void setCapacityPoints(Integer capacityPoints) {
        ensureOpen();
        if (capacityPoints != null && (capacityPoints < 0 || capacityPoints > 1000)) {
            throw new BusinessRuleException("SPRINT_CAPACITY_INVALID", "La capacité est comprise entre 0 et 1000 points.");
        }
        this.capacityPoints = capacityPoints;
    }

    /** §3.3-3 dans la release, sans chevauchement avec ses autres sprints. */
    public void reschedule(LocalDate start, LocalDate end) {
        ensureOpen();
        SprintSchedule.checkDates(start, end);
        if (release != null) {
            release.checkFits(this, start, end);
        }
        this.startDate = start;
        this.endDate = end;
    }

    void attachTo(Release release) {
        this.release = release;
    }

    /** Détache le sprint de sa release (F-PLN-01 « ajouter des sprints existants » : et les retirer). */
    public void detachFromRelease() {
        ensureOpen();
        if (release != null) {
            release.detach(this);
            release = null;
        }
    }

    // ---------------------------------------------------------------- périmètre (F-PLN-05)

    /**
     * Remplace le périmètre, dans l'ordre donné. Une exigence ajoutée est prête (READY) ; une
     * exigence déjà au périmètre d'un sprint actif est IN_SPRINT. Renvoie les exigences ajoutées et retirées.
     */
    public ScopeChange replaceScope(List<Requirement> requirements) {
        ensureOpen();
        Map<Object, SprintScopeItem> current = new LinkedHashMap<>();
        scope.forEach(item -> current.put(identity(item.getRequirement()), item));
        List<Requirement> added = new ArrayList<>();
        for (Requirement requirement : requirements) {
            if (!PLANNABLE.contains(requirement.getType())) {
                throw new BusinessRuleException("SPRINT_SCOPE_TYPE_INVALID",
                        requirement.getKey() + " est une " + requirement.getType() + " : seules les stories, règles, ENF et enablers se planifient.");
            }
            boolean kept = current.containsKey(identity(requirement));
            if (!kept && requirement.getStatus() != RequirementStatus.READY) {
                throw new BusinessRuleException("SPRINT_SCOPE_NOT_READY",
                        requirement.getKey() + " n'est pas prête (statut " + requirement.getStatus() + ").");
            }
            if (!kept) {
                added.add(requirement);
            }
        }
        if (requirements.stream().map(Sprint::identity).distinct().count() != requirements.size()) {
            throw new BusinessRuleException("SPRINT_SCOPE_DUPLICATED", "Une exigence apparaît deux fois dans le périmètre.");
        }
        List<Object> wanted = requirements.stream().map(Sprint::identity).toList();
        List<Requirement> removed = current.values().stream().map(SprintScopeItem::getRequirement)
                .filter(r -> !wanted.contains(identity(r))).toList();
        scope.removeIf(item -> !wanted.contains(identity(item.getRequirement())));
        for (int i = 0; i < requirements.size(); i++) {
            Requirement requirement = requirements.get(i);
            SprintScopeItem item = current.get(identity(requirement));
            if (item == null) {
                scope.add(new SprintScopeItem(this, requirement, i + 1));
            } else {
                item.moveTo(i + 1);
            }
        }
        scope.sort(java.util.Comparator.comparingInt(SprintScopeItem::getPosition));
        return new ScopeChange(added, removed);
    }

    /** Ajout en fin de périmètre (report d'une story à la clôture du sprint précédent). */
    public void append(Requirement requirement) {
        ensureOpen();
        if (scope.stream().noneMatch(item -> identity(item.getRequirement()).equals(identity(requirement)))) {
            scope.add(new SprintScopeItem(this, requirement, scope.size() + 1));
        }
    }

    /** Identifiant persistant (proxys Hibernate) ou, avant persistance, l'instance elle-même. */
    private static Object identity(Requirement requirement) {
        return requirement.getId() != null ? requirement.getId() : requirement;
    }

    public record ScopeChange(List<Requirement> added, List<Requirement> removed) {
    }

    public List<Requirement> requirements() {
        return scope.stream().map(SprintScopeItem::getRequirement).toList();
    }

    /** F-PLN-05 charge : somme des points des exigences du périmètre (engagement figé à la clôture). */
    public int loadPoints() {
        return scope.stream().mapToInt(item -> status == PlanningStatus.CLOSED
                ? Objects.requireNonNullElse(item.getCommittedPoints(), 0)
                : Objects.requireNonNullElse(item.getRequirement().getStoryPoints(), 0)).sum();
    }

    /** Charge / capacité en % ; {@code null} sans capacité renseignée. */
    public Integer loadPercent() {
        return capacityPoints == null || capacityPoints == 0 ? null : Math.round(loadPoints() * 100f / capacityPoints);
    }

    public boolean isOverCapacity() {
        return capacityPoints != null && loadPoints() > capacityPoints;
    }

    public int donePoints() {
        return scope.stream().filter(item -> item.getOutcome() == ScopeOutcome.DONE)
                .mapToInt(item -> Objects.requireNonNullElse(item.getCommittedPoints(), 0)).sum();
    }

    // ---------------------------------------------------------------- cycle de vie (F-PLN-06)

    public void start() {
        if (status != PlanningStatus.PLANNED) {
            throw new BusinessRuleException("SPRINT_STATUS_INVALID", "Seul un sprint planifié peut démarrer (" + key + " est " + status + ").");
        }
        status = PlanningStatus.ACTIVE;
    }

    public void close() {
        if (status != PlanningStatus.ACTIVE) {
            throw new BusinessRuleException("SPRINT_STATUS_INVALID", "Seul un sprint actif peut être clôturé (" + key + " est " + status + ").");
        }
        status = PlanningStatus.CLOSED;
    }

    /** Issue d'une exigence du périmètre, fixée à la clôture. */
    public void recordOutcome(Requirement requirement, ScopeOutcome outcome) {
        scope.stream().filter(item -> identity(item.getRequirement()).equals(identity(requirement))).findFirst()
                .orElseThrow(() -> new BusinessRuleException("SPRINT_SCOPE_UNKNOWN", requirement.getKey() + " n'est pas au périmètre de " + key + "."))
                .setOutcome(outcome);
    }

    public Project getProject() {
        return project;
    }

    public String getKey() {
        return key;
    }

    public int getKeyNumber() {
        return keyNumber;
    }

    public String getName() {
        return name;
    }

    public String getGoal() {
        return goal;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public Integer getCapacityPoints() {
        return capacityPoints;
    }

    public PlanningStatus getStatus() {
        return status;
    }

    public Release getRelease() {
        return release;
    }

    public List<SprintScopeItem> getScope() {
        return List.copyOf(scope);
    }
}
