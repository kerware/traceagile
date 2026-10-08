package com.traceagile.application.common;

/** Échec d'authentification → HTTP 401. */
public class AuthenticationFailedException extends ApplicationException {

    public AuthenticationFailedException(String code, String message) {
        super(code, message);
    }
}
