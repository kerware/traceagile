package com.traceagile.application.testcase;

import com.traceagile.application.requirement.GherkinValidator.GherkinError;
import java.util.List;

/**
 * F-AUT-05 / F-AUT-07 découpage d'un fichier .feature en scénarios et recomposition (implémenté
 * avec io.cucumber:gherkin dans l'infrastructure).
 */
public interface FeatureFileParser {

    /**
     * @return la fonctionnalité découpée : en-tête (directive de langue, tags, titre, description,
     * contexte) et un bloc de texte par scénario, tags compris
     */
    ParsedFeature parse(String source);

    /** F-AUT-04 textes des étapes (sans mot-clé), pour l'autocomplétion. */
    List<String> stepTexts(String source);

    record ParsedScenario(String name, List<String> tags, String block) {
    }

    record ParsedFeature(String language, String featureName, String header, List<ParsedScenario> scenarios,
                         List<GherkinError> errors) {

        public boolean valid() {
            return errors.isEmpty();
        }

        /** Document d'un seul scénario : en-tête de la fonctionnalité suivi du bloc du scénario. */
        public String documentFor(ParsedScenario scenario) {
            return compose(header, List.of(scenario.block()));
        }

        public static String compose(String header, List<String> blocks) {
            StringBuilder document = new StringBuilder(header.stripTrailing()).append("\n");
            for (String block : blocks) {
                document.append("\n").append(block.stripTrailing()).append("\n");
            }
            return document.toString();
        }
    }
}
