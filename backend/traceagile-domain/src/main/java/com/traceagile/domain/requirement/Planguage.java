package com.traceagile.domain.requirement;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

/**
 * F-REQ-16 Champs mesurables d'une ENF au format Planguage : échelle, méthode de mesure, seuil
 * minimal, cible, unité. Seuil et cible sont du texte (« 800 », « 99,9 »), comparés au lot 7.
 */
@Embeddable
public record Planguage(
        @Column(name = "nfr_scale", length = 500) String scale,
        @Column(name = "nfr_measurement_method", length = 500) String measurementMethod,
        @Column(name = "nfr_minimum_threshold", length = 100) String minimumThreshold,
        @Column(name = "nfr_target", length = 100) String target,
        @Column(name = "nfr_unit", length = 50) String unit) {

    public static final Planguage EMPTY = new Planguage(null, null, null, null, null);

    public boolean isEmpty() {
        return scale == null && measurementMethod == null && minimumThreshold == null && target == null && unit == null;
    }
}
