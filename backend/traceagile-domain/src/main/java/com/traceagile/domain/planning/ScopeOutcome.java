package com.traceagile.domain.planning;

/** F-PLN-06 issue d'une story du périmètre, fixée à la clôture du sprint (ADR-0015). */
public enum ScopeOutcome {
    /** Sprint pas encore clos. */
    PLANNED,
    /** DONE ou ACCEPTED à la clôture. */
    DONE,
    /** Renvoyée au backlog (READY). */
    RETURNED,
    /** Reportée sur le sprint suivant. */
    CARRIED_OVER,
    /** Rejetée ou rendue obsolète pendant le sprint. */
    DROPPED
}
