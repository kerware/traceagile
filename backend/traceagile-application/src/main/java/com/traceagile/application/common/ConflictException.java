package com.traceagile.application.common;

/** Conflit avec l'état existant (unicité…) → HTTP 409. */
public class ConflictException extends ApplicationException {

    public ConflictException(String code, String message) {
        super(code, message);
    }
}
