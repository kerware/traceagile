package com.traceagile.domain.reporting;

/** §9.2 recommandation de mise en production ; la synthèse en déduit l'atteinte de l'objectif (ADR-0023). */
public enum Verdict {
    GO(SprintObjective.ACHIEVED),
    GO_WITH_RESERVATIONS(SprintObjective.PARTIALLY_ACHIEVED),
    NO_GO(SprintObjective.NOT_ACHIEVED);

    private final SprintObjective objective;

    Verdict(SprintObjective objective) {
        this.objective = objective;
    }

    public SprintObjective objective() {
        return objective;
    }
}
