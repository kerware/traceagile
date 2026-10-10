package com.traceagile.domain.requirement;

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
import java.util.Map;
import java.util.Optional;

/**
 * F-REQ-18 valeur mesurée d'une ENF (ADR-0024) : remontée par un test de performance ({@code metrics} de
 * TEST_FINISHED) ou saisie, comparée au seuil et à la cible Planguage au moment de la mesure.
 */
@Entity
@Table(name = "nfr_measurements")
public class NfrMeasurement extends AuditableEntity {

    /** Résultat de la comparaison. */
    public enum Outcome {
        /** Cible atteinte. */
        TARGET_MET,
        /** Seuil respecté, cible non atteinte. */
        THRESHOLD_MET,
        /** Seuil dépassé. */
        NOT_MET,
        /** Seuil et cible absents ou non numériques. */
        UNKNOWN
    }

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requirement_id")
    private Requirement requirement;

    @Column(name = "measured_value", nullable = false)
    private double value;

    @Column(length = 50)
    private String unit;

    @Column(length = 60)
    private String metric;

    /** Test et run d'origine ({@code null} pour une saisie). */
    @Column(name = "test_key", length = 20)
    private String testKey;

    @Column(name = "run_key", length = 20)
    private String runKey;

    @Column(name = "measured_at", nullable = false)
    private Instant measuredAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 15)
    private Outcome outcome;

    protected NfrMeasurement() {
    }

    public NfrMeasurement(Requirement nfr, double value, String metric, String testKey, String runKey, Instant measuredAt) {
        if (nfr.getType() != RequirementType.NON_FUNCTIONAL) {
            throw new BusinessRuleException("MEASUREMENT_NFR_ONLY", "Une valeur mesurée porte sur une exigence non fonctionnelle.");
        }
        if (Double.isNaN(value) || Double.isInfinite(value)) {
            throw new BusinessRuleException("MEASUREMENT_INVALID", "La valeur mesurée doit être un nombre.");
        }
        Planguage p = nfr.getPlanguage() == null ? Planguage.EMPTY : nfr.getPlanguage();
        this.requirement = nfr;
        this.value = value;
        this.unit = p.unit();
        this.metric = metric;
        this.testKey = testKey;
        this.runKey = runKey;
        this.measuredAt = measuredAt;
        this.outcome = evaluate(p, value);
    }

    /**
     * F-REQ-18 comparaison au seuil et à la cible : le sens se déduit de leur ordre (cible &lt; seuil :
     * plus petit est meilleur, comme un temps de réponse ; sinon plus grand est meilleur). Avec une seule
     * des deux valeurs, une unité de durée (ms, s, min, h) signifie « plus petit est meilleur ».
     */
    public static Outcome evaluate(Planguage p, double value) {
        Optional<Double> threshold = number(p.minimumThreshold());
        Optional<Double> target = number(p.target());
        if (threshold.isEmpty() && target.isEmpty()) {
            return Outcome.UNKNOWN;
        }
        boolean lowerIsBetter = threshold.isPresent() && target.isPresent() ? target.get() < threshold.get() : isDuration(p.unit());
        if (target.isPresent() && better(value, target.get(), lowerIsBetter)) {
            return Outcome.TARGET_MET;
        }
        if (threshold.isPresent()) {
            return better(value, threshold.get(), lowerIsBetter) ? Outcome.THRESHOLD_MET : Outcome.NOT_MET;
        }
        return Outcome.NOT_MET;
    }

    private static boolean isDuration(String unit) {
        return unit != null && java.util.Set.of("ms", "s", "sec", "min", "h").contains(unit.strip().toLowerCase(java.util.Locale.ROOT));
    }

    private static boolean better(double value, double limit, boolean lowerIsBetter) {
        return lowerIsBetter ? value <= limit : value >= limit;
    }

    /** « 1 500 », « 99,9 », « 1500 ms » → nombre ; vide ou texte → absent. */
    static Optional<Double> number(String text) {
        if (text == null) {
            return Optional.empty();
        }
        String cleaned = text.replace(' ', ' ').replace(" ", "").replace(',', '.').replaceAll("[^0-9.\\-]+$", "");
        try {
            return cleaned.isEmpty() ? Optional.empty() : Optional.of(Double.parseDouble(cleaned));
        } catch (NumberFormatException e) {
            return Optional.empty();
        }
    }

    /**
     * ADR-0024 métrique retenue parmi celles d'un test : celle dont le nom finit par l'unité de l'ENF
     * ({@code p95Ms} pour « ms »), sinon la première.
     */
    public static Optional<Map.Entry<String, Double>> pick(Map<String, Double> metrics, String unit) {
        if (metrics == null || metrics.isEmpty()) {
            return Optional.empty();
        }
        if (unit != null && !unit.isBlank()) {
            String suffix = unit.strip().toLowerCase(java.util.Locale.ROOT);
            Optional<Map.Entry<String, Double>> match = metrics.entrySet().stream()
                    .filter(e -> e.getKey().toLowerCase(java.util.Locale.ROOT).endsWith(suffix)).findFirst();
            if (match.isPresent()) {
                return match;
            }
        }
        return metrics.entrySet().stream().findFirst();
    }

    public Requirement getRequirement() {
        return requirement;
    }

    public double getValue() {
        return value;
    }

    public String getUnit() {
        return unit;
    }

    public String getMetric() {
        return metric;
    }

    public String getTestKey() {
        return testKey;
    }

    public String getRunKey() {
        return runKey;
    }

    public Instant getMeasuredAt() {
        return measuredAt;
    }

    public Outcome getOutcome() {
        return outcome;
    }
}
