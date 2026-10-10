package com.traceagile.infrastructure.automation;

import static com.github.tomakehurst.wiremock.client.WireMock.aResponse;
import static com.github.tomakehurst.wiremock.client.WireMock.equalTo;
import static com.github.tomakehurst.wiremock.client.WireMock.equalToJson;
import static com.github.tomakehurst.wiremock.client.WireMock.get;
import static com.github.tomakehurst.wiremock.client.WireMock.matchingJsonPath;
import static com.github.tomakehurst.wiremock.client.WireMock.okJson;
import static com.github.tomakehurst.wiremock.client.WireMock.post;
import static com.github.tomakehurst.wiremock.client.WireMock.postRequestedFor;
import static com.github.tomakehurst.wiremock.client.WireMock.unauthorized;
import static com.github.tomakehurst.wiremock.client.WireMock.urlEqualTo;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.tomakehurst.wiremock.WireMockServer;
import com.github.tomakehurst.wiremock.core.WireMockConfiguration;
import com.github.tomakehurst.wiremock.stubbing.Scenario;
import com.traceagile.application.automation.ExecutionServerClient.Capabilities;
import com.traceagile.application.automation.ExecutionServerClient.IssuedToken;
import com.traceagile.application.automation.ExecutionServerClient.JobRequest;
import com.traceagile.application.automation.ExecutionServerClient.JobTest;
import com.traceagile.application.automation.ExecutionServerClient.ServerConnection;
import com.traceagile.application.automation.ExecutionServerClient.UnauthorizedException;
import com.traceagile.application.automation.RunEvent;
import com.traceagile.domain.testcase.TestTechnique;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** §15.2 contrat du serveur d'exécution côté client (WireMock) : jeton émis par le serveur, soumission, polling, erreurs. */
class HttpExecutionServerClientTest {

    WireMockServer server;
    HttpExecutionServerClient client;
    ServerConnection connection;

    @BeforeEach
    void start() {
        server = new WireMockServer(WireMockConfiguration.options().dynamicPort());
        server.start();
        client = new HttpExecutionServerClient(new ObjectMapper());
        connection = new ServerConnection(server.baseUrl(), "ets_jeton");
    }

    @AfterEach
    void stop() {
        server.stop();
    }

    @Test
    @DisplayName("ADR-0020 le jeton est demandé au serveur avec les identifiants de son administrateur ; refus → UnauthorizedException")
    void requestToken() {
        String basic = "Basic " + Base64.getEncoder().encodeToString("admin:simulateur".getBytes());
        server.stubFor(post("/api/v1/tokens").withHeader("Authorization", equalTo(basic))
                .willReturn(okJson("{\"tokenId\":\"tok-1\",\"token\":\"ets_abc\",\"webhookSecret\":\"whs_def\"}").withStatus(201)));
        server.stubFor(post("/api/v1/tokens").atPriority(10).willReturn(unauthorized()));

        IssuedToken issued = client.requestToken(server.baseUrl(), "admin", "simulateur", "TraceAgile");
        assertThat(issued).isEqualTo(new IssuedToken("tok-1", "ets_abc", "whs_def"));
        assertThatThrownBy(() -> client.requestToken(server.baseUrl(), "admin", "faux", "TraceAgile")).isInstanceOf(UnauthorizedException.class);
    }

    @Test
    @DisplayName("§10.2 santé et capacités avec le jeton Bearer ; technique inconnue ignorée ; jeton refusé → UnauthorizedException")
    void probe() {
        server.stubFor(get("/api/v1/health").willReturn(okJson("{\"status\":\"UP\",\"name\":\"sim\",\"version\":\"1.0.0\"}")));
        server.stubFor(get("/api/v1/capabilities").withHeader("Authorization", equalTo("Bearer ets_jeton"))
                .willReturn(okJson("{\"techniques\":[\"API\",\"BDD\",\"QUANTUM\"],\"frameworks\":[\"cucumber-jvm\"],\"environments\":[\"recette\"],\"agents\":2}")));

        Capabilities capabilities = client.probe(connection);
        assertThat(capabilities).isEqualTo(new Capabilities("1.0.0", List.of(TestTechnique.API, TestTechnique.BDD), List.of("cucumber-jvm"),
                List.of("recette"), 2));
        assertThatThrownBy(() -> client.probe(new ServerConnection(server.baseUrl(), "ets_revoque")))
                .isInstanceOf(com.traceagile.application.automation.ExecutionServerClient.UnavailableException.class);
        server.stubFor(get("/api/v1/capabilities").withHeader("Authorization", equalTo("Bearer ets_revoque")).willReturn(unauthorized()));
        assertThatThrownBy(() -> client.probe(new ServerConnection(server.baseUrl(), "ets_revoque"))).isInstanceOf(UnauthorizedException.class);
    }

    @Test
    @DisplayName("§10.3 soumission : corps du contrat, jobId ; serveur momentanément indisponible réessayé (requête idempotente par runId)")
    void submit() {
        server.stubFor(post("/api/v1/jobs").inScenario("réseau").whenScenarioStateIs(Scenario.STARTED)
                .willReturn(aResponse().withStatus(503)).willSetStateTo("rétabli"));
        server.stubFor(post("/api/v1/jobs").inScenario("réseau").whenScenarioStateIs("rétabli")
                .withHeader("Authorization", equalTo("Bearer ets_jeton"))
                .willReturn(okJson("{\"jobId\":\"job-42\",\"status\":\"ACCEPTED\"}").withStatus(202)));
        JobRequest job = new JobRequest("RUN-3", "SHOP", "CMP-2", "recette", "2.0.0", "http://traceagile/api/v1/execution-callbacks",
                "https://git/shop.git", "main", List.of(new JobTest("8f1c", "TC-45", TestTechnique.BDD, "cucumber-jvm", "features/panier.feature",
                "Livraison gratuite au seuil", "# language: fr", null, Map.of("browser", "chromium"), List.of("smoke", "REQ-12"))), 30, 4, 0);

        assertThat(client.submit(connection, job)).isEqualTo("job-42");
        server.verify(2, postRequestedFor(urlEqualTo("/api/v1/jobs")));
        server.verify(postRequestedFor(urlEqualTo("/api/v1/jobs"))
                .withRequestBody(matchingJsonPath("$.runId", equalTo("RUN-3")))
                .withRequestBody(matchingJsonPath("$.callbackUrl", equalTo("http://traceagile/api/v1/execution-callbacks")))
                .withRequestBody(matchingJsonPath("$.repository.url", equalTo("https://git/shop.git")))
                .withRequestBody(matchingJsonPath("$.tests[0].executionId", equalTo("8f1c")))
                .withRequestBody(matchingJsonPath("$.tests[0].technique", equalTo("BDD")))
                .withRequestBody(matchingJsonPath("$.options", equalToJson("{\"timeoutMinutes\":30,\"parallelism\":4,\"retryFailed\":0}"))));
    }

    @Test
    @DisplayName("§10.1 polling : événements du job relus au format webhook")
    void poll() {
        server.stubFor(get("/api/v1/jobs/job-42").willReturn(okJson("""
                {"jobId":"job-42","runId":"RUN-3","status":"COMPLETED","results":[
                  {"eventId":"e1","event":"TEST_FINISHED","runId":"RUN-3","jobId":"job-42","occurredAt":"2026-10-12T09:00:05Z",
                   "executionId":"8f1c","status":"FAILED","durationMs":800,"message":"KO"},
                  {"eventId":"e2","event":"JOB_FINISHED","runId":"RUN-3","jobId":"job-42","occurredAt":"2026-10-12T09:00:06Z",
                   "status":"COMPLETED","summary":{"total":1,"passed":0,"failed":1,"error":0,"skipped":0}}]}""")));
        List<RunEvent> events = client.poll(connection, "job-42");
        assertThat(events).extracting(RunEvent::event).containsExactly("TEST_FINISHED", "JOB_FINISHED");
        assertThat(events.getFirst().durationMs()).isEqualTo(800L);
        assertThat(events.get(1).summary().failed()).isEqualTo(1);
    }
}
