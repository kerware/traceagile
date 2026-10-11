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
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * Tests Java par Maven (JUnit 5, REST Assured, Selenium Java, Cucumber-JVM…) : {@code mvn test
 * -Dtest=Classe#méthode}. Un test BDD dont le Gherkin vient de TraceAgile est écrit dans le projet et
 * joué par le moteur Cucumber seul. Les tests d'un même projet passent l'un après l'autre (dossier
 * target partagé).
 */
@Component
@Order(40)
public class MavenExecutor implements TestExecutor {

    static final String MVN = "mvn -B -ntp";

    @Override
    public String name() {
        return "Maven";
    }

    @Override
    public Set<String> frameworks() {
        return Set.of("JUnit 5", "REST Assured", "Cucumber-JVM", "Spring Cloud Contract", "Kotest", "Pact");
    }

    @Override
    public boolean handles(TestSpec test, Path workspace) {
        if ("Selenium".equalsIgnoreCase(test.framework()) && test.path() != null && test.path().endsWith(".java")) {
            return true;
        }
        return TestExecutor.super.handles(test, workspace);
    }

    @Override
    public boolean accepts(TestSpec test, Path workspace) {
        String path = test.path() == null ? "" : test.path().toLowerCase(Locale.ROOT);
        if (path.endsWith(".java") || path.endsWith(".kt")) {
            return true;
        }
        // BDD sans framework : projet Maven avec Cucumber
        return (test.gherkinSource() != null || path.endsWith(".feature")) && TestExecutor.contains(project(test, workspace).resolve("pom.xml"), "cucumber");
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
    public ProcessRunner.Result prepare(ExecutionContext context, Path project) {
        if (!Files.exists(project.resolve("pom.xml"))) {
            context.log().accept("Aucun pom.xml dans " + project);
            return new ProcessRunner.Result(1, false, false, "pom.xml introuvable");
        }
        return context.run(MVN + " -q -DskipTests test-compile", project);
    }

    @Override
    public TestOutcome execute(ExecutionContext context, TestSpec test, Path project, Path output) {
        Path surefire = project.resolve("target").resolve("surefire-reports");
        clear(surefire);
        String command;
        if (cucumber(test)) {
            Path feature = feature(test, project, context.workspace());
            if (feature == null) {
                return TestOutcome.error("Scénario Gherkin absent : ni source transmise ni fichier .feature dans le dépôt.");
            }
            command = MVN + " test -Dsurefire.includeJUnit5Engines=cucumber -Dsurefire.failIfNoSpecifiedTests=false"
                    + " -Dcucumber.features=" + ExecutionContext.quote(feature.toString())
                    + " -Dcucumber.plugin=" + ExecutionContext.quote("junit:" + output.resolve("cucumber.xml"))
                    + (test.testIdentifier() == null ? "" : " -Dcucumber.filter.name=" + ExecutionContext.quote("^" + NodeProjects.exact(test.testIdentifier()) + "$"));
        } else {
            command = MVN + " test -Dtest=" + ExecutionContext.quote(selector(test)) + " -Dsurefire.failIfNoSpecifiedTests=false -DfailIfNoTests=false";
        }
        ProcessRunner.Result result = context.run(command, project);
        copy(surefire, output.resolve("surefire"));
        List<JUnitReports.Case> cases = new ArrayList<>(JUnitReports.read(output));
        String identifier = cucumber(test) ? test.testIdentifier() : test.testIdentifier() == null ? selector(test) : test.testIdentifier();
        return TestExecutor.outcome(result, cases, identifier, TestExecutor.files(output, ".png"), List.of(), Map.of());
    }

    static boolean cucumber(TestSpec test) {
        return test.gherkinSource() != null || "Cucumber-JVM".equalsIgnoreCase(test.framework())
                || test.path() != null && test.path().toLowerCase(Locale.ROOT).endsWith(".feature");
    }

    /** -Dtest : identifiant « Classe#méthode » ; à défaut, la classe du fichier. */
    static String selector(TestSpec test) {
        if (test.testIdentifier() != null && !test.testIdentifier().isBlank()) {
            return test.testIdentifier().strip();
        }
        String file = Path.of(test.path() == null ? "Test" : test.path()).getFileName().toString();
        int dot = file.lastIndexOf('.');
        return dot > 0 ? file.substring(0, dot) : file;
    }

    /** Scénario à jouer : Gherkin transmis par TraceAgile (écrit dans le projet) ou fichier du dépôt. */
    static Path feature(TestSpec test, Path project, Path workspace) {
        try {
            if (test.gherkinSource() != null) {
                Path file = project.resolve("target").resolve("traceagile-features").resolve(safe(test.testKey()) + ".feature");
                Files.createDirectories(file.getParent());
                Files.writeString(file, test.gherkinSource());
                return file;
            }
        } catch (IOException e) {
            return null;
        }
        Path file = test.path() == null ? null : workspace.resolve(test.path()).normalize();
        return file != null && Files.exists(file) ? file : null;
    }

    static String safe(String text) {
        return text == null ? "test" : text.replaceAll("[^A-Za-z0-9_-]", "_");
    }

    private static void clear(Path directory) {
        if (!Files.isDirectory(directory)) {
            return;
        }
        try (Stream<Path> files = Files.list(directory)) {
            files.filter(Files::isRegularFile).forEach(f -> f.toFile().delete());
        } catch (IOException e) {
            // rapports précédents laissés en place : la sélection par identifiant les écarte
        }
    }

    static void copy(Path from, Path to) {
        if (!Files.isDirectory(from)) {
            return;
        }
        try (Stream<Path> files = Files.list(from)) {
            Files.createDirectories(to);
            for (Path file : files.filter(f -> f.toString().endsWith(".xml")).toList()) {
                Files.copy(file, to.resolve(file.getFileName()), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException e) {
            // rapport non copié : le code de retour décide
        }
    }
}
