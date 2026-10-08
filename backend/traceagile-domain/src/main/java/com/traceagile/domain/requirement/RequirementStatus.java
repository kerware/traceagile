package com.traceagile.domain.requirement;

import java.util.EnumSet;
import java.util.Set;

/**
 * §3.2 Cycle de vie : DRAFT → TO_REFINE → READY → IN_SPRINT → DONE → ACCEPTED, plus REJECTED et
 * OBSOLETE. Retour d'un cran en arrière autorisé ; OBSOLETE est terminal (ADR-0009).
 */
public enum RequirementStatus {
    DRAFT,
    TO_REFINE,
    READY,
    IN_SPRINT,
    DONE,
    ACCEPTED,
    REJECTED,
    OBSOLETE;

    public Set<RequirementStatus> nextStatuses() {
        return switch (this) {
            case DRAFT -> EnumSet.of(TO_REFINE, READY, REJECTED, OBSOLETE);
            case TO_REFINE -> EnumSet.of(DRAFT, READY, REJECTED, OBSOLETE);
            case READY -> EnumSet.of(TO_REFINE, IN_SPRINT, REJECTED, OBSOLETE);
            case IN_SPRINT -> EnumSet.of(READY, DONE, OBSOLETE);
            case DONE -> EnumSet.of(IN_SPRINT, ACCEPTED, OBSOLETE);
            case ACCEPTED -> EnumSet.of(DONE, OBSOLETE);
            case REJECTED -> EnumSet.of(DRAFT, OBSOLETE);
            case OBSOLETE -> EnumSet.noneOf(RequirementStatus.class);
        };
    }

    public boolean canMoveTo(RequirementStatus target) {
        return nextStatuses().contains(target);
    }
}
