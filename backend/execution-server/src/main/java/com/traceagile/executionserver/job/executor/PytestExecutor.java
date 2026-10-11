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
 * pytest (tests Selenium Python, API avec requests) : l'identifiant est le nœud pytest
 * (« tests/test_panier.py::test_retrait ») ou un nom filtré par {@code -k}. Les captures enregistrées
 * dans le dossier {@code TRACEAGILE_OUTPUT_DIR} par le test sont jointes.
 */
@Component
@Order(60)
public class PytestExecutor implements TestExecutor {

    @Override
    public String name() {
        return "pytest";
    }

    @Override
    public Set<String> frameworks() {
        return Set.of("pytest", "pytest + requests", "Selenium", "Behave");
    }

    @Override
    public boolean handles(TestSpec test, Path workspace) {
        if ("Selenium".equalsIgnoreCase(test.framework()) && test.path() != null && test.path().endsWith(".java")) {
            return false;
        }
        return TestExecutor.super.handles(test, workspace);
    }

    @Override
    public boolean accepts(TestSpec test, Path workspace) {
        return test.path() != null && test.path().endsWith(".py");
    }

    @Override
    public Path project(TestSpec test, Path workspace) {
        return PythonProjects.project(workspace, test.path());
    }

    @Override
    public ProcessRunner.Result prepare(ExecutionContext context, Path project) {
        return PythonProjects.install(context, project);
    }

    @Override
    public TestOutcome execute(ExecutionContext context, TestSpec test, Path project, Path output) {
        StringBuilder command = new StringBuilder("python -m pytest -q");
        String identifier = test.testIdentifier();
        if (identifier != null && identifier.contains("::")) {
            command.append(' ').append(ExecutionContext.quote(identifier));
        } else {
            if (TestExecutor.exists(project, test.path())) {
                command.append(' ').append(ExecutionContext.quote(ExecutionContext.relative(project, project.resolve(test.path()).normalize())));
            }
            if (identifier != null) {
                command.append(" -k ").append(ExecutionContext.quote(JUnitReports.lastSegment(identifier)));
            }
        }
        Path junit = output.resolve("junit.xml");
        command.append(" --junitxml=").append(ExecutionContext.quote(junit.toString()));
        ProcessRunner.Result result = context.run(command.toString(), project, Map.of("TRACEAGILE_OUTPUT_DIR", output.toString()));
        return TestExecutor.outcome(result, JUnitReports.read(junit), identifier, TestExecutor.files(output, ".png", ".jpg"), List.of(), Map.of());
    }
}
