package com.traceagile.domain.common;

/** Modification d'un champ entre deux instantanés (F-REQ-21, NF-16). */
public record FieldChange(String field, Object before, Object after) {
}
