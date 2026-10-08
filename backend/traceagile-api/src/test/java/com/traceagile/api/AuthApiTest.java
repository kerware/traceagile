package com.traceagile.api;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.traceagile.domain.administration.ProjectRole;
import jakarta.servlet.http.Cookie;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;

/** §12 Authentification : POST /auth/login, /auth/refresh, /auth/logout, GET /me (§11.1 JWT). */
class AuthApiTest extends AbstractApiTest {

    @BeforeEach
    void data() {
        user("admin", true);
        user("qa1", false);
        project("SHOP", Map.of("qa1", ProjectRole.TESTER));
    }

    @Test
    @DisplayName("§11.1 POST /auth/login : jeton d'accès de 15 min et cookie de rafraîchissement HttpOnly")
    void login() throws Exception {
        mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("login", "qa1", "password", PASSWORD))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.tokenType", is("Bearer")))
                .andExpect(jsonPath("$.expiresIn", is(900)))
                .andExpect(jsonPath("$.accessToken").isString())
                .andExpect(jsonPath("$.user.login", is("qa1")))
                .andExpect(header().string("Set-Cookie", containsString("traceagile_refresh=")))
                .andExpect(header().string("Set-Cookie", containsString("HttpOnly")))
                .andExpect(header().string("Set-Cookie", containsString("SameSite=Strict")))
                .andExpect(header().string("Set-Cookie", containsString("Path=/api/v1/auth")));
    }

    @Test
    @DisplayName("§12 POST /auth/login : identifiants invalides → 401 problem+json AUTH_INVALID_CREDENTIALS")
    void loginInvalid() throws Exception {
        mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("login", "qa1", "password", "mauvais"))))
                .andExpect(status().isUnauthorized())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON))
                .andExpect(jsonPath("$.code", is("AUTH_INVALID_CREDENTIALS")));
    }

    @Test
    @DisplayName("§15.2 validation : login vide → 400 VALIDATION_FAILED")
    void loginValidation() throws Exception {
        mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("login", "", "password", ""))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code", is("VALIDATION_FAILED")))
                .andExpect(jsonPath("$.errors.login").exists());
    }

    @Test
    @DisplayName("§12 GET /me : profil et rôles par projet")
    void me() throws Exception {
        mvc.perform(get("/api/v1/me").header("Authorization", bearer("qa1")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.login", is("qa1")))
                .andExpect(jsonPath("$.systemAdmin", is(false)))
                .andExpect(jsonPath("$.projects[0].key", is("SHOP")))
                .andExpect(jsonPath("$.projects[0].role", is("TESTER")));
    }

    @Test
    @DisplayName("§12 GET /me sans jeton → 401 AUTH_REQUIRED")
    void meRequiresAuthentication() throws Exception {
        mvc.perform(get("/api/v1/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code", is("AUTH_REQUIRED")));
    }

    @Test
    @DisplayName("§11.1 GET /me avec un jeton falsifié → 401")
    void forgedToken() throws Exception {
        mvc.perform(get("/api/v1/me").header("Authorization", "Bearer eyJhbGciOiJIUzI1NiJ9.e30.invalide"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("§12 POST /auth/refresh : nouveau jeton d'accès, rotation du cookie")
    void refresh() throws Exception {
        Cookie refresh = loginCookie("qa1");

        MvcResult result = mvc.perform(post("/api/v1/auth/refresh").cookie(refresh))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.accessToken").isString())
                .andReturn();

        assertThat(result.getResponse().getCookie("traceagile_refresh").getValue()).isNotEqualTo(refresh.getValue());
    }

    @Test
    @DisplayName("§12 POST /auth/refresh sans cookie → 401 AUTH_REFRESH_INVALID")
    void refreshWithoutCookie() throws Exception {
        mvc.perform(post("/api/v1/auth/refresh"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code", is("AUTH_REFRESH_INVALID")));
    }

    @Test
    @DisplayName("§12 POST /auth/logout : révoque la session et efface le cookie")
    void logout() throws Exception {
        Cookie refresh = loginCookie("qa1");

        mvc.perform(post("/api/v1/auth/logout").cookie(refresh))
                .andExpect(status().isNoContent())
                .andExpect(header().string("Set-Cookie", containsString("Max-Age=0")));

        mvc.perform(post("/api/v1/auth/refresh").cookie(refresh)).andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("NF-15 l'identifiant de corrélation X-Correlation-Id est propagé ou généré")
    void correlationId() throws Exception {
        mvc.perform(get("/actuator/health").header("X-Correlation-Id", "abc-123"))
                .andExpect(header().string("X-Correlation-Id", "abc-123"));
        mvc.perform(get("/actuator/health"))
                .andExpect(header().exists("X-Correlation-Id"));
    }

    private Cookie loginCookie(String login) throws Exception {
        return mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("login", login, "password", PASSWORD))))
                .andReturn().getResponse().getCookie("traceagile_refresh");
    }
}
