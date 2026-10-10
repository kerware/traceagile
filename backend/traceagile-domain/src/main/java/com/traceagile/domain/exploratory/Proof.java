package com.traceagile.domain.exploratory;

import com.traceagile.domain.common.BusinessRuleException;
import java.util.List;
import java.util.stream.Stream;

/**
 * F-EXP-11 débriefing PROOF : Past (ce qui s'est passé), Results (constats), Obstacles, Outlook (ce
 * qui reste à faire, une piste par ligne — F-EXP-12) et Feelings (confiance du testeur, 1 à 5).
 */
public record Proof(String past, String results, String obstacles, String outlook, int feelings) {

    public Proof {
        past = strip(past);
        results = strip(results);
        obstacles = strip(obstacles);
        outlook = strip(outlook);
    }

    void validate() {
        if (past == null || results == null) {
            throw new BusinessRuleException("SESSION_DEBRIEF_INCOMPLETE", "Le débriefing précise au moins ce qui s'est passé et les constats.");
        }
        if (feelings < 1 || feelings > 5) {
            throw new BusinessRuleException("SESSION_FEELINGS_INVALID", "La confiance se note de 1 à 5.");
        }
    }

    /** F-EXP-12 pistes de l'Outlook, une par ligne non vide (sans puce). */
    public List<String> outlookItems() {
        if (outlook == null) {
            return List.of();
        }
        return Stream.of(outlook.split("\\R")).map(l -> l.strip().replaceFirst("^[-*•]\\s*", "")).filter(l -> !l.isEmpty()).toList();
    }

    private static String strip(String value) {
        return value == null || value.isBlank() ? null : value.strip();
    }
}
