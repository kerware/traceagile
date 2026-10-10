package com.traceagile.application.automation;

import com.traceagile.application.automation.AutomationRepositories.AutomatedRunRepository;
import com.traceagile.application.automation.AutomationRepositories.ExecutionServerRepository;
import com.traceagile.application.automation.ExecutionServerClient.Capabilities;
import com.traceagile.application.automation.ExecutionServerClient.IssuedToken;
import com.traceagile.application.automation.ExecutionServerClient.ServerConnection;
import com.traceagile.application.common.ConflictException;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.domain.automation.ExecutionServer;
import com.traceagile.domain.common.BusinessRuleException;
import java.time.Clock;
import java.util.List;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §10 serveurs d'exécution (administration système). ADR-0020 appairage : le serveur émet un jeton et
 * un secret de signature, soit demandés par TraceAgile avec les identifiants de l'administrateur du
 * serveur (non conservés), soit saisis après émission sur le serveur. Heartbeat : santé et capacités.
 */
@Service
@Transactional
public class ExecutionServerService {

    private static final Logger LOG = LoggerFactory.getLogger(ExecutionServerService.class);

    private final ExecutionServerRepository servers;
    private final AutomatedRunRepository runs;
    private final ExecutionServerClient client;
    private final SecretCipher cipher;
    private final Clock clock;

    public ExecutionServerService(ExecutionServerRepository servers, AutomatedRunRepository runs, ExecutionServerClient client, SecretCipher cipher,
                                  Clock clock) {
        this.servers = servers;
        this.runs = runs;
        this.client = client;
        this.cipher = cipher;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public List<ExecutionServer> list() {
        return servers.findAllByOrderByNameAsc();
    }

    @Transactional(readOnly = true)
    public ExecutionServer get(UUID id) {
        return servers.findById(id).orElseThrow(() -> new NotFoundException("SERVER_NOT_FOUND", "Serveur d'exécution introuvable."));
    }

    public ExecutionServer create(String name, String baseUrl) {
        if (servers.existsByNameIgnoreCase(name == null ? "" : name.strip())) {
            throw new ConflictException("SERVER_NAME_TAKEN", "Un serveur d'exécution porte déjà le nom « " + name + " ».");
        }
        return servers.save(new ExecutionServer(name, baseUrl));
    }

    /** {@code null} = inchangé. Changer d'URL efface le jeton (nouvel appairage). */
    public ExecutionServer update(UUID id, String name, String baseUrl, Boolean enabled) {
        ExecutionServer server = get(id);
        if (name != null && !name.strip().equalsIgnoreCase(server.getName())) {
            if (servers.existsByNameIgnoreCase(name.strip())) {
                throw new ConflictException("SERVER_NAME_TAKEN", "Un serveur d'exécution porte déjà le nom « " + name + " ».");
            }
            server.rename(name);
        }
        if (baseUrl != null) {
            server.moveTo(baseUrl);
        }
        if (enabled != null) {
            server.enable(enabled);
        }
        return server;
    }

    /** Un serveur qui a reçu des runs ne se supprime pas : on le désactive (historique des runs). */
    public void delete(UUID id) {
        ExecutionServer server = get(id);
        if (runs.existsByServer_Id(id)) {
            throw new BusinessRuleException("SERVER_IN_USE", "Ce serveur a exécuté des runs : désactivez-le plutôt que de le supprimer.");
        }
        servers.delete(server);
    }

    /** ADR-0020 demande un jeton au serveur avec les identifiants de son administrateur (non conservés). */
    public ExecutionServer pairWithCredentials(UUID id, String adminUser, String adminPassword) {
        ExecutionServer server = get(id);
        IssuedToken issued;
        try {
            issued = client.requestToken(server.getBaseUrl(), adminUser, adminPassword, "TraceAgile — " + server.getName());
        } catch (ExecutionServerClient.UnauthorizedException e) {
            throw new BusinessRuleException("SERVER_ADMIN_REJECTED", "Le serveur refuse ces identifiants d'administration.");
        } catch (ExecutionServerClient.UnavailableException e) {
            throw new BusinessRuleException("SERVER_UNREACHABLE", "Serveur injoignable : " + e.getMessage());
        }
        return store(server, issued);
    }

    /** ADR-0020 jeton et secret émis sur le serveur puis saisis par l'administrateur de TraceAgile. */
    public ExecutionServer pairWithToken(UUID id, String token, String webhookSecret, String tokenId) {
        ExecutionServer server = get(id);
        if (token == null || token.isBlank() || webhookSecret == null || webhookSecret.isBlank()) {
            throw new BusinessRuleException("SERVER_TOKEN_REQUIRED", "Le jeton et le secret de signature émis par le serveur sont obligatoires.");
        }
        return store(server, new IssuedToken(tokenId, token.strip(), webhookSecret.strip()));
    }

    public ExecutionServer unpair(UUID id) {
        ExecutionServer server = get(id);
        server.unpair();
        return server;
    }

    /** §12 POST /execution-servers/{id}/test-connection : santé, capacités, jeton accepté. */
    public ExecutionServer testConnection(UUID id) {
        ExecutionServer server = get(id);
        probe(server);
        return server;
    }

    /** §10.2 heartbeat (toutes les 60 s) des serveurs appairés et actifs. */
    public void heartbeat() {
        for (ExecutionServer server : servers.findAllByOrderByNameAsc()) {
            if (server.isEnabled() && server.isPaired()) {
                probe(server);
            }
        }
    }

    /** Adresse et jeton déchiffré, pour un appel. */
    @Transactional(readOnly = true)
    public ServerConnection connection(ExecutionServer server) {
        server.ensureUsable();
        return new ServerConnection(server.getBaseUrl(), cipher.decrypt(server.getApiTokenCipher()));
    }

    /** Secret de vérification des webhooks du serveur. */
    public String webhookSecret(ExecutionServer server) {
        return server.getWebhookSecretCipher() == null ? null : cipher.decrypt(server.getWebhookSecretCipher());
    }

    private ExecutionServer store(ExecutionServer server, IssuedToken issued) {
        String hint = issued.token().length() <= 4 ? "****" : issued.token().substring(issued.token().length() - 4);
        server.pair(cipher.encrypt(issued.token()), cipher.encrypt(issued.webhookSecret()), issued.tokenId(), hint, clock.instant());
        probe(server);
        return server;
    }

    private void probe(ExecutionServer server) {
        if (!server.isPaired()) {
            throw new BusinessRuleException("SERVER_NOT_PAIRED", "Le serveur « " + server.getName() + " » n'est pas appairé : demandez-lui un jeton.");
        }
        try {
            Capabilities capabilities = client.probe(new ServerConnection(server.getBaseUrl(), cipher.decrypt(server.getApiTokenCipher())));
            server.reportCapabilities(capabilities.version(), capabilities.techniques(), capabilities.frameworks(), capabilities.environments(),
                    capabilities.agents(), clock.instant());
        } catch (ExecutionServerClient.UnauthorizedException e) {
            server.reportUnauthorized(clock.instant());
        } catch (ExecutionServerClient.UnavailableException e) {
            LOG.info("Serveur d'exécution {} injoignable : {}", server.getName(), e.getMessage());
            server.reportUnreachable(e.getMessage(), clock.instant());
        }
    }
}
