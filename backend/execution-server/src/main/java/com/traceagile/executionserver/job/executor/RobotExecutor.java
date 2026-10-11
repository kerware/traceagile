package com.traceagile.executionserver.job.executor;

import com.traceagile.executionserver.job.JobSpec.TestSpec;
import com.traceagile.executionserver.process.ProcessRunner;
import java.nio.file.Path;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * Robot Framework : {@code python -m robot --test <nom> --xunit} ; les paramètres et la ligne de jeu de
 * données deviennent des variables Robot ({@code --variable NOM:valeur}). Copies d'écran de
 * SeleniumLibrary et de Browser (Playwright) jointes.
 */
@Component
@Order(50)
public class RobotExecutor implements TestExecutor {

    @Override
    public String name() {
        return "Robot Framework";
    }

    @Override
    public Set<String> frameworks() {
        return Set.of("Robot Framework");
    }

    @Override
    public boolean accepts(TestSpec test, Path workspace) {
        return test.path() != null && test.path().endsWith(".robot");
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
        StringBuilder command = new StringBuilder("python -m robot --outputdir ").append(ExecutionContext.quote(output.toString()))
                .append(" --xunit junit.xml --consolecolors off");
        if (test.testIdentifier() != null) {
            command.append(" --test ").append(ExecutionContext.quote(test.testIdentifier()));
        }
        variables(test).forEach((name, value) -> command.append(" --variable ").append(ExecutionContext.quote(name + ":" + value)));
        command.append(' ').append(ExecutionContext.quote(TestExecutor.exists(context.workspace(), test.path())
                ? ExecutionContext.relative(project, context.workspace().resolve(test.path()).normalize()) : "."));
        ProcessRunner.Result result = context.run(command.toString(), project);
        return TestExecutor.outcome(result, JUnitReports.read(output.resolve("junit.xml")), test.testIdentifier(),
                TestExecutor.files(output, ".png", ".jpg"), List.of(output.resolve("log.html"), output.resolve("report.html")), Map.of());
    }

    static Map<String, String> variables(TestSpec test) {
        Map<String, String> variables = new LinkedHashMap<>();
        test.parameters().forEach((k, v) -> variables.put(k, String.valueOf(v)));
        test.dataSet().forEach((k, v) -> variables.put(k, String.valueOf(v)));
        variables.remove("jdk");
        return variables;
    }
}
