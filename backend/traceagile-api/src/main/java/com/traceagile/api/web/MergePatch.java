package com.traceagile.api.web;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import jakarta.validation.ConstraintViolationException;
import jakarta.validation.Validator;
import java.util.Optional;

/**
 * §12 JSON Merge Patch (RFC 7396) : distingue un champ absent ({@code null} Java : inchangé) d'un
 * champ explicitement {@code null} ({@link Optional#empty()} : effacé). Le corps est d'abord validé
 * avec les contraintes du DTO de documentation (ADR-0009).
 */
public final class MergePatch {

    private final ObjectNode body;
    private final ObjectMapper json;

    private MergePatch(ObjectNode body, ObjectMapper json) {
        this.body = body;
        this.json = json;
    }

    /**
     * @param schema DTO portant les contraintes Bean Validation et servant à la documentation OpenAPI
     * @throws ConstraintViolationException si une contrainte n'est pas respectée (→ 400)
     */
    public static <T> MergePatch of(JsonNode body, Class<T> schema, ObjectMapper json, Validator validator) {
        if (!(body instanceof ObjectNode object)) {
            throw new MalformedRequestException("Le corps d'un PATCH doit être un objet JSON.");
        }
        T dto = convert(json, object, schema);
        var violations = validator.validate(dto);
        if (!violations.isEmpty()) {
            throw new ConstraintViolationException(violations);
        }
        return new MergePatch(object, json);
    }

    public <T> Optional<T> field(String name, Class<T> type) {
        if (!body.has(name)) {
            return null;
        }
        JsonNode value = body.get(name);
        return value.isNull() ? Optional.empty() : Optional.of(convert(json, value, type));
    }

    public <T> Optional<T> field(String name, TypeReference<T> type) {
        if (!body.has(name)) {
            return null;
        }
        JsonNode value = body.get(name);
        try {
            return value.isNull() ? Optional.empty() : Optional.of(json.convertValue(value, type));
        } catch (IllegalArgumentException e) {
            throw new MalformedRequestException("Valeur invalide pour « " + name + " ».");
        }
    }

    private static <T> T convert(ObjectMapper json, JsonNode value, Class<T> type) {
        try {
            return json.convertValue(value, type);
        } catch (IllegalArgumentException e) {
            throw new MalformedRequestException("Le corps de la requête contient une valeur invalide.");
        }
    }

    /** Corps illisible ou valeur d'un type inattendu → 400 MALFORMED_REQUEST. */
    public static class MalformedRequestException extends RuntimeException {
        public MalformedRequestException(String message) {
            super(message);
        }
    }
}
