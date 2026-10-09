package com.traceagile.domain.defect;

import java.util.EnumSet;
import java.util.Set;

/** F-DEF-01 OPEN → IN_PROGRESS → RESOLVED → CLOSED, ou REJECTED ; réouverture possible (ADR-0016). */
public enum DefectStatus {
    OPEN,
    IN_PROGRESS,
    RESOLVED,
    CLOSED,
    REJECTED;

    public Set<DefectStatus> nextStatuses() {
        return switch (this) {
            case OPEN -> EnumSet.of(IN_PROGRESS, RESOLVED, REJECTED);
            case IN_PROGRESS -> EnumSet.of(OPEN, RESOLVED, REJECTED);
            case RESOLVED -> EnumSet.of(CLOSED, OPEN);
            case CLOSED, REJECTED -> EnumSet.of(OPEN);
        };
    }

    public boolean canMoveTo(DefectStatus target) {
        return nextStatuses().contains(target);
    }

    /** ADR-0016 une anomalie « ouverte » n'est ni résolue, ni close, ni rejetée. */
    public boolean isOpen() {
        return this == OPEN || this == IN_PROGRESS;
    }
}
