package com.traceagile.application.automation;

import com.traceagile.domain.testcase.TestTechnique;
import java.util.List;
import java.util.Map;

/**
 * §10 port vers un serveur d'exécution distant (implémentation HTTP en infrastructure ; d'autres
 * types plus tard, §10.6). ADR-0020 le jeton Bearer est émis par le serveur ({@link #requestToken}).
 */
public interface ExecutionServerClient {

    /** Adresse et jeton (en clair, le temps de l'appel). */
    record ServerConnection(String baseUrl, String token) {
    }

    /** ADR-0020 jeton émis par le serveur et secret de signature de ses webhooks. */
    record IssuedToken(String tokenId, String token, String webhookSecret) {
    }

    /** §10.2 GET /health et GET /capabilities. */
    record Capabilities(String version, List<TestTechnique> techniques, List<String> frameworks, List<String> environments, int agents) {
    }

    /** §10.3 un test du job. */
    record JobTest(String executionId, String testKey, TestTechnique technique, String framework, String path, String testIdentifier,
                   String gherkinSource, Map<String, Object> dataSet, Map<String, Object> parameters, List<String> tags) {
    }

    /** §10.3 soumission d'un job. */
    record JobRequest(String runId, String project, String campaign, String environment, String buildVersion, String callbackUrl,
                      String repositoryUrl, String branch, List<JobTest> tests, int timeoutMinutes, int parallelism, int retryFailed) {
    }

    /** ADR-0021 contenu d'un artefact et son type MIME. */
    record ArtifactContent(byte[] content, String contentType) {
    }

    /** Le serveur refuse le jeton (401) : il faut l'appairer à nouveau. */
    class UnauthorizedException extends RuntimeException {
        public UnauthorizedException(String message) {
            super(message);
        }
    }

    /** Serveur injoignable ou réponse inattendue. */
    class UnavailableException extends RuntimeException {
        public UnavailableException(String message, Throwable cause) {
            super(message, cause);
        }
    }

    /** ADR-0020 demande un jeton à l'administrateur du serveur (identifiants non conservés). */
    IssuedToken requestToken(String baseUrl, String adminUser, String adminPassword, String label);

    Capabilities probe(ServerConnection connection);

    /** @return identifiant du job (idempotent par runId) */
    String submit(ServerConnection connection, JobRequest job);

    void cancel(ServerConnection connection, String jobId);

    /** Mode polling (§10.1) : événements déjà émis par le serveur pour ce job. */
    List<RunEvent> poll(ServerConnection connection, String jobId);

    String logs(ServerConnection connection, String jobId);

    /** ADR-0021 artefacts du job (traces système, JUnit XML, Jest JSON, rapport, copies d'écran). */
    List<RunEvent.ArtifactRef> artifacts(ServerConnection connection, String jobId);

    /** ADR-0021 contenu d'un artefact ; artefact inconnu → {@link UnavailableException}. */
    ArtifactContent download(ServerConnection connection, String jobId, String name);
}
