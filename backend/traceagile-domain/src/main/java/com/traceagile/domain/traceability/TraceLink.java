package com.traceagile.domain.traceability;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.AuditableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

/**
 * §3.1 TraceLink : lien générique de traçabilité : test → exigence et test → critère d'acceptation
 * (F-TRA-03), créés à la main, par tag Gherkin, par génération ou par découverte. Porte l'alerte de
 * suspicion (§3.3-7, lot 3).
 */
@Entity
@Table(name = "trace_links")
public class TraceLink extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @Enumerated(EnumType.STRING)
    @Column(name = "source_type", nullable = false, length = 25)
    private TraceEntityType sourceType;

    @Column(name = "source_id", nullable = false)
    private UUID sourceId;

    @Enumerated(EnumType.STRING)
    @Column(name = "target_type", nullable = false, length = 25)
    private TraceEntityType targetType;

    @Column(name = "target_id", nullable = false)
    private UUID targetId;

    @Enumerated(EnumType.STRING)
    @Column(name = "link_type", nullable = false, length = 20)
    private LinkType linkType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 15)
    private LinkOrigin origin;

    /** §3.3-7 alerte de suspicion : l'exigence a changé depuis la dernière revue du test. */
    @Column(name = "suspect_since")
    private Instant suspectSince;

    protected TraceLink() {
    }

    private TraceLink(Project project, TraceEntityType sourceType, UUID sourceId, TraceEntityType targetType, UUID targetId,
                      LinkType linkType, LinkOrigin origin) {
        this.project = Objects.requireNonNull(project);
        this.sourceType = sourceType;
        this.sourceId = Objects.requireNonNull(sourceId);
        this.targetType = targetType;
        this.targetId = Objects.requireNonNull(targetId);
        this.linkType = Objects.requireNonNull(linkType);
        this.origin = Objects.requireNonNull(origin);
    }

    public static TraceLink testToRequirement(Project project, UUID testId, UUID requirementId, LinkType type, LinkOrigin origin) {
        return new TraceLink(project, TraceEntityType.TEST_CASE, testId, TraceEntityType.REQUIREMENT, requirementId, type, origin);
    }

    public static TraceLink testToCriterion(Project project, UUID testId, UUID criterionId, LinkType type, LinkOrigin origin) {
        return new TraceLink(project, TraceEntityType.TEST_CASE, testId, TraceEntityType.ACCEPTANCE_CRITERION, criterionId, type, origin);
    }

    public void setLinkType(LinkType linkType) {
        this.linkType = Objects.requireNonNull(linkType);
    }

    /** §3.3-7 la première modification non revue fait foi. */
    public void markSuspect(Instant since) {
        if (suspectSince == null) {
            suspectSince = Objects.requireNonNull(since);
        }
    }

    public void clearSuspicion() {
        suspectSince = null;
    }

    public boolean isSuspect() {
        return suspectSince != null;
    }

    public Instant getSuspectSince() {
        return suspectSince;
    }

    public Project getProject() {
        return project;
    }

    public TraceEntityType getSourceType() {
        return sourceType;
    }

    public UUID getSourceId() {
        return sourceId;
    }

    public TraceEntityType getTargetType() {
        return targetType;
    }

    public UUID getTargetId() {
        return targetId;
    }

    public LinkType getLinkType() {
        return linkType;
    }

    public LinkOrigin getOrigin() {
        return origin;
    }
}
