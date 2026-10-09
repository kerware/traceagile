package com.traceagile.domain.execution;

import java.util.List;

/**
 * F-EXE-02 statut global déduit des pas : FAILED si un pas échoue, BLOCKED si un pas est bloqué et
 * aucun n'échoue, PASSED si tous passent. Tant qu'un pas reste à jouer : RUNNING. Un pas ignoré
 * (SKIPPED) ne compte pas, sauf si tous le sont (ADR-0016).
 */
public final class ExecutionRules {

    private ExecutionRules() {
    }

    public static ExecutionStatus derive(List<ExecutionStatus> steps) {
        if (steps.contains(ExecutionStatus.FAILED)) {
            return ExecutionStatus.FAILED;
        }
        if (steps.contains(ExecutionStatus.BLOCKED)) {
            return ExecutionStatus.BLOCKED;
        }
        if (steps.isEmpty() || steps.contains(ExecutionStatus.NOT_RUN)) {
            return ExecutionStatus.RUNNING;
        }
        return steps.stream().allMatch(s -> s == ExecutionStatus.SKIPPED) ? ExecutionStatus.SKIPPED : ExecutionStatus.PASSED;
    }

    /** Statut qu'un pas peut recevoir. */
    public static boolean isStepStatus(ExecutionStatus status) {
        return status == ExecutionStatus.NOT_RUN || status == ExecutionStatus.PASSED || status == ExecutionStatus.FAILED
                || status == ExecutionStatus.BLOCKED || status == ExecutionStatus.SKIPPED;
    }
}
