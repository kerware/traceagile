package com.traceagile.infrastructure.attachment;

import com.traceagile.application.attachment.FileStorage;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.UUID;
import java.util.regex.Pattern;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * ADR-0024 adaptateur disque du port {@link FileStorage} : un fichier par clé (UUID), réparti en
 * sous-dossiers par ses deux premiers caractères ; la clé est vérifiée (pas de chemin arbitraire).
 */
@Component
public class LocalFileStorage implements FileStorage {

    private static final Pattern KEY = Pattern.compile("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}");

    private final Path root;

    public LocalFileStorage(@Value("${traceagile.attachments.dir:${java.io.tmpdir}/traceagile-attachments}") Path root) {
        this.root = root.toAbsolutePath().normalize();
    }

    @Override
    public String store(byte[] content) {
        String key = UUID.randomUUID().toString();
        Path file = path(key);
        try {
            Files.createDirectories(file.getParent());
            Files.write(file, content, StandardOpenOption.CREATE_NEW);
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        return key;
    }

    @Override
    public byte[] read(String key) {
        try {
            return Files.readAllBytes(path(key));
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    @Override
    public void delete(String key) {
        try {
            Files.deleteIfExists(path(key));
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    private Path path(String key) {
        if (key == null || !KEY.matcher(key).matches()) {
            throw new IllegalArgumentException("Clé de stockage invalide");
        }
        return root.resolve(key.substring(0, 2)).resolve(key);
    }
}
