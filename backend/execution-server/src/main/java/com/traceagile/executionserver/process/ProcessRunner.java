package com.traceagile.executionserver.process;

import java.nio.file.Path;
import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;

/**
 * ADR-0026 port d'exécution des processus externes (installations, git, frameworks de test). Les tests
 * le remplacent par une implémentation scriptée : aucun outil réel n'est lancé pendant {@code mvn verify}.
 */
public interface ProcessRunner {

    /**
     * @param arguments commande et arguments (voir {@link Platform#shell} / {@link Platform#script})
     * @param directory dossier de travail
     * @param environment variables ajoutées ou remplacées
     * @param timeout    durée maximale ; au-delà le processus et ses enfants sont arrêtés
     */
    record Command(List<String> arguments, Path directory, Map<String, String> environment, Duration timeout) {
    }

    /** @param timedOut le délai a été atteint ; @param cancelled le processus a été arrêté à la demande */
    record Result(int exitCode, boolean timedOut, boolean cancelled, String output) {

        public boolean succeeded() {
            return exitCode == 0 && !timedOut && !cancelled;
        }
    }

    /** Lance la commande, transmet chaque ligne de sortie (stdout et stderr mêlés) et attend la fin. */
    Result run(Command command, Consumer<String> output, Cancellation cancellation);
}
