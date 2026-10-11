package com.traceagile.executionserver.job.executor;

import com.traceagile.executionserver.process.ProcessRunner;
import java.nio.file.Files;
import java.nio.file.Path;

/** Projets Node.js : dépendances installées une fois par job (npm ci si un verrou existe). */
final class NodeProjects {

    private NodeProjects() {
    }

    static ProcessRunner.Result install(ExecutionContext context, Path project) {
        if (!Files.exists(project.resolve("package.json")) || Files.isDirectory(project.resolve("node_modules"))) {
            return new ProcessRunner.Result(0, false, false, "");
        }
        String command = Files.exists(project.resolve("package-lock.json")) ? "npm ci --no-audit --no-fund" : "npm install --no-audit --no-fund";
        return context.run(command, project);
    }

    static boolean uses(Path project, String dependency) {
        return TestExecutor.contains(project.resolve("package.json"), "\"" + dependency + "\"");
    }

    /** Expression régulière qui reconnaît exactement un texte (titre de test). */
    static String exact(String text) {
        StringBuilder regex = new StringBuilder();
        for (char c : text.toCharArray()) {
            if ("\\^$.|?*+()[]{}".indexOf(c) >= 0) {
                regex.append('\\');
            }
            if (c != '"') {
                regex.append(c);
            } else {
                regex.append('.');
            }
        }
        return regex.toString();
    }
}
