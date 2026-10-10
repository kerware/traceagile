package com.traceagile.application.common;

/** Action réservée à un autre utilisateur (ex. le testeur d'une session) → HTTP 403. */
public class ForbiddenException extends ApplicationException {

    public ForbiddenException(String code, String message) {
        super(code, message);
    }
}
