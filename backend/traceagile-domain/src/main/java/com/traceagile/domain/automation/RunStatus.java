package com.traceagile.domain.automation;

/** §3.2 RunStatus : cycle de vie d'un run automatisé (§8.5, §10). */
public enum RunStatus {
    QUEUED,
    DISPATCHED,
    RUNNING,
    COMPLETED,
    FAILED,
    CANCELLED,
    TIMEOUT;

    public boolean isFinal() {
        return this == COMPLETED || this == FAILED || this == CANCELLED || this == TIMEOUT;
    }
}
