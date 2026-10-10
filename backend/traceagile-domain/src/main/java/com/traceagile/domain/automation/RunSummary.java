package com.traceagile.domain.automation;

/** §10.4 JOB_FINISHED.summary : nombre de tests par résultat. */
public record RunSummary(int total, int passed, int failed, int error, int skipped) {

    public static final RunSummary EMPTY = new RunSummary(0, 0, 0, 0, 0);
}
