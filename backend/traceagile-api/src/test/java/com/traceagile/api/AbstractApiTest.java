package com.traceagile.api;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.application.administration.CreateProjectCommand;
import com.traceagile.application.administration.CreateUserCommand;
import com.traceagile.application.administration.MemberAssignment;
import com.traceagile.application.administration.ProjectService;
import com.traceagile.application.administration.UserAdministrationService;
import com.traceagile.domain.administration.ProjectRole;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.containers.PostgreSQLContainer;

/**
 * Base des tests d'intégration (§15.2) : PostgreSQL 16 réel via Testcontainers, partagé par toutes
 * les classes ; la base est vidée avant chaque test.
 */
@SpringBootTest
@AutoConfigureMockMvc
public abstract class AbstractApiTest {

    /** Mot de passe de tous les utilisateurs créés par {@link #user}. */
    protected static final String PASSWORD = "motdepasse";

    @ServiceConnection
    static final PostgreSQLContainer<?> POSTGRES = new PostgreSQLContainer<>("postgres:16-alpine");

    static {
        POSTGRES.start();
    }

    @Autowired
    protected MockMvc mvc;
    @Autowired
    protected ObjectMapper json;
    @Autowired
    protected UserAdministrationService userService;
    @Autowired
    protected ProjectService projectService;
    @Autowired
    JdbcTemplate jdbc;

    @BeforeEach
    void cleanDatabase() {
        jdbc.execute("truncate table audit_events, refresh_tokens, project_members, projects, users cascade");
        jdbc.execute("delete from automation_frameworks where created_by <> 'system'");
    }

    protected void user(String login, boolean systemAdmin) {
        userService.create(new CreateUserCommand(login, login + "@example.com", null, PASSWORD, systemAdmin));
    }

    protected void project(String key, Map<String, ProjectRole> members) {
        projectService.create(new CreateProjectCommand(key, "Projet " + key, null));
        projectService.replaceMembers(key, members.entrySet().stream()
                .map(e -> new MemberAssignment(e.getKey(), e.getValue())).toList());
    }

    /** Se connecte et renvoie la valeur de l'en-tête {@code Authorization}. */
    protected String bearer(String login) throws Exception {
        String body = mvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("login", login, "password", PASSWORD))))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        return "Bearer " + json.readTree(body).get("accessToken").asText();
    }

    protected String toJson(Object value) throws Exception {
        return json.writeValueAsString(value);
    }

    protected JsonNode readJson(String value) throws Exception {
        return json.readTree(value);
    }
}
