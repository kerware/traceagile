package com.traceagile.executionserver.job.executor;

import java.nio.file.Path;
import java.util.List;
import java.util.Map;

/**
 * Résultat d'un test exécuté par un framework.
 *
 * @param status      PASSED, FAILED, ERROR ou SKIPPED (§10.4)
 * @param metrics     métriques de performance (p95Ms, throughputRps…) remontées à TraceAgile (F-REQ-18)
 * @param screenshots copies d'écran produites par le framework (ADR-0021)
 * @param attachments autres fichiers à exposer (rapport du framework, archive Gatling…)
 */
public record TestOutcome(String status, String message, String stackTrace, Map<String, Double> metrics, List<Path> screenshots,
                          List<Path> attachments) {

    public static TestOutcome error(String message) {
        return new TestOutcome("ERROR", message, null, Map.of(), List.of(), List.of());
    }

    public boolean passed() {
        return "PASSED".equals(status);
    }
}
