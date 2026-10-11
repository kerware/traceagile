package com.traceagile.executionserver.job.executor;

import com.traceagile.executionserver.job.JobSpec.TestSpec;
import java.nio.file.Path;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import org.springframework.stereotype.Component;

/**
 * Choix de l'exécuteur d'un test : d'abord le framework déclaré dans TraceAgile, sinon le fichier du
 * test (extension, dépendances du projet), sinon le Gherkin (Cucumber-JS ou Cucumber-JVM selon le dépôt).
 */
@Component
public class ExecutorRegistry {

    private final List<TestExecutor> executors;

    public ExecutorRegistry(List<TestExecutor> executors) {
        this.executors = executors;
    }

    public Optional<TestExecutor> resolve(TestSpec test, Path workspace) {
        if (test.framework() != null && !test.framework().isBlank()) {
            String framework = test.framework().strip().toLowerCase(Locale.ROOT);
            Optional<TestExecutor> declared = executors.stream()
                    .filter(e -> e.frameworks().stream().anyMatch(f -> f.toLowerCase(Locale.ROOT).equals(framework)))
                    .filter(e -> e.handles(test, workspace)).findFirst();
            if (declared.isPresent()) {
                return declared;
            }
        }
        return executors.stream().filter(e -> e.accepts(test, workspace)).findFirst();
    }

    public List<TestExecutor> all() {
        return executors;
    }
}
