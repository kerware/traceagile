package com.traceagile.domain.git;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import java.net.URI;
import java.util.Locale;
import java.util.regex.Pattern;

/**
 * ADR-0030 dépôt Git déclaré pour toute l'instance (Administration › Dépôts Git) : l'adresse d'un
 * compte ou d'une organisation (« https://github.com/kerware »), sous laquelle on déclare des
 * {@link GitProject projets}. Le secret (jeton ou clé SSH) est stocké chiffré par l'application ;
 * le domaine n'en voit que le texte chiffré.
 */
@Entity
@Table(name = "git_sources")
public class GitSource extends AuditableEntity {

    private static final Pattern SCP_LIKE = Pattern.compile("^[\\w.-]+@[\\w.-]+:.+$");

    @Column(nullable = false, unique = true, length = 100)
    private String name;

    @Column(name = "base_url", nullable = false, length = 300)
    private String baseUrl;

    @Enumerated(EnumType.STRING)
    @Column(name = "auth_type", nullable = false, length = 10)
    private GitAuthType authType = GitAuthType.NONE;

    @Column(length = 100)
    private String username;

    /** Jeton ou clé privée, chiffré (SecretCipher). */
    @Column(name = "secret", columnDefinition = "text")
    private String secretCipher;

    @Column(length = 500)
    private String description;

    protected GitSource() {
    }

    public GitSource(String name, String baseUrl, String description) {
        rename(name);
        changeUrl(baseUrl);
        this.description = blankToNull(description);
    }

    public void rename(String name) {
        if (name == null || name.isBlank()) {
            throw new BusinessRuleException("GIT_SOURCE_NAME_REQUIRED", "Le dépôt a un nom.");
        }
        this.name = name.strip();
    }

    /**
     * https://hôte/chemin, http://…, file:///chemin (dépôt local du serveur d'exécution) ou
     * utilisateur@hôte:chemin (SSH) ; sans « / » final.
     */
    public void changeUrl(String baseUrl) {
        String url = baseUrl == null ? "" : baseUrl.strip();
        while (url.endsWith("/") && !url.endsWith(":///")) {
            url = url.substring(0, url.length() - 1);
        }
        boolean http = url.startsWith("https://") || url.startsWith("http://");
        if (!(http && host(url) != null) && !url.startsWith("file://") && !SCP_LIKE.matcher(url).matches()) {
            throw new BusinessRuleException("GIT_SOURCE_URL_INVALID",
                    "Adresse de dépôt invalide : https://hôte/compte, file:///dossier ou git@hôte:compte.");
        }
        this.baseUrl = url;
        checkAuthentication(authType);
    }

    public void describe(String description) {
        this.description = blankToNull(description);
    }

    /** Aucune authentification : le secret est effacé. */
    public void makePublic() {
        this.authType = GitAuthType.NONE;
        this.username = null;
        this.secretCipher = null;
    }

    /**
     * Jeton (HTTPS) ou clé SSH. {@code secretCipher} {@code null} : on garde le secret existant (modification
     * du nom d'utilisateur seulement), à condition qu'il y en ait un pour ce même type.
     */
    public void authenticate(GitAuthType type, String username, String secretCipher) {
        if (type == null || type == GitAuthType.NONE) {
            makePublic();
            return;
        }
        checkAuthentication(type);
        boolean keep = secretCipher == null || secretCipher.isBlank();
        if (keep && (this.secretCipher == null || this.authType != type)) {
            throw new BusinessRuleException("GIT_SOURCE_SECRET_REQUIRED",
                    type == GitAuthType.TOKEN ? "Saisissez le jeton d'accès." : "Saisissez la clé privée SSH.");
        }
        this.authType = type;
        this.username = type == GitAuthType.TOKEN ? (username == null || username.isBlank() ? "x-access-token" : username.strip()) : null;
        if (!keep) {
            this.secretCipher = secretCipher;
        }
    }

    private void checkAuthentication(GitAuthType type) {
        if (baseUrl == null || type == null) {
            return;
        }
        if (baseUrl.startsWith("file://") && type != GitAuthType.NONE) {
            throw new BusinessRuleException("GIT_SOURCE_AUTH_INVALID", "Un dépôt local (file://) ne s'authentifie pas.");
        }
        if (type == GitAuthType.TOKEN && !baseUrl.startsWith("http")) {
            throw new BusinessRuleException("GIT_SOURCE_AUTH_INVALID", "Un jeton d'accès s'utilise avec une adresse https://.");
        }
    }

    /**
     * Adresse de clonage d'un projet : base + « / » + projet ; avec une clé SSH, la forme
     * git@hôte:chemin/projet.git (déduite d'une adresse https://hôte/chemin).
     */
    public String cloneUrl(String project) {
        if (authType == GitAuthType.SSH_KEY) {
            String scp = SCP_LIKE.matcher(baseUrl).matches() ? baseUrl : "git@" + host(baseUrl) + ":" + path(baseUrl);
            return scp + "/" + project + ".git";
        }
        return baseUrl + "/" + project;
    }

    /** Adresse web d'un projet (lien dans l'interface), quand le dépôt est en HTTP(S). */
    public String webUrl(String project) {
        return baseUrl.startsWith("http") ? baseUrl + "/" + project : null;
    }

    private static String host(String url) {
        try {
            return URI.create(url).getHost();
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private static String path(String url) {
        String path = URI.create(url).getPath();
        return path.startsWith("/") ? path.substring(1) : path;
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.strip();
    }

    public String getName() {
        return name;
    }

    public String getBaseUrl() {
        return baseUrl;
    }

    public GitAuthType getAuthType() {
        return authType;
    }

    public String getUsername() {
        return username;
    }

    public String getSecretCipher() {
        return secretCipher;
    }

    public boolean hasSecret() {
        return secretCipher != null;
    }

    public String getDescription() {
        return description;
    }

    public String key() {
        return name.toLowerCase(Locale.ROOT);
    }
}
