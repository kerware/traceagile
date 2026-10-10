package com.traceagile.api;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.request;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.traceagile.application.automation.AutomatedRunService;
import com.traceagile.application.automation.ExecutionServerClient;
import com.traceagile.application.automation.ExecutionServerClient.Capabilities;
import com.traceagile.application.automation.ExecutionServerClient.IssuedToken;
import com.traceagile.application.automation.ExecutionServerClient.JobRequest;
import com.traceagile.application.automation.RunEvent;
import com.traceagile.domain.administration.ProjectRole;
import com.traceagile.domain.automation.WebhookSignature;
import com.traceagile.domain.testcase.TestTechnique;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.ResultActions;

/** §8.5 runs automatisés, §10 contrat du serveur d'exécution (jeton émis par le serveur, ADR-0020), F-EXE-10 import, F-EXE-11 instables. */
class AutomatedRunApiTest extends AbstractApiTest {

    static final String P = "/api/v1/projects/SHOP";
    static final String SECRET = "whs_secret-du-serveur";

    @MockitoBean
    ExecutionServerClient client;
    @Autowired
    AutomatedRunService runService;
    @Autowired
    JdbcTemplate db;

    String admin;
    String dev;
    String qa;
    String serverId;

    @BeforeEach
    void data() throws Exception {
        user("admin", true);
        user("po", false);
        user("qa1", false);
        user("dev", false);
        user("viewer", false);
        project("SHOP", Map.of("po", ProjectRole.PRODUCT_OWNER, "qa1", ProjectRole.TESTER, "dev", ProjectRole.DEVELOPER, "viewer", ProjectRole.VIEWER));
        admin = bearer("admin");
        dev = bearer("dev");
        qa = bearer("qa1");
        String po = bearer("po");
        send(po, P + "/requirements", Map.of("type", "FEATURE", "title", "Panier"));
        send(po, P + "/requirements", Map.of("type", "USER_STORY", "title", "Ajouter au panier", "parentKey", "REQ-1"));
        // TC-1, TC-2 (@fail) API liés à REQ-2 ; TC-3 UI (technique non prise en charge par le serveur)
        automated("CartApiTest#add", TestTechnique.API, "REQ-2");
        automated("CartApiTest#total @fail", TestTechnique.API, "REQ-2");
        automated("panier.spec.ts › ajoute", TestTechnique.UI, null);
        for (String key : List.of("TC-1", "TC-2", "TC-3")) {
            send(qa, P + "/test-cases/" + key + "/status", Map.of("status", "READY"));
        }
        mvc.perform(post(P + "/campaigns").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("name", "Régression", "scopeType", "REGRESSION", "environment", "recette", "buildVersion", "2.0.0"))))
                .andExpect(status().isCreated());
        send(qa, P + "/campaigns/CMP-1/items/select", Map.of("strategy", "MANUAL", "testKeys", List.of("TC-1", "TC-2", "TC-3")));

        when(client.requestToken(anyString(), eq("admin-serveur"), eq("secret-admin"), anyString()))
                .thenReturn(new IssuedToken("tok-1", "ets_jeton-emis-par-le-serveur", SECRET));
        when(client.requestToken(anyString(), eq("admin-serveur"), eq("faux"), anyString()))
                .thenThrow(new ExecutionServerClient.UnauthorizedException("refus"));
        when(client.probe(any())).thenReturn(new Capabilities("1.0.0", List.of(TestTechnique.API, TestTechnique.BDD), List.of("rest-assured"),
                List.of("recette"), 2));
        when(client.submit(any(), any())).thenReturn("job-1");
        serverId = pairedServer();
    }

    JsonNode send(String token, String url, Object body) throws Exception {
        String json = mvc.perform(post(url).header("Authorization", token).contentType(MediaType.APPLICATION_JSON).content(toJson(body)))
                .andExpect(status().is2xxSuccessful()).andReturn().getResponse().getContentAsString();
        return json.isBlank() ? null : readJson(json);
    }

    void automated(String identifier, TestTechnique technique, String requirementKey) throws Exception {
        Map<String, Object> body = new LinkedHashMap<>(Map.of("kind", "AUTOMATED", "title", "Test " + identifier, "technique", technique.name(),
                "repositoryUrl", "https://git.example.com/shop.git", "branch", "main", "testIdentifier", identifier));
        if (requirementKey != null) {
            body.put("links", List.of(Map.of("requirementKey", requirementKey, "linkType", "VERIFIES")));
        }
        send(dev, P + "/test-cases", body);
    }

    String pairedServer() throws Exception {
        String id = send(admin, "/api/v1/execution-servers", Map.of("name", "Simulateur", "baseUrl", "http://simulateur:8090/")).get("id").asText();
        send(admin, "/api/v1/execution-servers/" + id + "/pair", Map.of("adminUser", "admin-serveur", "adminPassword", "secret-admin"));
        return id;
    }

    JsonNode launch(String token, Map<String, Object> body) throws Exception {
        return readJson(mvc.perform(post(P + "/campaigns/CMP-1/runs").header("Authorization", token).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(body))).andExpect(status().isCreated()).andReturn().getResponse().getContentAsString());
    }

    List<String> itemIds(String... keys) throws Exception {
        JsonNode items = readJson(mvc.perform(get(P + "/campaigns/CMP-1").header("Authorization", qa)).andReturn().getResponse().getContentAsString())
                .get("items");
        List<String> ids = new java.util.ArrayList<>();
        for (String key : keys) {
            items.forEach(i -> {
                if (i.get("test").get("key").asText().equals(key)) {
                    ids.add(i.get("id").asText());
                }
            });
        }
        return ids;
    }

    String executionOf(JsonNode run, String testKey) {
        for (JsonNode e : run.get("executions")) {
            if (e.get("test").get("key").asText().equals(testKey)) {
                return e.get("id").asText();
            }
        }
        throw new IllegalStateException(testKey);
    }

    ResultActions webhook(Map<String, Object> event, String secret) throws Exception {
        byte[] body = toJson(event).getBytes(StandardCharsets.UTF_8);
        return mvc.perform(post("/api/v1/execution-callbacks").contentType(MediaType.APPLICATION_JSON).content(body)
                .header(WebhookSignature.HEADER, WebhookSignature.sign(secret, body)));
    }

    static Map<String, Object> event(String type, String runId, Map<String, Object> fields) {
        Map<String, Object> event = new LinkedHashMap<>();
        event.put("eventId", UUID.randomUUID().toString());
        event.put("event", type);
        event.put("runId", runId);
        event.put("jobId", "job-1");
        event.put("occurredAt", "2026-10-12T09:00:00Z");
        event.putAll(fields);
        return event;
    }

    void finishRun(String runKey, JsonNode run, Map<String, String> results) throws Exception {
        webhook(event("JOB_STARTED", runKey, Map.of("agent", "agent-1")), SECRET).andExpect(status().isOk());
        for (Map.Entry<String, String> result : results.entrySet()) {
            webhook(event("TEST_FINISHED", runKey, Map.of("executionId", executionOf(run, result.getKey()), "status", result.getValue(),
                    "durationMs", 900, "message", result.getValue().equals("PASSED") ? "" : "AssertionError")), SECRET).andExpect(status().isOk());
        }
        webhook(event("JOB_FINISHED", runKey, Map.of("status", "COMPLETED", "summary", Map.of("total", results.size(), "passed", 0, "failed", 0,
                "error", 0, "skipped", 0))), SECRET).andExpect(status().isOk());
    }

    @Test
    @DisplayName("ADR-0020 serveurs : appairage par un jeton émis par le serveur, jamais renvoyé et chiffré en base ; droits ; refus du serveur")
    void servers() throws Exception {
        mvc.perform(get("/api/v1/execution-servers").header("Authorization", admin))
                .andExpect(jsonPath("$[0].name", is("Simulateur")))
                .andExpect(jsonPath("$[0].baseUrl", is("http://simulateur:8090")))
                .andExpect(jsonPath("$[0].paired", is(true)))
                .andExpect(jsonPath("$[0].tokenHint", is("veur")))
                .andExpect(jsonPath("$[0].status", is("ONLINE")))
                .andExpect(jsonPath("$[0].techniques", contains("API", "BDD")))
                .andExpect(jsonPath("$[0].token").doesNotExist());
        String raw = mvc.perform(get("/api/v1/execution-servers").header("Authorization", admin)).andReturn().getResponse().getContentAsString();
        assertThat(raw).doesNotContain("ets_jeton").doesNotContain(SECRET);
        assertThat(db.queryForObject("select api_token from execution_servers", String.class)).doesNotContain("ets_jeton");
        verify(client).requestToken(eq("http://simulateur:8090"), eq("admin-serveur"), eq("secret-admin"), anyString());

        mvc.perform(get("/api/v1/execution-servers").header("Authorization", dev)).andExpect(status().isForbidden());
        mvc.perform(get(P + "/execution-servers").header("Authorization", dev))
                .andExpect(jsonPath("$[0].usable", is(true)))
                .andExpect(jsonPath("$[0].techniques", contains("API", "BDD")));
        mvc.perform(post("/api/v1/execution-servers/" + serverId + "/pair").header("Authorization", admin).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("adminUser", "admin-serveur", "adminPassword", "faux"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("SERVER_ADMIN_REJECTED")));
        // jeton révoqué côté serveur : le test de connexion le signale
        when(client.probe(any())).thenThrow(new ExecutionServerClient.UnauthorizedException("401"));
        mvc.perform(post("/api/v1/execution-servers/" + serverId + "/test-connection").header("Authorization", admin))
                .andExpect(jsonPath("$.status", is("UNAUTHORIZED")));
        mvc.perform(post(P + "/campaigns/CMP-1/runs").header("Authorization", dev).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("serverId", serverId))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("SERVER_UNAUTHORIZED")));
        // jeton émis sur le serveur puis saisi
        doReturn(new Capabilities("1.0.0", List.of(TestTechnique.API), List.of(), List.of(), 1)).when(client).probe(any());
        send(admin, "/api/v1/execution-servers/" + serverId + "/pair", Map.of("token", "ets_saisi-1234", "webhookSecret", "whs_saisi"));
        mvc.perform(get("/api/v1/execution-servers").header("Authorization", admin))
                .andExpect(jsonPath("$[0].tokenHint", is("1234")))
                .andExpect(jsonPath("$[0].status", is("ONLINE")));
    }

    @Test
    @DisplayName("Lot 7 — critère de fin (§15.3 étape 4) : run lancé, résultats par webhooks signés, le test @fail échoue et rend l'exigence rouge")
    void runJourney() throws Exception {
        JsonNode run = launch(dev, Map.of("serverId", serverId, "itemIds", itemIds("TC-1", "TC-2")));
        assertThat(run.at("/run/key").asText()).isEqualTo("RUN-1");
        assertThat(run.at("/run/status").asText()).isEqualTo("DISPATCHED");
        assertThat(run.at("/run/externalJobId").asText()).isEqualTo("job-1");
        assertThat(run.at("/run/counts/pending").asInt()).isEqualTo(2);
        ArgumentCaptor<JobRequest> job = ArgumentCaptor.forClass(JobRequest.class);
        verify(client).submit(any(), job.capture());
        assertThat(job.getValue().runId()).isEqualTo("RUN-1");
        assertThat(job.getValue().buildVersion()).isEqualTo("2.0.0");
        assertThat(job.getValue().callbackUrl()).endsWith("/api/v1/execution-callbacks");
        assertThat(job.getValue().repositoryUrl()).isEqualTo("https://git.example.com/shop.git");
        assertThat(job.getValue().tests()).extracting(ExecutionServerClient.JobTest::testIdentifier).containsExactly("CartApiTest#add", "CartApiTest#total @fail");
        mvc.perform(get(P + "/runs/RUN-1/events").header("Authorization", qa)).andExpect(request().asyncStarted());

        webhook(event("JOB_STARTED", "RUN-1", Map.of("agent", "agent-1")), SECRET).andExpect(status().isOk());
        Map<String, Object> started = event("TEST_STARTED", "RUN-1", Map.of("executionId", executionOf(run, "TC-1")));
        webhook(started, SECRET).andExpect(status().isOk());
        mvc.perform(get(P + "/runs/RUN-1").header("Authorization", qa))
                .andExpect(jsonPath("$.run.status", is("RUNNING")))
                .andExpect(jsonPath("$.run.agent", is("agent-1")))
                .andExpect(jsonPath("$.run.counts.running", is(1)));
        webhook(event("TEST_FINISHED", "RUN-1", Map.of("executionId", executionOf(run, "TC-1"), "status", "PASSED", "durationMs", 812)), SECRET)
                .andExpect(status().isOk());
        webhook(event("TEST_FINISHED", "RUN-1", Map.of("executionId", executionOf(run, "TC-2"), "status", "FAILED", "durationMs", 640,
                "message", "AssertionError : total attendu 12,50 €", "stackTrace", "at CartApiTest.total(CartApiTest.java:42)")), SECRET)
                .andExpect(status().isOk());
        // §10.4 doublon ignoré, signature fausse 401, run inconnu 404
        webhook(started, SECRET).andExpect(status().isOk());
        webhook(event("JOB_STARTED", "RUN-1", Map.of()), "whs_mauvais").andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code", is("WEBHOOK_SIGNATURE_INVALID")));
        mvc.perform(post("/api/v1/execution-callbacks").contentType(MediaType.APPLICATION_JSON).content(toJson(event("JOB_STARTED", "RUN-1", Map.of()))))
                .andExpect(status().isUnauthorized());
        webhook(event("JOB_STARTED", "RUN-99", Map.of()), SECRET).andExpect(status().isNotFound());
        webhook(event("JOB_FINISHED", "RUN-1", Map.of("status", "COMPLETED", "summary", Map.of("total", 2, "passed", 1, "failed", 1, "error", 0,
                "skipped", 0), "reportUrl", "http://simulateur/report.json", "logsUrl", "http://simulateur/logs")), SECRET).andExpect(status().isOk());

        mvc.perform(get(P + "/runs/RUN-1").header("Authorization", qa))
                .andExpect(jsonPath("$.run.status", is("COMPLETED")))
                .andExpect(jsonPath("$.run.counts.passed", is(1)))
                .andExpect(jsonPath("$.run.counts.failed", is(1)))
                .andExpect(jsonPath("$.cancellable", is(false)))
                .andExpect(jsonPath("$.executions[1].message", is("AssertionError : total attendu 12,50 €\nat CartApiTest.total(CartApiTest.java:42)")))
                .andExpect(jsonPath("$.executions[0].durationMs", is(812)));
        mvc.perform(get(P + "/campaigns/CMP-1").header("Authorization", qa))
                .andExpect(jsonPath("$.items[0].lastStatus", is("PASSED")))
                .andExpect(jsonPath("$.items[1].lastStatus", is("FAILED")));
        mvc.perform(get(P + "/requirements/REQ-2").header("Authorization", qa)).andExpect(jsonPath("$.verificationStatus", is("FAILED")));
        mvc.perform(get(P + "/campaigns/CMP-1/runs").header("Authorization", qa)).andExpect(jsonPath("$[0].key", is("RUN-1")));
        // événement tardif après la fin : ignoré
        webhook(event("TEST_FINISHED", "RUN-1", Map.of("executionId", executionOf(run, "TC-1"), "status", "FAILED")), SECRET).andExpect(status().isOk());
        mvc.perform(get(P + "/runs/RUN-1").header("Authorization", qa)).andExpect(jsonPath("$.executions[0].status", is("PASSED")));

        // F-EXE-09 relance des échecs : un nouveau run avec TC-2 seul
        JsonNode rerun = readJson(mvc.perform(post(P + "/runs/RUN-1/rerun-failed").header("Authorization", dev))
                .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString());
        assertThat(rerun.at("/run/key").asText()).isEqualTo("RUN-2");
        assertThat(rerun.at("/run/rerunOf").asText()).isEqualTo("RUN-1");
        assertThat(rerun.get("executions")).hasSize(1);
        assertThat(rerun.at("/executions/0/test/key").asText()).isEqualTo("TC-2");
    }

    @Test
    @DisplayName("F-EXE-06 règles : droits, technique non prise en charge, test déjà en cours ; F-EXE-08 annulation ; envoi refusé → run en échec")
    void rules() throws Exception {
        mvc.perform(post(P + "/campaigns/CMP-1/runs").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("serverId", serverId)))).andExpect(status().isForbidden());
        mvc.perform(post(P + "/campaigns/CMP-1/runs").header("Authorization", dev).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("serverId", serverId))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("RUN_TECHNIQUE_UNSUPPORTED")));
        launch(dev, Map.of("serverId", serverId, "itemIds", itemIds("TC-1")));
        mvc.perform(post(P + "/campaigns/CMP-1/runs").header("Authorization", dev).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("serverId", serverId, "itemIds", itemIds("TC-1")))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("RUN_ITEM_BUSY")));
        mvc.perform(post(P + "/runs/RUN-1/cancel").header("Authorization", dev))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.run.status", is("CANCELLED")))
                .andExpect(jsonPath("$.executions[0].status", is("SKIPPED")));
        verify(client).cancel(any(), eq("job-1"));
        mvc.perform(post(P + "/runs/RUN-1/cancel").header("Authorization", dev)).andExpect(status().isUnprocessableEntity());
        mvc.perform(delete("/api/v1/execution-servers/" + serverId).header("Authorization", admin)).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("SERVER_IN_USE")));

        when(client.submit(any(), any())).thenThrow(new ExecutionServerClient.UnavailableException("Connection refused", null));
        JsonNode failed = launch(dev, Map.of("serverId", serverId, "itemIds", itemIds("TC-1")));
        assertThat(failed.at("/run/status").asText()).isEqualTo("FAILED");
        assertThat(failed.at("/run/errorCode").asText()).isEqualTo("SERVER_UNREACHABLE");
        assertThat(failed.at("/executions/0/status").asText()).isEqualTo("ERROR");
    }

    @Test
    @DisplayName("§10.4 TIMEOUT après timeoutMinutes + 5 min sans événement, après un dernier polling (§10.1) qui rattrape les résultats manqués")
    void timeoutAndPolling() throws Exception {
        JsonNode run = launch(dev, Map.of("serverId", serverId, "itemIds", itemIds("TC-1", "TC-2"), "timeoutMinutes", 10));
        db.update("update automated_runs set last_event_at = now() - interval '16 minutes' where run_key = 'RUN-1'");
        when(client.poll(any(), eq("job-1"))).thenReturn(List.of(new RunEvent("p1", "TEST_FINISHED", "RUN-1", "job-1",
                java.time.Instant.now().minusSeconds(900), null,
                executionOf(run, "TC-1"), "PASSED", 500L, null, null, null, null, null, null, null, null)));
        runService.checkTimeouts();
        mvc.perform(get(P + "/runs/RUN-1").header("Authorization", qa))
                .andExpect(jsonPath("$.run.status", is("TIMEOUT")))
                .andExpect(jsonPath("$.run.errorCode", is("TIMEOUT")))
                .andExpect(jsonPath("$.executions[*].status", containsInAnyOrder("PASSED", "ERROR")));
    }

    @Test
    @DisplayName("F-EXE-11 un test qui alterne réussite et échec sur le même build est marqué instable")
    void flaky() throws Exception {
        for (String result : List.of("PASSED", "FAILED", "PASSED")) {
            JsonNode run = launch(dev, Map.of("serverId", serverId, "itemIds", itemIds("TC-1")));
            finishRun(run.at("/run/key").asText(), run, Map.of("TC-1", result));
        }
        mvc.perform(get(P + "/test-cases/TC-1").header("Authorization", qa)).andExpect(jsonPath("$.flaky", is(true)));
        mvc.perform(get(P + "/test-cases/TC-2").header("Authorization", qa)).andExpect(jsonPath("$.flaky", is(false)));
        mvc.perform(get(P + "/runs/RUN-3").header("Authorization", qa)).andExpect(jsonPath("$.executions[0].flaky", is(true)));
    }

    @Test
    @DisplayName("F-EXE-10 import JUnit : aperçu (rapprochement par identifiant ou tag d'exigence), puis application avec création des inconnus")
    void importReport() throws Exception {
        String junit = """
                <testsuite name="CartApiTest">
                  <testcase classname="com.shop.CartApiTest" name="add" time="0.4"/>
                  <testcase classname="com.shop.CheckoutTest" name="pay" time="1.2"><failure message="refusé"/></testcase>
                </testsuite>""";
        MockMultipartFile file = new MockMultipartFile("file", "junit.xml", "application/xml", junit.getBytes(StandardCharsets.UTF_8));
        mvc.perform(multipart(P + "/campaigns/CMP-1/imports").file(file).param("format", "JUNIT").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.applied", is(false)))
                .andExpect(jsonPath("$.lines", hasSize(2)))
                .andExpect(jsonPath("$.lines[0].testKey", is("TC-1")))
                .andExpect(jsonPath("$.lines[0].matchedBy", is("IDENTIFIER")))
                .andExpect(jsonPath("$.lines[1].testKey").doesNotExist());
        mvc.perform(multipart(P + "/campaigns/CMP-1/imports").file(file).param("format", "JUNIT").param("apply", "true").param("createUnknown", "true")
                        .header("Authorization", qa))
                .andExpect(jsonPath("$.applied", is(true)))
                .andExpect(jsonPath("$.created", contains("TC-4")))
                .andExpect(jsonPath("$.recorded", is(2)));
        mvc.perform(get(P + "/test-cases/TC-4").header("Authorization", qa))
                .andExpect(jsonPath("$.kind", is("AUTOMATED")))
                .andExpect(jsonPath("$.automation.technique", is("UNIT")))
                .andExpect(jsonPath("$.automation.testIdentifier", is("com.shop.CheckoutTest#pay")));
        mvc.perform(get(P + "/campaigns/CMP-1").header("Authorization", qa))
                .andExpect(jsonPath("$.items[?(@.test.key == 'TC-4')].lastStatus", contains("FAILED")))
                .andExpect(jsonPath("$.items[?(@.test.key == 'TC-1')].lastStatus", contains("PASSED")));
        mvc.perform(multipart(P + "/campaigns/CMP-1/imports").file(new MockMultipartFile("file", "x.json", "application/json", "{}".getBytes()))
                .param("format", "JUNIT").header("Authorization", qa)).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("REPORT_INVALID")));
        mvc.perform(multipart(P + "/campaigns/CMP-1/imports").file(file).param("format", "JUNIT").header("Authorization", bearer("viewer")))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("ADR-0021 artefacts : copie d'écran annoncée par TEST_FINISHED, traces système, JUnit XML et Jest JSON par JOB_FINISHED ; contenu relu sur le serveur")
    void artifacts() throws Exception {
        JsonNode run = launch(dev, Map.of("serverId", serverId, "itemIds", itemIds("TC-1", "TC-2")));
        String failed = executionOf(run, "TC-2");
        webhook(event("TEST_FINISHED", "RUN-1", Map.of("executionId", failed, "status", "FAILED", "durationMs", 640, "message", "AssertionError",
                "artifacts", List.of(Map.of("name", "screenshot-TC-2.png", "type", "image/png", "kind", "SCREENSHOT", "size", 3198,
                        "executionId", failed)))), SECRET).andExpect(status().isOk());
        webhook(event("JOB_FINISHED", "RUN-1", Map.of("status", "COMPLETED", "artifacts", List.of(
                Map.of("name", "system.log", "type", "text/plain", "kind", "SYSTEM_TRACE"),
                Map.of("name", "junit.xml", "type", "application/xml", "kind", "JUNIT"),
                Map.of("name", "jest.json", "type", "application/json", "kind", "JEST"),
                Map.of("name", "../secret", "type", "text/plain")))), SECRET).andExpect(status().isOk());
        when(client.artifacts(any(), eq("job-1"))).thenReturn(List.of(new RunEvent.ArtifactRef("report.json", "application/json", "REPORT", 223L, null)));

        mvc.perform(get(P + "/runs/RUN-1/artifacts").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].name", contains("screenshot-TC-2.png", "jest.json", "junit.xml", "report.json", "system.log")))
                .andExpect(jsonPath("$[0].kind", is("SCREENSHOT")))
                .andExpect(jsonPath("$[0].testKey", is("TC-2")))
                .andExpect(jsonPath("$[4].kind", is("SYSTEM_TRACE")));
        mvc.perform(get(P + "/runs/RUN-1").header("Authorization", qa))
                .andExpect(jsonPath("$.executions[1].screenshot", is("screenshot-TC-2.png")))
                .andExpect(jsonPath("$.executions[0].screenshot").doesNotExist());

        byte[] png = {(byte) 0x89, 'P', 'N', 'G'};
        when(client.download(any(), eq("job-1"), eq("screenshot-TC-2.png"))).thenReturn(new ExecutionServerClient.ArtifactContent(png, "image/png"));
        when(client.download(any(), eq("job-1"), eq("junit.xml")))
                .thenReturn(new ExecutionServerClient.ArtifactContent("<testsuites/>".getBytes(StandardCharsets.UTF_8), "application/xml"));
        mvc.perform(get(P + "/runs/RUN-1/artifacts/screenshot-TC-2.png").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.content().contentType("image/png"))
                .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.content().bytes(png))
                .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.header().string("Content-Disposition",
                        org.hamcrest.Matchers.startsWith("inline")));
        mvc.perform(get(P + "/runs/RUN-1/artifacts/junit.xml").param("download", "true").header("Authorization", qa))
                .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.header().string("Content-Disposition",
                        org.hamcrest.Matchers.startsWith("attachment")));
        mvc.perform(get(P + "/runs/RUN-1/artifacts/inconnu.txt").header("Authorization", qa)).andExpect(status().isNotFound());
        when(client.download(any(), eq("job-1"), eq("jest.json"))).thenThrow(new ExecutionServerClient.UnavailableException("HTTP 404", null));
        mvc.perform(get(P + "/runs/RUN-1/artifacts/jest.json").header("Authorization", qa)).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("ARTIFACT_UNAVAILABLE")));
        mvc.perform(get(P + "/runs/RUN-1/artifacts").header("Authorization", bearer("viewer"))).andExpect(status().isOk());
    }

    @Test
    @DisplayName("ADR-0021 import d'un rapport Jest JSON : rapprochement par identifiant « describe#titre »")
    void importJest() throws Exception {
        String jest = """
                {"testResults":[{"name":"/app/cart.test.ts","assertionResults":[
                  {"ancestorTitles":["CartApiTest"],"title":"add","fullName":"CartApiTest add","status":"failed","duration":40,"failureMessages":["boom"]}]}]}""";
        MockMultipartFile file = new MockMultipartFile("file", "jest.json", "application/json", jest.getBytes(StandardCharsets.UTF_8));
        mvc.perform(multipart(P + "/campaigns/CMP-1/imports").file(file).param("format", "JEST").param("apply", "true").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.lines[0].testKey", is("TC-1")))
                .andExpect(jsonPath("$.recorded", is(1)));
    }

    @Autowired
    javax.sql.DataSource dataSource;

    @Test
    @DisplayName("F-EXE-07 un flux SSE ouvert ne garde pas de connexion JDBC (sinon dix onglets épuisent le pool)")
    void streamsDoNotHoldConnections() throws Exception {
        launch(dev, Map.of("serverId", serverId, "itemIds", itemIds("TC-1")));
        com.zaxxer.hikari.HikariPoolMXBean pool = dataSource.unwrap(com.zaxxer.hikari.HikariDataSource.class).getHikariPoolMXBean();
        for (int i = 0; i < 3; i++) {
            mvc.perform(get(P + "/runs/RUN-1/events").header("Authorization", qa)).andExpect(request().asyncStarted());
            mvc.perform(get(P + "/campaigns/CMP-1/run-events").header("Authorization", qa)).andExpect(request().asyncStarted());
        }
        assertThat(pool.getActiveConnections()).isZero();
    }

    @Test
    @DisplayName("F-REQ-18 un test de performance lié à une ENF remonte une valeur mesurée (metrics de TEST_FINISHED), comparée au seuil et à la cible ; saisie manuelle")
    void nfrMeasurements() throws Exception {
        String po = bearer("po");
        send(po, P + "/requirements", Map.of("type", "NON_FUNCTIONAL", "title", "Temps de réponse du panier", "category", "PERFORMANCE",
                "minimumThreshold", "1500", "target", "800", "unit", "ms"));
        org.springframework.test.web.servlet.ResultActions link = mvc.perform(post(P + "/trace-links").header("Authorization", dev)
                .contentType(MediaType.APPLICATION_JSON).content(toJson(Map.of("testKey", "TC-1", "requirementKey", "REQ-3", "linkType", "VERIFIES"))));
        link.andExpect(status().is2xxSuccessful());
        JsonNode run = launch(dev, Map.of("serverId", serverId, "itemIds", itemIds("TC-1")));
        webhook(event("TEST_FINISHED", "RUN-1", Map.of("executionId", executionOf(run, "TC-1"), "status", "PASSED", "durationMs", 900,
                "metrics", Map.of("throughputRps", 140, "p95Ms", 1200))), SECRET).andExpect(status().isOk());

        mvc.perform(get(P + "/requirements/REQ-3/measurements").header("Authorization", bearer("viewer")))
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].value", is(1200.0)))
                .andExpect(jsonPath("$[0].metric", is("p95Ms")))
                .andExpect(jsonPath("$[0].unit", is("ms")))
                .andExpect(jsonPath("$[0].testKey", is("TC-1")))
                .andExpect(jsonPath("$[0].runKey", is("RUN-1")))
                .andExpect(jsonPath("$[0].outcome", is("THRESHOLD_MET")));
        // REQ-2 (story) n'a pas de mesure : seules les ENF vérifiées par le test en reçoivent une
        mvc.perform(get(P + "/requirements/REQ-2/measurements").header("Authorization", qa)).andExpect(jsonPath("$", hasSize(0)));

        mvc.perform(post(P + "/requirements/REQ-3/measurements").header("Authorization", bearer("viewer")).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("value", 700)))).andExpect(status().isForbidden());
        mvc.perform(post(P + "/requirements/REQ-3/measurements").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("value", 700))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.outcome", is("TARGET_MET")))
                .andExpect(jsonPath("$.testKey").doesNotExist());
        mvc.perform(post(P + "/requirements/REQ-2/measurements").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("value", 1)))).andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("MEASUREMENT_NFR_ONLY")));
        mvc.perform(post(P + "/requirements/REQ-3/measurements").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of()))).andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("NF-06 webhooks désordonnés : un TEST_STARTED arrivé après TEST_FINISHED, un second TEST_FINISHED contradictoire sont sans effet")
    void outOfOrderWebhooks() throws Exception {
        JsonNode run = launch(dev, Map.of("serverId", serverId, "itemIds", itemIds("TC-1")));
        String execution = executionOf(run, "TC-1");
        webhook(event("TEST_FINISHED", "RUN-1", Map.of("executionId", execution, "status", "PASSED", "durationMs", 400)), SECRET)
                .andExpect(status().isOk());
        webhook(event("TEST_STARTED", "RUN-1", Map.of("executionId", execution)), SECRET).andExpect(status().isOk());
        webhook(event("TEST_FINISHED", "RUN-1", Map.of("executionId", execution, "status", "FAILED", "durationMs", 900)), SECRET)
                .andExpect(status().isOk());
        mvc.perform(get(P + "/runs/RUN-1").header("Authorization", qa))
                .andExpect(jsonPath("$.executions[0].status", is("PASSED")))
                .andExpect(jsonPath("$.executions[0].durationMs", is(400)));
    }
}
