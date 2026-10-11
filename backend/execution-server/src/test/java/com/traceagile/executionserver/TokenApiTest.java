package com.traceagile.executionserver;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.forwardedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

class TokenApiTest extends AbstractServerTest {

    @Test
    @DisplayName("ADR-0020 / ADR-0026 l'administrateur émet un jeton et son secret de webhook ; seule l'empreinte est conservée")
    void issueToken() throws Exception {
        String body = mvc.perform(post("/api/v1/tokens").header("Authorization", ADMIN).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"label\":\"TraceAgile recette\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.token", startsWith("ets_")))
                .andExpect(jsonPath("$.webhookSecret", startsWith("whs_")))
                .andExpect(jsonPath("$.tokenId", startsWith("tok-")))
                .andReturn().getResponse().getContentAsString();
        JsonNode issued = read(body);
        assertThat(db.sql("select token_hash from tokens").query(String.class).single()).doesNotContain(issued.get("token").asText()).hasSize(64);
        mvc.perform(get("/api/v1/tokens").header("Authorization", ADMIN))
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].label", is("TraceAgile recette")))
                .andExpect(jsonPath("$[0].hint", is(issued.get("token").asText().substring(issued.get("token").asText().length() - 4))))
                .andExpect(jsonPath("$[0].token").doesNotExist());
    }

    @Test
    @DisplayName("ADR-0026 accès : santé publique, administration en Basic, API des jobs en Bearer ; un jeton révoqué est refusé")
    void access() throws Exception {
        mvc.perform(get("/api/v1/health")).andExpect(status().isOk()).andExpect(jsonPath("$.status", is("UP")));
        mvc.perform(post("/api/v1/tokens")).andExpect(status().isUnauthorized()).andExpect(header().string("WWW-Authenticate", startsWith("Basic")));
        String wrong = "Basic " + Base64.getEncoder().encodeToString("admin:faux".getBytes(StandardCharsets.UTF_8));
        mvc.perform(get("/api/admin/me").header("Authorization", wrong)).andExpect(status().isUnauthorized())
                .andExpect(header().doesNotExist("WWW-Authenticate"));
        mvc.perform(get("/api/admin/me").header("Authorization", ADMIN)).andExpect(jsonPath("$.user", is("admin")));
        mvc.perform(get("/api/v1/capabilities")).andExpect(status().isUnauthorized()).andExpect(jsonPath("$.code", is("TOKEN_INVALID")));
        mvc.perform(get("/api/v1/capabilities").header("Authorization", ADMIN)).andExpect(status().isUnauthorized());

        String bearer = bearer();
        mvc.perform(get("/api/v1/capabilities").header("Authorization", bearer))
                .andExpect(jsonPath("$.agents", is(4)))
                .andExpect(jsonPath("$.techniques", notNullValue()));
        String tokenId = db.sql("select id from tokens").query(String.class).single();
        mvc.perform(delete("/api/v1/tokens/" + tokenId).header("Authorization", ADMIN)).andExpect(status().isNoContent());
        mvc.perform(get("/api/v1/capabilities").header("Authorization", bearer)).andExpect(status().isUnauthorized());
        mvc.perform(get("/api/v1/tokens").header("Authorization", ADMIN)).andExpect(jsonPath("$[0].revokedAt", notNullValue()));
        mvc.perform(delete("/api/v1/tokens/" + tokenId).header("Authorization", ADMIN)).andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("ADR-0026 l'interface est servie par le jar : une route de l'application renvoie index.html")
    void spaRoutes() throws Exception {
        mvc.perform(get("/jobs/job-1234")).andExpect(forwardedUrl("/index.html"));
    }
}
