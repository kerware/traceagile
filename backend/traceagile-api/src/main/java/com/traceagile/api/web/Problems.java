package com.traceagile.api.web;

import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;

/** Fabrique des réponses RFC 9457 portant un code métier dans la propriété {@code code} (§11.3). */
public final class Problems {

    public static final String CODE = "code";

    private Problems() {
    }

    public static ProblemDetail of(HttpStatus status, String code, String detail) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(status, detail);
        problem.setProperty(CODE, code);
        return problem;
    }

    public static ProblemDetail accessDenied() {
        return of(HttpStatus.FORBIDDEN, "ACCESS_DENIED", "Vous n'avez pas les droits nécessaires pour cette action.");
    }
}
