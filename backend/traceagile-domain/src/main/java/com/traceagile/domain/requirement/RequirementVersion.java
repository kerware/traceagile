package com.traceagile.domain.requirement;

import com.traceagile.domain.common.AuditableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.LinkedHashMap;
import java.util.Map;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/** §3.1 RequirementVersion : instantané figé au passage à READY ou sur demande (F-REQ-21). */
@Entity
@Table(name = "requirement_versions")
public class RequirementVersion extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requirement_id")
    private Requirement requirement;

    @Column(name = "version_number", nullable = false)
    private int versionNumber;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private Map<String, Object> snapshot = new LinkedHashMap<>();

    @Column(name = "change_comment", length = 500)
    private String changeComment;

    protected RequirementVersion() {
    }

    /** Fige l'état courant de l'exigence sous un nouveau numéro de version. */
    public static RequirementVersion freeze(Requirement requirement, String changeComment) {
        RequirementVersion version = new RequirementVersion();
        version.requirement = requirement;
        version.versionNumber = requirement.nextVersion();
        version.snapshot = requirement.snapshot();
        version.changeComment = changeComment == null || changeComment.isBlank() ? null : changeComment.strip();
        return version;
    }

    public Requirement getRequirement() {
        return requirement;
    }

    public int getVersionNumber() {
        return versionNumber;
    }

    /** Instantané dans l'ordre canonique des champs (voir {@link Requirement#SNAPSHOT_FIELDS}). */
    public Map<String, Object> getSnapshot() {
        return Requirement.inSnapshotOrder(snapshot);
    }

    public String getChangeComment() {
        return changeComment;
    }
}
