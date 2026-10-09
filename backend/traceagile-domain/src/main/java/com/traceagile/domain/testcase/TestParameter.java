package com.traceagile.domain.testcase;

/**
 * Paramètre d'un test (ADR-0013) : nom (lettres, chiffres, « _ », « - », « . »), valeur par défaut
 * et description. Dans un test manuel, chaque {@code ${nom}} des pas en déclare un automatiquement.
 */
public record TestParameter(String name, String defaultValue, String description) {

    public TestParameter {
        name = name == null ? null : name.strip();
        defaultValue = defaultValue == null || defaultValue.isEmpty() ? null : defaultValue;
        description = description == null || description.isBlank() ? null : description.strip();
    }

    public static TestParameter named(String name) {
        return new TestParameter(name, null, null);
    }
}
