package com.traceagile.executionserver.job.executor;

import com.traceagile.executionserver.process.ProcessRunner;
import java.nio.file.Files;
import java.nio.file.Path;

/** Projets Python : dépendances du dépôt installées dans l'environnement des outils, une fois par job. */
final class PythonProjects {

    private PythonProjects() {
    }

    static Path project(Path workspace, String path) {
        for (String marker : new String[] {"requirements.txt", "pyproject.toml", "pytest.ini"}) {
            Path project = TestExecutor.nearest(workspace, path, marker);
            if (Files.exists(project.resolve(marker))) {
                return project;
            }
        }
        return workspace.toAbsolutePath().normalize();
    }

    static ProcessRunner.Result install(ExecutionContext context, Path project) {
        if (!Files.exists(project.resolve("requirements.txt"))) {
            return new ProcessRunner.Result(0, false, false, "");
        }
        return context.run("python -m pip install -r requirements.txt", project);
    }
}
