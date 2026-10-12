package com.traceagile.domain.testcase;

import java.util.Map;

/**
 * Contenu d'un pas manuel (F-MAN-01). ADR-0018 un pas peut appeler un autre cas de test manuel
 * ({@code calledTest}) : l'action devient facultative et {@code callParameters} donne la valeur des
 * paramètres de l'appelé, qui peut citer ceux de l'appelant ({@code ${nom}}). ADR-0029 l'appel peut
 * désigner un jeu de données nommé de l'appelé ({@code callDataSet} › {@code callRow}) : ses valeurs
 * sont lues à l'exécution, {@code callParameters} les complète ou les remplace.
 */
public record StepContent(String action, String expectedResult, String testData, TestCase calledTest, Map<String, String> callParameters,
                          String callDataSet, String callRow) {

    public StepContent {
        callParameters = callParameters == null ? Map.of() : Map.copyOf(callParameters);
        callDataSet = blankToNull(callDataSet);
        callRow = blankToNull(callRow);
    }

    public StepContent(String action, String expectedResult, String testData, TestCase calledTest, Map<String, String> callParameters) {
        this(action, expectedResult, testData, calledTest, callParameters, null, null);
    }

    public static StepContent of(String action, String expectedResult, String testData) {
        return new StepContent(action, expectedResult, testData, null, null);
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.strip();
    }
}
