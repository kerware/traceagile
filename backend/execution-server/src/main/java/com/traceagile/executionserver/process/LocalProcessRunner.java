package com.traceagile.executionserver.process;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.TimeUnit;
import java.util.function.Consumer;
import org.springframework.stereotype.Component;

/** Exécution réelle par {@link ProcessBuilder} ; la sortie est conservée (64 000 derniers caractères). */
@Component
public class LocalProcessRunner implements ProcessRunner {

    private static final int KEPT = 64_000;

    @Override
    public Result run(Command command, Consumer<String> output, Cancellation cancellation) {
        ProcessBuilder builder = new ProcessBuilder(command.arguments()).redirectErrorStream(true);
        if (command.directory() != null) {
            builder.directory(command.directory().toFile());
        }
        builder.environment().putAll(command.environment());
        Process process;
        try {
            process = builder.start();
        } catch (IOException e) {
            String message = "Impossible de lancer « " + command.arguments().getFirst() + " » : " + e.getMessage();
            output.accept(message);
            return new Result(-1, false, false, message);
        }
        if (!cancellation.attach(process)) {
            return new Result(-1, false, true, "");
        }
        StringBuilder kept = new StringBuilder();
        Thread reader = Thread.ofVirtual().start(() -> read(process, output, kept));
        try {
            boolean finished = process.waitFor(command.timeout().toMillis(), TimeUnit.MILLISECONDS);
            if (!finished) {
                Cancellation.destroyTree(process);
                output.accept("Délai dépassé (" + command.timeout().toMinutes() + " min) : processus arrêté");
            }
            reader.join(5_000);
            synchronized (kept) {
                return new Result(finished ? process.exitValue() : -1, !finished, cancellation.cancelled(), kept.toString());
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            Cancellation.destroyTree(process);
            return new Result(-1, false, true, "");
        } finally {
            cancellation.detach(process);
        }
    }

    private static void read(Process process, Consumer<String> output, StringBuilder kept) {
        Charset charset = process.info().command().map(c -> c.toLowerCase().contains("cmd.exe")).orElse(false)
                ? Charset.defaultCharset() : StandardCharsets.UTF_8;
        try (BufferedReader lines = new BufferedReader(new InputStreamReader(process.getInputStream(), charset))) {
            String line;
            while ((line = lines.readLine()) != null) {
                output.accept(line);
                synchronized (kept) {
                    kept.append(line).append('\n');
                    if (kept.length() > KEPT) {
                        kept.delete(0, kept.length() - KEPT);
                    }
                }
            }
        } catch (IOException e) {
            output.accept("Lecture de la sortie interrompue : " + e.getMessage());
        }
    }
}
