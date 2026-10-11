package com.traceagile.executionserver.job.executor;

import com.traceagile.executionserver.process.Cancellation;
import com.traceagile.executionserver.process.Platform;
import com.traceagile.executionserver.process.ProcessRunner;
import java.nio.file.Path;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;

/**
 * Contexte d'exécution d'un test : espace de travail du job (dépôt cloné), environnement (outils,
 * paramètres du test), échéance du job et annulation, journal.
 */
public record ExecutionContext(Path workspace, Map<String, String> environment, Platform platform, ProcessRunner processes,
                               Cancellation cancellation, Instant deadline, Consumer<String> log) {

    /** Lance une ligne de commande dans {@code directory} avec le temps restant avant l'échéance du job. */
    public ProcessRunner.Result run(String commandLine, Path directory, Map<String, String> extraEnvironment) {
        Duration remaining = Duration.between(Instant.now(), deadline);
        if (remaining.isNegative() || remaining.isZero()) {
            log.accept("Échéance du job atteinte : commande non lancée");
            return new ProcessRunner.Result(-1, true, false, "");
        }
        log.accept("$ " + commandLine);
        Map<String, String> env = new java.util.LinkedHashMap<>(environment);
        env.putAll(extraEnvironment);
        return processes.run(new ProcessRunner.Command(platform.shell(commandLine), directory, env, remaining), log, cancellation);
    }

    public ProcessRunner.Result run(String commandLine, Path directory) {
        return run(commandLine, directory, Map.of());
    }

    /** Argument de ligne de commande entre guillemets doubles (les guillemets internes sont retirés). */
    public static String quote(String value) {
        return "\"" + value.replace("\"", "") + "\"";
    }

    /** Chemin relatif lisible par la ligne de commande (séparateur « / », accepté partout). */
    public static String relative(Path from, Path to) {
        return from.relativize(to).toString().replace('\\', '/');
    }

    public static List<String> words(String text) {
        return List.of(text.strip().split("\\s+"));
    }
}
