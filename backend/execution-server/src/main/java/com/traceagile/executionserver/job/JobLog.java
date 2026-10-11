package com.traceagile.executionserver.job;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.time.Clock;

/** Journal d'un job (fichier {@code jobs/<id>/job.log}) : lignes horodatées, tous tests confondus. */
public final class JobLog {

    private final Path file;
    private final Clock clock;

    public JobLog(Path file, Clock clock) {
        this.file = file;
        this.clock = clock;
    }

    public synchronized void line(String text) {
        try {
            Files.createDirectories(file.getParent());
            Files.writeString(file, clock.instant() + " " + text + System.lineSeparator(), StandardCharsets.UTF_8, StandardOpenOption.CREATE,
                    StandardOpenOption.APPEND);
        } catch (IOException e) {
            // journal indisponible (disque plein) : le job continue
        }
    }

    public Path file() {
        return file;
    }

    /** Fin du journal (500 000 caractères au plus). */
    public static String read(Path file) {
        try {
            if (!Files.exists(file)) {
                return "";
            }
            String content = Files.readString(file, StandardCharsets.UTF_8);
            return content.length() > 500_000 ? content.substring(content.length() - 500_000) : content;
        } catch (IOException e) {
            return "Journal illisible : " + e.getMessage();
        }
    }
}
