package com.traceagile.domain.common;

/**
 * Violation d'une règle métier. Le {@code code} est renvoyé tel quel au client dans la réponse
 * RFC 9457 (§11.3), par exemple {@code PROJECT_KEY_INVALID}.
 */
public class BusinessRuleException extends RuntimeException {

    private final String code;

    public BusinessRuleException(String code, String message) {
        super(message);
        this.code = code;
    }

    public String getCode() {
        return code;
    }
}
