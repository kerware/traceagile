package com.traceagile.executionserver.job;

import com.traceagile.executionserver.admin.GitCredentialService;
import com.traceagile.executionserver.job.executor.ExecutionContext;
import com.traceagile.executionserver.process.ProcessRunner;
import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import org.springframework.stereotype.Component;

/**
 * Espace de travail d'un job : clone superficiel de la branche du dépôt (identifiants du serveur pour
 * l'hôte du dépôt, jamais écrits dans les journaux), ou dossier vide si le job n'a pas de dépôt
 * (tests BDD dont le Gherkin vient de TraceAgile).
 */
@Component
public class GitWorkspace {

    private final GitCredentialService credentials;

    public GitWorkspace(GitCredentialService credentials) {
        this.credentials = credentials;
    }

    /** @return null si l'espace est prêt, sinon le message d'erreur */
    public String prepare(ExecutionContext context, String repositoryUrl, String branch) {
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
        String url = authenticated(repositoryUrl.strip());
        String secret = url.equals(repositoryUrl.strip()) ? null : url;
        String command = "git clone --depth 1 " + (branch == null || branch.isBlank() ? "" : "--branch " + ExecutionContext.quote(branch.strip()) + " ")
                + ExecutionContext.quote(url) + " " + ExecutionContext.quote(workspace.getFileName().toString());
        context.log().accept("Clone de " + repositoryUrl + (branch == null ? "" : " (branche " + branch + ")"));
        ExecutionContext masked = new ExecutionContext(context.workspace(), context.environment(), context.platform(), context.processes(),
                context.cancellation(), context.deadline(), line -> context.log().accept(secret == null ? line : line.replace(secret, repositoryUrl)));
        ProcessRunner.Result result = masked.run(command, workspace.getParent(), java.util.Map.of("GIT_TERMINAL_PROMPT", "0"));
        if (!result.succeeded()) {
            return "Clone du dépôt impossible (" + repositoryUrl + ") : " + lastLine(secret == null ? result.output() : result.output().replace(secret, repositoryUrl));
        }
        return null;
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
            return credentials.find(uri.getHost())
                    .map(c -> uri.getScheme() + "://" + encode(c.username()) + ":" + encode(c.secret()) + "@" + url.substring(uri.getScheme().length() + 3))
                    .orElse(url);
        } catch (IllegalArgumentException e) {
            return url;
        }
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
