package com.traceagile.domain.execution;

/**
 * §3.2 ExecutionStatus. Introduit au lot 3 pour les règles de vérification ; les exécutions
 * elles-mêmes arrivent aux lots 5 (manuelles) et 7 (automatisées).
 */
public enum ExecutionStatus {
    NOT_RUN,
    RUNNING,
    PASSED,
    FAILED,
    BLOCKED,
    SKIPPED,
    /** Erreur technique, distincte d'un échec fonctionnel. */
    ERROR;

    /** Un résultat a été obtenu (ADR-0014) : PASSED, FAILED, BLOCKED ou ERROR. */
    public boolean isExecuted() {
        return this == PASSED || this == FAILED || this == BLOCKED || this == ERROR;
    }
}
