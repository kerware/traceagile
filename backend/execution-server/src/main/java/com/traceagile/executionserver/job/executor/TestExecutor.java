package com.traceagile.executionserver.job.executor;

import com.traceagile.executionserver.job.JobSpec.TestSpec;
import com.traceagile.executionserver.process.ProcessRunner;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Stream;

/**
 * ADR-0026 adaptateur d'un framework de test : il sait reconnaître un test, préparer le projet une
 * fois par job (dépendances) et lancer le test seul, rapport JUnit XML à l'appui.
 */
public interface TestExecutor {

    /** Nom affiché (journal, interface). */
    String name();

    /** Frameworks de TraceAgile pris en charge (comparaison sans casse). */
    Set<String> frameworks();

    /** Le test est pour cet exécuteur sans framework déclaré (extension du fichier, Gherkin…). */
    default boolean accepts(TestSpec test, Path workspace) {
        return false;
    }

    /** Dossier du projet du test (racine contenant package.json, pom.xml…), dans l'espace de travail. */
    Path project(TestSpec test, Path workspace);

    /** Préparation commune aux tests du même projet (une fois par job). */
    default ProcessRunner.Result prepare(ExecutionContext context, Path project) {
        return new ProcessRunner.Result(0, false, false, "");
    }

    /** Les tests d'un même projet ne peuvent pas s'exécuter en même temps (Maven : dossier target partagé). */
    default boolean exclusive() {
        return false;
    }

    /** Exécute le test ; {@code output} est le dossier propre à ce test (rapports, captures). */
    TestOutcome execute(ExecutionContext context, TestSpec test, Path project, Path output);

    // ----------------------------------------------------------------------------------- utilitaires

    default boolean handles(TestSpec test, Path workspace) {
        String framework = test.framework() == null ? "" : test.framework().strip().toLowerCase(Locale.ROOT);
        if (!framework.isEmpty() && frameworks().stream().anyMatch(f -> f.toLowerCase(Locale.ROOT).equals(framework))) {
            return true;
        }
        return accepts(test, workspace);
    }

    /** Plus proche dossier, du fichier du test jusqu'à l'espace de travail, contenant {@code marker}. */
    static Path nearest(Path workspace, String path, String marker) {
        Path root = workspace.toAbsolutePath().normalize();
        if (path != null && !path.isBlank()) {
            Path current = root.resolve(path).normalize();
            if (!current.startsWith(root)) {
                return root;
            }
            if (!Files.isDirectory(current)) {
                current = current.getParent();
            }
            while (current != null && current.startsWith(root)) {
                if (Files.exists(current.resolve(marker))) {
                    return current;
                }
                current = current.getParent();
            }
        }
        return root;
    }

    /** Le fichier du test existe dans le projet (sinon, filtre par nom seulement). */
    static boolean exists(Path workspace, String path) {
        if (path == null || path.isBlank()) {
            return false;
        }
        Path root = workspace.toAbsolutePath().normalize();
        Path file = root.resolve(path).normalize();
        return file.startsWith(root) && Files.exists(file);
    }

    static boolean contains(Path file, String text) {
        try {
            return Files.isRegularFile(file) && Files.readString(file).contains(text);
        } catch (IOException e) {
            return false;
        }
    }

    /** Fichiers d'extension donnée sous un dossier (copies d'écran). */
    static List<Path> files(Path directory, String... extensions) {
        List<Path> found = new ArrayList<>();
        if (directory == null || !Files.isDirectory(directory)) {
            return found;
        }
        try (Stream<Path> walk = Files.walk(directory)) {
            walk.filter(Files::isRegularFile).filter(f -> {
                String name = f.getFileName().toString().toLowerCase(Locale.ROOT);
                for (String extension : extensions) {
                    if (name.endsWith(extension)) {
                        return true;
                    }
                }
                return false;
            }).sorted().forEach(found::add);
        } catch (IOException e) {
            return found;
        }
        return found;
    }

    /**
     * Résultat à partir des rapports JUnit et du code de retour : le rapport fait foi pour les cas de
     * l'identifiant ; sans rapport, code 0 = réussi, sinon échec (ou erreur si le délai est dépassé).
     */
    static TestOutcome outcome(ProcessRunner.Result result, List<JUnitReports.Case> cases, String identifier, List<Path> screenshots,
                               List<Path> attachments, Map<String, Double> metrics) {
        if (result.cancelled()) {
            return new TestOutcome("SKIPPED", "Job annulé", null, metrics, screenshots, attachments);
        }
        if (result.timedOut()) {
            return new TestOutcome("ERROR", "Délai du job dépassé", null, metrics, screenshots, attachments);
        }
        List<JUnitReports.Case> matching = JUnitReports.matching(cases, identifier);
        String status = JUnitReports.status(matching);
        if (status == null) {
            if (result.exitCode() == 0) {
                return new TestOutcome("PASSED", null, null, metrics, screenshots, attachments);
            }
            return new TestOutcome(result.exitCode() < 0 ? "ERROR" : "FAILED", "Code de retour " + result.exitCode() + " sans rapport de test : "
                    + lastLines(result.output(), 6), null, metrics, screenshots, attachments);
        }
        JUnitReports.Case problem = matching.stream().filter(c -> c.status().equals("FAILED") || c.status().equals("ERROR")).findFirst().orElse(null);
        return new TestOutcome(status, problem == null ? null : problem.message(), problem == null ? null : problem.stackTrace(), metrics,
                screenshots, attachments);
    }

    static String lastLines(String output, int count) {
        if (output == null || output.isBlank()) {
            return "aucune sortie";
        }
        List<String> lines = output.strip().lines().toList();
        return String.join(" / ", lines.subList(Math.max(0, lines.size() - count), lines.size()));
    }
}
