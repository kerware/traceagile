package com.traceagile.mockserver;

import com.traceagile.mockserver.TokenStore.TokenRecord;
import jakarta.servlet.http.HttpServletRequest;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
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

/** §10.2 capacités, soumission (idempotente par runId), statut (polling), annulation, journaux, artefacts. */
@RestController
@RequestMapping("/api/v1")
public class JobController {

    private final Map<String, Job> jobs = new ConcurrentHashMap<>();
    private final Map<String, String> jobByRun = new ConcurrentHashMap<>();
    private final JobRunner runner;
    private final SimulatorProperties properties;

    public JobController(JobRunner runner, SimulatorProperties properties) {
        this.runner = runner;
        this.properties = properties;
    }

    @GetMapping("/capabilities")
    public Map<String, Object> capabilities() {
        return Map.of("techniques", properties.techniques(), "frameworks", properties.frameworks(),
                "environments", properties.environments(), "agents", properties.agents());
    }

    @PostMapping("/jobs")
    public ResponseEntity<Map<String, Object>> submit(@RequestBody Map<String, Object> request,
                                                      @RequestAttribute(SecurityFilter.TOKEN_ATTRIBUTE) TokenRecord token, HttpServletRequest http) {
        Object runId = request.get("runId");
        Object tests = request.get("tests");
        if (runId == null || request.get("callbackUrl") == null || !(tests instanceof List<?> list) || list.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("code", "JOB_INVALID", "message", "runId, callbackUrl et au moins un test sont obligatoires."));
        }
        // §10.1 idempotence : même runId (pour le même jeton) → même job
        String runKey = token.tokenId() + "/" + runId;
        String existing = jobByRun.get(runKey);
        if (existing != null) {
            return ResponseEntity.status(HttpStatus.ACCEPTED).body(Map.of("jobId", existing, "status", "ACCEPTED"));
        }
        Job job = new Job("job-" + UUID.randomUUID().toString().substring(0, 8), token.tokenId(), request);
        jobs.put(job.jobId(), job);
        jobByRun.put(runKey, job.jobId());
        runner.start(job, ServletUriComponentsBuilder.fromContextPath(http).build().toUriString());
        return ResponseEntity.status(HttpStatus.ACCEPTED).body(Map.of("jobId", job.jobId(), "status", "ACCEPTED"));
    }

    @GetMapping("/jobs/{jobId}")
    public ResponseEntity<Map<String, Object>> status(@PathVariable String jobId, @RequestAttribute(SecurityFilter.TOKEN_ATTRIBUTE) TokenRecord token) {
        Job job = owned(jobId, token);
        if (job == null) {
            return notFound();
        }
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("jobId", job.jobId());
        body.put("runId", job.runId());
        body.put("status", job.status());
        body.put("startedAt", job.startedAt());
        body.put("endedAt", job.endedAt());
        body.put("results", job.events());
        return ResponseEntity.ok(body);
    }

    @PostMapping("/jobs/{jobId}/cancel")
    public ResponseEntity<Map<String, Object>> cancel(@PathVariable String jobId, @RequestAttribute(SecurityFilter.TOKEN_ATTRIBUTE) TokenRecord token) {
        Job job = owned(jobId, token);
        if (job == null) {
            return notFound();
        }
        job.cancel();
        return ResponseEntity.status(HttpStatus.ACCEPTED).body(Map.of("jobId", jobId, "status", "CANCELLED"));
    }

    @GetMapping(value = "/jobs/{jobId}/logs", produces = MediaType.TEXT_PLAIN_VALUE)
    public ResponseEntity<String> logs(@PathVariable String jobId, @RequestAttribute(SecurityFilter.TOKEN_ATTRIBUTE) TokenRecord token) {
        Job job = owned(jobId, token);
        return job == null ? ResponseEntity.status(HttpStatus.NOT_FOUND).body("Job inconnu") : ResponseEntity.ok(job.logs());
    }

    /** ADR-0021 artefacts du job : traces système, JUnit XML, Jest JSON, rapport, copies d'écran. */
    @GetMapping("/jobs/{jobId}/artifacts")
    public ResponseEntity<List<Map<String, Object>>> artifacts(@PathVariable String jobId, @RequestAttribute(SecurityFilter.TOKEN_ATTRIBUTE) TokenRecord token,
                                                               HttpServletRequest http) {
        Job job = owned(jobId, token);
        if (job == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
        String baseUrl = ServletUriComponentsBuilder.fromContextPath(http).build().toUriString();
        return ResponseEntity.ok(job.artifacts().stream().map(a -> JobRunner.describe(job, a, baseUrl)).toList());
    }

    @GetMapping("/jobs/{jobId}/artifacts/{name:.+}")
    public ResponseEntity<byte[]> artifact(@PathVariable String jobId, @PathVariable String name,
                                           @RequestAttribute(SecurityFilter.TOKEN_ATTRIBUTE) TokenRecord token) {
        Job job = owned(jobId, token);
        Job.Artifact artifact = job == null ? null : job.artifact(name);
        if (artifact == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).contentType(MediaType.APPLICATION_JSON)
                    .body("{\"code\":\"ARTIFACT_NOT_FOUND\"}".getBytes(java.nio.charset.StandardCharsets.UTF_8));
        }
        return ResponseEntity.ok().contentType(MediaType.parseMediaType(artifact.type())).body(artifact.content());
    }

    /** Un jeton ne voit que ses propres jobs. */
    private Job owned(String jobId, TokenRecord token) {
        Job job = jobs.get(jobId);
        return job != null && job.tokenId().equals(token.tokenId()) ? job : null;
    }

    private static ResponseEntity<Map<String, Object>> notFound() {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("code", "JOB_NOT_FOUND"));
    }
}
