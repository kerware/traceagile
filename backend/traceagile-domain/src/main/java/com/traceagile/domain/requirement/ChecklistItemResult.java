package com.traceagile.domain.requirement;

/** F-REQ-20 Résultat d'un item de DoR / DoD pour une exigence. */
public record ChecklistItemResult(ChecklistItem item, Outcome outcome) {

    public enum Outcome {
        SATISFIED,
        UNSATISFIED,
        /** Item automatique dont les données ne sont pas encore disponibles : ne bloque pas. */
        NOT_EVALUATED
    }

    public boolean automatic() {
        return item.isAutomatic();
    }
}
