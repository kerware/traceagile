package com.traceagile.executionserver.job.executor;

import com.traceagile.executionserver.job.JobSpec.TestSpec;
import com.traceagile.executionserver.process.ProcessRunner;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * Playwright Test : {@code npx playwright test <fichier> --grep <titre>} avec le rapporteur JUnit. Le
 * titre est l'identifiant du test (« Describe › titre », comme dans le rapport JUnit de Playwright) ;
 * si le fichier n'existe pas dans le dépôt (test BDD généré), seul le titre filtre.
 */
@Component
@Order(10)
public class PlaywrightExecutor implements TestExecutor {

    @Override
    public String name() {
        return "Playwright";
    }

    @Override
    public Set<String> frameworks() {
        return Set.of("Playwright");
    }

    @Override
    public boolean accepts(TestSpec test, Path workspace) {
        String path = test.path() == null ? "" : test.path();
        return path.matches(".*\\.(spec|test)\\.(ts|js|mjs|cjs|tsx)$") && NodeProjects.uses(project(test, workspace), "@playwright/test");
    }

    @Override
    public Path project(TestSpec test, Path workspace) {
        return TestExecutor.nearest(workspace, test.path(), "package.json");
    }

    @Override
    public ProcessRunner.Result prepare(ExecutionContext context, Path project) {
        ProcessRunner.Result install = NodeProjects.install(context, project);
        if (install.succeeded()) {
            // navigateurs de la version de Playwright du dépôt (cache partagé dans le dossier des outils)
            context.run("npx playwright install chromium", project);
        }
        return install;
    }

    @Override
    public TestOutcome execute(ExecutionContext context, TestSpec test, Path project, Path output) {
        StringBuilder command = new StringBuilder("npx playwright test");
        if (TestExecutor.exists(project, test.path())) {
            command.append(' ').append(ExecutionContext.quote(ExecutionContext.relative(project, project.resolve(test.path()).normalize())));
        }
        if (test.testIdentifier() != null) {
            command.append(" --grep ").append(ExecutionContext.quote(grep(test.testIdentifier())));
        }
        Path results = output.resolve("results");
        command.append(" --reporter=junit --retries=0 --output ").append(ExecutionContext.quote(results.toString()));
        Path junit = output.resolve("junit.xml");
        ProcessRunner.Result result = context.run(command.toString(), project, Map.of("PLAYWRIGHT_JUNIT_OUTPUT_NAME", junit.toString()));
        return TestExecutor.outcome(result, JUnitReports.read(junit), test.testIdentifier(), TestExecutor.files(results, ".png"), List.of(), Map.of());
    }

    /** « Panier › visualise le panier » → titre complet de Playwright (segments séparés par une espace). */
    static String grep(String identifier) {
        return Arrays.stream(identifier.split("\\s+›\\s+")).map(String::strip).map(NodeProjects::exact).collect(Collectors.joining(" "));
    }
}
