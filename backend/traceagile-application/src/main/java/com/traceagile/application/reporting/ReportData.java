package com.traceagile.application.reporting;

import java.util.List;
import java.util.Map;

/**
 * ADR-0023 données calculées d'un rapport, une propriété par section ({@code null} = section absente).
 * Sérialisées telles quelles dans l'instantané ({@code jsonb}) : dates en texte ISO, pas d'entité.
 */
public record ReportData(
        Header header,
        Summary summary,
        Delivery delivery,
        BurnChart burndown,
        CoverageSection coverage,
        ExecutionSection execution,
        ExploratorySection exploratory,
        DefectSection defects,
        List<RiskItem> risks,
        List<SprintTrendRow> sprintTrend,
        RegressionSection regression,
        List<NfrRow> nfr,
        List<RequirementRow> requirements,
        List<DefectRow> defectList,
        List<TestResultRow> testResults,
        Recommendation recommendation) {

    /** Périmètre et contexte. */
    public record Header(String projectKey, String projectName, String scope, String scopeLabel, String goal, String startDate,
                         String endDate, String status, String generatedAt, String generatedBy) {
    }

    /** §9.2-1 synthèse : objectif, verdict proposé et chiffres clés. */
    public record Summary(String goal, String objective, String verdict, Double validationPercent, Integer velocity, int openDefects,
                          int openBlockingDefects) {
    }

    /** §9.2-2 livraison. */
    public record Delivery(int committedStories, int committedPoints, int doneStories, int donePoints, int acceptedStories,
                           int carriedOverStories, int returnedStories, int droppedStories, List<StoryRow> stories) {
    }

    public record StoryRow(String key, String title, Integer points, String status, String outcome, String sprint) {
    }

    /** F-RPT-02 burndown (sprint) ou burnup (release) : {@code actual} réalisé, {@code reference} idéal ou total. */
    public record BurnChart(String kind, List<BurnPoint> points) {
    }

    public record BurnPoint(String label, Double actual, Double reference) {
    }

    /** §9.2-3 couverture : les cinq indicateurs du §7.2, exigences non couvertes ou en échec. */
    public record CoverageSection(Indicator design, Indicator criteria, Indicator execution, Indicator validation, Indicator riskWeighted,
                                  List<UnmetRequirement> uncovered, List<UnmetRequirement> failing) {
    }

    public record Indicator(double numerator, double denominator, Double percent) {
    }

    public record UnmetRequirement(String key, String title, String status) {
    }

    /** §9.2-4 exécution : statuts, types de test, tentatives par jour, tests instables. */
    public record ExecutionSection(int items, int attempts, Map<String, Integer> byStatus, List<KindRow> byKind, List<DayRow> attemptsByDay,
                                   List<FlakyTest> flaky) {
    }

    public record KindRow(String kind, int total, int passed, int failed, int notRun, int other) {
    }

    public record DayRow(String date, int attempts, int passed, int failed) {
    }

    public record FlakyTest(String key, String title) {
    }

    /** §9.2-5 exploratoire : métriques du §5.4 et constats des débriefings. */
    public record ExploratorySection(int sessions, int debriefed, long totalMinutes, Double averageMinutes, Double testPct, Double bugPct,
                                     Double setupPct, Double defectsPerHour, int chartersPlanned, int chartersExecuted, Double averageConfidence,
                                     List<String> neverExploredAreas, List<Finding> findings) {
    }

    public record Finding(String charter, String tester, String results, String obstacles) {
    }

    /** §9.2-6 anomalies. */
    public record DefectSection(int created, int resolved, int open, Map<String, Integer> openBySeverity, List<BlockingDefect> blocking) {
    }

    public record BlockingDefect(String key, String title, String severity, String status) {
    }

    /** §9.2-7 exigence à risque HIGH ou CRITICAL non validée. */
    public record RiskItem(String key, String title, String risk, String status) {
    }

    /** §9.3 évolution sprint par sprint. */
    public record SprintTrendRow(String key, String name, String status, int committedPoints, int donePoints, Double validationPercent,
                                 int defectsCreated, int defectsClosed) {
    }

    /** §9.3 campagne de régression finale. */
    public record RegressionSection(String campaignKey, String name, String status, int total, int passed, int failed, int notRun,
                                    Double passRate) {
    }

    /** §9.3 ENF : seuil et cible Planguage, valeur mesurée (F-REQ-18, non saisie au lot 8), statut. */
    public record NfrRow(String key, String title, String category, String threshold, String target, String measured, String status) {
    }

    /** Matrice simplifiée : exigence, tests liés, exécutés, réussis, statut. */
    public record RequirementRow(String key, String title, String type, String risk, int tests, int executed, int passed, String status) {
    }

    public record DefectRow(String key, String title, String severity, String status, String requirements, String createdAt) {
    }

    public record TestResultRow(String campaign, String test, String title, String kind, String status, String executedBy, String date) {
    }

    /** §9.2-8 recommandation : verdict calculé et motifs. */
    public record Recommendation(String verdict, List<String> reasons) {
    }
}
