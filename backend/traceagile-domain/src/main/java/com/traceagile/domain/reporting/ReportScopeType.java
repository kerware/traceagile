package com.traceagile.domain.reporting;

/** ADR-0023 périmètre d'un rapport : un sprint, une release ou tout le projet. */
public enum ReportScopeType {
    SPRINT("sprint"),
    RELEASE("release"),
    PROJECT("project");

    private final String prefix;

    ReportScopeType(String prefix) {
        this.prefix = prefix;
    }

    /** Périmètre au sens du §7.2 : « sprint:SPR-2 », « release:REL-1 », « project ». */
    public String scope(String key) {
        return this == PROJECT ? prefix : prefix + ":" + key;
    }
}
