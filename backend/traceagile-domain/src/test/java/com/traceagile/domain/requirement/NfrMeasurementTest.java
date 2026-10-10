package com.traceagile.domain.requirement;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.requirement.NfrMeasurement.Outcome;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/** F-REQ-18 valeur mesurée d'une ENF comparée au seuil et à la cible (ADR-0024). */
class NfrMeasurementTest {

    @ParameterizedTest(name = "seuil {0}, cible {1}, mesure {2} → {3}")
    @CsvSource({
            "1500, 800, 700, TARGET_MET",
            "1500, 800, 800, TARGET_MET",
            "1500, 800, 1200, THRESHOLD_MET",
            "1500, 800, 1600, NOT_MET",
            "99.5, 99.9, 99.95, TARGET_MET",
            "'99,5', '99,9', 99.7, THRESHOLD_MET",
            "99.5, 99.9, 98, NOT_MET",
            "1 500 ms, , 1400, THRESHOLD_MET",
            ", , 10, UNKNOWN",
            "rapide, , 10, UNKNOWN"})
    @DisplayName("F-REQ-18 sens déduit de l'ordre seuil / cible (temps : plus petit est meilleur ; disponibilité : plus grand)")
    void evaluate(String threshold, String target, double value, Outcome expected) {
        assertThat(NfrMeasurement.evaluate(new Planguage(null, null, threshold, target, "ms"), value)).isEqualTo(expected);
    }

    @Test
    @DisplayName("ADR-0024 métrique retenue : nom finissant par l'unité (p95Ms pour ms), sinon la première")
    void pick() {
        Map<String, Double> metrics = new LinkedHashMap<>();
        metrics.put("throughputRps", 120.0);
        metrics.put("p95Ms", 640.0);
        assertThat(NfrMeasurement.pick(metrics, "ms").orElseThrow().getKey()).isEqualTo("p95Ms");
        assertThat(NfrMeasurement.pick(metrics, "%").orElseThrow().getKey()).isEqualTo("throughputRps");
        assertThat(NfrMeasurement.pick(Map.of(), "ms")).isEmpty();
    }

    @Test
    @DisplayName("F-REQ-18 mesure d'une ENF seulement, nombre fini, unité et résultat figés à la mesure")
    void measurement() {
        Project shop = new Project("SHOP", "Boutique", null);
        Requirement nfr = new Requirement(shop, "REQ-40", RequirementType.NON_FUNCTIONAL, "Temps de réponse", "a");
        nfr.setPlanguage(new Planguage("p95", "Gatling", "1500", "800", "ms"));
        NfrMeasurement m = new NfrMeasurement(nfr, 640, "p95Ms", "TC-31", "RUN-2", Instant.parse("2026-10-20T10:00:00Z"));
        assertThat(m.getOutcome()).isEqualTo(Outcome.TARGET_MET);
        assertThat(m.getUnit()).isEqualTo("ms");
        Requirement story = new Requirement(shop, "REQ-2", RequirementType.USER_STORY, "Payer", "b");
        assertThatThrownBy(() -> new NfrMeasurement(story, 1, null, null, null, Instant.now())).extracting("code").isEqualTo("MEASUREMENT_NFR_ONLY");
        assertThatThrownBy(() -> new NfrMeasurement(nfr, Double.NaN, null, null, null, Instant.now())).extracting("code").isEqualTo("MEASUREMENT_INVALID");
    }
}
