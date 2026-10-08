package com.traceagile.application.requirement;

import java.util.List;

/** F-REQ-10 Port de validation Gherkin (io.cucumber:gherkin dans l'infrastructure). */
public interface GherkinValidator {

    /**
     * Valide un critère ou un fichier .feature. Un scénario seul est accepté : l'en-tête
     * « Fonctionnalité » est ajouté implicitement. Mots-clés français ou anglais (ADR-0011).
     */
    GherkinValidation validate(String source);

    /** Erreur de syntaxe positionnée dans le texte saisi (lignes à partir de 1). */
    record GherkinError(int line, int column, String message) {
    }

    record GherkinValidation(String language, List<GherkinError> errors) {
        public boolean valid() {
            return errors.isEmpty();
        }
    }
}
