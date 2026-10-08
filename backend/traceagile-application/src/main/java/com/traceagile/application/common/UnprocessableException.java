package com.traceagile.application.common;

import java.util.Map;

/**
 * Demande valide syntaxiquement mais refusée par une règle applicative → HTTP 422, avec des détails
 * exploitables par l'interface (items de DoR non satisfaits, erreurs Gherkin, lignes CSV…).
 */
public class UnprocessableException extends ApplicationException {

    private final Map<String, Object> details;

    public UnprocessableException(String code, String message, Map<String, Object> details) {
        super(code, message);
        this.details = Map.copyOf(details);
    }

    public UnprocessableException(String code, String message) {
        this(code, message, Map.of());
    }

    public Map<String, Object> getDetails() {
        return details;
    }
}
