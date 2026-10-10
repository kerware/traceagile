package com.traceagile.domain.automation;

import com.traceagile.domain.execution.ExecutionStatus;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * F-EXE-11 test instable : sur ses 10 dernières exécutions, il alterne réussite et échec ({@code FAILED}
 * ou {@code ERROR}) au moins deux fois sur un même build. Les autres statuts sont ignorés (ADR-0020).
 */
public final class FlakyDetector {

    public static final int WINDOW = 10;
    public static final int MIN_ALTERNATIONS = 2;

    /** Résultat d'une exécution : build de la campagne ({@code null} accepté) et statut. */
    public record Outcome(String build, ExecutionStatus status) {
    }

    private FlakyDetector() {
    }

    /** {@code history} : de la plus ancienne à la plus récente. */
    public static boolean isFlaky(List<Outcome> history) {
        List<Outcome> recent = history.subList(Math.max(0, history.size() - WINDOW), history.size());
        Map<String, Boolean> lastByBuild = new LinkedHashMap<>();
        Map<String, Integer> alternations = new LinkedHashMap<>();
        for (Outcome outcome : recent) {
            Boolean passed = switch (outcome.status()) {
                case PASSED -> true;
                case FAILED, ERROR -> false;
                default -> null;
            };
            if (passed == null) {
                continue;
            }
            String build = Objects.toString(outcome.build(), "");
            Boolean previous = lastByBuild.put(build, passed);
            if (previous != null && previous != passed && alternations.merge(build, 1, Integer::sum) >= MIN_ALTERNATIONS) {
                return true;
            }
        }
        return false;
    }
}
