package com.traceagile.executionserver;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.executionserver.job.WebhookSender;
import com.traceagile.executionserver.process.Platform;
import com.traceagile.executionserver.process.ToolEnvironment;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

/**
 * Base des tests d'API : serveur complet (MockMvc, H2 dans target/), processus scriptés
 * ({@link FakeProcessRunner}), webhooks capturés au lieu d'être envoyés.
 */
@SpringBootTest(properties = {
        "execution-server.data-dir=target/test-data",
        "execution-server.tools-dir=target/test-tools",
        "execution-server.admin-user=admin",
        "execution-server.admin-password=secret",
        "execution-server.agents=4",
        "spring.datasource.url=jdbc:h2:mem:execution-server;DB_CLOSE_DELAY=-1",
        "logging.file.name="})
@AutoConfigureMockMvc
@org.springframework.context.annotation.Import(AbstractServerTest.Processes.class)
public abstract class AbstractServerTest {

    @TestConfiguration
    static class Processes {
        @Bean
        @Primary
        FakeProcessRunner fakeProcessRunner() {
            return new FakeProcessRunner();
        }

        /** Recettes et lignes de commande de Linux, quelle que soit la machine qui lance les tests. */
        @Bean
        @Primary
        ToolEnvironment linuxToolEnvironment() {
            return new ToolEnvironment(java.nio.file.Path.of("target/test-tools").toAbsolutePath().normalize(), Platform.LINUX);
        }
    }

    protected static final String ADMIN = "Basic " + Base64.getEncoder().encodeToString("admin:secret".getBytes(StandardCharsets.UTF_8));

    @Autowired
    protected MockMvc mvc;
    @Autowired
    protected ObjectMapper json;
    @Autowired
    protected FakeProcessRunner processes;
    @Autowired
    protected JdbcClient db;
    @MockitoBean
    protected WebhookSender webhooks;

    protected final List<Map<String, Object>> sent = new CopyOnWriteArrayList<>();

    @BeforeEach
    void resetServer() {
        processes.reset();
        sent.clear();
        org.mockito.Mockito.when(webhooks.send(org.mockito.ArgumentMatchers.anyString(), org.mockito.ArgumentMatchers.anyString(),
                org.mockito.ArgumentMatchers.anyMap())).thenAnswer(invocation -> {
                    sent.add(invocation.getArgument(2));
                    return true;
                });
        for (String table : new String[] {"artifacts", "job_events", "job_tests", "jobs", "tokens", "tool_installs", "git_credentials"}) {
            db.sql("delete from " + table).update();
        }
    }

    /** Jeton émis par l'administrateur : « Bearer ets_… ». */
    protected String bearer() throws Exception {
        String body = mvc.perform(post("/api/v1/tokens").header("Authorization", ADMIN).contentType(MediaType.APPLICATION_JSON)
                .content("{\"label\":\"TraceAgile\"}")).andReturn().getResponse().getContentAsString();
        return "Bearer " + json.readTree(body).get("token").asText();
    }

    protected JsonNode read(String body) throws Exception {
        return json.readTree(body);
    }

    protected List<String> sentTypes() {
        List<String> types = new ArrayList<>();
        sent.forEach(e -> types.add(String.valueOf(e.get("event"))));
        return types;
    }

    protected String toJson(Object value) throws Exception {
        return json.writeValueAsString(value);
    }
}
