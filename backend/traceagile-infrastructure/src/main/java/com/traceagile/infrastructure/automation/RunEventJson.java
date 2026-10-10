package com.traceagile.infrastructure.automation;

import com.fasterxml.jackson.databind.JsonNode;
import com.traceagile.application.automation.RunEvent;
import com.traceagile.domain.automation.RunSummary;
import java.time.Instant;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

/** §10.4 lecture d'un événement de job (webhook ou polling) au format du contrat. */
public final class RunEventJson {

    private RunEventJson() {
    }

    public static RunEvent read(JsonNode node) {
        JsonNode summary = node.path("summary");
        return new RunEvent(text(node, "eventId"), text(node, "event"), text(node, "runId"), text(node, "jobId"), instant(node, "occurredAt"),
                text(node, "agent"), text(node, "executionId"), text(node, "status"),
                node.hasNonNull("durationMs") ? node.get("durationMs").asLong() : null, text(node, "message"), text(node, "stackTrace"),
                summary.isObject() ? new RunSummary(summary.path("total").asInt(), summary.path("passed").asInt(), summary.path("failed").asInt(),
                        summary.path("error").asInt(), summary.path("skipped").asInt()) : null,
                text(node, "reportUrl"), text(node, "logsUrl"), text(node, "errorCode"), artifacts(node.path("artifacts")));
    }

    /** ADR-0021 artefacts annoncés (copie d'écran d'un test, traces, résultats…). */
    public static List<RunEvent.ArtifactRef> artifacts(JsonNode array) {
        List<RunEvent.ArtifactRef> refs = new ArrayList<>();
        array.forEach(a -> refs.add(new RunEvent.ArtifactRef(text(a, "name"), text(a, "type"), text(a, "kind"),
                a.hasNonNull("size") ? a.get("size").asLong() : null, text(a, "executionId"))));
        return refs;
    }

    private static String text(JsonNode node, String field) {
        return node.hasNonNull(field) ? node.get(field).asText() : null;
    }

    private static Instant instant(JsonNode node, String field) {
        try {
            return node.hasNonNull(field) ? Instant.parse(node.get(field).asText()) : null;
        } catch (DateTimeParseException e) {
            return null;
        }
    }
}
