package com.traceagile.domain.defect;

/** §3.2 DefectSeverity. */
public enum DefectSeverity {
    BLOCKER,
    CRITICAL,
    MAJOR,
    MINOR,
    TRIVIAL;

    /** §7.3 / F-REQ-19 anomalie « bloquante » : BLOCKER ou CRITICAL. */
    public boolean isBlocking() {
        return this == BLOCKER || this == CRITICAL;
    }
}
