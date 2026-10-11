package com.traceagile.executionserver.job.executor;

import com.traceagile.executionserver.job.JobSpec.TestSpec;
import com.traceagile.executionserver.process.ProcessRunner;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * Cucumber-JS : un scénario Gherkin (transmis par TraceAgile ou fichier .feature du dépôt) joué avec
 * les définitions d'étapes du projet ; filtre par nom de scénario, rapport JUnit.
 */
@Component
@Order(70)
public class CucumberJsExecutor implements TestExecutor {

    @Override
    public String name() {
        return "Cucumber-JS";
    }

    @Override
    public Set<String> frameworks() {
        return Set.of("Cucumber-JS");
    }

    @Override
    public boolean accepts(TestSpec test, Path workspace) {
        boolean gherkin = test.gherkinSource() != null || test.path() != null && test.path().endsWith(".feature");
        return gherkin && NodeProjects.uses(project(test, workspace), "@cucumber/cucumber");
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
        Path feature;
        try {
            if (test.gherkinSource() != null) {
                feature = project.resolve("features").resolve("traceagile").resolve(MavenExecutor.safe(test.testKey()) + ".feature");
                Files.createDirectories(feature.getParent());
                Files.writeString(feature, test.gherkinSource());
            } else if (TestExecutor.exists(context.workspace(), test.path())) {
                feature = context.workspace().resolve(test.path()).normalize();
            } else {
                return TestOutcome.error("Scénario Gherkin absent : ni source transmise ni fichier .feature dans le dépôt.");
            }
        } catch (IOException e) {
            return TestOutcome.error("Écriture du scénario impossible : " + e.getMessage());
        }
        Path junit = output.resolve("junit.xml");
        String command = "npx cucumber-js " + ExecutionContext.quote(ExecutionContext.relative(project, feature))
                + (test.testIdentifier() == null ? "" : " --name " + ExecutionContext.quote("^" + NodeProjects.exact(test.testIdentifier()) + "$"))
                + " --format " + ExecutionContext.quote("junit:" + junit);
        ProcessRunner.Result result = context.run(command, project);
        return TestExecutor.outcome(result, JUnitReports.read(junit), test.testIdentifier(), TestExecutor.files(output, ".png"), List.of(), Map.of());
    }
}
