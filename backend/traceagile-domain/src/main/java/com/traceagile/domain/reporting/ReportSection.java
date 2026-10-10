package com.traceagile.domain.reporting;

import java.util.EnumSet;
import java.util.List;
import java.util.Set;

/**
 * ADR-0023 sections d'un rapport : les 8 du bilan de sprint (§9.2), les compléments du bilan de
 * release (§9.3) et des sections détaillées. Une section sans objet pour le périmètre est omise.
 */
public enum ReportSection {
    SUMMARY,
    DELIVERY,
    BURNDOWN(ReportScopeType.SPRINT, ReportScopeType.RELEASE),
    COVERAGE,
    EXECUTION,
    EXPLORATORY,
    DEFECTS,
    RISKS,
    SPRINT_TREND(ReportScopeType.RELEASE, ReportScopeType.PROJECT),
    REGRESSION(ReportScopeType.RELEASE),
    NFR,
    REQUIREMENTS,
    DEFECT_LIST,
    TEST_RESULTS,
    RECOMMENDATION;

    /** §9.2 bilan de sprint, dans l'ordre. */
    public static final List<ReportSection> SPRINT_REVIEW = List.of(SUMMARY, DELIVERY, COVERAGE, EXECUTION, EXPLORATORY, DEFECTS, RISKS,
            RECOMMENDATION);

    /** §9.3 bilan de release : même structure, plus l'évolution par sprint, la régression finale et les ENF. */
    public static final List<ReportSection> RELEASE_REVIEW = List.of(SUMMARY, DELIVERY, COVERAGE, EXECUTION, EXPLORATORY, DEFECTS, RISKS,
            SPRINT_TREND, REGRESSION, NFR, RECOMMENDATION);

    private final Set<ReportScopeType> scopes;

    ReportSection(ReportScopeType... scopes) {
        this.scopes = scopes.length == 0 ? EnumSet.allOf(ReportScopeType.class) : EnumSet.of(scopes[0], scopes);
    }

    public boolean appliesTo(ReportScopeType scope) {
        return scopes.contains(scope);
    }
}
