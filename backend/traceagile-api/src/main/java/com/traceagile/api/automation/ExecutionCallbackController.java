package com.traceagile.api.automation;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.application.automation.AutomatedRunService;
import com.traceagile.application.automation.RunEvent;
import com.traceagile.domain.automation.WebhookSignature;
import com.traceagile.infrastructure.automation.RunEventJson;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.io.IOException;
import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

/**
 * §10.4 webhooks du serveur d'exécution : sans JWT, authentifiés par la signature HMAC du corps brut
 * avec le secret émis par le serveur (401 sinon) ; run inconnu 404 ; doublon (eventId) ignoré.
 */
@RestController
@Tag(name = "Runs automatisés")
public class ExecutionCallbackController {

    private final AutomatedRunService runs;
    private final ObjectMapper json;

    public ExecutionCallbackController(AutomatedRunService runs, ObjectMapper json) {
        this.runs = runs;
        this.json = json;
    }

    @PostMapping("/api/v1/execution-callbacks")
    @Operation(security = {}, summary = "Webhook du serveur d'exécution (signature X-TraceAgile-Signature)")
    public ResponseEntity<Map<String, String>> receive(@RequestBody byte[] body,
                                                       @RequestHeader(name = WebhookSignature.HEADER, required = false) String signature) {
        JsonNode node;
        try {
            node = json.readTree(body);
        } catch (IOException e) {
            return ResponseEntity.badRequest().body(Map.of("code", "WEBHOOK_INVALID", "message", "Corps JSON illisible."));
        }
        RunEvent event = RunEventJson.read(node);
        if (event.runId() == null || event.event() == null) {
            return ResponseEntity.badRequest().body(Map.of("code", "WEBHOOK_INVALID", "message", "runId et event sont obligatoires."));
        }
        runs.receive(event, body, signature);
        return ResponseEntity.ok(Map.of("status", "accepted"));
    }
}
