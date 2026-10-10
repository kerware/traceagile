package com.traceagile.api.automation;

import com.traceagile.api.automation.AutomationDtos.CreateServerRequest;
import com.traceagile.api.automation.AutomationDtos.PairServerRequest;
import com.traceagile.api.automation.AutomationDtos.ServerChoice;
import com.traceagile.api.automation.AutomationDtos.ServerResponse;
import com.traceagile.api.automation.AutomationDtos.UpdateServerRequest;
import com.traceagile.application.automation.ExecutionServerService;
import com.traceagile.domain.automation.ExecutionServer;
import com.traceagile.domain.common.BusinessRuleException;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * §12 Administration des serveurs d'exécution (administrateur système). ADR-0020 le jeton est émis
 * par le serveur ; il n'est jamais renvoyé par l'API (seule son empreinte courte l'est).
 */
@RestController
@Tag(name = "Serveurs d'exécution")
public class ExecutionServerController {

    static final String ADMIN = "hasRole('SYSTEM_ADMIN')";
    /** F-EXE-06 choix du serveur au lancement d'un run. */
    static final String LAUNCH = "hasPermission(#projectKey, 'Project', 'CAMPAIGN_READ')";

    private final ExecutionServerService servers;
    private final AutomationMapper mapper;

    public ExecutionServerController(ExecutionServerService servers, AutomationMapper mapper) {
        this.servers = servers;
        this.mapper = mapper;
    }

    @GetMapping("/api/v1/execution-servers")
    @PreAuthorize(ADMIN)
    public List<ServerResponse> list() {
        return servers.list().stream().map(mapper::server).toList();
    }

    @PostMapping("/api/v1/execution-servers")
    @PreAuthorize(ADMIN)
    public ResponseEntity<ServerResponse> create(@Valid @RequestBody CreateServerRequest r) {
        ExecutionServer server = servers.create(r.name(), r.baseUrl());
        return ResponseEntity.created(URI.create("/api/v1/execution-servers/" + server.getId())).body(mapper.server(server));
    }

    @PatchMapping("/api/v1/execution-servers/{id}")
    @PreAuthorize(ADMIN)
    public ServerResponse update(@PathVariable UUID id, @Valid @RequestBody UpdateServerRequest r) {
        return mapper.server(servers.update(id, r.name(), r.baseUrl(), r.enabled()));
    }

    @DeleteMapping("/api/v1/execution-servers/{id}")
    @PreAuthorize(ADMIN)
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        servers.delete(id);
        return ResponseEntity.noContent().build();
    }

    /** ADR-0020 enregistre le jeton émis par le serveur (demandé avec ses identifiants d'administration, ou saisi). */
    @PostMapping("/api/v1/execution-servers/{id}/pair")
    @PreAuthorize(ADMIN)
    public ServerResponse pair(@PathVariable UUID id, @RequestBody PairServerRequest r) {
        if (r.token() != null && !r.token().isBlank()) {
            return mapper.server(servers.pairWithToken(id, r.token(), r.webhookSecret(), r.tokenId()));
        }
        if (r.adminUser() == null || r.adminUser().isBlank() || r.adminPassword() == null) {
            throw new BusinessRuleException("SERVER_PAIRING_INVALID",
                    "Indiquez soit les identifiants de l'administrateur du serveur, soit le jeton et le secret qu'il a émis.");
        }
        return mapper.server(servers.pairWithCredentials(id, r.adminUser(), r.adminPassword()));
    }

    @PostMapping("/api/v1/execution-servers/{id}/unpair")
    @PreAuthorize(ADMIN)
    public ServerResponse unpair(@PathVariable UUID id) {
        return mapper.server(servers.unpair(id));
    }

    /** §12 test de connexion : santé, capacités, jeton accepté. */
    @PostMapping("/api/v1/execution-servers/{id}/test-connection")
    @PreAuthorize(ADMIN)
    public ServerResponse testConnection(@PathVariable UUID id) {
        return mapper.server(servers.testConnection(id));
    }

    @GetMapping("/api/v1/projects/{projectKey}/execution-servers")
    @PreAuthorize(LAUNCH)
    public List<ServerChoice> choices(@PathVariable String projectKey) {
        return servers.list().stream().filter(ExecutionServer::isEnabled).map(mapper::choice).toList();
    }
}
