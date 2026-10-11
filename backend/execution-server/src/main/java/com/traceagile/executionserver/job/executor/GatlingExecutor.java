package com.traceagile.executionserver.job.executor;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.executionserver.job.JobSpec.TestSpec;
import com.traceagile.executionserver.process.ProcessRunner;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Stream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * Gatling : plugin Maven du projet ({@code mvn gatling:test}) ou, sans pom.xml, bundle installé par le
 * serveur. L'identifiant est la classe de simulation. Les statistiques du rapport (stats.json) donnent
 * les métriques p95Ms, throughputRps et koRequests ; les assertions non satisfaites rendent le test
 * en échec ; le rapport HTML est joint en archive.
 */
@Component
@Order(30)
public class GatlingExecutor implements TestExecutor {

    private final ObjectMapper json;

    public GatlingExecutor(ObjectMapper json) {
        this.json = json;
    }

    @Override
    public String name() {
        return "Gatling";
    }

    @Override
    public Set<String> frameworks() {
        return Set.of("Gatling");
    }

    @Override
    public Path project(TestSpec test, Path workspace) {
        return TestExecutor.nearest(workspace, test.path(), "pom.xml");
    }

    @Override
    public boolean exclusive() {
        return true;
    }

    @Override
    public TestOutcome execute(ExecutionContext context, TestSpec test, Path project, Path output) {
        if (test.testIdentifier() == null) {
            return TestOutcome.error("Classe de simulation Gatling absente (identifiant du test).");
        }
        Path results;
        ProcessRunner.Result result;
        if (Files.exists(project.resolve("pom.xml"))) {
            results = project.resolve("target").resolve("gatling");
            result = context.run(MavenExecutor.MVN + " gatling:test -Dgatling.simulationClass=" + ExecutionContext.quote(test.testIdentifier()), project);
        } else {
            results = output.resolve("gatling");
            Path simulations = test.path() == null ? project : context.workspace().resolve(test.path()).normalize();
            if (!Files.isDirectory(simulations)) {
                simulations = simulations.getParent();
            }
            String launcher = context.platform().windows() ? "gatling.bat" : "gatling.sh";
            result = context.run(launcher + " -sf " + ExecutionContext.quote(simulations.toString()) + " -s " + ExecutionContext.quote(test.testIdentifier())
                    + " -rf " + ExecutionContext.quote(results.toString()) + " -rm local", project);
        }
        Optional<Path> report = latestReport(results);
        Map<String, Double> metrics = report.map(dir -> metrics(dir.resolve("js").resolve("stats.json"))).orElse(Map.of());
        List<Path> attachments = report.map(dir -> zip(dir, output.resolve("gatling-" + MavenExecutor.safe(test.testKey()) + ".zip"))).stream().toList();
        if (result.cancelled() || result.timedOut() || report.isEmpty()) {
            return TestExecutor.outcome(result, List.of(), null, List.of(), attachments, metrics);
        }
        if (result.exitCode() == 0) {
            return new TestOutcome("PASSED", null, null, metrics, List.of(), attachments);
        }
        return new TestOutcome("FAILED", "Assertions Gatling non satisfaites : " + TestExecutor.lastLines(result.output(), 4), null, metrics, List.of(),
                attachments);
    }

    /** Dossier de rapport le plus récent (celui qui contient js/stats.json). */
    static Optional<Path> latestReport(Path results) {
        if (!Files.isDirectory(results)) {
            return Optional.empty();
        }
        try (Stream<Path> dirs = Files.list(results)) {
            return dirs.filter(d -> Files.exists(d.resolve("js").resolve("stats.json")))
                    .max(Comparator.comparing(d -> d.toFile().lastModified()));
        } catch (IOException e) {
            return Optional.empty();
        }
    }

    /** stats.json : percentiles3 = 95e centile, débit moyen, requêtes en échec. */
    Map<String, Double> metrics(Path stats) {
        Map<String, Double> metrics = new LinkedHashMap<>();
        try {
            JsonNode root = json.readTree(stats.toFile());
            JsonNode s = root.path("stats");
            put(metrics, "p95Ms", s.path("percentiles3").path("total"));
            put(metrics, "meanMs", s.path("meanResponseTime").path("total"));
            put(metrics, "throughputRps", s.path("meanNumberOfRequestsPerSecond").path("total"));
            put(metrics, "koRequests", s.path("numberOfRequests").path("ko"));
        } catch (IOException e) {
            return metrics;
        }
        return metrics;
    }

    private static void put(Map<String, Double> metrics, String name, JsonNode value) {
        if (value.isNumber()) {
            metrics.put(name, value.asDouble());
        } else if (value.isTextual()) {
            try {
                metrics.put(name, Double.parseDouble(value.asText()));
            } catch (NumberFormatException e) {
                // valeur absente (« - ») : non remontée
            }
        }
    }

    static Path zip(Path directory, Path target) {
        try (OutputStream out = Files.newOutputStream(target); ZipOutputStream zip = new ZipOutputStream(out); Stream<Path> files = Files.walk(directory)) {
            for (Path file : files.filter(Files::isRegularFile).toList()) {
                zip.putNextEntry(new ZipEntry(directory.relativize(file).toString().replace('\\', '/')));
                Files.copy(file, zip);
                zip.closeEntry();
            }
            return target;
        } catch (IOException e) {
            return null;
        }
    }
}
