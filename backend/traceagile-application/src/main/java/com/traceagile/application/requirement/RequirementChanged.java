package com.traceagile.application.requirement;

import java.util.Set;

/**
 * §11.3 Événement de domaine : une exigence a été modifiée ({@code changedFields} : champs de
 * l'instantané qui ont changé). Écouté par la traçabilité : une modification du contenu passe les
 * tests liés à NEEDS_UPDATE et rend leurs liens suspects (§3.3-7, ADR-0014).
 */
public record RequirementChanged(String projectKey, String requirementKey, Set<String> changedFields) {

    /** ADR-0014 champs dont la modification oblige à revoir les tests liés (pas le statut, le rang, la priorité…). */
    public static final Set<String> CONTENT_FIELDS = Set.of("type", "title", "description", "userStory.asA", "userStory.iWant",
            "userStory.soThat", "criteria", "category", "planguage.scale", "planguage.measurementMethod",
            "planguage.minimumThreshold", "planguage.target", "planguage.unit");

    public RequirementChanged {
        changedFields = changedFields == null ? Set.of() : Set.copyOf(changedFields);
    }

    public boolean contentChanged() {
        return changedFields.stream().anyMatch(CONTENT_FIELDS::contains);
    }
}
