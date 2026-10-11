package com.traceagile.executionserver.job;

import com.traceagile.executionserver.ServerProperties;
import com.traceagile.executionserver.job.JobStore.ArtifactRow;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import org.springframework.stereotype.Component;

/**
 * ADR-0021 / ADR-0026 artefacts d'un job, conservés sur disque ({@code jobs/<id>/artifacts}) jusqu'à la
 * fin de la rétention ; décrits à TraceAgile dans les webhooks et par {@code GET /jobs/{id}/artifacts}.
 */
@Component
public class ArtifactStore {

    private final ServerProperties properties;
    private final JobStore jobs;

    public ArtifactStore(ServerProperties properties, JobStore jobs) {
        this.properties = properties;
        this.jobs = jobs;
    }

    public Path directory(String jobId) {
        return properties.jobsDir().resolve(jobId).resolve("artifacts");
    }

    public ArtifactRow store(String jobId, String name, String kind, String executionId, byte[] content) {
        try {
            Path file = file(jobId, name);
            Files.createDirectories(file.getParent());
            Files.write(file, content);
            return register(jobId, name, kind, executionId, content.length);
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    public Optional<ArtifactRow> copy(String jobId, Path source, String name, String kind, String executionId) {
        if (source == null || !Files.isRegularFile(source)) {
            return Optional.empty();
        }
        try {
            Path file = file(jobId, name);
            Files.createDirectories(file.getParent());
            Files.copy(source, file, StandardCopyOption.REPLACE_EXISTING);
            return Optional.of(register(jobId, name, kind, executionId, Files.size(file)));
        } catch (IOException e) {
            return Optional.empty();
        }
    }

    public Optional<byte[]> read(String jobId, String name) {
        try {
            Path file = file(jobId, name);
            return Files.isRegularFile(file) ? Optional.of(Files.readAllBytes(file)) : Optional.empty();
        } catch (IOException | IllegalArgumentException e) {
            return Optional.empty();
        }
    }

    /** Description d'un artefact pour TraceAgile (§10.4, ADR-0021). */
    public static Map<String, Object> describe(ArtifactRow artifact, String baseUrl) {
        Map<String, Object> description = new LinkedHashMap<>();
        description.put("name", artifact.name());
        description.put("type", artifact.contentType());
        description.put("kind", artifact.kind());
        description.put("size", artifact.size());
        if (artifact.executionId() != null) {
            description.put("executionId", artifact.executionId());
        }
        description.put("url", baseUrl + "/api/v1/jobs/" + artifact.jobId() + "/artifacts/" + artifact.name());
        return description;
    }

    private ArtifactRow register(String jobId, String name, String kind, String executionId, long size) {
        ArtifactRow row = new ArtifactRow(jobId, name, contentType(name), kind, executionId, size);
        jobs.artifact(row);
        return row;
    }

    /** Nom d'artefact sûr : pas de séparateur ni de remontée de dossier. */
    private Path file(String jobId, String name) {
        if (name.contains("/") || name.contains("\\") || name.contains("..") || name.isBlank()) {
            throw new IllegalArgumentException("Nom d'artefact invalide : " + name);
        }
        return directory(jobId).resolve(name);
    }

    static String contentType(String name) {
        String lower = name.toLowerCase(Locale.ROOT);
        if (lower.endsWith(".png")) {
            return "image/png";
        }
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
            return "image/jpeg";
        }
        if (lower.endsWith(".xml")) {
            return "application/xml";
        }
        if (lower.endsWith(".json")) {
            return "application/json";
        }
        if (lower.endsWith(".html")) {
            return "text/html";
        }
        if (lower.endsWith(".zip")) {
            return "application/zip";
        }
        return "text/plain";
    }
}
