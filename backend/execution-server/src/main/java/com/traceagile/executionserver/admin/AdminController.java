package com.traceagile.executionserver.admin;

import com.traceagile.executionserver.ServerProperties;
import com.traceagile.executionserver.job.ArtifactStore;
import com.traceagile.executionserver.job.JobController;
import com.traceagile.executionserver.job.JobLog;
import com.traceagile.executionserver.job.JobRunner;
import com.traceagile.executionserver.job.JobStore;
import com.traceagile.executionserver.job.JobStore.JobRow;
import com.traceagile.executionserver.process.Platform;
import com.traceagile.executionserver.process.ToolEnvironment;
import com.traceagile.executionserver.tool.ToolService;
import com.traceagile.executionserver.tool.ToolService.ToolException;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Instant;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * ADR-0026 API de l'interface d'administration (HTTP Basic de l'administrateur du serveur) :
 * tableau de bord, jobs, outils et assistant d'installation, dépôts Git, paramètres, journal du serveur.
 * Les jetons passent par {@code /api/v1/tokens} (même contrat que pour TraceAgile).
 */
@RestController
@RequestMapping("/api/admin")
public class AdminController {

    public record JobDetail(JobRow job, List<JobStore.TestRow> tests, List<JobStore.ArtifactRow> artifacts) {
    }

    public record GitCredentialView(String host, String username, Instant updatedAt) {
    }

    public record GitCredentialRequest(@NotBlank @Size(max = 200) String host, @NotBlank @Size(max = 120) String username,
                                       @NotBlank @Size(max = 500) String secret) {
    }

    public record Settings(String serverName, String version, String platform, String architecture, String javaVersion, int agents, int retentionDays,
                           String dataDir, String toolsDir, String adminUser) {
    }

    private final StatsService stats;
    private final JobStore jobs;
    private final JobRunner runner;
    private final ArtifactStore artifacts;
    private final ToolService tools;
    private final GitCredentialService git;
    private final ServerProperties properties;
    private final ToolEnvironment environment;

    public AdminController(StatsService stats, JobStore jobs, JobRunner runner, ArtifactStore artifacts, ToolService tools, GitCredentialService git,
                           ServerProperties properties, ToolEnvironment environment) {
        this.stats = stats;
        this.jobs = jobs;
        this.runner = runner;
        this.artifacts = artifacts;
        this.tools = tools;
        this.git = git;
        this.properties = properties;
        this.environment = environment;
    }

    /** Vérifie les identifiants de l'interface. */
    @GetMapping("/me")
    public Map<String, String> me() {
        return Map.of("user", properties.adminUser(), "serverName", properties.serverName());
    }

    @GetMapping("/dashboard")
    public StatsService.Dashboard dashboard() {
        return stats.dashboard();
    }

    // ---------------------------------------------------------------------------------------- jobs

    @GetMapping("/jobs")
    public List<JobRow> jobs(@RequestParam(required = false) String status, @RequestParam(required = false) String q,
                             @RequestParam(defaultValue = "200") int limit) {
        return jobs.jobs(status == null || status.isBlank() ? null : status, q, Math.max(1, Math.min(limit, 1000)));
    }

    @GetMapping("/jobs/{jobId}")
    public ResponseEntity<JobDetail> job(@PathVariable String jobId) {
        return jobs.job(jobId).map(j -> ResponseEntity.ok(new JobDetail(j, jobs.tests(jobId), jobs.artifacts(jobId))))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping(value = "/jobs/{jobId}/logs", produces = MediaType.TEXT_PLAIN_VALUE)
    public String jobLogs(@PathVariable String jobId) {
        return JobLog.read(runner.log(jobId));
    }

    @PostMapping("/jobs/{jobId}/cancel")
    public ResponseEntity<Map<String, Object>> cancel(@PathVariable String jobId) {
        return runner.cancel(jobId) ? ResponseEntity.accepted().body(Map.of("jobId", jobId, "status", "CANCELLING"))
                : ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("code", "JOB_NOT_RUNNING", "message", "Le job n'est pas en cours."));
    }

    @GetMapping("/jobs/{jobId}/artifacts/{name:.+}")
    public ResponseEntity<byte[]> artifact(@PathVariable String jobId, @PathVariable String name) {
        return JobController.download(jobs, artifacts, jobId, name);
    }

    // --------------------------------------------------------------------------------------- outils

    @GetMapping("/tools")
    public List<ToolService.ToolState> tools() {
        return tools.states();
    }

    @PostMapping("/tools/detect")
    public List<ToolService.ToolState> detectAll() {
        tools.detectAll();
        return tools.states();
    }

    @PostMapping("/tools/{id}/detect")
    public ToolService.ToolState detect(@PathVariable String id) {
        tools.detect(id);
        return tools.state(id);
    }

    @PostMapping("/tools/{id}/install")
    public ResponseEntity<Map<String, Object>> install(@PathVariable String id, @RequestParam(defaultValue = "true") boolean withDependencies) {
        return ResponseEntity.accepted().body(Map.of("queued", tools.install(id, withDependencies)));
    }

    @GetMapping(value = "/tools/{id}/log", produces = MediaType.TEXT_PLAIN_VALUE)
    public String toolLog(@PathVariable String id) {
        return tools.log(id);
    }

    /** Assistant : plan d'installation pour les frameworks utilisés par les projets. */
    @GetMapping("/tools/plan")
    public List<ToolService.PlanStep> plan(@RequestParam List<String> frameworks) {
        return tools.plan(frameworks);
    }

    // ---------------------------------------------------------------------------------- dépôts Git

    @GetMapping("/git-credentials")
    public List<GitCredentialView> credentials() {
        return git.list().stream().map(c -> new GitCredentialView(c.host(), c.username(), c.updatedAt())).toList();
    }

    @PutMapping("/git-credentials")
    public ResponseEntity<Void> saveCredential(@Valid @RequestBody GitCredentialRequest request) {
        git.save(request.host(), request.username(), request.secret());
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/git-credentials/{host}")
    public ResponseEntity<Void> deleteCredential(@PathVariable String host) {
        return git.delete(host) ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();
    }

    // ------------------------------------------------------------------------------ paramètres, journal

    @GetMapping("/settings")
    public Settings settings() {
        String version = AdminController.class.getPackage().getImplementationVersion();
        return new Settings(properties.serverName(), version == null ? "dev" : version, Platform.current().name(), System.getProperty("os.arch"),
                System.getProperty("java.version"), properties.agents(), properties.retentionDays(), properties.dataDir().toAbsolutePath().normalize().toString(),
                environment.tools().toString(), properties.adminUser());
    }

    /** Fin du journal du serveur, filtrée par niveau (ERROR, WARN, INFO) si demandé. */
    @GetMapping(value = "/logs", produces = MediaType.TEXT_PLAIN_VALUE)
    public String logs(@RequestParam(defaultValue = "500") int lines, @RequestParam(required = false) String level) {
        Path file = properties.dataDir().resolve("logs").resolve("execution-server.log");
        if (!Files.exists(file)) {
            return "";
        }
        try {
            List<String> all = Files.readAllLines(file, StandardCharsets.UTF_8);
            List<String> filtered = level == null || level.isBlank() ? all
                    : all.stream().filter(l -> Arrays.stream(level.split(",")).anyMatch(lv -> l.contains(" " + lv.strip() + " "))).toList();
            return String.join("\n", filtered.subList(Math.max(0, filtered.size() - Math.max(1, Math.min(lines, 5000))), filtered.size()));
        } catch (IOException e) {
            return "Journal illisible : " + e.getMessage();
        }
    }

    @ExceptionHandler(ToolException.class)
    public ResponseEntity<Map<String, String>> toolError(ToolException e) {
        HttpStatus status = e.code().equals("TOOL_NOT_FOUND") ? HttpStatus.NOT_FOUND : HttpStatus.UNPROCESSABLE_ENTITY;
        return ResponseEntity.status(status).body(Map.of("code", e.code(), "message", e.getMessage()));
    }
}
