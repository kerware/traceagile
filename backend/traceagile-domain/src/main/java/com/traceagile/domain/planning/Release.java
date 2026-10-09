package com.traceagile.domain.planning;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
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
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * §3.1 Release : groupe de sprints ordonnés (F-PLN-01). §3.3-3 les sprints d'une release sont dans
 * ses dates et ne se chevauchent pas. F-PLN-03 la clôture fige un bilan ; la release devient en
 * lecture seule.
 */
@Entity
@Table(name = "releases")
public class Release extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @Column(name = "release_key", nullable = false, length = 20, updatable = false)
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

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private PlanningStatus status = PlanningStatus.PLANNED;

    @Column(name = "closed_at")
    private Instant closedAt;

    /** F-PLN-03 bilan figé à la clôture (instantané JSON horodaté). */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "closing_report", columnDefinition = "jsonb")
    private Map<String, Object> closingReport;

    @OneToMany(mappedBy = "release")
    @OrderBy("startDate ASC")
    private List<Sprint> sprints = new ArrayList<>();

    protected Release() {
    }

    public Release(Project project, String key, String name, String goal, LocalDate startDate, LocalDate endDate) {
        this.project = Objects.requireNonNull(project);
        this.key = Objects.requireNonNull(key);
        this.keyNumber = Integer.parseInt(key.substring(key.lastIndexOf('-') + 1));
        rename(name);
        setGoal(goal);
        SprintSchedule.checkDates(startDate, endDate);
        this.startDate = startDate;
        this.endDate = endDate;
    }

    private void ensureOpen() {
        if (status == PlanningStatus.CLOSED) {
            throw new BusinessRuleException("RELEASE_CLOSED", "La release " + key + " est clôturée : elle est en lecture seule.");
        }
    }

    public void rename(String name) {
        ensureOpen();
        if (name == null || name.isBlank()) {
            throw new BusinessRuleException("RELEASE_NAME_REQUIRED", "Le nom de la release est obligatoire.");
        }
        this.name = name.strip();
    }

    public void setGoal(String goal) {
        ensureOpen();
        this.goal = goal == null || goal.isBlank() ? null : goal.strip();
    }

    /** §3.3-3 les dates englobent toujours les sprints rattachés. */
    public void reschedule(LocalDate start, LocalDate end) {
        ensureOpen();
        SprintSchedule.checkDates(start, end);
        for (Sprint sprint : sprints) {
            if (sprint.getStartDate().isBefore(start) || sprint.getEndDate().isAfter(end)) {
                throw new BusinessRuleException("SPRINT_OUTSIDE_RELEASE",
                        "Le sprint " + sprint.getKey() + " (" + sprint.getStartDate() + " → " + sprint.getEndDate() + ") sortirait de la release.");
            }
        }
        this.startDate = start;
        this.endDate = end;
    }

    /** ADR-0015 la génération de sprints prolonge la release si nécessaire. */
    public void extendTo(LocalDate end) {
        ensureOpen();
        if (end.isAfter(endDate)) {
            endDate = end;
        }
    }

    /** §3.3-3 rattache un sprint : dans les dates de la release, sans chevauchement. */
    public void attach(Sprint sprint) {
        ensureOpen();
        checkFits(sprint, sprint.getStartDate(), sprint.getEndDate());
        if (!sprints.contains(sprint)) {
            sprints.add(sprint);
            sprints.sort(Comparator.comparing(Sprint::getStartDate));
        }
        sprint.attachTo(this);
    }

    /** Vérifie qu'un sprint (nouveau ou replanifié) tient dans la release. */
    public void checkFits(Sprint sprint, LocalDate start, LocalDate end) {
        if (start.isBefore(startDate) || end.isAfter(endDate)) {
            throw new BusinessRuleException("SPRINT_OUTSIDE_RELEASE",
                    "Le sprint doit être compris dans les dates de la release " + key + " (" + startDate + " → " + endDate + ").");
        }
        for (Sprint other : sprints) {
            if (other != sprint && SprintSchedule.overlap(start, end, other.getStartDate(), other.getEndDate())) {
                throw new BusinessRuleException("SPRINT_OVERLAP",
                        "Le sprint chevauche " + other.getKey() + " (" + other.getStartDate() + " → " + other.getEndDate() + ").");
            }
        }
    }

    public void detach(Sprint sprint) {
        ensureOpen();
        sprints.remove(sprint);
    }

    /** Un sprint de la release démarre. */
    public void activate() {
        if (status == PlanningStatus.PLANNED) {
            status = PlanningStatus.ACTIVE;
        }
    }

    /** F-PLN-03 clôture : tous les sprints sont clos ; le bilan est figé. */
    public void close(Instant at, Map<String, Object> report) {
        ensureOpen();
        List<String> open = sprints.stream().filter(s -> s.getStatus() != PlanningStatus.CLOSED).map(Sprint::getKey).toList();
        if (!open.isEmpty()) {
            throw new BusinessRuleException("RELEASE_SPRINTS_NOT_CLOSED",
                    "Clôturez d'abord les sprints de la release : " + String.join(", ", open) + ".");
        }
        status = PlanningStatus.CLOSED;
        closedAt = Objects.requireNonNull(at);
        closingReport = new LinkedHashMap<>(report);
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

    public PlanningStatus getStatus() {
        return status;
    }

    public Instant getClosedAt() {
        return closedAt;
    }

    public Map<String, Object> getClosingReport() {
        return closingReport == null ? null : java.util.Collections.unmodifiableMap(closingReport);
    }

    public List<Sprint> getSprints() {
        return List.copyOf(sprints);
    }
}
