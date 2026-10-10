package com.traceagile.domain.exploratory;

/** ADR-0019 cycle de vie d'une session exploratoire (§5.2, §5.3). */
public enum SessionState {
    /** Chronomètre en marche. */
    RUNNING,
    /** Chronomètre arrêté ; notes encore possibles. */
    PAUSED,
    /** Terminée (TBS, zones, statut saisis) ; débriefing à faire ou à approuver. */
    FINISHED,
    /** F-EXP-13 débriefing approuvé par un second utilisateur. */
    DEBRIEFED;

    public boolean isOpen() {
        return this == RUNNING || this == PAUSED;
    }
}
