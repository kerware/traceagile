package com.traceagile.api.demo;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.traceagile.application.automation.ExecutionServerService;
import com.traceagile.domain.automation.ExecutionServer;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** ADR-0026 profil demo : le serveur d'exécution réel est déclaré et appairé s'il est configuré. */
class DemoExecutionServerPairingTest {

    private final ExecutionServerService servers = mock(ExecutionServerService.class);

    private DemoAutomationLoader loader(String executionServerUrl) {
        return new DemoAutomationLoader(servers, null, null, null, null, "http://simulateur:8090", "admin", "simulateur", executionServerUrl,
                "admin", "executeur");
    }

    @Test
    @DisplayName("ADR-0026 sans URL configurée, aucun serveur réel n'est déclaré")
    void disabled() {
        loader("").pairExecutionServer();
        verify(servers, never()).create(anyString(), anyString());
    }

    @Test
    @DisplayName("ADR-0026 avec une URL, « Serveur d'exécution » est déclaré puis appairé avec les identifiants de son administrateur")
    void pairs() {
        ExecutionServer server = mock(ExecutionServer.class);
        UUID id = UUID.randomUUID();
        when(server.getId()).thenReturn(id);
        when(server.getName()).thenReturn(DemoAutomationLoader.EXECUTION_SERVER_NAME);
        when(server.isPaired()).thenReturn(false);
        when(servers.list()).thenReturn(List.of());
        when(servers.create(DemoAutomationLoader.EXECUTION_SERVER_NAME, "http://execution-server:8091")).thenReturn(server);
        loader("http://execution-server:8091").pairExecutionServer();
        verify(servers).pairWithCredentials(id, "admin", "executeur");
    }

    @Test
    @DisplayName("ADR-0026 un serveur déjà appairé (jeton accepté) n'est pas réappairé")
    void alreadyPaired() {
        ExecutionServer server = mock(ExecutionServer.class);
        when(server.getName()).thenReturn(DemoAutomationLoader.EXECUTION_SERVER_NAME);
        when(server.isPaired()).thenReturn(true);
        when(server.getStatus()).thenReturn(com.traceagile.domain.automation.ServerStatus.ONLINE);
        when(servers.list()).thenReturn(List.of(server));
        loader("http://execution-server:8091").pairExecutionServer();
        verify(servers, never()).pairWithCredentials(any(), anyString(), anyString());
    }
}
