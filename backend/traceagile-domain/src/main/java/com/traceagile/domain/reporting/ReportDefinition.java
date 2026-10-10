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
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * ADR-0023 définition d'un rapport configurable : périmètre, sections ordonnées, format par défaut,
 * options. Les définitions intégrées (bilans de sprint et de release) ne se modifient pas.
 */
@Entity
@Table(name = "report_definitions")
public class ReportDefinition extends AuditableEntity {

    public static final int NAME_MAX = 120;
    public static final String SPRINT_REVIEW = "Bilan de sprint";
    public static final String RELEASE_REVIEW = "Bilan de release";

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @Column(nullable = false, length = NAME_MAX)
    private String name;

    @Column(columnDefinition = "text")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "scope_type", nullable = false, length = 12)
    private ReportScopeType scopeType;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private List<ReportSection> sections = new ArrayList<>();

    @Enumerated(EnumType.STRING)
    @Column(name = "default_format", nullable = false, length = 12)
    private ReportFormat defaultFormat;

    @Column(name = "include_charts", nullable = false)
    private boolean includeCharts;

    @Column(name = "include_details", nullable = false)
    private boolean includeDetails;

    @Column(name = "built_in", nullable = false)
    private boolean builtIn;

    protected ReportDefinition() {
    }

    public ReportDefinition(Project project, String name, String description, ReportScopeType scopeType, List<ReportSection> sections,
                            ReportFormat defaultFormat, boolean includeCharts, boolean includeDetails) {
        this.project = project;
        apply(name, description, scopeType, sections, defaultFormat, includeCharts, includeDetails);
    }

    /** §9.2 / §9.3 définitions intégrées. */
    public static ReportDefinition sprintReview(Project project) {
        return builtIn(project, SPRINT_REVIEW, "Bilan de sprint du §9.2 : synthèse, livraison, couverture, exécution, exploratoire, "
                + "anomalies, risques résiduels et recommandation.", ReportScopeType.SPRINT, ReportSection.SPRINT_REVIEW);
    }

    public static ReportDefinition releaseReview(Project project) {
        return builtIn(project, RELEASE_REVIEW, "Bilan de release du §9.3 : la structure du bilan de sprint, agrégée sur la release, "
                + "avec l'évolution par sprint, la régression finale et les ENF.", ReportScopeType.RELEASE, ReportSection.RELEASE_REVIEW);
    }

    private static ReportDefinition builtIn(Project project, String name, String description, ReportScopeType scope, List<ReportSection> sections) {
        ReportDefinition definition = new ReportDefinition(project, name, description, scope, sections, ReportFormat.PDF, true, false);
        definition.builtIn = true;
        return definition;
    }

    /** Modification complète (formulaire) ; refusée sur une définition intégrée. */
    public void update(String name, String description, ReportScopeType scopeType, List<ReportSection> sections, ReportFormat defaultFormat,
                       boolean includeCharts, boolean includeDetails) {
        ensureEditable();
        apply(name, description, scopeType, sections, defaultFormat, includeCharts, includeDetails);
    }

    public void ensureEditable() {
        if (builtIn) {
            throw new BusinessRuleException("REPORT_DEFINITION_BUILT_IN",
                    "« " + name + " » est une définition intégrée : dupliquez-la pour l'adapter.");
        }
    }

    private void apply(String name, String description, ReportScopeType scopeType, List<ReportSection> sections, ReportFormat defaultFormat,
                       boolean includeCharts, boolean includeDetails) {
        String trimmed = name == null ? "" : name.strip();
        if (trimmed.isEmpty()) {
            throw new BusinessRuleException("REPORT_NAME_REQUIRED", "Le nom du rapport est obligatoire.");
        }
        if (trimmed.length() > NAME_MAX) {
            throw new BusinessRuleException("REPORT_NAME_TOO_LONG", "Le nom du rapport dépasse " + NAME_MAX + " caractères.");
        }
        if (scopeType == null) {
            throw new BusinessRuleException("REPORT_SCOPE_REQUIRED", "Choisissez le périmètre du rapport (sprint, release ou projet).");
        }
        List<ReportSection> distinct = sections == null ? List.of() : List.copyOf(new LinkedHashSet<>(sections));
        if (distinct.isEmpty()) {
            throw new BusinessRuleException("REPORT_SECTIONS_REQUIRED", "Choisissez au moins une section.");
        }
        List<ReportSection> unsupported = distinct.stream().filter(s -> !s.appliesTo(scopeType)).toList();
        if (!unsupported.isEmpty()) {
            throw new BusinessRuleException("REPORT_SECTION_SCOPE", "Section(s) sans objet pour ce périmètre : " + unsupported + ".");
        }
        this.name = trimmed;
        this.description = description == null || description.isBlank() ? null : description.strip();
        this.scopeType = scopeType;
        this.sections = new ArrayList<>(distinct);
        this.defaultFormat = defaultFormat == null ? ReportFormat.PDF : defaultFormat;
        this.includeCharts = includeCharts;
        this.includeDetails = includeDetails;
    }

    public Project getProject() {
        return project;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public ReportScopeType getScopeType() {
        return scopeType;
    }

    public List<ReportSection> getSections() {
        return List.copyOf(sections);
    }

    public ReportFormat getDefaultFormat() {
        return defaultFormat;
    }

    public boolean isIncludeCharts() {
        return includeCharts;
    }

    public boolean isIncludeDetails() {
        return includeDetails;
    }

    public boolean isBuiltIn() {
        return builtIn;
    }
}
