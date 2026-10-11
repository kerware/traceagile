package com.traceagile.executionserver.job;

import com.traceagile.executionserver.ServerProperties;
import com.traceagile.executionserver.job.JobStore.ArtifactRow;
import com.traceagile.executionserver.job.JobStore.JobRow;
import com.traceagile.executionserver.security.SecurityFilter;
import com.traceagile.executionserver.token.TokenService.TokenRecord;
import com.traceagile.executionserver.tool.ToolService;
import jakarta.servlet.http.HttpServletRequest;
import java.time.Clock;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

/**
 * §10.2 API appelée par TraceAgile (docs/execution-server-api.yaml), jeton Bearer : capacités,
 * soumission idempotente par runId, statut (polling), annulation, journaux, artefacts. Un jeton ne
 * voit que ses jobs.
 */
@RestController
@RequestMapping("/api/v1")
public class JobController {

    private final JobStore store;
    private final JobRunner runner;
    private final ArtifactStore artifacts;
    private final ToolService tools;
    private final ServerProperties properties;
    private final Clock clock;

    public JobController(JobStore store, JobRunner runner, ArtifactStore artifacts, ToolService tools, ServerProperties properties, Clock clock) {
        this.store = store;
        this.runner = runner;
        this.artifacts = artifacts;
        this.tools = tools;
        this.properties = properties;
        this.clock = clock;
    }

    /** Techniques et frameworks utilisables d'après les outils détectés sur la machine. */
    @GetMapping("/capabilities")
    public Map<String, Object> capabilities() {
        List<String> frameworks = tools.frameworks();
        return Map.of("techniques", List.of("API", "BDD", "UNIT", "UI", "KEYWORD", "DATA_DRIVEN", "PERFORMANCE", "CONTRACT"), "frameworks", frameworks,
                "environments", List.of(), "agents", properties.agents());
    }

    @PostMapping("/jobs")
    public ResponseEntity<Map<String, Object>> submit(@RequestBody Map<String, Object> body, @RequestAttribute(SecurityFilter.TOKEN_ATTRIBUTE) TokenRecord token,
                                                      HttpServletRequest http) {
        JobSpec spec;
        try {
            spec = JobSpec.from(body);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("code", "JOB_INVALID", "message", e.getMessage()));
        }
        // §10.1 idempotence : même runId pour le même jeton → même job
        Optional<String> existing = store.jobIdFor(token.tokenId(), spec.runId());
        if (existing.isPresent()) {
            return ResponseEntity.status(HttpStatus.ACCEPTED).body(Map.of("jobId", existing.get(), "status", "ACCEPTED"));
        }
        String jobId = "job-" + UUID.randomUUID().toString().substring(0, 8);
        store.create(jobId, token.tokenId(), spec, ServletUriComponentsBuilder.fromContextPath(http).build().toUriString(), clock.instant());
        runner.start(jobId);
        return ResponseEntity.status(HttpStatus.ACCEPTED).body(Map.of("jobId", jobId, "status", "ACCEPTED"));
    }

    @GetMapping("/jobs/{jobId}")
    public ResponseEntity<Map<String, Object>> status(@PathVariable String jobId, @RequestAttribute(SecurityFilter.TOKEN_ATTRIBUTE) TokenRecord token) {
        Optional<JobRow> job = owned(jobId, token);
        if (job.isEmpty()) {
            return notFound();
        }
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("jobId", job.get().id());
        body.put("runId", job.get().runId());
        body.put("status", contractStatus(job.get()));
        body.put("startedAt", job.get().startedAt());
        body.put("endedAt", job.get().endedAt());
        body.put("results", store.events(jobId));
        return ResponseEntity.ok(body);
    }

    @PostMapping("/jobs/{jobId}/cancel")
    public ResponseEntity<Map<String, Object>> cancel(@PathVariable String jobId, @RequestAttribute(SecurityFilter.TOKEN_ATTRIBUTE) TokenRecord token) {
        if (owned(jobId, token).isEmpty()) {
            return notFound();
        }
        runner.cancel(jobId);
        return ResponseEntity.status(HttpStatus.ACCEPTED).body(Map.of("jobId", jobId, "status", "CANCELLED"));
    }

    @GetMapping(value = "/jobs/{jobId}/logs", produces = MediaType.TEXT_PLAIN_VALUE)
    public ResponseEntity<String> logs(@PathVariable String jobId, @RequestAttribute(SecurityFilter.TOKEN_ATTRIBUTE) TokenRecord token) {
        return owned(jobId, token).isEmpty() ? ResponseEntity.status(HttpStatus.NOT_FOUND).body("Job inconnu")
                : ResponseEntity.ok(JobLog.read(runner.log(jobId)));
    }

    @GetMapping("/jobs/{jobId}/artifacts")
    public ResponseEntity<List<Map<String, Object>>> artifacts(@PathVariable String jobId, @RequestAttribute(SecurityFilter.TOKEN_ATTRIBUTE) TokenRecord token) {
        Optional<JobRow> job = owned(jobId, token);
        return job.map(j -> ResponseEntity.ok(store.artifacts(jobId).stream().map(a -> ArtifactStore.describe(a, j.baseUrl())).toList()))
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    @GetMapping("/jobs/{jobId}/artifacts/{name:.+}")
    public ResponseEntity<byte[]> artifact(@PathVariable String jobId, @PathVariable String name, @RequestAttribute(SecurityFilter.TOKEN_ATTRIBUTE) TokenRecord token) {
        return owned(jobId, token).isEmpty() ? artifactNotFound() : download(store, artifacts, jobId, name);
    }

    /** Contenu d'un artefact : jamais interprété par le navigateur (nosniff ; HTML en pièce jointe). */
    public static ResponseEntity<byte[]> download(JobStore store, ArtifactStore artifacts, String jobId, String name) {
        Optional<ArtifactRow> row = store.artifact(jobId, name);
        Optional<byte[]> content = row.flatMap(r -> artifacts.read(jobId, name));
        if (content.isEmpty()) {
            return artifactNotFound();
        }
        ResponseEntity.BodyBuilder response = ResponseEntity.ok().contentType(MediaType.parseMediaType(row.get().contentType()))
                .header("X-Content-Type-Options", "nosniff");
        if (row.get().contentType().equals("text/html")) {
            response.header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + name + "\"");
        }
        return response.body(content.get());
    }

    /** Statut du contrat : ACCEPTED, RUNNING, COMPLETED, CANCELLED (un job interrompu est terminé). */
    static String contractStatus(JobRow job) {
        return switch (job.status()) {
            case INTERRUPTED -> "COMPLETED";
            default -> job.status().name();
        };
    }

    private Optional<JobRow> owned(String jobId, TokenRecord token) {
        return store.job(jobId).filter(j -> j.tokenId().equals(token.tokenId()));
    }

    private static ResponseEntity<Map<String, Object>> notFound() {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("code", "JOB_NOT_FOUND"));
    }

    private static ResponseEntity<byte[]> artifactNotFound() {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).contentType(MediaType.APPLICATION_JSON)
                .body("{\"code\":\"ARTIFACT_NOT_FOUND\"}".getBytes(java.nio.charset.StandardCharsets.UTF_8));
    }
}
