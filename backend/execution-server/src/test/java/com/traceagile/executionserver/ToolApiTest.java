package com.traceagile.executionserver;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.traceagile.executionserver.process.ProcessRunner;
import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.atomic.AtomicBoolean;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class ToolApiTest extends AbstractServerTest {

    private JsonNode tool(String id) throws Exception {
        for (JsonNode state : read(mvc.perform(get("/api/admin/tools").header("Authorization", ADMIN)).andReturn().getResponse().getContentAsString())) {
            if (state.get("tool").get("id").asText().equals(id)) {
                return state;
            }
        }
        throw new AssertionError("outil inconnu " + id);
    }

    private JsonNode awaitStatus(String id, String status) throws Exception {
        Instant limit = Instant.now().plus(Duration.ofSeconds(15));
        while (Instant.now().isBefore(limit)) {
            JsonNode state = tool(id);
            if (state.get("status").asText().equals(status)) {
                return state;
            }
            Thread.sleep(50);
        }
        throw new AssertionError(id + " toujours pas " + status + " : " + tool(id));
    }

    @Test
    @DisplayName("ADR-0026 détection : version lue dans la sortie, même avec un code de retour non nul (robot --version : 251)")
    void detection() throws Exception {
        mvc.perform(post("/api/admin/tools/detect").header("Authorization", ADMIN)).andExpect(status().isOk());
        processes.when("-m robot --version", (c, l, o, x) -> {
            o.accept("Robot Framework 7.1.1 (Python 3.12.3 on linux)");
            return new ProcessRunner.Result(251, false, false, "Robot Framework 7.1.1 (Python 3.12.3 on linux)");
        });
        processes.when("node --version", (c, l, o, x) -> {
            o.accept("v22.12.0");
            return FakeProcessRunner.ok("v22.12.0");
        });
        mvc.perform(post("/api/admin/tools/robotframework/detect").header("Authorization", ADMIN))
                .andExpect(jsonPath("$.status", is("INSTALLED"))).andExpect(jsonPath("$.version", is("7.1.1")));
        mvc.perform(post("/api/admin/tools/node/detect").header("Authorization", ADMIN))
                .andExpect(jsonPath("$.version", is("22.12.0")))
                .andExpect(jsonPath("$.tool.prerequisite", is(true)))
                .andExpect(jsonPath("$.installable", is(false)));
        mvc.perform(post("/api/admin/tools/cypress/detect").header("Authorization", ADMIN)).andExpect(jsonPath("$.status", is("MISSING")));
        String bearer = bearer();
        mvc.perform(get("/api/v1/capabilities").header("Authorization", bearer))
                .andExpect(jsonPath("$.frameworks", hasItem("Robot Framework")))
                .andExpect(jsonPath("$.frameworks", hasItem("Cucumber-JS")));
    }

    @Test
    @DisplayName("ADR-0026 assistant : plan ordonné (dépendances d'abord), prérequis absents à installer à la main")
    void plan() throws Exception {
        processes.when("--version", (c, l, o, x) -> new ProcessRunner.Result(1, false, false, "introuvable"));
        mvc.perform(post("/api/admin/tools/detect").header("Authorization", ADMIN)).andExpect(status().isOk());
        mvc.perform(get("/api/admin/tools/plan").param("frameworks", "Robot Framework", "Gatling").header("Authorization", ADMIN))
                .andExpect(jsonPath("$[*].toolId", contains("python", "python-env", "robotframework", "java", "gatling", "maven")))
                .andExpect(jsonPath("$[0].action", is("MANUAL")))
                .andExpect(jsonPath("$[1].action", is("INSTALL")));
    }

    @Test
    @DisplayName("ADR-0026 installation : refusée sans le prérequis ; sinon dépendances puis outil, journal, outil détecté")
    void install() throws Exception {
        mvc.perform(post("/api/admin/tools/detect").header("Authorization", ADMIN)).andExpect(status().isOk());
        mvc.perform(post("/api/admin/tools/node/install").header("Authorization", ADMIN))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("TOOL_NOT_INSTALLABLE")));
        mvc.perform(post("/api/admin/tools/selenium/install").header("Authorization", ADMIN))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("PREREQUISITE_MISSING")))
                .andExpect(jsonPath("$.message", containsString("Python 3")));

        AtomicBoolean venv = new AtomicBoolean();
        AtomicBoolean selenium = new AtomicBoolean();
        processes.when("python3 --version", (c, l, o, x) -> {
            o.accept("Python 3.12.3");
            return FakeProcessRunner.ok("Python 3.12.3");
        });
        processes.when(l -> l.contains("python") && l.endsWith("--version") && !l.startsWith("python3"), (c, l, o, x) -> {
            if (venv.get()) {
                o.accept("Python 3.12.3");
            }
            return new ProcessRunner.Result(venv.get() ? 0 : 1, false, false, "");
        });
        processes.when("-m venv", (c, l, o, x) -> {
            o.accept("venv créé");
            venv.set(true);
            return FakeProcessRunner.ok("");
        });
        processes.when("import selenium", (c, l, o, x) -> {
            if (selenium.get()) {
                o.accept("selenium 4.27.1");
            }
            return new ProcessRunner.Result(selenium.get() ? 0 : 1, false, false, "");
        });
        processes.when("pip install selenium", (c, l, o, x) -> {
            o.accept("Successfully installed selenium-4.27.1 pytest-8.3.4");
            selenium.set(true);
            return FakeProcessRunner.ok("");
        });
        mvc.perform(post("/api/admin/tools/python/detect").header("Authorization", ADMIN)).andExpect(jsonPath("$.status", is("INSTALLED")));
        mvc.perform(post("/api/admin/tools/selenium/install").param("withDependencies", "false").header("Authorization", ADMIN))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("DEPENDENCY_MISSING")));
        mvc.perform(post("/api/admin/tools/selenium/install").header("Authorization", ADMIN))
                .andExpect(status().isAccepted()).andExpect(jsonPath("$.queued", contains("python-env", "selenium")));

        JsonNode installed = awaitStatus("selenium", "INSTALLED");
        assertThat(installed.get("version").asText()).isEqualTo("4.27.1");
        assertThat(awaitStatus("python-env", "INSTALLED").get("version").asText()).isEqualTo("3.12.3");
        String log = mvc.perform(get("/api/admin/tools/selenium/log").header("Authorization", ADMIN)).andReturn().getResponse().getContentAsString();
        assertThat(log).contains("Successfully installed selenium-4.27.1").contains("# Installé : version 4.27.1");
        assertThat(processes.executed()).anyMatch(l -> l.contains("pip install selenium==4.27.1 pytest==8.3.4"));
        mvc.perform(get("/api/admin/settings").header("Authorization", ADMIN)).andExpect(jsonPath("$.agents", is(4)));
    }
}
