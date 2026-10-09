package com.traceagile.domain.campaign;

import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.requirement.RiskLevel;

/**
 * F-CMP-03 ordre proposé = risque de l'exigence × priorité du test (ADR-0016) : poids du risque 1, 2,
 * 4, 8 (le plus élevé des exigences couvertes ; 1 sans exigence) × poids de la priorité MUST 4,
 * SHOULD 3, COULD 2, WONT 1.
 */
public final class RiskPriority {

    private RiskPriority() {
    }

    public static int score(RiskLevel risk, Priority priority) {
        int riskWeight = risk == null ? 1 : risk.weight();
        int priorityWeight = switch (priority == null ? Priority.SHOULD : priority) {
            case MUST -> 4;
            case SHOULD -> 3;
            case COULD -> 2;
            case WONT -> 1;
        };
        return riskWeight * priorityWeight;
    }
}
