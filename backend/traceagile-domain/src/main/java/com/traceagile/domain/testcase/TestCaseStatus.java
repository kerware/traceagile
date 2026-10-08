package com.traceagile.domain.testcase;

import java.util.EnumSet;
import java.util.Set;

/**
 * §3.2 TestCaseStatus. NEEDS_UPDATE est posé par l'outil quand une exigence liée change (§3.3-7,
 * lot 3) ou par le testeur ; OBSOLETE est terminal (ADR-0012).
 */
public enum TestCaseStatus {
    DRAFT,
    READY,
    NEEDS_UPDATE,
    OBSOLETE;

    public Set<TestCaseStatus> nextStatuses() {
        return switch (this) {
            case DRAFT -> EnumSet.of(READY, OBSOLETE);
            case READY -> EnumSet.of(DRAFT, NEEDS_UPDATE, OBSOLETE);
            case NEEDS_UPDATE -> EnumSet.of(READY, DRAFT, OBSOLETE);
            case OBSOLETE -> EnumSet.noneOf(TestCaseStatus.class);
        };
    }

    public boolean canMoveTo(TestCaseStatus target) {
        return nextStatuses().contains(target);
    }
}
