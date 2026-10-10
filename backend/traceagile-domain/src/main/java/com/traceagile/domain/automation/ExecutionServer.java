package com.traceagile.domain.automation;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.testcase.TestTechnique;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import java.net.URI;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * §3.1 ExecutionServer : serveur d'exécution distant (§10). ADR-0020 le jeton d'accès et le secret de
 * signature des webhooks sont **émis par le serveur** à l'appairage ; ils sont conservés chiffrés et ne
 * quittent jamais l'API (seule une empreinte courte est affichée). Les capacités viennent du serveur.
 */
@Entity
@Table(name = "execution_servers")
public class ExecutionServer extends AuditableEntity {

    @Column(nullable = false, unique = true, length = 100)
    private String name;

    @Column(name = "base_url", nullable = false, length = 300)
    private String baseUrl;

    /** §3.1 authType : jeton Bearer émis par le serveur. */
    @Column(name = "auth_type", nullable = false, length = 20)
    private String authType = "SERVER_TOKEN";

    @Column(name = "api_token", columnDefinition = "text")
    private String apiTokenCipher;

    @Column(name = "webhook_secret", columnDefinition = "text")
    private String webhookSecretCipher;

    /** Identifiant du jeton côté serveur (révocation). */
    @Column(name = "token_id", length = 100)
    private String tokenId;

    /** Quatre derniers caractères du jeton, pour l'affichage. */
    @Column(name = "token_hint", length = 8)
    private String tokenHint;

    @Column(name = "paired_at")
    private Instant pairedAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 15)
    private ServerStatus status = ServerStatus.UNPAIRED;

    @Column(name = "last_heartbeat")
    private Instant lastHeartbeat;

    @Column(name = "last_error", length = 500)
    private String lastError;

    @Column(name = "server_version", length = 50)
    private String serverVersion;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private List<TestTechnique> techniques = new ArrayList<>();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private List<String> frameworks = new ArrayList<>();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private List<String> environments = new ArrayList<>();

    @Column(nullable = false)
    private int agents;

    @Column(nullable = false)
    private boolean enabled = true;

    protected ExecutionServer() {
    }

    public ExecutionServer(String name, String baseUrl) {
        rename(name);
        moveTo(baseUrl);
    }

    public void rename(String name) {
        if (name == null || name.isBlank()) {
            throw new BusinessRuleException("SERVER_NAME_REQUIRED", "Le nom du serveur est obligatoire.");
        }
        this.name = name.strip();
    }

    /** URL de base http(s) sans « / » final. Changer d'URL impose un nouvel appairage. */
    public void moveTo(String baseUrl) {
        String url = baseUrl == null ? "" : baseUrl.strip().replaceAll("/+$", "");
        try {
            URI uri = URI.create(url);
            if (uri.getHost() == null || !(url.startsWith("http://") || url.startsWith("https://"))) {
                throw new IllegalArgumentException();
            }
        } catch (IllegalArgumentException e) {
            throw new BusinessRuleException("SERVER_URL_INVALID", "L'URL du serveur doit être une adresse http(s) valide.");
        }
        if (this.baseUrl != null && !this.baseUrl.equals(url)) {
            unpair();
        }
        this.baseUrl = url;
    }

    public void enable(boolean enabled) {
        this.enabled = enabled;
    }

    /** ADR-0020 enregistre le jeton et le secret émis par le serveur (déjà chiffrés). */
    public void pair(String tokenCipher, String webhookSecretCipher, String tokenId, String tokenHint, Instant now) {
        if (tokenCipher == null || webhookSecretCipher == null) {
            throw new BusinessRuleException("SERVER_TOKEN_REQUIRED", "Le jeton et le secret de signature émis par le serveur sont obligatoires.");
        }
        this.apiTokenCipher = tokenCipher;
        this.webhookSecretCipher = webhookSecretCipher;
        this.tokenId = tokenId;
        this.tokenHint = tokenHint;
        this.pairedAt = now;
        this.status = ServerStatus.UNKNOWN;
        this.lastError = null;
    }

    public void unpair() {
        this.apiTokenCipher = null;
        this.webhookSecretCipher = null;
        this.tokenId = null;
        this.tokenHint = null;
        this.pairedAt = null;
        this.status = ServerStatus.UNPAIRED;
    }

    public boolean isPaired() {
        return apiTokenCipher != null;
    }

    /** §10.2 heartbeat réussi : version et capacités annoncées. */
    public void reportCapabilities(String version, List<TestTechnique> techniques, List<String> frameworks, List<String> environments,
                                   int agents, Instant now) {
        this.serverVersion = version;
        this.techniques = new ArrayList<>(techniques == null ? List.of() : techniques);
        this.frameworks = new ArrayList<>(frameworks == null ? List.of() : frameworks);
        this.environments = new ArrayList<>(environments == null ? List.of() : environments);
        this.agents = agents;
        this.lastHeartbeat = now;
        this.lastError = null;
        this.status = ServerStatus.ONLINE;
    }

    public void reportUnreachable(String error, Instant now) {
        this.lastHeartbeat = now;
        this.lastError = truncate(error);
        this.status = ServerStatus.OFFLINE;
    }

    public void reportUnauthorized(Instant now) {
        this.lastHeartbeat = now;
        this.lastError = "Jeton refusé par le serveur : appairez-le à nouveau.";
        this.status = ServerStatus.UNAUTHORIZED;
    }

    public boolean supports(TestTechnique technique) {
        return techniques.contains(technique);
    }

    /** F-EXE-06 prêt à recevoir un run. */
    public void ensureUsable() {
        if (!enabled) {
            throw new BusinessRuleException("SERVER_DISABLED", "Le serveur « " + name + " » est désactivé.");
        }
        if (!isPaired()) {
            throw new BusinessRuleException("SERVER_NOT_PAIRED", "Le serveur « " + name + " » n'est pas appairé : demandez-lui un jeton.");
        }
        if (status == ServerStatus.UNAUTHORIZED) {
            throw new BusinessRuleException("SERVER_UNAUTHORIZED", "Le serveur « " + name + " » refuse le jeton enregistré : appairez-le à nouveau.");
        }
    }

    private static String truncate(String text) {
        return text == null || text.length() <= 500 ? text : text.substring(0, 499) + "…";
    }

    public String getName() {
        return name;
    }

    public String getBaseUrl() {
        return baseUrl;
    }

    public String getAuthType() {
        return authType;
    }

    public String getApiTokenCipher() {
        return apiTokenCipher;
    }

    public String getWebhookSecretCipher() {
        return webhookSecretCipher;
    }

    public String getTokenId() {
        return tokenId;
    }

    public String getTokenHint() {
        return tokenHint;
    }

    public Instant getPairedAt() {
        return pairedAt;
    }

    public ServerStatus getStatus() {
        return status;
    }

    public Instant getLastHeartbeat() {
        return lastHeartbeat;
    }

    public String getLastError() {
        return lastError;
    }

    public String getServerVersion() {
        return serverVersion;
    }

    public List<TestTechnique> getTechniques() {
        return List.copyOf(techniques);
    }

    public List<String> getFrameworks() {
        return List.copyOf(frameworks);
    }

    public List<String> getEnvironments() {
        return List.copyOf(environments);
    }

    public int getAgents() {
        return agents;
    }

    public boolean isEnabled() {
        return enabled;
    }
}
