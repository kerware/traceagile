package com.traceagile.mockserver;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.atomic.AtomicInteger;
import org.springframework.stereotype.Component;

/**
 * §10.5 déroulé d'un job : JOB_STARTED, puis pour chaque test TEST_STARTED / TEST_FINISHED après un
 * délai aléatoire, enfin JOB_FINISHED avec la synthèse. Résultat tiré selon {@code passRate} et
 * {@code errorRate} ; un identifiant contenant « @fail » échoue toujours, « @flaky » alterne.
 */
@Component
public class JobRunner {

    private final ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();
    private final Map<String, AtomicInteger> flaky = new ConcurrentHashMap<>();
    private final SimulatorProperties properties;
    private final WebhookSender webhooks;
    private final TokenStore tokens;
    private final ObjectMapper json;

    public JobRunner(SimulatorProperties properties, WebhookSender webhooks, TokenStore tokens, ObjectMapper json) {
        this.properties = properties;
        this.webhooks = webhooks;
        this.tokens = tokens;
        this.json = json;
    }

    public void start(Job job, String baseUrl) {
        executor.submit(() -> run(job, baseUrl));
    }

    /** Résultat d'un test : déterministe pour « @fail » et « @flaky », sinon tiré au sort. */
    String outcome(Map<String, Object> test) {
        String identifier = String.valueOf(test.getOrDefault("testIdentifier", "")).toLowerCase(Locale.ROOT);
        if (identifier.contains("@fail")) {
            return "FAILED";
        }
        if (identifier.contains("@flaky")) {
            return flaky.computeIfAbsent(String.valueOf(test.get("testKey")), k -> new AtomicInteger()).getAndIncrement() % 2 == 0 ? "PASSED" : "FAILED";
        }
        double draw = ThreadLocalRandom.current().nextDouble();
        return draw < properties.errorRate() ? "ERROR" : draw < properties.errorRate() + properties.passRate() ? "PASSED" : "FAILED";
    }

    private void run(Job job, String baseUrl) {
        String agent = "sim-agent-" + (1 + ThreadLocalRandom.current().nextInt(Math.max(1, properties.agents())));
        job.status("RUNNING");
        job.startedAt(Instant.now());
        job.log("Job " + job.jobId() + " (run " + job.runId() + ") pris en charge par " + agent);
        emit(job, event(job, "JOB_STARTED", Map.of("agent", agent, "startedAt", job.startedAt().toString())));
        Map<String, Integer> counts = new LinkedHashMap<>(Map.of("total", 0, "passed", 0, "failed", 0, "error", 0, "skipped", 0));
        List<Map<String, Object>> results = new ArrayList<>();
        List<ResultFormats.TestResult> formatted = new ArrayList<>();
        StringBuilder system = new StringBuilder();
        system.append(Instant.now()).append(" [system] agent=").append(agent).append(" os=").append(System.getProperty("os.name"))
                .append(' ').append(System.getProperty("os.arch")).append(" java=").append(System.getProperty("java.version"))
                .append(" processeurs=").append(Runtime.getRuntime().availableProcessors()).append('\n');
        system.append(Instant.now()).append(" [system] run=").append(job.runId()).append(" projet=").append(job.request().get("project"))
                .append(" environnement=").append(job.request().get("environment")).append(" build=").append(job.request().get("buildVersion"))
                .append(" dépôt=").append(job.request().get("repository")).append('\n');
        for (Map<String, Object> test : job.tests()) {
            if (job.cancelled()) {
                break;
            }
            String executionId = String.valueOf(test.get("executionId"));
            String key = String.valueOf(test.get("testKey"));
            emit(job, event(job, "TEST_STARTED", Map.of("executionId", executionId, "startedAt", Instant.now().toString())));
            job.log(key + " démarré (" + test.get("technique") + ", " + test.getOrDefault("testIdentifier", "") + ")");
            List<String> trace = new ArrayList<>();
            trace.add(Instant.now() + " [" + key + "] démarrage sur " + agent + " (" + test.get("framework") + ")");
            trace.add(Instant.now() + " [" + key + "] mémoire libre " + Runtime.getRuntime().freeMemory() / 1_048_576 + " Mo");
            long duration = pause();
            if (job.cancelled()) {
                break;
            }
            String status = outcome(test);
            Map<String, Object> finished = new LinkedHashMap<>();
            finished.put("executionId", executionId);
            finished.put("status", status);
            finished.put("durationMs", duration);
            if (!status.equals("PASSED")) {
                finished.put("message", status.equals("ERROR") ? "Erreur technique simulée : agent " + agent + " indisponible"
                        : "AssertionError simulée sur " + key);
                finished.put("stackTrace", "org.opentest4j.AssertionFailedError: simulated\n\tat " + key + "(Simulator.java:42)");
            }
            finished.put("steps", steps(test, status));
            finished.put("metrics", "PERFORMANCE".equals(test.get("technique"))
                    ? Map.of("p95Ms", 300 + ThreadLocalRandom.current().nextInt(700), "throughputRps", 50 + ThreadLocalRandom.current().nextInt(150))
                    : Map.of());
            trace.add(Instant.now() + " [" + key + "] terminé : " + status + " en " + duration + " ms");
            List<Map<String, Object>> testArtifacts = new ArrayList<>();
            if (status.equals("FAILED") || status.equals("ERROR")) {
                // ADR-0021 copie d'écran au moment de l'échec
                Job.Artifact screenshot = job.store("screenshot-" + key + ".png", "image/png", "SCREENSHOT", executionId,
                        Screenshots.failure(key, status.equals("ERROR")));
                testArtifacts.add(describe(job, screenshot, baseUrl));
                trace.add(Instant.now() + " [" + key + "] capture d'écran " + screenshot.name());
            }
            finished.put("artifacts", testArtifacts);
            system.append(String.join("\n", trace)).append('\n');
            if (finished.get("stackTrace") != null) {
                system.append(finished.get("stackTrace")).append('\n');
            }
            formatted.add(new ResultFormats.TestResult(key, String.valueOf(test.getOrDefault("testIdentifier", "")), String.valueOf(test.get("technique")),
                    status, duration, (String) finished.get("message"), (String) finished.get("stackTrace"), trace));
            emit(job, event(job, "TEST_FINISHED", finished));
            job.log(key + " terminé : " + status + " en " + duration + " ms");
            results.add(Map.of("testKey", key, "status", status, "durationMs", duration));
            counts.merge("total", 1, Integer::sum);
            counts.merge(switch (status) {
                case "PASSED" -> "passed";
                case "FAILED" -> "failed";
                case "ERROR" -> "error";
                default -> "skipped";
            }, 1, Integer::sum);
        }
        job.endedAt(Instant.now());
        system.append(job.endedAt()).append(" [system] fin du job ").append(job.jobId()).append(" : ").append(counts).append('\n');
        // ADR-0021 traces système, résultats JUnit XML et Jest JSON, synthèse
        List<Map<String, Object>> jobArtifacts = new ArrayList<>();
        jobArtifacts.add(describe(job, job.store("system.log", "text/plain", "SYSTEM_TRACE", null, system.toString().getBytes(StandardCharsets.UTF_8)), baseUrl));
        jobArtifacts.add(describe(job, job.store("junit.xml", "application/xml", "JUNIT", null,
                ResultFormats.junit(job.runId(), formatted, job.startedAt()).getBytes(StandardCharsets.UTF_8)), baseUrl));
        jobArtifacts.add(describe(job, job.store("jest.json", "application/json", "JEST", null,
                ResultFormats.jest(json, formatted, job.startedAt()).getBytes(StandardCharsets.UTF_8)), baseUrl));
        jobArtifacts.add(describe(job, job.store("report.json", "application/json", "REPORT", null,
                toJson(Map.of("jobId", job.jobId(), "runId", job.runId(), "summary", counts, "results", results)).getBytes(StandardCharsets.UTF_8)), baseUrl));
        if (job.cancelled()) {
            job.status("CANCELLED");
            job.log("Job annulé");
            return;
        }
        job.log("Job terminé : " + counts);
        Map<String, Object> end = new LinkedHashMap<>();
        end.put("status", "COMPLETED");
        end.put("endedAt", job.endedAt().toString());
        end.put("summary", counts);
        end.put("reportUrl", baseUrl + "/api/v1/jobs/" + job.jobId() + "/artifacts/report.json");
        end.put("logsUrl", baseUrl + "/api/v1/jobs/" + job.jobId() + "/logs");
        end.put("artifacts", jobArtifacts);
        // JOB_FINISHED est visible au plus tard quand le job passe à COMPLETED (lecture par polling)
        Map<String, Object> finished = event(job, "JOB_FINISHED", end);
        job.record(finished);
        job.status("COMPLETED");
        tokens.byId(job.tokenId()).ifPresent(token -> webhooks.send(job.callbackUrl(), token.webhookSecret(), finished));
    }

    /** ADR-0021 description d'un artefact (liste, événements). */
    static Map<String, Object> describe(Job job, Job.Artifact artifact, String baseUrl) {
        Map<String, Object> description = new LinkedHashMap<>();
        description.put("name", artifact.name());
        description.put("type", artifact.type());
        description.put("kind", artifact.kind());
        description.put("size", artifact.content().length);
        if (artifact.executionId() != null) {
            description.put("executionId", artifact.executionId());
        }
        description.put("url", baseUrl + "/api/v1/jobs/" + job.jobId() + "/artifacts/" + artifact.name());
        return description;
    }

    /** BDD : statut par étape du Gherkin (la dernière échoue en cas d'échec). */
    private static List<Map<String, String>> steps(Map<String, Object> test, String status) {
        Object source = test.get("gherkinSource");
        if (source == null) {
            return List.of();
        }
        List<String> lines = String.valueOf(source).lines().map(String::strip)
                .filter(l -> l.matches("(?i)^(Soit|Étant donné|Etant donné|Quand|Lorsque|Alors|Et|Mais|Given|When|Then|And|But)\\b.*")).toList();
        List<Map<String, String>> steps = new ArrayList<>();
        for (int i = 0; i < lines.size(); i++) {
            boolean last = i == lines.size() - 1;
            steps.add(Map.of("name", lines.get(i), "status", last && !status.equals("PASSED") ? "failed" : "passed"));
        }
        return steps;
    }

    private Map<String, Object> event(Job job, String type, Map<String, Object> fields) {
        Map<String, Object> event = new LinkedHashMap<>();
        event.put("eventId", UUID.randomUUID().toString());
        event.put("event", type);
        event.put("runId", job.runId());
        event.put("jobId", job.jobId());
        event.put("occurredAt", Instant.now().toString());
        event.putAll(fields);
        return event;
    }

    private void emit(Job job, Map<String, Object> event) {
        job.record(event);
        tokens.byId(job.tokenId()).ifPresent(token -> webhooks.send(job.callbackUrl(), token.webhookSecret(), event));
    }

    private long pause() {
        long min = Math.max(0, properties.minDelayMs());
        long max = Math.max(min, properties.maxDelayMs());
        long delay = min == max ? min : ThreadLocalRandom.current().nextLong(min, max + 1);
        try {
            Thread.sleep(delay);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        return delay;
    }

    private String toJson(Object value) {
        try {
            return json.writeValueAsString(value);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
    }
}
