package com.traceagile.executionserver.job.executor;

import com.traceagile.executionserver.job.JobSpec.TestSpec;
import com.traceagile.executionserver.process.ProcessRunner;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * Cypress : {@code npx cypress run --spec <fichier>} avec le rapporteur JUnit intégré ; Cypress ne
 * filtre pas par titre, le résultat est lu sur le cas du rapport qui porte l'identifiant.
 */
@Component
@Order(20)
public class CypressExecutor implements TestExecutor {

    @Override
    public String name() {
        return "Cypress";
    }

    @Override
    public Set<String> frameworks() {
        return Set.of("Cypress");
    }

    @Override
    public boolean accepts(TestSpec test, Path workspace) {
        return test.path() != null && test.path().matches(".*\\.cy\\.(ts|js|tsx|jsx)$");
    }

    @Override
    public Path project(TestSpec test, Path workspace) {
        return TestExecutor.nearest(workspace, test.path(), "package.json");
    }

    @Override
    public ProcessRunner.Result prepare(ExecutionContext context, Path project) {
        return NodeProjects.install(context, project);
    }

    @Override
    public TestOutcome execute(ExecutionContext context, TestSpec test, Path project, Path output) {
        if (!TestExecutor.exists(project, test.path())) {
            return TestOutcome.error("Fichier de test Cypress introuvable dans le dépôt : " + test.path());
        }
        Path screenshots = output.resolve("screenshots");
        String command = "npx cypress run --spec " + ExecutionContext.quote(ExecutionContext.relative(project, project.resolve(test.path()).normalize()))
                + " --reporter junit --reporter-options " + ExecutionContext.quote("mochaFile=" + output.resolve("junit-[hash].xml"))
                + " --config " + ExecutionContext.quote("screenshotsFolder=" + screenshots + ",video=false");
        ProcessRunner.Result result = context.run(command, project);
        return TestExecutor.outcome(result, JUnitReports.read(output), test.testIdentifier(), TestExecutor.files(screenshots, ".png"), List.of(), Map.of());
    }
}
