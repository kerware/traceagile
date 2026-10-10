package com.traceagile.application.reporting;

import com.traceagile.domain.reporting.ReportSection;
import java.util.Map;

/** ADR-0023 libellés français des documents produits par le serveur (traduction : lot 9). */
public final class Labels {

    private static final Map<String, String> EXECUTION = Map.of("NOT_RUN", "Non exécuté", "RUNNING", "En cours", "PASSED", "Réussi",
            "FAILED", "Échoué", "BLOCKED", "Bloqué", "SKIPPED", "Ignoré", "ERROR", "Erreur technique");
    private static final Map<String, String> VERIFICATION = Map.of("NOT_COVERED", "Non couverte", "NOT_RUN", "Non exécutée",
            "IN_PROGRESS", "En cours", "VALIDATED", "Validée", "FAILED", "En échec", "BLOCKED", "Bloquée", "SUSPECT", "Suspecte");
    private static final Map<String, String> REQUIREMENT_STATUS = Map.of("DRAFT", "Brouillon", "TO_REFINE", "À affiner", "READY", "Prête",
            "IN_SPRINT", "En sprint", "DONE", "Terminée", "ACCEPTED", "Acceptée", "REJECTED", "Rejetée", "OBSOLETE", "Obsolète");
    private static final Map<String, String> REQUIREMENT_TYPE = Map.of("EPIC", "Épic", "FEATURE", "Feature", "USER_STORY", "User story",
            "BUSINESS_RULE", "Règle métier", "NON_FUNCTIONAL", "ENF", "TECHNICAL_ENABLER", "Enabler technique");
    private static final Map<String, String> SEVERITY = Map.of("BLOCKER", "Bloquante", "CRITICAL", "Critique", "MAJOR", "Majeure",
            "MINOR", "Mineure", "TRIVIAL", "Triviale");
    private static final Map<String, String> DEFECT_STATUS = Map.of("OPEN", "Ouverte", "IN_PROGRESS", "En correction", "RESOLVED", "Résolue",
            "CLOSED", "Fermée", "REJECTED", "Rejetée");
    private static final Map<String, String> RISK = Map.of("LOW", "Faible", "MEDIUM", "Moyen", "HIGH", "Élevé", "CRITICAL", "Critique");
    private static final Map<String, String> KIND = Map.of("MANUAL", "Manuel", "EXPLORATORY", "Exploratoire", "AUTOMATED", "Automatisé");
    private static final Map<String, String> PLANNING = Map.of("PLANNED", "Planifié", "ACTIVE", "Actif", "CLOSED", "Clos");
    private static final Map<String, String> CAMPAIGN = Map.of("PLANNED", "Planifiée", "IN_PROGRESS", "En cours", "COMPLETED", "Terminée",
            "ABORTED", "Abandonnée");
    private static final Map<String, String> OUTCOME = Map.of("PLANNED", "En cours", "DONE", "Terminée", "RETURNED", "Renvoyée au backlog",
            "CARRIED_OVER", "Reportée", "DROPPED", "Abandonnée");
    private static final Map<String, String> VERDICT = Map.of("GO", "Go", "GO_WITH_RESERVATIONS", "Go sous réserve", "NO_GO", "No go");
    private static final Map<String, String> OBJECTIVE = Map.of("ACHIEVED", "Atteint", "PARTIALLY_ACHIEVED", "Partiellement atteint",
            "NOT_ACHIEVED", "Non atteint");

    private Labels() {
    }

    public static String section(ReportSection section) {
        return switch (section) {
            case SUMMARY -> "Synthèse";
            case DELIVERY -> "Livraison";
            case BURNDOWN -> "Burndown / burnup";
            case COVERAGE -> "Couverture";
            case EXECUTION -> "Exécution";
            case EXPLORATORY -> "Tests exploratoires";
            case DEFECTS -> "Anomalies";
            case RISKS -> "Risques résiduels";
            case SPRINT_TREND -> "Évolution sprint par sprint";
            case REGRESSION -> "Campagne de régression finale";
            case NFR -> "Exigences non fonctionnelles";
            case REQUIREMENTS -> "Matrice des exigences";
            case DEFECT_LIST -> "Liste des anomalies";
            case TEST_RESULTS -> "Résultats détaillés des tests";
            case RECOMMENDATION -> "Recommandation de mise en production";
        };
    }

    public static String execution(String value) {
        return label(EXECUTION, value);
    }

    public static String verification(String value) {
        return label(VERIFICATION, value);
    }

    public static String requirementStatus(String value) {
        return label(REQUIREMENT_STATUS, value);
    }

    public static String requirementType(String value) {
        return label(REQUIREMENT_TYPE, value);
    }

    public static String severity(String value) {
        return label(SEVERITY, value);
    }

    public static String defectStatus(String value) {
        return label(DEFECT_STATUS, value);
    }

    public static String risk(String value) {
        return label(RISK, value);
    }

    public static String kind(String value) {
        return label(KIND, value);
    }

    public static String planning(String value) {
        return label(PLANNING, value);
    }

    public static String campaign(String value) {
        return label(CAMPAIGN, value);
    }

    public static String outcome(String value) {
        return label(OUTCOME, value);
    }

    public static String verdict(String value) {
        return label(VERDICT, value);
    }

    public static String objective(String value) {
        return label(OBJECTIVE, value);
    }

    /** Texte libre : « — » si vide. */
    public static String of(String value) {
        return value == null || value.isBlank() ? "—" : value;
    }

    private static String label(Map<String, String> labels, String value) {
        return value == null ? "—" : labels.getOrDefault(value, value);
    }
}
