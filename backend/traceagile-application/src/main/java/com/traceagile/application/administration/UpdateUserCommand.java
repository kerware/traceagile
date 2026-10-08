package com.traceagile.application.administration;

/** Mise à jour partielle (JSON Merge Patch) : un champ {@code null} reste inchangé. */
public record UpdateUserCommand(String email, String displayName, String password, Boolean active, Boolean systemAdmin) {
}
