package com.traceagile.application.common;

/** Erreur applicative portant un code métier renvoyé au client (RFC 9457, §11.3). */
public abstract class ApplicationException extends RuntimeException {

    private final String code;

    protected ApplicationException(String code, String message) {
        super(message);
        this.code = code;
    }

    public String getCode() {
        return code;
    }
}
