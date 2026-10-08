package com.traceagile.api.web;

import com.traceagile.application.common.AuthenticationFailedException;
import com.traceagile.application.common.ConflictException;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.common.VersionConflictException;
import com.traceagile.domain.common.BusinessRuleException;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.mapping.PropertyReferenceException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.lang.Nullable;
import org.springframework.orm.ObjectOptimisticLockingFailureException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.method.annotation.HandlerMethodValidationException;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

/**
 * §11.3 Gestion des erreurs : toute erreur est renvoyée en {@code application/problem+json} (RFC 9457)
 * avec un code métier. 400 validation, 401 authentification, 403 accès refusé, 404 introuvable,
 * 409 conflit, 412 version périmée, 422 règle métier (ADR-0006).
 */
@RestControllerAdvice
public class ApiExceptionHandler extends ResponseEntityExceptionHandler {

    @ExceptionHandler(BusinessRuleException.class)
    ProblemDetail businessRule(BusinessRuleException e) {
        return Problems.of(HttpStatus.UNPROCESSABLE_ENTITY, e.getCode(), e.getMessage());
    }

    @ExceptionHandler(NotFoundException.class)
    ProblemDetail notFound(NotFoundException e) {
        return Problems.of(HttpStatus.NOT_FOUND, e.getCode(), e.getMessage());
    }

    @ExceptionHandler(ConflictException.class)
    ProblemDetail conflict(ConflictException e) {
        return Problems.of(HttpStatus.CONFLICT, e.getCode(), e.getMessage());
    }

    @ExceptionHandler(VersionConflictException.class)
    ProblemDetail versionConflict(VersionConflictException e) {
        return Problems.of(HttpStatus.PRECONDITION_FAILED, e.getCode(), e.getMessage());
    }

    @ExceptionHandler(ObjectOptimisticLockingFailureException.class)
    ProblemDetail optimisticLock(ObjectOptimisticLockingFailureException e) {
        return Problems.of(HttpStatus.PRECONDITION_FAILED, "VERSION_CONFLICT",
                "La ressource a été modifiée entre-temps. Rechargez-la avant de la modifier.");
    }

    @ExceptionHandler(AuthenticationFailedException.class)
    ProblemDetail authenticationFailed(AuthenticationFailedException e) {
        return Problems.of(HttpStatus.UNAUTHORIZED, e.getCode(), e.getMessage());
    }

    @ExceptionHandler(AccessDeniedException.class)
    ProblemDetail accessDenied(AccessDeniedException e) {
        return Problems.accessDenied();
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    ProblemDetail integrity(DataIntegrityViolationException e) {
        return Problems.of(HttpStatus.CONFLICT, "DATA_CONFLICT", "L'opération entre en conflit avec des données existantes.");
    }

    @ExceptionHandler(PropertyReferenceException.class)
    ProblemDetail invalidSort(PropertyReferenceException e) {
        return Problems.of(HttpStatus.BAD_REQUEST, "INVALID_SORT", "Critère de tri inconnu : " + e.getPropertyName());
    }

    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(MethodArgumentNotValidException e, HttpHeaders headers,
                                                                  HttpStatusCode status, WebRequest request) {
        Map<String, String> errors = new LinkedHashMap<>();
        for (FieldError error : e.getBindingResult().getFieldErrors()) {
            errors.putIfAbsent(error.getField(), error.getDefaultMessage());
        }
        return ResponseEntity.badRequest().body(validationProblem(errors));
    }

    @Override
    protected ResponseEntity<Object> handleHandlerMethodValidationException(HandlerMethodValidationException e, HttpHeaders headers,
                                                                            HttpStatusCode status, WebRequest request) {
        Map<String, String> errors = new LinkedHashMap<>();
        e.getParameterValidationResults().forEach(result -> result.getResolvableErrors().forEach(error ->
                errors.putIfAbsent(error instanceof FieldError field ? field.getField() : result.getMethodParameter().getParameterName(),
                        error.getDefaultMessage())));
        return ResponseEntity.badRequest().body(validationProblem(errors));
    }

    @Override
    protected ResponseEntity<Object> handleHttpMessageNotReadable(HttpMessageNotReadableException e, HttpHeaders headers,
                                                                  HttpStatusCode status, WebRequest request) {
        return ResponseEntity.badRequest().body(Problems.of(HttpStatus.BAD_REQUEST, "MALFORMED_REQUEST",
                "Le corps de la requête est illisible ou contient une valeur inconnue."));
    }

    /** Toute autre erreur gérée par Spring MVC reçoit aussi un code. */
    @Override
    protected ResponseEntity<Object> handleExceptionInternal(Exception e, @Nullable Object body, HttpHeaders headers,
                                                             HttpStatusCode status, WebRequest request) {
        if (body instanceof ProblemDetail problem && (problem.getProperties() == null || !problem.getProperties().containsKey(Problems.CODE))) {
            problem.setProperty(Problems.CODE, "HTTP_" + status.value());
        }
        return super.handleExceptionInternal(e, body, headers, status, request);
    }

    private static ProblemDetail validationProblem(Map<String, String> errors) {
        ProblemDetail problem = Problems.of(HttpStatus.BAD_REQUEST, "VALIDATION_FAILED", "Certains champs sont invalides.");
        problem.setProperty("errors", errors);
        return problem;
    }
}
