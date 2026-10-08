package com.traceagile.api.web;

import com.traceagile.domain.common.AuditableEntity;

/** §12 Verrou optimiste : version exposée en {@code ETag}, attendue en {@code If-Match}. */
public final class Versions {

    private Versions() {
    }

    public static String etag(AuditableEntity entity) {
        return "\"" + entity.getVersion() + "\"";
    }

    /** Lit {@code If-Match} ({@code "3"}, {@code W/"3"} ou {@code 3}) ; {@code null} si absent ou {@code *}. */
    public static Long parseIfMatch(String ifMatch) {
        if (ifMatch == null || ifMatch.isBlank() || ifMatch.strip().equals("*")) {
            return null;
        }
        String value = ifMatch.strip();
        if (value.startsWith("W/")) {
            value = value.substring(2);
        }
        value = value.replace("\"", "");
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException e) {
            // Une valeur illisible ne correspond à aucune version : conflit plutôt qu'écrasement.
            return -1L;
        }
    }
}
