package com.traceagile.application.administration;

/** Événement de domaine : un projet vient d'être créé (initialisation de ses paramètres). */
public record ProjectCreated(String projectKey) {
}
