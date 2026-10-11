package com.traceagile.executionserver.tool;

import com.traceagile.executionserver.ServerProperties;
import com.traceagile.executionserver.process.Cancellation;
import com.traceagile.executionserver.process.Platform;
import com.traceagile.executionserver.process.ProcessRunner;
import com.traceagile.executionserver.process.ToolEnvironment;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Service;

/**
 * ADR-0026 détection et installation des outils. Une seule installation à la fois (les installateurs
 * npm et pip ne supportent pas les écritures concurrentes) ; chaque installation a son journal.
 */
@Service
public class ToolService {

    public enum Status { INSTALLED, MISSING, INSTALLING, QUEUED, FAILED }

    /** Résultat de la dernière détection. */
    public record Detection(boolean installed, String version, String output, Instant checkedAt) {
    }

    /** État d'un outil pour l'interface. */
    public record ToolState(ToolDefinition tool, Status status, String version, String message, boolean installable, Instant checkedAt,
                            Instant installStartedAt, Instant installEndedAt, List<String> missingDependencies, String script) {
    }

    /** Étape d'un plan d'installation : outil, état, action (INSTALL, NONE, MANUAL). */
    public record PlanStep(String toolId, String name, Status status, String action, String help) {
    }

    public static class ToolException extends RuntimeException {
        private final String code;

        public ToolException(String code, String message) {
            super(message);
            this.code = code;
        }

        public String code() {
            return code;
        }
    }

    private static final Logger LOG = LoggerFactory.getLogger(ToolService.class);
    private static final DateTimeFormatter STAMP = DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss").withZone(java.time.ZoneOffset.UTC);

    private final ToolCatalog catalog;
    private final ProcessRunner processes;
    private final ToolEnvironment environment;
    private final ServerProperties properties;
    private final JdbcClient db;
    private final Clock clock;
    private final Map<String, Detection> detections = new ConcurrentHashMap<>();
    private final Set<String> queued = ConcurrentHashMap.newKeySet();
    private final ExecutorService installer = Executors.newSingleThreadExecutor(Thread.ofVirtual().name("installer").factory());

    public ToolService(ToolCatalog catalog, ProcessRunner processes, ToolEnvironment environment, ServerProperties properties, JdbcClient db, Clock clock) {
        this.catalog = catalog;
        this.processes = processes;
        this.environment = environment;
        this.properties = properties;
        this.db = db;
        this.clock = clock;
    }

    /** Au démarrage : une installation interrompue par un arrêt est en échec ; détection de tous les outils. */
    @EventListener(ApplicationReadyEvent.class)
    public void onStart() {
        db.sql("update tool_installs set status = 'FAILED', message = 'Installation interrompue par l''arrêt du serveur' where status in ('INSTALLING', 'QUEUED')").update();
        Thread.ofVirtual().name("detection").start(this::detectAll);
    }

    public void detectAll() {
        catalog.all().forEach(t -> detect(t.id()));
    }

    public Detection detect(String id) {
        ToolDefinition tool = tool(id);
        StringBuilder out = new StringBuilder();
        ProcessRunner.Result result = processes.run(new ProcessRunner.Command(platform().shell(detectCommand(tool)), null,
                environment.variables(), Duration.ofSeconds(60)), line -> out.append(line).append('\n'), Cancellation.none());
        // certaines commandes de version sortent avec un code non nul (robot --version : 251) : seule la version compte
        String version = result.timedOut() ? null : tool.version(out.toString());
        Detection detection = new Detection(version != null, version, out.toString().strip(), clock.instant());
        detections.put(id, detection);
        return detection;
    }

    public List<ToolState> states() {
        return catalog.all().stream().map(this::state).toList();
    }

    public ToolState state(String id) {
        return state(tool(id));
    }

    private ToolState state(ToolDefinition tool) {
        Detection detection = detections.get(tool.id());
        Optional<Map<String, Object>> install = db.sql("select status, version, message, started_at, ended_at from tool_installs where tool_id = ?")
                .param(tool.id()).query().listOfRows().stream().findFirst();
        Status status = detection != null && detection.installed() ? Status.INSTALLED : Status.MISSING;
        String message = null;
        if (install.isPresent()) {
            Status recorded = Status.valueOf((String) install.get().get("STATUS"));
            if (recorded == Status.INSTALLING || recorded == Status.QUEUED || recorded == Status.FAILED && status != Status.INSTALLED) {
                status = recorded;
            }
            message = (String) install.get().get("MESSAGE");
        }
        List<String> missing = tool.dependencies().stream().filter(d -> !installed(d)).toList();
        return new ToolState(tool, status, detection == null ? null : detection.version(), message, tool.installable(platform()),
                detection == null ? null : detection.checkedAt(), instant(install.map(r -> r.get("STARTED_AT")).orElse(null)),
                instant(install.map(r -> r.get("ENDED_AT")).orElse(null)), missing, tool.installable(platform()) ? script(tool) : null);
    }

    public boolean installed(String id) {
        Detection detection = detections.get(id);
        return detection != null && detection.installed();
    }

    /** Frameworks utilisables : ceux des outils détectés (capacités annoncées à TraceAgile). */
    public List<String> frameworks() {
        Set<String> frameworks = new LinkedHashSet<>();
        catalog.all().stream().filter(t -> installed(t.id())).forEach(t -> frameworks.addAll(t.frameworks()));
        if (installed("node")) {
            frameworks.add("Cucumber-JS");
        }
        return List.copyOf(frameworks);
    }

    /**
     * Assistant : outils à installer, dans l'ordre, pour exécuter les frameworks demandés ; les prérequis
     * absents sont signalés (installation manuelle).
     */
    public List<PlanStep> plan(List<String> frameworks) {
        Set<String> wanted = new LinkedHashSet<>();
        for (String framework : frameworks) {
            catalog.all().stream().filter(t -> !t.prerequisite() && t.frameworks().contains(framework)).findFirst().ifPresent(t -> wanted.add(t.id()));
            if (framework.equals("Cucumber-JS")) {
                wanted.add("node");
            }
            if (framework.equals("Gatling")) {
                wanted.add("maven");
            }
        }
        List<String> ordered = new ArrayList<>();
        wanted.forEach(id -> order(id, ordered, new LinkedHashSet<>()));
        return ordered.stream().map(this::state).map(s -> new PlanStep(s.tool().id(), s.tool().name(), s.status(),
                s.status() == Status.INSTALLED ? "NONE" : s.tool().prerequisite() || !s.installable() ? "MANUAL" : "INSTALL", s.tool().help())).toList();
    }

    private void order(String id, List<String> ordered, Set<String> visiting) {
        if (ordered.contains(id) || !visiting.add(id)) {
            return;
        }
        tool(id).dependencies().forEach(d -> order(d, ordered, visiting));
        ordered.add(id);
    }

    /**
     * Met l'outil (et, si demandé, ses dépendances manquantes) en file d'installation.
     *
     * @return les outils mis en file, dans l'ordre
     */
    public List<String> install(String id, boolean withDependencies) {
        ToolDefinition tool = tool(id);
        if (!tool.installable(platform())) {
            throw new ToolException("TOOL_NOT_INSTALLABLE", tool.name() + " est un prérequis de la machine : " + tool.help());
        }
        List<String> ordered = new ArrayList<>();
        order(id, ordered, new LinkedHashSet<>());
        List<String> toInstall = new ArrayList<>();
        for (String step : ordered) {
            ToolDefinition current = tool(step);
            boolean target = step.equals(id);
            if (!target && installed(step)) {
                continue;
            }
            if (!target && (current.prerequisite() || !current.installable(platform()))) {
                throw new ToolException("PREREQUISITE_MISSING", current.name() + " est nécessaire à " + tool.name() + " : " + current.help());
            }
            if (!target && !withDependencies) {
                throw new ToolException("DEPENDENCY_MISSING", current.name() + " doit être installé avant " + tool.name() + ".");
            }
            toInstall.add(step);
        }
        for (String step : toInstall) {
            if (!queued.add(step)) {
                continue;
            }
            record(step, Status.QUEUED, null, null);
            installer.submit(() -> runInstall(tool(step)));
        }
        return toInstall;
    }

    private void runInstall(ToolDefinition tool) {
        Path log = properties.toolLogsDir().resolve(tool.id() + "-" + STAMP.format(clock.instant()) + ".log");
        try {
            Files.createDirectories(log.getParent());
            Files.createDirectories(environment.tools());
            record(tool.id(), Status.INSTALLING, null, log);
            append(log, "# " + tool.name() + " — " + platform() + " — " + clock.instant());
            append(log, "$ " + script(tool));
            ProcessRunner.Result result = processes.run(new ProcessRunner.Command(platform().script(script(tool)), environment.tools(),
                    environment.variables(), Duration.ofMinutes(30)), line -> append(log, line), Cancellation.none());
            Detection detection = detect(tool.id());
            if (result.succeeded() && detection.installed()) {
                append(log, "# Installé : version " + detection.version());
                record(tool.id(), Status.INSTALLED, null, log);
                LOG.info("Outil {} installé (version {})", tool.id(), detection.version());
            } else {
                String message = result.timedOut() ? "Délai d'installation dépassé (30 min)"
                        : !result.succeeded() ? "L'installation a échoué (code " + result.exitCode() + ") : voir le journal"
                        : "Installation terminée mais l'outil n'est pas détecté : " + detection.output();
                append(log, "# " + message);
                record(tool.id(), Status.FAILED, message, log);
                LOG.warn("Outil {} : {}", tool.id(), message);
            }
        } catch (IOException | UncheckedIOException e) {
            record(tool.id(), Status.FAILED, "Journal d'installation impossible : " + e.getMessage(), log);
        } finally {
            queued.remove(tool.id());
        }
    }

    /** Journal de la dernière installation (fin du fichier, 200 000 caractères au plus). */
    public String log(String id) {
        tool(id);
        String file = db.sql("select log_file from tool_installs where tool_id = ?").param(id).query(String.class).optional().orElse(null);
        if (file == null || !Files.exists(Path.of(file))) {
            return "";
        }
        try {
            String content = Files.readString(Path.of(file), StandardCharsets.UTF_8);
            return content.length() > 200_000 ? content.substring(content.length() - 200_000) : content;
        } catch (IOException e) {
            return "Journal illisible : " + e.getMessage();
        }
    }

    /** Commande de détection, jetons remplacés (Windows : « ls » devient « dir /b »). */
    String detectCommand(ToolDefinition tool) {
        String command = substitute(tool.detect());
        if (platform().windows()) {
            command = command.replace("python3 --version || ", "").replaceFirst("^ls ", "dir /b ").replace('/', '\\');
        }
        return command;
    }

    String script(ToolDefinition tool) {
        return substitute(tool.script(platform()));
    }

    private String substitute(String text) {
        String tools = environment.tools().toString();
        String python = environment.pythonExecutable("python").toString();
        if (!platform().windows()) {
            tools = tools.replace('\\', '/');
            python = python.replace('\\', '/');
        }
        return text.replace("{tools}", tools).replace("{python}", python).replace("{os}", platform().adoptiumOs())
                .replace("{arch}", Platform.arch()).replace("{strip}", platform() == Platform.MAC ? "3" : "1");
    }

    private Platform platform() {
        return environment.platform();
    }

    private ToolDefinition tool(String id) {
        return catalog.find(id).orElseThrow(() -> new ToolException("TOOL_NOT_FOUND", "Outil inconnu : " + id));
    }

    private void record(String id, Status status, String message, Path log) {
        Timestamp now = Timestamp.from(clock.instant());
        int updated = db.sql("update tool_installs set status = ?, message = ?, log_file = coalesce(?, log_file),"
                        + " started_at = case when ? = 'INSTALLING' then ? else started_at end,"
                        + " ended_at = case when ? in ('INSTALLED', 'FAILED') then ? else null end where tool_id = ?")
                .params(status.name(), message, log == null ? null : log.toString(), status.name(), now, status.name(), now, id).update();
        if (updated == 0) {
            db.sql("insert into tool_installs (tool_id, status, message, log_file, started_at, ended_at) values (?, ?, ?, ?, ?, ?)")
                    .params(id, status.name(), message, log == null ? null : log.toString(), status == Status.INSTALLING ? now : null,
                            status == Status.INSTALLED || status == Status.FAILED ? now : null)
                    .update();
        }
    }

    private static void append(Path log, String line) {
        try {
            Files.writeString(log, line + System.lineSeparator(), StandardCharsets.UTF_8, StandardOpenOption.CREATE, StandardOpenOption.APPEND);
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    private static Instant instant(Object value) {
        if (value instanceof Timestamp timestamp) {
            return timestamp.toInstant();
        }
        if (value instanceof java.time.OffsetDateTime offset) {
            return offset.toInstant();
        }
        return null;
    }
}
