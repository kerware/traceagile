package com.traceagile.domain.reporting;

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
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * ADR-0023 rapport généré ({@code RPT-n}) : données calculées à la génération, exportées telles quelles
 * dans tous les formats. Figé (F-RPT-04), il n'est plus supprimable et garde un lien permanent ; le
 * verdict peut être remplacé par le PO, avec un commentaire (§9.2).
 */
@Entity
@Table(name = "report_snapshots")
public class ReportSnapshot extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @Column(name = "report_key", nullable = false, length = 20, updatable = false)
    private String key;

    @Column(name = "key_number", nullable = false, updatable = false)
    private int keyNumber;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(name = "definition_name", nullable = false, length = ReportDefinition.NAME_MAX)
    private String definitionName;

    @Enumerated(EnumType.STRING)
    @Column(name = "scope_type", nullable = false, length = 12)
    private ReportScopeType scopeType;

    @Column(nullable = false, length = 40)
    private String scope;

    @Column(name = "scope_label", nullable = false, length = 200)
    private String scopeLabel;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private List<ReportSection> sections = new ArrayList<>();

    @Column(name = "include_charts", nullable = false)
    private boolean includeCharts;

    @Column(name = "include_details", nullable = false)
    private boolean includeDetails;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private Map<String, Object> data = new LinkedHashMap<>();

    @Enumerated(EnumType.STRING)
    @Column(name = "computed_verdict", length = 24)
    private Verdict computedVerdict;

    @Enumerated(EnumType.STRING)
    @Column(name = "verdict_override", length = 24)
    private Verdict verdictOverride;

    @Column(name = "verdict_comment", columnDefinition = "text")
    private String verdictComment;

    @Column(name = "verdict_by", length = 50)
    private String verdictBy;

    @Column(name = "verdict_at")
    private Instant verdictAt;

    @Column(nullable = false)
    private boolean frozen;

    @Column(name = "frozen_at")
    private Instant frozenAt;

    @Column(name = "frozen_by", length = 50)
    private String frozenBy;

    protected ReportSnapshot() {
    }

    public ReportSnapshot(Project project, String key, String title, String definitionName, ReportScopeType scopeType, String scope,
                          String scopeLabel, List<ReportSection> sections, boolean includeCharts, boolean includeDetails,
                          Map<String, Object> data, Verdict computedVerdict) {
        this.project = project;
        this.key = key;
        this.keyNumber = Integer.parseInt(key.substring(key.lastIndexOf('-') + 1));
        String trimmed = title == null ? "" : title.strip();
        if (trimmed.isEmpty()) {
            throw new BusinessRuleException("REPORT_TITLE_REQUIRED", "Le titre du rapport est obligatoire.");
        }
        this.title = trimmed.length() > 200 ? trimmed.substring(0, 200) : trimmed;
        this.definitionName = definitionName;
        this.scopeType = scopeType;
        this.scope = scope;
        this.scopeLabel = scopeLabel;
        this.sections = new ArrayList<>(sections);
        this.includeCharts = includeCharts;
        this.includeDetails = includeDetails;
        this.data = new LinkedHashMap<>(data);
        this.computedVerdict = computedVerdict;
    }

    /** §9.2 verdict modifié par le PO, avec commentaire ; {@code null} = revenir au verdict calculé. */
    public void overrideVerdict(Verdict verdict, String comment, String login, Instant now) {
        if (computedVerdict == null) {
            throw new BusinessRuleException("REPORT_WITHOUT_VERDICT", "Ce rapport ne comporte ni synthèse ni recommandation.");
        }
        String text = comment == null ? "" : comment.strip();
        if (verdict != null && text.isEmpty()) {
            throw new BusinessRuleException("VERDICT_COMMENT_REQUIRED", "Expliquez en commentaire pourquoi le verdict est modifié.");
        }
        this.verdictOverride = verdict;
        this.verdictComment = verdict == null ? null : text;
        this.verdictBy = verdict == null ? null : login;
        this.verdictAt = verdict == null ? null : now;
    }

    /** F-RPT-04 instantané figé : lien permanent, plus de suppression. */
    public void freeze(String login, Instant now) {
        if (frozen) {
            throw new BusinessRuleException("REPORT_ALREADY_FROZEN", key + " est déjà figé.");
        }
        this.frozen = true;
        this.frozenAt = now;
        this.frozenBy = login;
    }

    public void ensureDeletable() {
        if (frozen) {
            throw new BusinessRuleException("REPORT_FROZEN", key + " est figé : il ne peut plus être supprimé.");
        }
    }

    /** Verdict retenu : celui du PO s'il l'a modifié, sinon le verdict calculé. */
    public Verdict getVerdict() {
        return verdictOverride != null ? verdictOverride : computedVerdict;
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

    public String getTitle() {
        return title;
    }

    public String getDefinitionName() {
        return definitionName;
    }

    public ReportScopeType getScopeType() {
        return scopeType;
    }

    public String getScope() {
        return scope;
    }

    public String getScopeLabel() {
        return scopeLabel;
    }

    public List<ReportSection> getSections() {
        return List.copyOf(sections);
    }

    public boolean isIncludeCharts() {
        return includeCharts;
    }

    public boolean isIncludeDetails() {
        return includeDetails;
    }

    public Map<String, Object> getData() {
        return data;
    }

    public Verdict getComputedVerdict() {
        return computedVerdict;
    }

    public Verdict getVerdictOverride() {
        return verdictOverride;
    }

    public String getVerdictComment() {
        return verdictComment;
    }

    public String getVerdictBy() {
        return verdictBy;
    }

    public Instant getVerdictAt() {
        return verdictAt;
    }

    public boolean isFrozen() {
        return frozen;
    }

    public Instant getFrozenAt() {
        return frozenAt;
    }

    public String getFrozenBy() {
        return frozenBy;
    }
}
