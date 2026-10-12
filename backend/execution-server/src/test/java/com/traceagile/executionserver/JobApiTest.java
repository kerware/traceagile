package com.traceagile.executionserver;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.traceagile.executionserver.process.ProcessRunner;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

class JobApiTest extends AbstractServerTest {

    private static final byte[] PNG = {(byte) 0x89, 'P', 'N', 'G', 13, 10, 26, 10};

    // ------------------------------------------------------------------------------------- simulations

    /** git clone : crée le dépôt dans le dossier « workspace » du job. */
    private void repository(Map<String, String> files) {
        processes.when("git clone", (command, line, output, cancellation) -> {
            Path workspace = command.directory().resolve("workspace");
            for (Map.Entry<String, String> file : files.entrySet()) {
                Path target = workspace.resolve(file.getKey());
                Files.createDirectories(target.getParent());
                Files.writeString(target, file.getValue());
            }
            output.accept("Cloning into 'workspace'...");
            return FakeProcessRunner.ok("");
        });
        processes.when("npm ci", (command, line, output, cancellation) -> {
            Files.createDirectories(command.directory().resolve("node_modules"));
            return FakeProcessRunner.ok("added 3 packages");
        });
    }

    private static String junit(String className, String name, boolean passed) {
        return "<?xml version=\"1.0\"?><testsuites><testsuite name=\"s\"><testcase classname=\"" + className + "\" name=\"" + name + "\" time=\"1.25\">"
                + (passed ? "" : "<failure message=\"Le badge doit disparaître\">AssertionError: expected 0 received 1\n    at panier.spec.ts:30</failure>")
                + "</testcase></testsuite></testsuites>";
    }

    private static String option(String line, String name) {
        Matcher matcher = Pattern.compile(Pattern.quote(name) + "\\s*=?\\s*\"([^\"]*)\"").matcher(line);
        return matcher.find() ? matcher.group(1) : null;
    }

    private Map<String, Object> test(String executionId, String key, String technique, String framework, String path, String identifier) {
        Map<String, Object> test = new LinkedHashMap<>();
        test.put("executionId", executionId);
        test.put("testKey", key);
        test.put("technique", technique);
        test.put("framework", framework);
        test.put("path", path);
        test.put("testIdentifier", identifier);
        test.put("parameters", Map.of());
        test.put("dataSet", Map.of());
        test.put("tags", List.of());
        return test;
    }

    private Map<String, Object> job(String runId, List<Map<String, Object>> tests, Map<String, Object> options) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("runId", runId);
        body.put("project", "SHOP");
        body.put("campaign", "CMP-2");
        body.put("environment", "recette");
        body.put("buildVersion", "1.0.0");
        body.put("callbackUrl", "http://traceagile/api/v1/execution-callbacks");
        body.put("repository", Map.of("url", "https://git.example.com/shop/tests.git", "branch", "main"));
        body.put("tests", tests);
        body.put("options", options);
        return body;
    }

    private String submit(String bearer, Map<String, Object> body) throws Exception {
        String response = mvc.perform(post("/api/v1/jobs").header("Authorization", bearer).contentType(MediaType.APPLICATION_JSON).content(toJson(body)))
                .andExpect(status().isAccepted()).andReturn().getResponse().getContentAsString();
        return read(response).get("jobId").asText();
    }

    private JsonNode await(String bearer, String jobId, String expected) throws Exception {
        Instant limit = Instant.now().plus(Duration.ofSeconds(20));
        while (Instant.now().isBefore(limit)) {
            JsonNode job = read(mvc.perform(get("/api/v1/jobs/" + jobId).header("Authorization", bearer)).andReturn().getResponse().getContentAsString());
            if (job.get("status").asText().equals(expected)) {
                return job;
            }
            Thread.sleep(50);
        }
        throw new AssertionError("Job " + jobId + " toujours pas " + expected);
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> finished(String executionId) {
        return sent.stream().filter(e -> "TEST_FINISHED".equals(e.get("event")) && executionId.equals(e.get("executionId"))).findFirst().orElseThrow();
    }

    // -------------------------------------------------------------------------------------------- tests

    @Test
    @DisplayName("§10.3 / §10.4 job Playwright : clone (identifiants du serveur masqués), npm ci, un test réussi et un en échec avec copie d'écran,"
            + " webhooks, polling, artefacts, idempotence par runId, isolement des jetons")
    @SuppressWarnings("unchecked")
    void playwrightJob() throws Exception {
        mvc.perform(put("/api/admin/git-credentials").header("Authorization", ADMIN).contentType(MediaType.APPLICATION_JSON)
                .content("{\"host\":\"git.example.com\",\"username\":\"ci\",\"secret\":\"jeton-git-tres-secret\"}")).andExpect(status().isNoContent());
        repository(Map.of("package.json", "{\"devDependencies\":{\"@playwright/test\":\"1.63.0\"}}", "package-lock.json", "{}",
                "tests/panier.spec.ts", "test('…')"));
        processes.when("npx playwright test", (command, line, output, cancellation) -> {
            Path junit = Path.of(command.environment().get("PLAYWRIGHT_JUNIT_OUTPUT_NAME"));
            Files.createDirectories(junit.getParent());
            boolean fail = line.contains("@fail");
            String identifier = fail ? "Panier › problem_user retire un produit @fail" : "Panier › visualise le contenu du panier";
            Files.writeString(junit, junit("panier.spec.ts", identifier, !fail));
            if (fail) {
                Path results = Path.of(option(line, "--output"));
                Files.createDirectories(results.resolve("panier-retrait"));
                Files.write(results.resolve("panier-retrait").resolve("test-failed-1.png"), PNG);
            }
            output.accept(fail ? "1 failed" : "1 passed");
            return new ProcessRunner.Result(fail ? 1 : 0, false, false, fail ? "1 failed" : "1 passed");
        });
        String bearer = bearer();
        Map<String, Object> body = job("SHOP/RUN-1", List.of(
                test("e-1", "TC-9", "UI", "Playwright", "tests/panier.spec.ts", "Panier › visualise le contenu du panier"),
                test("e-2", "TC-10", "UI", "Playwright", "tests/panier.spec.ts", "Panier › problem_user retire un produit @fail")),
                Map.of("timeoutMinutes", 10, "parallelism", 2, "retryFailed", 0));
        String jobId = submit(bearer, body);
        JsonNode done = await(bearer, jobId, "COMPLETED");

        assertThat(submit(bearer, body)).as("même runId, même job").isEqualTo(jobId);
        assertThat(sentTypes()).startsWith("JOB_STARTED").endsWith("JOB_FINISHED").contains("TEST_STARTED", "TEST_FINISHED");
        assertThat(sent).allSatisfy(e -> assertThat(e).containsKeys("eventId", "runId", "jobId", "occurredAt").containsEntry("runId", "SHOP/RUN-1"));
        assertThat(finished("e-1")).containsEntry("status", "PASSED");
        Map<String, Object> failed = finished("e-2");
        assertThat(failed).containsEntry("status", "FAILED").containsEntry("message", "Le badge doit disparaître");
        assertThat((String) failed.get("stackTrace")).contains("AssertionError");
        List<Map<String, Object>> screenshots = ((List<Map<String, Object>>) failed.get("artifacts")).stream().filter(a -> "SCREENSHOT".equals(a.get("kind"))).toList();
        assertThat(screenshots).singleElement().satisfies(a -> {
            assertThat(a).containsEntry("name", "screenshot-TC-10.png").containsEntry("executionId", "e-2").containsEntry("type", "image/png");
            assertThat((String) a.get("url")).endsWith("/api/v1/jobs/" + jobId + "/artifacts/screenshot-TC-10.png");
        });
        Map<String, Object> end = sent.getLast();
        assertThat((Map<String, Object>) end.get("summary")).containsEntry("total", 2).containsEntry("passed", 1).containsEntry("failed", 1);
        assertThat(end).containsEntry("status", "COMPLETED");
        assertThat(done.get("results").size()).isEqualTo(sent.size());

        assertThat(processes.executed()).anyMatch(l -> l.startsWith("git clone --depth 1 --branch \"main\" \"https://ci:jeton-git-tres-secret@git.example.com/shop/tests.git\""));
        assertThat(processes.executed()).contains("npm ci --no-audit --no-fund");
        assertThat(processes.executed().stream().filter(l -> l.equals("npm ci --no-audit --no-fund"))).as("préparation une fois par projet").hasSize(1);
        assertThat(processes.executed()).anyMatch(l -> l.startsWith("npx playwright test \"tests/panier.spec.ts\" --grep \"Panier visualise le contenu du panier\""));

        mvc.perform(get("/api/v1/jobs/" + jobId + "/artifacts").header("Authorization", bearer))
                .andExpect(jsonPath("$[*].name", hasItem("system.log")))
                .andExpect(jsonPath("$[*].name", hasItem("junit.xml")))
                .andExpect(jsonPath("$[*].name", hasItem("report.json")))
                .andExpect(jsonPath("$[0].kind", is("SCREENSHOT")));
        mvc.perform(get("/api/v1/jobs/" + jobId + "/artifacts/screenshot-TC-10.png").header("Authorization", bearer))
                .andExpect(content().bytes(PNG)).andExpect(content().contentType("image/png"));
        String junit = mvc.perform(get("/api/v1/jobs/" + jobId + "/artifacts/junit.xml").header("Authorization", bearer)).andReturn().getResponse()
                .getContentAsString();
        assertThat(junit).contains("tests=\"2\"").contains("failures=\"1\"").contains("problem_user retire un produit @fail");
        String logs = mvc.perform(get("/api/v1/jobs/" + jobId + "/logs").header("Authorization", bearer)).andReturn().getResponse().getContentAsString();
        assertThat(logs).contains("Clone de https://git.example.com/shop/tests.git").contains("[TC-10]").doesNotContain("jeton-git-tres-secret");

        String other = bearer();
        mvc.perform(get("/api/v1/jobs/" + jobId).header("Authorization", other)).andExpect(status().isNotFound());
        mvc.perform(get("/api/admin/jobs/" + jobId).header("Authorization", ADMIN))
                .andExpect(jsonPath("$.job.status", is("COMPLETED")))
                .andExpect(jsonPath("$.tests[1].status", is("FAILED")))
                .andExpect(jsonPath("$.job.passed", is(1)));
        mvc.perform(get("/api/admin/jobs").param("q", "run-1").header("Authorization", ADMIN))
                .andExpect(jsonPath("$[0].id", is(jobId))).andExpect(jsonPath("$[0].tokenLabel", is("TraceAgile")));
        mvc.perform(get("/api/admin/jobs").param("status", "RUNNING").header("Authorization", ADMIN)).andExpect(jsonPath("$.length()", is(0)));
        mvc.perform(get("/api/admin/dashboard").header("Authorization", ADMIN))
                .andExpect(jsonPath("$.week.jobs", is(1)))
                .andExpect(jsonPath("$.week.passRate", is(50.0)))
                .andExpect(jsonPath("$.failing[0].testKey", is("TC-10")))
                .andExpect(jsonPath("$.frameworks[0].framework", is("Playwright")));
    }

    @Test
    @DisplayName("ADR-0026 Maven (JDK choisi par paramètre), Gatling (métriques p95), Robot Framework (variables, nouvelle tentative), framework inconnu en erreur")
    @SuppressWarnings("unchecked")
    void otherFrameworks() throws Exception {
        Files.createDirectories(Path.of("target/test-tools/jdk-17"));
        repository(Map.of("pom.xml", "<project><dependencies>gatling</dependencies></project>", "src/test/java/com/shop/CartApiTest.java", "class X {}",
                "robot/requirements.txt", "robotframework", "robot/panier.robot", "*** Test Cases ***"));
        processes.when("-Dtest=", (command, line, output, cancellation) -> {
            Path reports = command.directory().resolve("target").resolve("surefire-reports");
            Files.createDirectories(reports);
            Files.writeString(reports.resolve("TEST-com.shop.CartApiTest.xml"), junit("com.shop.CartApiTest", "add", true));
            return FakeProcessRunner.ok("BUILD SUCCESS");
        });
        processes.when("gatling:test", (command, line, output, cancellation) -> {
            Path report = command.directory().resolve("target").resolve("gatling").resolve("cataloguesimulation-20261011").resolve("js");
            Files.createDirectories(report);
            Files.writeString(report.resolve("stats.json"), "{\"stats\":{\"percentiles3\":{\"total\":420},\"meanResponseTime\":{\"total\":180},"
                    + "\"meanNumberOfRequestsPerSecond\":{\"total\":35.5},\"numberOfRequests\":{\"ok\":100,\"ko\":0}}}");
            Files.writeString(report.getParent().resolve("index.html"), "<html></html>");
            return FakeProcessRunner.ok("Simulation shop.CatalogueSimulation completed");
        });
        AtomicInteger robotRuns = new AtomicInteger();
        processes.when("python -m robot", (command, line, output, cancellation) -> {
            boolean pass = robotRuns.incrementAndGet() > 1;
            Path out = Path.of(option(line, "--outputdir"));
            Files.writeString(out.resolve("junit.xml"), junit("Panier", "Retirer un produit", pass));
            return new ProcessRunner.Result(pass ? 0 : 1, false, false, "");
        });
        Map<String, Object> junitTest = test("e-1", "TC-3", "UNIT", "JUnit 5", "src/test/java/com/shop/CartApiTest.java", "com.shop.CartApiTest#add");
        junitTest.put("parameters", Map.of("jdk", "17"));
        Map<String, Object> robotTest = test("e-3", "TC-5", "KEYWORD", "Robot Framework", "robot/panier.robot", "Retirer un produit");
        robotTest.put("dataSet", Map.of("utilisateur", "problem_user"));
        String bearer = bearer();
        String jobId = submit(bearer, job("SHOP/RUN-2", List.of(junitTest,
                test("e-2", "TC-4", "PERFORMANCE", "Gatling", "src/test/scala", "shop.CatalogueSimulation"),
                robotTest,
                test("e-4", "TC-6", "UI", "Appium", "mobile/app.spec.js", "Panier mobile")),
                Map.of("timeoutMinutes", 10, "parallelism", 4, "retryFailed", 1)));
        await(bearer, jobId, "COMPLETED");

        assertThat(finished("e-1")).containsEntry("status", "PASSED");
        Map<String, Object> gatling = finished("e-2");
        assertThat(gatling).containsEntry("status", "PASSED");
        assertThat((Map<String, Object>) gatling.get("metrics")).containsEntry("p95Ms", 420.0).containsEntry("throughputRps", 35.5).containsEntry("koRequests", 0.0);
        assertThat((List<Map<String, Object>>) gatling.get("artifacts")).anyMatch(a -> "TC-4-gatling-TC-4.zip".equals(a.get("name")));
        assertThat(finished("e-3")).containsEntry("status", "PASSED").containsEntry("attempts", 2);
        assertThat((String) finished("e-4").get("message")).contains("Aucun exécuteur pour « Appium »");
        assertThat(finished("e-4")).containsEntry("status", "ERROR");

        ProcessRunner.Command maven = processes.commands().stream().filter(c -> c.arguments().getLast().contains("-Dtest=")).findFirst().orElseThrow();
        assertThat(maven.arguments().getLast()).contains("-Dtest=\"com.shop.CartApiTest#add\"");
        assertThat(maven.environment().get("JAVA_HOME")).endsWith("jdk-17");
        assertThat(maven.environment().get("TRACEAGILE_TEST_KEY")).isEqualTo("TC-3");
        assertThat(processes.executed()).anyMatch(l -> l.contains("python -m robot") && l.contains("--variable \"utilisateur:problem_user\"")
                && l.contains("--test \"Retirer un produit\""));
        assertThat(processes.executed()).anyMatch(l -> l.equals("python -m pip install -r requirements.txt"));
        assertThat(processes.executed().stream().filter(l -> l.contains("test-compile"))).as("compilation Maven une fois").hasSize(1);
    }

    @Test
    @DisplayName("ADR-0026 convention : un test écrit metrics.json dans TRACEAGILE_OUTPUT_DIR (métriques remontées) ; un scénario .feature filtré par son titre")
    @SuppressWarnings("unchecked")
    void metricsAndFeatures() throws Exception {
        repository(Map.of("saucedemo/package.json", "{\"devDependencies\":{\"@playwright/test\":\"1.63.0\"}}",
                "saucedemo/app-tests/performance.spec.ts", "", "saucedemo/features/panier.feature", "Scénario: Ajouter"));
        processes.when("npx playwright test", (command, line, output, cancellation) -> {
            Path junit = Path.of(command.environment().get("PLAYWRIGHT_JUNIT_OUTPUT_NAME"));
            Files.createDirectories(junit.getParent());
            boolean perf = line.contains("performance.spec.ts");
            Files.writeString(junit, junit(perf ? "performance.spec.ts" : "panier-bdd.spec.ts",
                    perf ? "Performance › temps de chargement du catalogue" : "Ajouter un produit au panier depuis le catalogue", true));
            if (perf) {
                Files.writeString(Path.of(command.environment().get("TRACEAGILE_OUTPUT_DIR")).resolve("metrics.json"), "{\"p95Ms\": 812, \"mesures\": [1, 2]}");
            }
            return FakeProcessRunner.ok("1 passed");
        });
        String bearer = bearer();
        String jobId = submit(bearer, job("SWAG/RUN-5", List.of(
                test("e-1", "TC-11", "PERFORMANCE", "Playwright", "saucedemo/app-tests/performance.spec.ts", "Performance › temps de chargement du catalogue"),
                test("e-2", "TC-8", "BDD", "Playwright", "saucedemo/features/panier.feature", "Ajouter un produit au panier depuis le catalogue")),
                Map.of()));
        await(bearer, jobId, "COMPLETED");
        assertThat((Map<String, Object>) finished("e-1").get("metrics")).containsEntry("p95Ms", 812.0).doesNotContainKey("mesures");
        assertThat(finished("e-2")).containsEntry("status", "PASSED");
        assertThat(processes.executed()).anyMatch(l -> l.startsWith("npx playwright test --grep \"Ajouter un produit au panier depuis le catalogue\""));
        assertThat(processes.commands()).filteredOn(c -> c.arguments().getLast().startsWith("npx playwright test"))
                .allSatisfy(c -> assertThat(c.directory().toString().replace('\\', '/')).endsWith("workspace/saucedemo"));
    }

    @Test
    @DisplayName("F-EXE-08 annulation : le processus est arrêté, le test est ignoré, JOB_FINISHED CANCELLED")
    void cancel() throws Exception {
        repository(Map.of("package.json", "{\"devDependencies\":{\"@playwright/test\":\"1.63.0\"}}", "tests/long.spec.ts", ""));
        processes.when("npx playwright test", (command, line, output, cancellation) -> {
            Instant limit = Instant.now().plusSeconds(15);
            while (!cancellation.cancelled() && Instant.now().isBefore(limit)) {
                Thread.sleep(20);
            }
            return new ProcessRunner.Result(-1, false, true, "");
        });
        String bearer = bearer();
        String jobId = submit(bearer, job("SHOP/RUN-3", List.of(test("e-1", "TC-1", "UI", "Playwright", "tests/long.spec.ts", "Long")),
                Map.of("timeoutMinutes", 10)));
        Instant limit = Instant.now().plusSeconds(10);
        while (!sentTypes().contains("TEST_STARTED") && Instant.now().isBefore(limit)) {
            Thread.sleep(20);
        }
        mvc.perform(post("/api/v1/jobs/" + jobId + "/cancel").header("Authorization", bearer)).andExpect(status().isAccepted());
        await(bearer, jobId, "CANCELLED");
        assertThat(finished("e-1")).containsEntry("status", "SKIPPED");
        assertThat(sent.getLast()).containsEntry("event", "JOB_FINISHED").containsEntry("status", "CANCELLED");
    }

    @Test
    @DisplayName("ADR-0030 identifiants transmis avec le job : jeton dans l'URL du clone (masqué au journal), clé SSH écrite pour le clone puis supprimée")
    void credentialsFromTraceAgile() throws Exception {
        List<Path> keys = new ArrayList<>();
        processes.when("git clone", (command, line, output, cancellation) -> {
            String ssh = command.environment().get("GIT_SSH_COMMAND");
            if (ssh != null) {
                Path key = command.directory().resolve("cle-ssh");
                assertThat(Files.readString(key)).isEqualTo("-----BEGIN OPENSSH PRIVATE KEY-----\nabc\n-----END OPENSSH PRIVATE KEY-----\n");
                keys.add(key);
            }
            output.accept("Cloning into 'workspace'... " + line);
            return FakeProcessRunner.ok("");
        });
        String bearer = bearer();
        Map<String, Object> withToken = job("SHOP/RUN-21", List.of(test("e-1", "TC-1", "UI", "Inconnu", "a.spec.ts", "A")), Map.of());
        withToken.put("repository", Map.of("url", "https://github.com/kerware/saucedemo-e2e", "branch", "master",
                "credentials", Map.of("type", "TOKEN", "username", "bot", "secret", "ghp_jeton-transmis")));
        String tokenJob = submit(bearer, withToken);
        await(bearer, tokenJob, "COMPLETED");
        assertThat(processes.executed()).anyMatch(l -> l.contains("\"https://bot:ghp_jeton-transmis@github.com/kerware/saucedemo-e2e\""));
        String logs = mvc.perform(get("/api/v1/jobs/" + tokenJob + "/logs").header("Authorization", bearer)).andReturn().getResponse().getContentAsString();
        assertThat(logs).contains("jeton transmis par TraceAgile").doesNotContain("ghp_jeton-transmis");

        Map<String, Object> withKey = job("SHOP/RUN-22", List.of(test("e-2", "TC-2", "UI", "Inconnu", "b.spec.ts", "B")), Map.of());
        withKey.put("repository", Map.of("url", "git@github.com:kerware/saucedemo-e2e.git",
                "credentials", Map.of("type", "SSH_KEY", "secret", "-----BEGIN OPENSSH PRIVATE KEY-----\r\nabc\r\n-----END OPENSSH PRIVATE KEY-----")));
        await(bearer, submit(bearer, withKey), "COMPLETED");
        assertThat(keys).hasSize(1);
        assertThat(keys.getFirst()).doesNotExist();
        assertThat(processes.commands()).anyMatch(c -> String.valueOf(c.environment().get("GIT_SSH_COMMAND")).contains("StrictHostKeyChecking=accept-new"));
    }

    @Test
    @DisplayName("ADR-0030 un job mêle plusieurs dépôts : un espace de travail par dépôt, avec les identifiants propres au test")
    void testWithItsOwnRepository() throws Exception {
        processes.when("git clone", (command, line, output, cancellation) -> FakeProcessRunner.ok(""));
        String bearer = bearer();
        Map<String, Object> other = test("e-2", "TC-14", "UI", "Inconnu", "src/test/java/A.java", "A#b");
        other.put("repository", Map.of("url", "https://github.com/kerware/saucedemo-e2e", "branch", "master",
                "credentials", Map.of("type", "TOKEN", "secret", "ghp_du-test")));
        String jobId = submit(bearer, job("SHOP/RUN-23", List.of(test("e-1", "TC-1", "UI", "Inconnu", "a.spec.ts", "A"), other), Map.of()));
        await(bearer, jobId, "COMPLETED");
        assertThat(processes.executed()).anyMatch(l -> l.startsWith("git clone --depth 1 --branch \"main\" \"https://git.example.com/shop/tests.git\" \"workspace\""));
        assertThat(processes.executed()).anyMatch(l -> l.startsWith("git clone --depth 1 --branch \"master\"")
                && l.contains("\"https://x-access-token:ghp_du-test@github.com/kerware/saucedemo-e2e\" \"workspace-2\""));
        assertThat(processes.executed().stream().filter(l -> l.startsWith("git clone"))).hasSize(2);
    }

    @Test
    @DisplayName("§10.3 un clone impossible met chaque test en erreur ; une requête incomplète est refusée (400)")
    void cloneFailure() throws Exception {
        processes.when("git clone", (command, line, output, cancellation) -> {
            output.accept("fatal: repository not found");
            return new ProcessRunner.Result(128, false, false, "fatal: repository not found");
        });
        String bearer = bearer();
        mvc.perform(post("/api/v1/jobs").header("Authorization", bearer).contentType(MediaType.APPLICATION_JSON).content("{\"runId\":\"SHOP/RUN-9\"}"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code", is("JOB_INVALID")));
        String jobId = submit(bearer, job("SHOP/RUN-4", List.of(test("e-1", "TC-1", "UI", "Playwright", "a.spec.ts", "A"),
                test("e-2", "TC-2", "UI", "Playwright", "b.spec.ts", "B")), Map.of()));
        await(bearer, jobId, "COMPLETED");
        List<String> messages = new ArrayList<>();
        for (String id : List.of("e-1", "e-2")) {
            assertThat(finished(id)).containsEntry("status", "ERROR");
            messages.add((String) finished(id).get("message"));
        }
        assertThat(messages).allSatisfy(m -> assertThat(m).contains("Clone du dépôt impossible").contains("repository not found"));
    }
}
