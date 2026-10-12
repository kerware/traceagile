package com.traceagile.infrastructure.automation;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.application.automation.ExecutionServerClient;
import com.traceagile.application.automation.RunEvent;
import com.traceagile.domain.testcase.TestTechnique;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Consumer;
import java.util.function.Supplier;
import org.slf4j.MDC;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

/**
 * §10 client HTTP du contrat docs/execution-server-api.yaml (ADR-0020) : jeton Bearer émis par le
 * serveur, {@code X-Correlation-Id} propagé (NF-15), délais courts, trois essais sur erreur réseau
 * pour les lectures et l'envoi idempotent d'un job (§10.1). 401 → {@link UnauthorizedException}.
 */
@Component
public class HttpExecutionServerClient implements ExecutionServerClient {

    private static final int ATTEMPTS = 3;

    private final RestClient http;
    private final ObjectMapper json;

    public HttpExecutionServerClient(ObjectMapper json) {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(3_000);
        factory.setReadTimeout(10_000);
        this.http = RestClient.builder().requestFactory(factory).build();
        this.json = json;
    }

    @Override
    public IssuedToken requestToken(String baseUrl, String adminUser, String adminPassword, String label) {
        String basic = Base64.getEncoder().encodeToString((adminUser + ":" + adminPassword).getBytes(StandardCharsets.UTF_8));
        JsonNode body = call(() -> http.post().uri(baseUrl + "/api/v1/tokens").header(HttpHeaders.AUTHORIZATION, "Basic " + basic)
                .contentType(MediaType.APPLICATION_JSON).body(Map.of("label", label)).retrieve().body(JsonNode.class), false);
        if (body == null || !body.hasNonNull("token") || !body.hasNonNull("webhookSecret")) {
            throw new UnavailableException("réponse d'émission de jeton incomplète", null);
        }
        return new IssuedToken(body.path("tokenId").asText(null), body.get("token").asText(), body.get("webhookSecret").asText());
    }

    @Override
    public Capabilities probe(ServerConnection connection) {
        JsonNode health = call(() -> http.get().uri(connection.baseUrl() + "/api/v1/health").retrieve().body(JsonNode.class), true);
        JsonNode capabilities = call(() -> http.get().uri(connection.baseUrl() + "/api/v1/capabilities").headers(auth(connection))
                .retrieve().body(JsonNode.class), true);
        List<TestTechnique> techniques = new ArrayList<>();
        capabilities.path("techniques").forEach(t -> {
            try {
                techniques.add(TestTechnique.valueOf(t.asText()));
            } catch (IllegalArgumentException ignored) {
                // technique inconnue de TraceAgile : ignorée
            }
        });
        return new Capabilities(health.path("version").asText(null), techniques, strings(capabilities.path("frameworks")),
                strings(capabilities.path("environments")), capabilities.path("agents").asInt(0));
    }

    @Override
    public String submit(ServerConnection connection, JobRequest job) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("runId", job.runId());
        body.put("project", job.project());
        body.put("campaign", job.campaign());
        body.put("environment", job.environment());
        body.put("buildVersion", job.buildVersion());
        body.put("callbackUrl", job.callbackUrl());
        Map<String, Object> repository = new LinkedHashMap<>();
        repository.put("url", job.repositoryUrl());
        repository.put("branch", job.branch());
        if (job.credentials() != null) {
            // ADR-0030 jeton ou clé SSH du dépôt déclaré : utilisé pour le clone, jamais conservé par le serveur
            Map<String, Object> credentials = new LinkedHashMap<>();
            credentials.put("type", job.credentials().type());
            credentials.put("username", job.credentials().username());
            credentials.put("secret", job.credentials().secret());
            repository.put("credentials", credentials);
        }
        body.put("repository", repository);
        body.put("tests", job.tests().stream().map(t -> {
            Map<String, Object> test = new LinkedHashMap<>();
            test.put("executionId", t.executionId());
            test.put("testKey", t.testKey());
            test.put("technique", t.technique().name());
            test.put("framework", t.framework());
            test.put("path", t.path());
            test.put("testIdentifier", t.testIdentifier());
            test.put("gherkinSource", t.gherkinSource());
            test.put("dataSet", t.dataSet());
            test.put("parameters", t.parameters());
            test.put("tags", t.tags());
            return test;
        }).toList());
        body.put("options", Map.of("timeoutMinutes", job.timeoutMinutes(), "parallelism", job.parallelism(), "retryFailed", job.retryFailed()));
        JsonNode accepted = call(() -> http.post().uri(connection.baseUrl() + "/api/v1/jobs").headers(auth(connection))
                .contentType(MediaType.APPLICATION_JSON).body(body).retrieve().body(JsonNode.class), true);
        if (accepted == null || !accepted.hasNonNull("jobId")) {
            throw new UnavailableException("réponse sans jobId", null);
        }
        return accepted.get("jobId").asText();
    }

    @Override
    public void cancel(ServerConnection connection, String jobId) {
        call(() -> http.post().uri(connection.baseUrl() + "/api/v1/jobs/{id}/cancel", jobId).headers(auth(connection)).retrieve().toBodilessEntity(), false);
    }

    @Override
    public List<RunEvent> poll(ServerConnection connection, String jobId) {
        JsonNode status = call(() -> http.get().uri(connection.baseUrl() + "/api/v1/jobs/{id}", jobId).headers(auth(connection))
                .retrieve().body(JsonNode.class), true);
        List<RunEvent> events = new ArrayList<>();
        status.path("results").forEach(e -> events.add(RunEventJson.read(e)));
        return events;
    }

    @Override
    public String logs(ServerConnection connection, String jobId) {
        String logs = call(() -> http.get().uri(connection.baseUrl() + "/api/v1/jobs/{id}/logs", jobId).headers(auth(connection))
                .accept(MediaType.TEXT_PLAIN).retrieve().body(String.class), true);
        return logs == null ? "" : logs;
    }

    @Override
    public List<RunEvent.ArtifactRef> artifacts(ServerConnection connection, String jobId) {
        JsonNode list = call(() -> http.get().uri(connection.baseUrl() + "/api/v1/jobs/{id}/artifacts", jobId).headers(auth(connection))
                .retrieve().body(JsonNode.class), true);
        return list == null ? List.of() : RunEventJson.artifacts(list);
    }

    @Override
    public ArtifactContent download(ServerConnection connection, String jobId, String name) {
        ResponseEntity<byte[]> response = call(() -> http.get().uri(connection.baseUrl() + "/api/v1/jobs/{id}/artifacts/{name}", jobId, name)
                .headers(auth(connection)).retrieve().toEntity(byte[].class), true);
        MediaType type = response.getHeaders().getContentType();
        return new ArtifactContent(response.getBody() == null ? new byte[0] : response.getBody(), type == null ? null : type.toString());
    }

    /** Jeton Bearer émis par le serveur ; corrélation propagée (NF-15). */
    private static Consumer<HttpHeaders> auth(ServerConnection connection) {
        return headers -> {
            headers.setBearerAuth(connection.token());
            String correlation = MDC.get("correlationId");
            if (correlation != null) {
                headers.set("X-Correlation-Id", correlation);
            }
        };
    }

    /** 401 → UnauthorizedException ; erreurs réseau ou 5xx : jusqu'à trois essais si {@code retry}. */
    private <T> T call(Supplier<T> request, boolean retry) {
        RuntimeException last = null;
        for (int attempt = 1; attempt <= (retry ? ATTEMPTS : 1); attempt++) {
            try {
                return request.get();
            } catch (HttpClientErrorException e) {
                if (e.getStatusCode().isSameCodeAs(HttpStatusCode.valueOf(401))) {
                    throw new UnauthorizedException("jeton refusé par le serveur");
                }
                throw new UnavailableException("HTTP " + e.getStatusCode().value() + " " + e.getResponseBodyAsString(), e);
            } catch (HttpServerErrorException e) {
                last = new UnavailableException("HTTP " + e.getStatusCode().value(), e);
                sleep(150L * attempt);
            } catch (ResourceAccessException e) {
                last = new UnavailableException(e.getMostSpecificCause().getMessage(), e);
                sleep(150L * attempt);
            } catch (RestClientException e) {
                throw new UnavailableException(e.getMessage(), e);
            }
        }
        throw last;
    }

    private static List<String> strings(JsonNode array) {
        List<String> values = new ArrayList<>();
        array.forEach(v -> values.add(v.asText()));
        return values;
    }

    private static void sleep(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
