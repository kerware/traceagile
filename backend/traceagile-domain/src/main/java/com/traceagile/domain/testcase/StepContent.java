package com.traceagile.domain.testcase;

import java.util.Map;

/**
 * Contenu d'un pas manuel (F-MAN-01). ADR-0018 un pas peut appeler un autre cas de test manuel
 * ({@code calledTest}) : l'action devient facultative et {@code callParameters} donne la valeur des
 * paramètres de l'appelé, qui peut citer ceux de l'appelant ({@code ${nom}}).
 */
public record StepContent(String action, String expectedResult, String testData, TestCase calledTest, Map<String, String> callParameters) {

    public StepContent {
        callParameters = callParameters == null ? Map.of() : Map.copyOf(callParameters);
    }

    public static StepContent of(String action, String expectedResult, String testData) {
        return new StepContent(action, expectedResult, testData, null, null);
    }
}
