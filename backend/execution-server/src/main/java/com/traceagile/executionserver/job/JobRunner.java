package com.traceagile.executionserver.job;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.executionserver.ServerProperties;
import com.traceagile.executionserver.job.JobSpec.TestSpec;
import com.traceagile.executionserver.job.JobStore.ArtifactRow;
import com.traceagile.executionserver.job.JobStore.JobRow;
import com.traceagile.executionserver.job.JobStore.JobStatus;
import com.traceagile.executionserver.job.JobStore.TestRow;
import com.traceagile.executionserver.job.executor.ExecutionContext;
import com.traceagile.executionserver.job.executor.ExecutorRegistry;
import com.traceagile.executionserver.job.executor.TestExecutor;
import com.traceagile.executionserver.job.executor.TestOutcome;
import com.traceagile.executionserver.process.Cancellation;
import com.traceagile.executionserver.process.ProcessRunner;
import com.traceagile.executionserver.process.ToolEnvironment;
import com.traceagile.executionserver.token.TokenService;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.locks.ReentrantLock;
import java.util.function.Consumer;
import java.util.function.Function;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

/**
 * §10.3 / §10.4 déroulé d'un job : JOB_STARTED, clone du dépôt, puis pour chaque test (en parallèle,
 * au plus {@code parallelism} par job et {@code agents} pour tout le serveur) TEST_STARTED, préparation
 * du projet (une fois), exécution par l'adaptateur du framework avec nouvelles tentatives,
 * TEST_FINISHED avec métriques et copies d'écran ; enfin JOB_FINISHED avec la synthèse et les
 * artefacts du job (traces système, JUnit XML, rapport JSON).
 */
@Service
public class JobRunner {

    private static final Logger LOG = LoggerFactory.getLogger(JobRunner.class);

    private final JobStore store;
    private final TokenService tokens;
    private final ArtifactStore artifacts;
    private final WebhookSender webhooks;
    private final ExecutorRegistry executors;
    private final GitWorkspace git;
    private final ProcessRunner processes;
    private final ToolEnvironment tools;
    private final ServerProperties properties;
    private final Clock clock;
    private final ObjectMapper json;
    private final Semaphore agents;
    private final AtomicInteger busy = new AtomicInteger();
    private final ExecutorService pool = Executors.newVirtualThreadPerTaskExecutor();
    private final Map<String, Cancellation> running = new ConcurrentHashMap<>();

    public JobRunner(JobStore store, TokenService tokens, ArtifactStore artifacts, WebhookSender webhooks, ExecutorRegistry executors, GitWorkspace git,
                     ProcessRunner processes, ToolEnvironment tools, ServerProperties properties, Clock clock, ObjectMapper json) {
        this.store = store;
        this.tokens = tokens;
        this.artifacts = artifacts;
        this.webhooks = webhooks;
        this.executors = executors;
        this.git = git;
        this.processes = processes;
        this.tools = tools;
        this.properties = properties;
        this.clock = clock;
        this.json = json;
        this.agents = new Semaphore(properties.agents(), true);
    }

    public Future<?> start(String jobId) {
        return pool.submit(() -> {
            try {
                run(jobId);
            } catch (RuntimeException e) {
                LOG.error("Job {} interrompu par une erreur", jobId, e);
                store.finished(jobId, JobStatus.INTERRUPTED, clock.instant(), "Erreur interne : " + e.getMessage());
            }
        });
    }

    /** F-EXE-08 annulation : processus arrêtés, tests restants « ignorés », JOB_FINISHED CANCELLED. */
    public boolean cancel(String jobId) {
        Cancellation cancellation = running.get(jobId);
        if (cancellation == null) {
            return false;
        }
        cancellation.cancel();
        return true;
    }

    public int busyAgents() {
        return busy.get();
    }

    public int runningJobs() {
        return running.size();
    }

    public Path log(String jobId) {
        return properties.jobsDir().resolve(jobId).resolve("job.log");
    }

    // --------------------------------------------------------------------------------------------- job

    private void run(String jobId) {
        JobRow job = store.job(jobId).orElseThrow();
        Cancellation cancellation = new Cancellation();
        running.put(jobId, cancellation);
        JobLog log = new JobLog(log(jobId), clock);
        try {
            Instant start = clock.instant();
            String agent = properties.serverName() + "@" + host();
            store.started(jobId, agent, start);
            log.line("Job " + jobId + " (run " + job.runId() + ", projet " + job.project() + ", campagne " + job.campaign() + ") sur " + agent);
            log.line("Système : " + tools.platform() + " " + System.getProperty("os.arch") + ", Java " + System.getProperty("java.version")
                    + ", " + Runtime.getRuntime().availableProcessors() + " processeurs ; parallélisme " + job.parallelism() + " ; agents " + properties.agents());
            emit(job, "JOB_STARTED", Map.of("agent", agent, "startedAt", start.toString()));

            Map<String, String> environment = new LinkedHashMap<>(tools.variables());
            environment.put("TRACEAGILE_RUN_ID", job.runId());
            putIfPresent(environment, "TRACEAGILE_PROJECT", job.project());
            putIfPresent(environment, "TRACEAGILE_CAMPAIGN", job.campaign());
            putIfPresent(environment, "TRACEAGILE_ENVIRONMENT", job.environment());
            putIfPresent(environment, "TRACEAGILE_BUILD", job.buildVersion());
            Instant deadline = start.plus(job.timeoutMinutes(), ChronoUnit.MINUTES);
            // ADR-0030 un espace de travail par dépôt : celui du job (« workspace »), puis ceux propres à des tests
            List<TestRow> rows = store.tests(jobId);
            Map<String, Workspace> workspaces = new LinkedHashMap<>();
            Function<String[], Workspace> workspace = repo -> workspaces.computeIfAbsent(repo[0] + "|" + repo[1], key -> {
                String name = workspaces.isEmpty() ? "workspace" : "workspace-" + (workspaces.size() + 1);
                Path dir = properties.jobsDir().resolve(jobId).resolve(name).toAbsolutePath().normalize();
                ExecutionContext context = new ExecutionContext(dir, environment, tools.platform(), processes, cancellation, deadline, log::line);
                String error = git.prepare(context, jobId, repo[0], repo[1]);
                if (error != null) {
                    log.line(error);
                }
                return new Workspace(context, error);
            });
            workspace.apply(new String[] {job.repositoryUrl(), job.branch()});

            Shared shared = new Shared(new Semaphore(job.parallelism()), new ConcurrentHashMap<>(), new ConcurrentHashMap<>());
            List<Future<?>> tests = new ArrayList<>();
            for (TestRow test : rows) {
                TestSpec spec = test.spec();
                Workspace own = spec.repositoryUrl() == null ? workspace.apply(new String[] {job.repositoryUrl(), job.branch()})
                        : workspace.apply(new String[] {spec.repositoryUrl(), spec.branch()});
                tests.add(pool.submit(() -> runTest(job, test, own.context(), own.error(), shared, log)));
            }
            for (Future<?> test : tests) {
                try {
                    test.get();
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    cancellation.cancel();
                } catch (java.util.concurrent.ExecutionException e) {
                    log.line("Erreur interne d'un test : " + e.getCause());
                }
            }
            finish(job, cancellation.cancelled() ? JobStatus.CANCELLED : JobStatus.COMPLETED, log, null);
        } finally {
            running.remove(jobId);
        }
    }

    /** Espace de travail d'un dépôt du job et l'erreur de son clone ({@code null} s'il est prêt). */
    private record Workspace(ExecutionContext context, String error) {
    }

    private record Shared(Semaphore slots, Map<String, CompletableFuture<ProcessRunner.Result>> prepared, Map<Path, ReentrantLock> locks) {
    }

    private void runTest(JobRow job, TestRow test, ExecutionContext jobContext, String workspaceError, Shared shared, JobLog log) {
        TestSpec spec = test.spec();
        boolean slot = false;
        boolean agent = false;
        try {
            shared.slots().acquire();
            slot = true;
            agents.acquire();
            agent = true;
            busy.incrementAndGet();
            if (jobContext.cancellation().cancelled()) {
                finishTest(job, test, new TestOutcome("SKIPPED", "Job annulé", null, Map.of(), List.of(), List.of()), 0, 0, null, log);
                return;
            }
            Instant started = clock.instant();
            store.testStarted(test.id(), started);
            emit(job, "TEST_STARTED", Map.of("executionId", spec.executionId(), "startedAt", started.toString()));
            StringBuilder testLog = new StringBuilder();
            Consumer<String> output = line -> {
                log.line("[" + spec.testKey() + "] " + line);
                synchronized (testLog) {
                    if (testLog.length() < 2_000_000) {
                        testLog.append(line).append('\n');
                    }
                }
            };
            output.accept("Démarrage : " + spec.label() + (spec.framework() == null ? "" : " — " + spec.framework()));
            TestOutcome outcome;
            int attempts = 0;
            if (workspaceError != null) {
                outcome = TestOutcome.error(workspaceError);
            } else {
                Optional<TestExecutor> executor = executors.resolve(spec, jobContext.workspace());
                if (executor.isEmpty()) {
                    outcome = TestOutcome.error("Aucun exécuteur pour « " + (spec.framework() == null ? "framework non précisé" : spec.framework()) + " »"
                            + (spec.path() == null ? "" : " (" + spec.path() + ")") + " : précisez le framework du test dans TraceAgile ou installez l'outil.");
                } else {
                    ExecutionContext context = new ExecutionContext(jobContext.workspace(), testEnvironment(jobContext, spec), jobContext.platform(),
                            jobContext.processes(), jobContext.cancellation(), jobContext.deadline(), output);
                    int[] counter = {0};
                    outcome = execute(executor.get(), context, spec, job, shared, output, counter);
                    attempts = counter[0];
                }
            }
            output.accept("Résultat : " + outcome.status() + (outcome.message() == null ? "" : " — " + outcome.message()));
            finishTest(job, test, outcome, attempts, Duration.between(started, clock.instant()).toMillis(), testLog.toString(), log);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } finally {
            if (agent) {
                busy.decrementAndGet();
                agents.release();
            }
            if (slot) {
                shared.slots().release();
            }
        }
    }

    private TestOutcome execute(TestExecutor executor, ExecutionContext context, TestSpec spec, JobRow job, Shared shared, Consumer<String> output,
                                int[] attempts) {
        Path project = executor.project(spec, context.workspace());
        output.accept("Exécuteur " + executor.name() + ", projet " + ExecutionContext.relative(context.workspace(), project).replaceFirst("^$", "."));
        ProcessRunner.Result prepared = shared.prepared().computeIfAbsent(executor.name() + "|" + project,
                key -> CompletableFuture.supplyAsync(() -> executor.prepare(context, project), pool)).join();
        if (!prepared.succeeded()) {
            return prepared.cancelled() ? new TestOutcome("SKIPPED", "Job annulé", null, Map.of(), List.of(), List.of())
                    : TestOutcome.error("Préparation du projet impossible (" + executor.name() + ") : " + TestExecutor.lastLines(prepared.output(), 4));
        }
        ReentrantLock lock = executor.exclusive() ? shared.locks().computeIfAbsent(project, p -> new ReentrantLock(true)) : null;
        if (lock != null) {
            lock.lock();
        }
        try {
            TestOutcome outcome = null;
            for (int attempt = 1; attempt <= 1 + job.retryFailed(); attempt++) {
                attempts[0] = attempt;
                if (attempt > 1) {
                    output.accept("Nouvelle tentative " + attempt + "/" + (1 + job.retryFailed()));
                }
                Path out = properties.jobsDir().resolve(job.id()).resolve("tests").resolve(safe(spec.testKey()) + "-" + attempt).toAbsolutePath();
                try {
                    Files.createDirectories(out);
                } catch (IOException e) {
                    return TestOutcome.error("Dossier de résultats impossible : " + e.getMessage());
                }
                // ADR-0026 convention : tout test peut déposer captures et metrics.json dans TRACEAGILE_OUTPUT_DIR
                Map<String, String> env = new LinkedHashMap<>(context.environment());
                env.put("TRACEAGILE_OUTPUT_DIR", out.toString());
                ExecutionContext attemptContext = new ExecutionContext(context.workspace(), env, context.platform(), context.processes(),
                        context.cancellation(), context.deadline(), context.log());
                outcome = withMetrics(executor.execute(attemptContext, spec, project, out), out.resolve("metrics.json"));
                if (outcome.passed() || context.cancellation().cancelled() || "SKIPPED".equals(outcome.status())) {
                    break;
                }
            }
            return outcome;
        } finally {
            if (lock != null) {
                lock.unlock();
            }
        }
    }

    /** Métriques numériques déposées par le test (metrics.json), sans remplacer celles de l'adaptateur. */
    private TestOutcome withMetrics(TestOutcome outcome, Path file) {
        if (!Files.isRegularFile(file)) {
            return outcome;
        }
        Map<String, Double> metrics = new LinkedHashMap<>();
        try {
            json.readTree(file.toFile()).fields().forEachRemaining(field -> {
                if (field.getValue().isNumber()) {
                    metrics.put(field.getKey(), field.getValue().asDouble());
                }
            });
        } catch (IOException e) {
            return outcome;
        }
        metrics.putAll(outcome.metrics());
        return new TestOutcome(outcome.status(), outcome.message(), outcome.stackTrace(), metrics, outcome.screenshots(), outcome.attachments());
    }

    /** Paramètres et ligne de jeu de données du test : variables TRACEAGILE_PARAM_NOM ; « jdk » choisit le JDK. */
    private Map<String, String> testEnvironment(ExecutionContext job, TestSpec spec) {
        Map<String, String> env = new LinkedHashMap<>(tools.withJdk(job.environment(), spec.parameter("jdk")));
        env.put("TRACEAGILE_TEST_KEY", spec.testKey());
        env.put("TRACEAGILE_EXECUTION_ID", spec.executionId());
        Map<String, Object> values = new LinkedHashMap<>(spec.parameters());
        values.putAll(spec.dataSet());
        values.forEach((name, value) -> env.put("TRACEAGILE_PARAM_" + name.toUpperCase(Locale.ROOT).replaceAll("[^A-Z0-9]", "_"), String.valueOf(value)));
        return env;
    }

    private void finishTest(JobRow job, TestRow test, TestOutcome outcome, int attempts, long durationMs, String testLog, JobLog log) {
        TestSpec spec = test.spec();
        List<Map<String, Object>> described = new ArrayList<>();
        int index = 0;
        for (Path screenshot : outcome.screenshots()) {
            String name = "screenshot-" + safe(spec.testKey()) + (index++ == 0 ? "" : "-" + index) + extension(screenshot);
            artifacts.copy(job.id(), screenshot, name, "SCREENSHOT", spec.executionId()).ifPresent(a -> described.add(ArtifactStore.describe(a, job.baseUrl())));
        }
        for (Path attachment : outcome.attachments()) {
            artifacts.copy(job.id(), attachment, safe(spec.testKey()) + "-" + attachment.getFileName(), "REPORT", spec.executionId())
                    .ifPresent(a -> described.add(ArtifactStore.describe(a, job.baseUrl())));
        }
        if (testLog != null && !testLog.isBlank()) {
            ArtifactRow logFile = artifacts.store(job.id(), "log-" + safe(spec.testKey()) + ".txt", "SYSTEM_TRACE", spec.executionId(),
                    testLog.getBytes(StandardCharsets.UTF_8));
            described.add(ArtifactStore.describe(logFile, job.baseUrl()));
        }
        Instant ended = clock.instant();
        store.testFinished(test.id(), outcome.status(), attempts, durationMs, outcome.message(), outcome.metrics(), ended);
        Map<String, Object> finished = new LinkedHashMap<>();
        finished.put("executionId", spec.executionId());
        finished.put("status", outcome.status());
        finished.put("durationMs", durationMs);
        if (outcome.message() != null) {
            finished.put("message", outcome.message());
        }
        if (outcome.stackTrace() != null) {
            finished.put("stackTrace", outcome.stackTrace().length() > 20_000 ? outcome.stackTrace().substring(0, 20_000) : outcome.stackTrace());
        }
        finished.put("metrics", outcome.metrics());
        finished.put("attempts", attempts);
        finished.put("artifacts", described);
        emit(job, "TEST_FINISHED", finished);
        log.line("[" + spec.testKey() + "] terminé : " + outcome.status() + " en " + durationMs + " ms");
    }

    private void finish(JobRow job, JobStatus status, JobLog log, String error) {
        Instant ended = clock.instant();
        store.finished(job.id(), status, ended, error);
        JobRow done = store.job(job.id()).orElseThrow();
        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("total", done.total());
        summary.put("passed", done.passed());
        summary.put("failed", done.failed());
        summary.put("error", done.errored());
        summary.put("skipped", done.skipped());
        log.line("Job terminé (" + status + ") : " + summary);
        List<TestRow> tests = store.tests(job.id());
        List<Map<String, Object>> results = tests.stream().map(t -> {
            Map<String, Object> result = new LinkedHashMap<>();
            result.put("testKey", t.spec().testKey());
            result.put("status", t.status());
            result.put("durationMs", t.durationMs() == null ? 0 : t.durationMs());
            result.put("attempts", t.attempts());
            if (t.message() != null) {
                result.put("message", t.message());
            }
            return result;
        }).toList();
        List<Map<String, Object>> described = new ArrayList<>();
        artifacts.copy(job.id(), log.file(), "system.log", "SYSTEM_TRACE", null).ifPresent(a -> described.add(ArtifactStore.describe(a, job.baseUrl())));
        described.add(ArtifactStore.describe(artifacts.store(job.id(), "junit.xml", "JUNIT", null,
                JunitWriter.write(job.runId(), tests).getBytes(StandardCharsets.UTF_8)), job.baseUrl()));
        described.add(ArtifactStore.describe(artifacts.store(job.id(), "report.json", "REPORT", null,
                toJson(Map.of("jobId", job.id(), "runId", job.runId(), "status", status.name(), "summary", summary, "results", results))
                        .getBytes(StandardCharsets.UTF_8)), job.baseUrl()));
        Map<String, Object> end = new LinkedHashMap<>();
        end.put("status", status == JobStatus.CANCELLED ? "CANCELLED" : "COMPLETED");
        end.put("endedAt", ended.toString());
        end.put("summary", summary);
        end.put("reportUrl", job.baseUrl() + "/api/v1/jobs/" + job.id() + "/artifacts/report.json");
        end.put("logsUrl", job.baseUrl() + "/api/v1/jobs/" + job.id() + "/logs");
        end.put("artifacts", described);
        emit(job, "JOB_FINISHED", end);
    }

    /** Enregistre l'événement (polling) puis l'envoie à TraceAgile, signé avec le secret du jeton. */
    private void emit(JobRow job, String type, Map<String, Object> fields) {
        Map<String, Object> event = new LinkedHashMap<>();
        event.put("eventId", java.util.UUID.randomUUID().toString());
        event.put("event", type);
        event.put("runId", job.runId());
        event.put("jobId", job.id());
        event.put("occurredAt", clock.instant().toString());
        event.putAll(fields);
        store.event(job.id(), event, clock.instant());
        tokens.byId(job.tokenId()).ifPresent(token -> webhooks.send(job.callbackUrl(), token.webhookSecret(), event));
    }

    // ------------------------------------------------------------------------------ reprise, rétention

    /** Un job en cours lors d'un arrêt du serveur : tests restants en erreur, JOB_FINISHED envoyé. */
    @EventListener(ApplicationReadyEvent.class)
    public void recover() {
        for (JobRow job : store.unfinished()) {
            JobLog log = new JobLog(log(job.id()), clock);
            log.line("Serveur redémarré pendant le job : tests non terminés en erreur");
            for (TestRow test : store.tests(job.id())) {
                if (test.status().equals("PENDING") || test.status().equals("RUNNING")) {
                    finishTest(job, test, TestOutcome.error("Serveur d'exécution redémarré pendant le test"), 0, 0, null, log);
                }
            }
            finish(job, JobStatus.INTERRUPTED, log, "Serveur redémarré pendant le job");
        }
    }

    /** Chaque nuit : espaces de travail et artefacts des jobs terminés depuis plus de {@code retentionDays} jours supprimés. */
    @Scheduled(cron = "0 30 3 * * *")
    public void purge() {
        Instant limit = clock.instant().minus(properties.retentionDays(), ChronoUnit.DAYS);
        for (String jobId : store.finishedBefore(limit)) {
            Path directory = properties.jobsDir().resolve(jobId);
            if (Files.exists(directory)) {
                deleteTree(directory);
                store.forgetArtifacts(jobId);
            }
        }
    }

    static void deleteTree(Path directory) {
        try (var files = Files.walk(directory)) {
            files.sorted(java.util.Comparator.reverseOrder()).forEach(p -> p.toFile().delete());
        } catch (IOException e) {
            LOG.warn("Suppression de {} incomplète : {}", directory, e.getMessage());
        }
    }

    private static void putIfPresent(Map<String, String> env, String key, String value) {
        if (value != null) {
            env.put(key, value);
        }
    }

    static String safe(String text) {
        return text == null ? "test" : text.replaceAll("[^A-Za-z0-9_-]", "_");
    }

    private static String extension(Path file) {
        String name = file.getFileName().toString();
        int dot = name.lastIndexOf('.');
        return dot < 0 ? ".png" : name.substring(dot).toLowerCase(Locale.ROOT);
    }

    private static String host() {
        try {
            return java.net.InetAddress.getLocalHost().getHostName();
        } catch (java.net.UnknownHostException e) {
            return "localhost";
        }
    }

    private String toJson(Object value) {
        try {
            return json.writeValueAsString(value);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
    }
}
