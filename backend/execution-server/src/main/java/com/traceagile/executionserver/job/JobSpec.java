package com.traceagile.executionserver.job;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * §10.3 job reçu de TraceAgile (docs/execution-server-api.yaml) : dépôt, tests et options.
 *
 * @param parallelism nombre de tests du job exécutés en même temps (borné par les agents du serveur)
 * @param retryFailed nouvelles tentatives d'un test en échec avant de rendre son résultat
 */
public record JobSpec(String runId, String project, String campaign, String environment, String buildVersion, String callbackUrl,
                      String repositoryUrl, String branch, Credentials credentials, List<TestSpec> tests, int timeoutMinutes, int parallelism,
                      int retryFailed) {

    /** ADR-0030 identifiants du dépôt transmis par TraceAgile (TOKEN ou SSH_KEY) ; jamais enregistrés. */
    public record Credentials(String type, String username, String secret) {

        @Override
        public String toString() {
            return "Credentials[" + type + "]";
        }
    }

    /** Un test du job ; {@code parameters} et {@code dataSet} deviennent des variables d'environnement. */
    public record TestSpec(String executionId, String testKey, String technique, String framework, String path, String testIdentifier,
                           String gherkinSource, Map<String, Object> dataSet, Map<String, Object> parameters, List<String> tags) {

        public String label() {
            return testKey + (testIdentifier == null || testIdentifier.isBlank() ? "" : " (" + testIdentifier + ")");
        }

        public String parameter(String name) {
            Object value = parameters == null ? null : parameters.get(name);
            return value == null ? null : String.valueOf(value);
        }
    }

    /** Lecture tolérante du corps JSON ; {@link IllegalArgumentException} si un champ obligatoire manque. */
    @SuppressWarnings("unchecked")
    public static JobSpec from(Map<String, Object> body) {
        Object runId = body.get("runId");
        Object callback = body.get("callbackUrl");
        if (!(body.get("tests") instanceof List<?> rawTests) || rawTests.isEmpty() || runId == null || callback == null) {
            throw new IllegalArgumentException("runId, callbackUrl et au moins un test sont obligatoires.");
        }
        Map<String, Object> repository = body.get("repository") instanceof Map<?, ?> r ? (Map<String, Object>) r : Map.of();
        Map<String, Object> options = body.get("options") instanceof Map<?, ?> o ? (Map<String, Object>) o : Map.of();
        List<TestSpec> tests = new ArrayList<>();
        for (Object raw : rawTests) {
            if (!(raw instanceof Map<?, ?> t) || t.get("executionId") == null) {
                throw new IllegalArgumentException("Chaque test doit porter un executionId.");
            }
            Map<String, Object> test = (Map<String, Object>) t;
            tests.add(new TestSpec(text(test.get("executionId")), text(test.getOrDefault("testKey", test.get("executionId"))), text(test.get("technique")),
                    text(test.get("framework")), text(test.get("path")), text(test.get("testIdentifier")), text(test.get("gherkinSource")),
                    map(test.get("dataSet")), map(test.get("parameters")),
                    test.get("tags") instanceof List<?> tags ? tags.stream().map(String::valueOf).toList() : List.of()));
        }
        return new JobSpec(text(runId), text(body.get("project")), text(body.get("campaign")), text(body.get("environment")),
                text(body.get("buildVersion")), text(callback), text(repository.getOrDefault("url", body.get("repositoryUrl"))),
                text(repository.getOrDefault("branch", body.get("branch"))), credentials(repository.get("credentials")), List.copyOf(tests),
                number(options.get("timeoutMinutes"), 30, 1, 24 * 60), number(options.get("parallelism"), 1, 1, 32), number(options.get("retryFailed"), 0, 0, 3));
    }

    @SuppressWarnings("unchecked")
    private static Credentials credentials(Object value) {
        if (!(value instanceof Map<?, ?> m)) {
            return null;
        }
        Map<String, Object> c = (Map<String, Object>) m;
        String type = text(c.get("type"));
        String secret = c.get("secret") == null ? null : String.valueOf(c.get("secret"));
        if (type == null || secret == null || secret.isBlank() || !(type.equals("TOKEN") || type.equals("SSH_KEY"))) {
            return null;
        }
        return new Credentials(type, text(c.get("username")), secret);
    }

    private static String text(Object value) {
        if (value == null) {
            return null;
        }
        String text = String.valueOf(value).strip();
        return text.isEmpty() ? null : text;
    }

    @SuppressWarnings("unchecked")
    private static Map<String, Object> map(Object value) {
        return value instanceof Map<?, ?> m ? new LinkedHashMap<>((Map<String, Object>) m) : Map.of();
    }

    private static int number(Object value, int fallback, int min, int max) {
        int n = value instanceof Number number ? number.intValue() : fallback;
        return Math.max(min, Math.min(max, n));
    }
}
