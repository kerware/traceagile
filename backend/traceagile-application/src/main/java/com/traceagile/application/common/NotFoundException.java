package com.traceagile.application.common;

/** Ressource introuvable → HTTP 404. */
public class NotFoundException extends ApplicationException {

    public NotFoundException(String code, String message) {
        super(code, message);
    }
}
