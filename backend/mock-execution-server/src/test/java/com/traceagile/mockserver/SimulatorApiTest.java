package com.traceagile.mockserver;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.startsWith;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.atLeast;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

/** §10.2 / §10.5 simulateur : jetons émis par le serveur (ADR-0020), jobs asynchrones, webhooks, idempotence, annulation. */
@SpringBootTest(properties = {"simulator.min-delay-ms=0", "simulator.max-delay-ms=0", "simulator.pass-rate=1", "simulator.error-rate=0"})
@AutoConfigureMockMvc
class SimulatorApiTest {

    static final String ADMIN = "Basic " + Base64.getEncoder().encodeToString("admin:simulateur".getBytes(StandardCharsets.UTF_8));

    @Autowired
    MockMvc mvc;
    @Autowired
    ObjectMapper json;
    @MockitoBean
    WebhookSender webhooks;

    String token;
    String secret;
    String tokenId;

    @BeforeEach
    void pair() throws Exception {
        JsonNode issued = json.readTree(mvc.perform(post("/api/v1/tokens").header("Authorization", ADMIN).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"label\":\"TraceAgile test\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.token", startsWith("ets_")))
                .andExpect(jsonPath("$.webhookSecret", startsWith("whs_")))
                .andReturn().getResponse().getContentAsString());
        token = "Bearer " + issued.get("token").asText();
        secret = issued.get("webhookSecret").asText();
        tokenId = issued.get("tokenId").asText();
    }

    String submit(String runId, List<Map<String, Object>> tests) throws Exception {
        String body = json.writeValueAsString(Map.of("runId", runId, "project", "SHOP", "callbackUrl", "http://traceagile/api/v1/execution-callbacks",
                "tests", tests));
        return json.readTree(mvc.perform(post("/api/v1/jobs").header("Authorization", token).contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isAccepted()).andReturn().getResponse().getContentAsString()).get("jobId").asText();
    }

    JsonNode awaitStatus(String jobId, String expected) throws Exception {
        for (int i = 0; i < 100; i++) {
            JsonNode job = json.readTree(mvc.perform(get("/api/v1/jobs/" + jobId).header("Authorization", token)).andReturn().getResponse().getContentAsString());
            if (job.get("status").asText().equals(expected)) {
                return job;
            }
            Thread.sleep(50);
        }
        throw new AssertionError("Job " + jobId + " jamais " + expected);
    }

    static Map<String, Object> test(String key, String identifier) {
        return Map.of("executionId", "exec-" + key, "testKey", key, "technique", "API", "testIdentifier", identifier);
    }

    @Test
    @DisplayName("ADR-0020 le jeton est émis par le serveur à son administrateur ; sans jeton valide, 401 ; révoqué, refusé")
    void tokens() throws Exception {
        mvc.perform(post("/api/v1/tokens")).andExpect(status().isUnauthorized()).andExpect(jsonPath("$.code", is("ADMIN_REQUIRED")));
        mvc.perform(post("/api/v1/tokens").header("Authorization", "Basic " + Base64.getEncoder().encodeToString("admin:faux".getBytes())))
                .andExpect(status().isUnauthorized());
        mvc.perform(get("/api/v1/health")).andExpect(status().isOk());
        mvc.perform(get("/api/v1/capabilities")).andExpect(status().isUnauthorized()).andExpect(jsonPath("$.code", is("TOKEN_INVALID")));
        mvc.perform(get("/api/v1/capabilities").header("Authorization", "Bearer ets_inconnu")).andExpect(status().isUnauthorized());
        mvc.perform(get("/api/v1/capabilities").header("Authorization", token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.techniques", hasSize(8)))
                .andExpect(jsonPath("$.agents", is(2)));
        mvc.perform(get("/api/v1/tokens").header("Authorization", ADMIN))
                .andExpect(jsonPath("$[?(@.tokenId == '" + tokenId + "')].hint").exists())
                .andExpect(jsonPath("$[0].token").doesNotExist());
        mvc.perform(delete("/api/v1/tokens/" + tokenId).header("Authorization", ADMIN)).andExpect(status().isNoContent());
        mvc.perform(get("/api/v1/capabilities").header("Authorization", token)).andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("§10.4 / §10.5 job : JOB_STARTED, TEST_STARTED / TEST_FINISHED par test, JOB_FINISHED ; @fail échoue, @flaky alterne ; webhooks signés")
    void job() throws Exception {
        String jobId = submit("RUN-1", List.of(test("TC-1", "CartApiTest#add"), test("TC-2", "CartApiTest#total @fail"), test("TC-3", "Cart @flaky")));
        JsonNode done = awaitStatus(jobId, "COMPLETED");
        List<String> events = new ArrayList<>();
        done.get("results").forEach(e -> events.add(e.get("event").asText() + (e.has("status") ? ":" + e.get("status").asText() : "")));
        assertThat(events).containsExactly("JOB_STARTED", "TEST_STARTED", "TEST_FINISHED:PASSED", "TEST_STARTED", "TEST_FINISHED:FAILED",
                "TEST_STARTED", "TEST_FINISHED:PASSED", "JOB_FINISHED:COMPLETED");
        JsonNode finished = done.get("results").get(7);
        assertThat(finished.get("summary").get("failed").asInt()).isEqualTo(1);
        assertThat(finished.get("logsUrl").asText()).endsWith("/api/v1/jobs/" + jobId + "/logs");

        @SuppressWarnings("unchecked")
        ArgumentCaptor<Map<String, Object>> sent = ArgumentCaptor.forClass(Map.class);
        verify(webhooks, atLeast(8)).send(eq("http://traceagile/api/v1/execution-callbacks"), eq(secret), sent.capture());
        assertThat(sent.getAllValues()).allSatisfy(e -> assertThat(e).containsKeys("eventId", "runId", "jobId", "occurredAt"));

        // @flaky alterne d'un job à l'autre
        String second = submit("RUN-2", List.of(test("TC-3", "Cart @flaky")));
        assertThat(awaitStatus(second, "COMPLETED").get("results").get(2).get("status").asText()).isEqualTo("FAILED");
        mvc.perform(get("/api/v1/jobs/" + jobId + "/logs").header("Authorization", token)).andExpect(status().isOk());
        mvc.perform(get("/api/v1/jobs/" + jobId + "/artifacts/report.json").header("Authorization", token))
                .andExpect(jsonPath("$.summary.total", is(3)));
    }

    @Test
    @DisplayName("§10.1 idempotence par runId ; requête invalide 400 ; un jeton ne voit pas les jobs d'un autre ; annulation")
    void rules() throws Exception {
        List<Map<String, Object>> tests = new CopyOnWriteArrayList<>(List.of(test("TC-1", "A")));
        String first = submit("RUN-9", tests);
        assertThat(submit("RUN-9", tests)).isEqualTo(first);
        mvc.perform(post("/api/v1/jobs").header("Authorization", token).contentType(MediaType.APPLICATION_JSON).content("{\"runId\":\"RUN-10\"}"))
                .andExpect(status().isBadRequest());
        String other = "Bearer " + json.readTree(mvc.perform(post("/api/v1/tokens").header("Authorization", ADMIN))
                .andReturn().getResponse().getContentAsString()).get("token").asText();
        mvc.perform(get("/api/v1/jobs/" + first).header("Authorization", other)).andExpect(status().isNotFound());
        mvc.perform(post("/api/v1/jobs/" + first + "/cancel").header("Authorization", token)).andExpect(status().isAccepted());
        mvc.perform(post("/api/v1/jobs/job-inconnu/cancel").header("Authorization", token)).andExpect(status().isNotFound());
        verify(webhooks, atLeast(1)).send(anyString(), anyString(), any());
    }

    @Test
    @DisplayName("§10.1 signature HMAC-SHA256 des webhooks : vecteur de référence")
    void signature() {
        // HMAC-SHA256("key", "The quick brown fox jumps over the lazy dog")
        assertThat(WebhookSender.sign("key", "The quick brown fox jumps over the lazy dog".getBytes(StandardCharsets.UTF_8)))
                .isEqualTo("sha256=f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8");
    }

    @Test
    @DisplayName("ADR-0021 artefacts : traces système, JUnit XML, Jest JSON, rapport ; copie d'écran PNG de chaque échec, annoncée dans TEST_FINISHED")
    void artifacts() throws Exception {
        String jobId = submit("RUN-20", List.of(test("TC-1", "CartApiTest#add"), test("TC-2", "CartApiTest#total @fail")));
        JsonNode done = awaitStatus(jobId, "COMPLETED");
        JsonNode failed = done.get("results").get(4);
        assertThat(failed.get("event").asText()).isEqualTo("TEST_FINISHED");
        assertThat(failed.get("artifacts").get(0).get("name").asText()).isEqualTo("screenshot-TC-2.png");
        assertThat(failed.get("artifacts").get(0).get("kind").asText()).isEqualTo("SCREENSHOT");
        assertThat(failed.get("artifacts").get(0).get("executionId").asText()).isEqualTo("exec-TC-2");
        assertThat(done.get("results").get(2).get("artifacts")).isEmpty();
        JsonNode end = done.get("results").get(5);
        List<String> jobArtifacts = new ArrayList<>();
        end.get("artifacts").forEach(a -> jobArtifacts.add(a.get("name").asText()));
        assertThat(jobArtifacts).containsExactly("system.log", "junit.xml", "jest.json", "report.json");

        mvc.perform(get("/api/v1/jobs/" + jobId + "/artifacts").header("Authorization", token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].name", org.hamcrest.Matchers.containsInAnyOrder("screenshot-TC-2.png", "system.log", "junit.xml", "jest.json", "report.json")));
        String junit = mvc.perform(get("/api/v1/jobs/" + jobId + "/artifacts/junit.xml").header("Authorization", token))
                .andExpect(status().isOk()).andReturn().getResponse().getContentAsString(StandardCharsets.UTF_8);
        assertThat(junit).contains("<testcase classname=\"CartApiTest\" name=\"add\"").contains("<failure message=\"AssertionError simulée sur TC-2\"")
                .contains("<system-out>");
        JsonNode jest = json.readTree(mvc.perform(get("/api/v1/jobs/" + jobId + "/artifacts/jest.json").header("Authorization", token))
                .andReturn().getResponse().getContentAsString(StandardCharsets.UTF_8));
        assertThat(jest.get("numFailedTests").asInt()).isEqualTo(1);
        assertThat(jest.at("/testResults/0/assertionResults/1/status").asText()).isEqualTo("failed");
        assertThat(jest.at("/testResults/0/assertionResults/1/fullName").asText()).isEqualTo("CartApiTest total @fail");
        String system = mvc.perform(get("/api/v1/jobs/" + jobId + "/artifacts/system.log").header("Authorization", token))
                .andReturn().getResponse().getContentAsString(StandardCharsets.UTF_8);
        assertThat(system).contains("[system] agent=").contains("[TC-2] terminé : FAILED").contains("AssertionFailedError");
        byte[] png = mvc.perform(get("/api/v1/jobs/" + jobId + "/artifacts/screenshot-TC-2.png").header("Authorization", token))
                .andExpect(status().isOk()).andReturn().getResponse().getContentAsByteArray();
        assertThat(png).startsWith((byte) 0x89, (byte) 'P', (byte) 'N', (byte) 'G');
        mvc.perform(get("/api/v1/jobs/" + jobId + "/artifacts/inconnu.txt").header("Authorization", token)).andExpect(status().isNotFound());
    }
}
