package com.traceagile.domain.planning;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.requirement.Requirement;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.Objects;

/**
 * §3.1 SprintScope : une exigence du périmètre d'un sprint, à sa position. Conservé après la
 * clôture avec son issue (F-PLN-06), pour les bilans du lot 8.
 */
@Entity
@Table(name = "sprint_scope")
public class SprintScopeItem extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "sprint_id")
    private Sprint sprint;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requirement_id")
    private Requirement requirement;

    @Column(nullable = false)
    private int position;

    /** Points de la story au moment de l'ajout (engagement) ; mis à jour tant que le sprint n'est pas clos. */
    @Column(name = "committed_points")
    private Integer committedPoints;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 15)
    private ScopeOutcome outcome = ScopeOutcome.PLANNED;

    protected SprintScopeItem() {
    }

    SprintScopeItem(Sprint sprint, Requirement requirement, int position) {
        this.sprint = Objects.requireNonNull(sprint);
        this.requirement = Objects.requireNonNull(requirement);
        this.position = position;
        this.committedPoints = requirement.getStoryPoints();
    }

    void moveTo(int position) {
        this.position = position;
        this.committedPoints = requirement.getStoryPoints();
    }

    void setOutcome(ScopeOutcome outcome) {
        this.outcome = Objects.requireNonNull(outcome);
    }

    public Sprint getSprint() {
        return sprint;
    }

    public Requirement getRequirement() {
        return requirement;
    }

    public int getPosition() {
        return position;
    }

    public Integer getCommittedPoints() {
        return committedPoints;
    }

    public ScopeOutcome getOutcome() {
        return outcome;
    }
}
