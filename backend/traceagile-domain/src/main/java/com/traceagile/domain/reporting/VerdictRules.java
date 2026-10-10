package com.traceagile.domain.reporting;

import com.traceagile.domain.common.BusinessRuleException;
import java.util.ArrayList;
import java.util.List;

/**
 * §9.2 règles du verdict, paramétrables par projet (ADR-0023). Par défaut : Go si validation ≥ 95 %,
 * aucune anomalie BLOCKER ou CRITICAL ouverte et aucune exigence CRITICAL non validée ; Go sous
 * réserve si validation ≥ 80 % et aucune anomalie BLOCKER ouverte ; No go sinon.
 *
 * @param goMinValidation                taux de validation minimal pour Go (%)
 * @param reservedMinValidation          taux de validation minimal pour Go sous réserve (%)
 * @param goForbidsCriticalDefects       Go exige aucune anomalie CRITICAL ouverte
 * @param goRequiresCriticalRequirements Go exige toutes les exigences à risque CRITICAL validées
 * @param reservedForbidsBlockerDefects  Go sous réserve (et donc Go) exige aucune anomalie BLOCKER ouverte
 */
public record VerdictRules(double goMinValidation, double reservedMinValidation, boolean goForbidsCriticalDefects,
                           boolean goRequiresCriticalRequirements, boolean reservedForbidsBlockerDefects) {

    public static final VerdictRules DEFAULT = new VerdictRules(95, 80, true, true, true);

    public VerdictRules {
        if (goMinValidation < 0 || goMinValidation > 100 || reservedMinValidation < 0 || reservedMinValidation > 100) {
            throw new BusinessRuleException("VERDICT_RULES_INVALID", "Les seuils de validation sont des pourcentages entre 0 et 100.");
        }
        if (reservedMinValidation > goMinValidation) {
            throw new BusinessRuleException("VERDICT_RULES_INVALID", "Le seuil « Go sous réserve » ne peut pas dépasser celui de « Go ».");
        }
    }

    /**
     * Faits du bilan.
     *
     * @param validationPercent                taux de validation (§7.2), {@code null} sans exigence
     * @param openBlockers                     anomalies BLOCKER ouvertes
     * @param openCriticals                    anomalies CRITICAL ouvertes
     * @param criticalRequirementsNotValidated exigences à risque CRITICAL non validées
     */
    public record Facts(Double validationPercent, int openBlockers, int openCriticals, int criticalRequirementsNotValidated) {
    }

    /** Verdict calculé et ses motifs (affichés dans la recommandation). */
    public record Evaluation(Verdict verdict, List<String> reasons) {
    }

    public Evaluation evaluate(Facts facts) {
        double validation = facts.validationPercent() == null ? 0 : facts.validationPercent();
        List<String> missing = new ArrayList<>();
        if (facts.validationPercent() == null) {
            missing.add("aucune exigence dans le périmètre");
        } else if (validation < goMinValidation) {
            missing.add("taux de validation " + percent(validation) + " < " + percent(goMinValidation));
        }
        if (reservedForbidsBlockerDefects && facts.openBlockers() > 0) {
            missing.add(facts.openBlockers() + " anomalie(s) BLOCKER ouverte(s)");
        }
        if (goForbidsCriticalDefects && facts.openCriticals() > 0) {
            missing.add(facts.openCriticals() + " anomalie(s) CRITICAL ouverte(s)");
        }
        if (goRequiresCriticalRequirements && facts.criticalRequirementsNotValidated() > 0) {
            missing.add(facts.criticalRequirementsNotValidated() + " exigence(s) CRITICAL non validée(s)");
        }
        if (missing.isEmpty()) {
            return new Evaluation(Verdict.GO, List.of("taux de validation " + percent(validation) + ", aucune anomalie bloquante"));
        }
        boolean reserved = facts.validationPercent() != null && validation >= reservedMinValidation
                && !(reservedForbidsBlockerDefects && facts.openBlockers() > 0);
        return new Evaluation(reserved ? Verdict.GO_WITH_RESERVATIONS : Verdict.NO_GO, List.copyOf(missing));
    }

    private static String percent(double value) {
        return (value == Math.rint(value) ? String.valueOf((long) value) : String.valueOf(value)) + " %";
    }
}
