package com.traceagile.executionserver.job;

import com.traceagile.executionserver.admin.GitCredentialService;
import com.traceagile.executionserver.job.JobSpec.Credentials;
import com.traceagile.executionserver.job.executor.ExecutionContext;
import com.traceagile.executionserver.process.ProcessRunner;
import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.PosixFilePermissions;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Component;

/**
 * Espace de travail d'un job : clone superficiel de la branche du dépôt, ou dossier vide si le job n'a
 * pas de dépôt (tests BDD dont le Gherkin vient de TraceAgile). Identifiants : ceux transmis avec le job
 * (ADR-0030, jeton HTTPS ou clé SSH, gardés en mémoire jusqu'au clone, jamais écrits en base ni dans les
 * journaux), sinon ceux enregistrés sur ce serveur pour l'hôte du dépôt (ADR-0026).
 */
@Component
public class GitWorkspace {

    private final GitCredentialService credentials;
    /** Identifiants reçus avec un job, consommés par son clone. */
    private final Map<String, Credentials> jobCredentials = new ConcurrentHashMap<>();

    public GitWorkspace(GitCredentialService credentials) {
        this.credentials = credentials;
    }

    /** ADR-0030 identifiants transmis par TraceAgile pour le dépôt d'un job ({@code null} : aucun). */
    public void remember(String jobId, Credentials credentials) {
        if (credentials != null) {
            jobCredentials.put(jobId, credentials);
        }
    }

    /** @return null si l'espace est prêt, sinon le message d'erreur */
    public String prepare(ExecutionContext context, String jobId, String repositoryUrl, String branch) {
        Credentials given = jobId == null ? null : jobCredentials.remove(jobId);
        Path workspace = context.workspace();
        try {
            Files.createDirectories(workspace.getParent());
        } catch (IOException e) {
            return "Espace de travail impossible : " + e.getMessage();
        }
        if (repositoryUrl == null || repositoryUrl.isBlank()) {
            try {
                Files.createDirectories(workspace);
            } catch (IOException e) {
                return "Espace de travail impossible : " + e.getMessage();
            }
            context.log().accept("Pas de dépôt : espace de travail vide (seuls les tests dont le Gherkin est transmis peuvent s'exécuter)");
            return null;
        }
        String plain = repositoryUrl.strip();
        Map<String, String> environment = new LinkedHashMap<>(Map.of("GIT_TERMINAL_PROMPT", "0"));
        Path key = null;
        String url;
        if (given != null && "SSH_KEY".equals(given.type())) {
            try {
                key = sshKey(workspace.getParent(), given.secret());
            } catch (IOException e) {
                return "Clé SSH impossible à préparer : " + e.getMessage();
            }
            String keyPath = key.toAbsolutePath().toString().replace('\\', '/');
            String knownHosts = workspace.getParent().resolve("known_hosts").toAbsolutePath().toString().replace('\\', '/');
            environment.put("GIT_SSH_COMMAND", "ssh -i \"" + keyPath + "\" -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
                    + " -o UserKnownHostsFile=\"" + knownHosts + "\"");
            url = plain;
        } else if (given != null && "TOKEN".equals(given.type())) {
            url = withUser(plain, given.username(), given.secret());
        } else {
            url = authenticated(plain);
        }
        String secret = url.equals(plain) ? null : url;
        String command = "git clone --depth 1 " + (branch == null || branch.isBlank() ? "" : "--branch " + ExecutionContext.quote(branch.strip()) + " ")
                + ExecutionContext.quote(url) + " " + ExecutionContext.quote(workspace.getFileName().toString());
        context.log().accept("Clone de " + plain + (branch == null ? "" : " (branche " + branch + ")")
                + (given == null ? "" : given.type().equals("SSH_KEY") ? ", clé SSH transmise par TraceAgile" : ", jeton transmis par TraceAgile"));
        ExecutionContext masked = new ExecutionContext(context.workspace(), context.environment(), context.platform(), context.processes(),
                context.cancellation(), context.deadline(), line -> context.log().accept(secret == null ? line : line.replace(secret, plain)));
        try {
            ProcessRunner.Result result = masked.run(command, workspace.getParent(), environment);
            if (!result.succeeded()) {
                return "Clone du dépôt impossible (" + plain + ") : " + lastLine(secret == null ? result.output() : result.output().replace(secret, plain));
            }
            return null;
        } finally {
            if (key != null) {
                try {
                    Files.deleteIfExists(key);
                } catch (IOException ignored) {
                    // le dossier du job est purgé avec lui
                }
            }
        }
    }

    /** Clé privée écrite pour le seul clone, lisible par le seul compte du serveur (OpenSSH le vérifie). */
    private static Path sshKey(Path directory, String secret) throws IOException {
        Path key = directory.resolve("cle-ssh");
        Files.deleteIfExists(key);
        try {
            Files.createFile(key, PosixFilePermissions.asFileAttribute(PosixFilePermissions.fromString("rw-------")));
        } catch (UnsupportedOperationException windows) {
            Files.createFile(key);
        }
        String text = secret.replace("\r\n", "\n");
        Files.writeString(key, text.endsWith("\n") ? text : text + "\n");
        return key;
    }

    /** https://hôte/… → https://utilisateur:secret@hôte/… si des identifiants sont enregistrés pour l'hôte. */
    String authenticated(String url) {
        if (!url.startsWith("https://") && !url.startsWith("http://")) {
            return url;
        }
        try {
            URI uri = URI.create(url);
            if (uri.getUserInfo() != null || uri.getHost() == null) {
                return url;
            }
            return credentials.find(uri.getHost()).map(c -> withUser(url, c.username(), c.secret())).orElse(url);
        } catch (IllegalArgumentException e) {
            return url;
        }
    }

    private static String withUser(String url, String username, String secret) {
        if (!url.startsWith("https://") && !url.startsWith("http://")) {
            return url;
        }
        String scheme = url.substring(0, url.indexOf("://"));
        String user = username == null || username.isBlank() ? "x-access-token" : username;
        return scheme + "://" + encode(user) + ":" + encode(secret) + "@" + url.substring(scheme.length() + 3);
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private static String lastLine(String output) {
        if (output == null || output.isBlank()) {
            return "aucune sortie";
        }
        var lines = output.strip().lines().toList();
        return lines.getLast();
    }
}
