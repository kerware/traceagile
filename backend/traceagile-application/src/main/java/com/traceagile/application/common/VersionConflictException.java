package com.traceagile.application.common;

/** §12 La version fournie dans {@code If-Match} n'est plus la version courante → HTTP 412. */
public class VersionConflictException extends ApplicationException {

    public VersionConflictException(long expected, long actual) {
        super("VERSION_CONFLICT", "La ressource a été modifiée entre-temps (version attendue " + expected
                + ", version actuelle " + actual + "). Rechargez-la avant de la modifier.");
    }

    /** Sans {@code If-Match} ({@code expected == null}), aucune vérification (ADR-0005). */
    public static void check(Long expected, long actual) {
        if (expected != null && expected != actual) {
            throw new VersionConflictException(expected, actual);
        }
    }
}
