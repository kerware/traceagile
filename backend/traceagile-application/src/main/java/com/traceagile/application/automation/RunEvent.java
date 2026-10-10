package com.traceagile.application.automation;

import com.traceagile.domain.automation.RunSummary;
import java.time.Instant;

/**
 * §10.4 événement d'un job, reçu par webhook ou relu par polling. Champs renseignés selon {@code event} :
 * JOB_STARTED (agent), TEST_STARTED / TEST_FINISHED (executionId, status, durationMs, message,
 * stackTrace), JOB_FINISHED (status, summary, reportUrl, logsUrl), JOB_ERROR (errorCode, message).
 */
public record RunEvent(String eventId, String event, String runId, String jobId, Instant occurredAt, String agent, String executionId,
                       String status, Long durationMs, String message, String stackTrace, RunSummary summary, String reportUrl,
                       String logsUrl, String errorCode) {
}
