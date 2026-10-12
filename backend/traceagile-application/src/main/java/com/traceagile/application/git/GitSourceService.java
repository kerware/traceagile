package com.traceagile.application.git;

import com.traceagile.application.automation.SecretCipher;
import com.traceagile.application.common.ConflictException;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.git.GitRepositories.GitProjectRepository;
import com.traceagile.application.git.GitRepositories.GitSourceRepository;
import com.traceagile.domain.git.GitAuthType;
import com.traceagile.domain.git.GitProject;
import com.traceagile.domain.git.GitSource;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * ADR-0030 dépôts Git déclarés pour toute l'instance (administrateur système) et leurs projets,
 * choisis dans les fiches de tests automatisés. Le jeton ou la clé SSH est chiffré (SecretCipher), jamais
 * renvoyé par l'API ; il n'est déchiffré que pour accompagner un job envoyé au serveur d'exécution.
 */
@Service
@Transactional
public class GitSourceService {

    /** Identifiants transmis au serveur d'exécution avec un job (en clair, le temps de l'envoi). */
    public record GitCredentials(GitAuthType type, String username, String secret) {
    }

    /** Champs d'un dépôt ; {@code secret} vide = secret conservé. */
    public record SourceCommand(String name, String baseUrl, String description, GitAuthType authType, String username, String secret) {
    }

    private final GitSourceRepository sources;
    private final GitProjectRepository projects;
    private final SecretCipher cipher;

    public GitSourceService(GitSourceRepository sources, GitProjectRepository projects, SecretCipher cipher) {
        this.sources = sources;
        this.projects = projects;
        this.cipher = cipher;
    }

    @Transactional(readOnly = true)
    public List<GitSource> list() {
        return sources.findAllByOrderByNameAsc();
    }

    /** Projets de tous les dépôts, rangés par dépôt puis par nom. */
    @Transactional(readOnly = true)
    public List<GitProject> projects() {
        return projects.findAllByOrderByNameAsc().stream()
                .sorted(Comparator.comparing((GitProject p) -> p.getSource().getName().toLowerCase()).thenComparing(p -> p.getName().toLowerCase()))
                .toList();
    }

    @Transactional(readOnly = true)
    public GitSource get(UUID id) {
        return sources.findById(id).orElseThrow(() -> new NotFoundException("GIT_SOURCE_NOT_FOUND", "Dépôt Git introuvable."));
    }

    @Transactional(readOnly = true)
    public GitProject project(UUID id) {
        return projects.findById(id).orElseThrow(() -> new NotFoundException("GIT_PROJECT_NOT_FOUND", "Projet Git introuvable."));
    }

    public GitSource create(SourceCommand c) {
        if (sources.existsByNameIgnoreCase(c.name() == null ? "" : c.name().strip())) {
            throw new ConflictException("GIT_SOURCE_NAME_TAKEN", "Un dépôt Git porte déjà le nom « " + c.name() + " ».");
        }
        GitSource source = new GitSource(c.name(), c.baseUrl(), c.description());
        authenticate(source, c);
        return sources.save(source);
    }

    /** Champs {@code null} = inchangés (sauf l'authentification, refaite si {@code authType} est donné). */
    public GitSource update(UUID id, SourceCommand c) {
        GitSource source = get(id);
        if (c.name() != null && !c.name().strip().equalsIgnoreCase(source.getName())) {
            if (sources.existsByNameIgnoreCase(c.name().strip())) {
                throw new ConflictException("GIT_SOURCE_NAME_TAKEN", "Un dépôt Git porte déjà le nom « " + c.name() + " ».");
            }
            source.rename(c.name());
        }
        if (c.description() != null) {
            source.describe(c.description());
        }
        if (c.authType() != null && c.authType() == GitAuthType.NONE) {
            source.makePublic();
        }
        if (c.baseUrl() != null) {
            source.changeUrl(c.baseUrl());
        }
        if (c.authType() != null && c.authType() != GitAuthType.NONE) {
            authenticate(source, c);
        }
        return source;
    }

    public void delete(UUID id) {
        GitSource source = get(id);
        if (projects.countBySource(source) > 0) {
            throw new ConflictException("GIT_SOURCE_IN_USE", "Supprimez d'abord les projets du dépôt « " + source.getName() + " ».");
        }
        sources.delete(source);
    }

    public GitProject addProject(UUID sourceId, String name, String defaultBranch, String description) {
        GitSource source = get(sourceId);
        GitProject project = new GitProject(source, name, defaultBranch, description);
        if (projects.existsBySourceAndNameIgnoreCase(source, project.getName())) {
            throw new ConflictException("GIT_PROJECT_NAME_TAKEN", "Le projet « " + project.getName() + " » existe déjà dans « " + source.getName() + " ».");
        }
        return projects.save(project);
    }

    public GitProject updateProject(UUID id, String name, String defaultBranch, String description) {
        GitProject project = project(id);
        String before = project.getName();
        project.update(name == null ? before : name, defaultBranch, description);
        if (!project.getName().equalsIgnoreCase(before) && projects.existsBySourceAndNameIgnoreCase(project.getSource(), project.getName())) {
            throw new ConflictException("GIT_PROJECT_NAME_TAKEN", "Le projet « " + project.getName() + " » existe déjà.");
        }
        return project;
    }

    public void deleteProject(UUID id) {
        GitProject project = project(id);
        long used = projects.countTestsUsing(project);
        if (used > 0) {
            throw new ConflictException("GIT_PROJECT_IN_USE", "Le projet « " + project.label() + " » est utilisé par " + used + " test(s) automatisé(s).");
        }
        projects.delete(project);
    }

    /** Identifiants déchiffrés du dépôt d'un projet ({@code null} pour un dépôt public). */
    @Transactional(readOnly = true)
    public GitCredentials credentials(GitProject project) {
        GitSource source = project.getSource();
        if (source.getAuthType() == GitAuthType.NONE || !source.hasSecret()) {
            return null;
        }
        return new GitCredentials(source.getAuthType(), source.getUsername(), cipher.decrypt(source.getSecretCipher()));
    }

    private void authenticate(GitSource source, SourceCommand c) {
        GitAuthType type = c.authType() == null ? GitAuthType.NONE : c.authType();
        String secret = c.secret() == null || c.secret().isBlank() ? null : cipher.encrypt(normalize(type, c.secret()));
        source.authenticate(type, c.username(), secret);
    }

    /** Une clé SSH collée depuis Windows : fins de ligne LF et saut de ligne final (exigés par OpenSSH). */
    private static String normalize(GitAuthType type, String secret) {
        if (type != GitAuthType.SSH_KEY) {
            return secret.strip();
        }
        String key = secret.replace("\r\n", "\n").strip();
        return key + "\n";
    }
}
