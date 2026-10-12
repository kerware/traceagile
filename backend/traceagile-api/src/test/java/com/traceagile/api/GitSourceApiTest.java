package com.traceagile.api;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.traceagile.domain.administration.ProjectRole;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

class GitSourceApiTest extends AbstractApiTest {

    String admin;
    String dev;

    @BeforeEach
    void data() throws Exception {
        user("admin", true);
        user("dev", false);
        project("SHOP", Map.of("dev", ProjectRole.DEVELOPER));
        admin = bearer("admin");
        dev = bearer("dev");
    }

    JsonNode send(String token, String url, Object body) throws Exception {
        String body2 = mvc.perform(post(url).header("Authorization", token).contentType(MediaType.APPLICATION_JSON).content(toJson(body)))
                .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString();
        return json.readTree(body2);
    }

    @Test
    @DisplayName("ADR-0030 dépôts Git : déclaration (jeton chiffré, jamais renvoyé), projets, choix dans une fiche de test ; 403 hors administrateur")
    void sourcesAndProjects() throws Exception {
        String sourceId = send(admin, "/api/v1/git-sources", Map.of("name", "kerware", "baseUrl", "https://github.com/kerware/",
                "authType", "TOKEN", "username", "bot", "secret", "ghp_jeton-tres-secret")).get("id").asText();
        String projectId = send(admin, "/api/v1/git-sources/" + sourceId + "/projects",
                Map.of("name", "saucedemo-e2e", "defaultBranch", "master")).get("id").asText();
        mvc.perform(post("/api/v1/git-sources").header("Authorization", dev).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("name", "x", "baseUrl", "https://x.org/y")))).andExpect(status().isForbidden());
        mvc.perform(post("/api/v1/git-sources").header("Authorization", admin).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("name", "local", "baseUrl", "file:///depots", "authType", "TOKEN", "secret", "s"))))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("GIT_SOURCE_AUTH_INVALID")));

        // lisible par tout utilisateur, sans le secret
        mvc.perform(get("/api/v1/git-sources").header("Authorization", dev))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].baseUrl", is("https://github.com/kerware")))
                .andExpect(jsonPath("$[0].hasSecret", is(true)))
                .andExpect(jsonPath("$[0].projects[0].label", is("kerware / saucedemo-e2e")))
                .andExpect(jsonPath("$[0].projects[0].cloneUrl", is("https://github.com/kerware/saucedemo-e2e")))
                .andExpect(content().string(not(containsString("ghp_jeton"))));

        // fiche de test : le projet donne l'adresse et la branche par défaut
        String key = send(dev, "/api/v1/projects/SHOP/test-cases", Map.of("kind", "AUTOMATED", "title", "Panier E2E", "technique", "UI",
                "gitProjectId", projectId, "path", "src/test/resources/features/panier.feature", "testIdentifier", "Panier")).get("key").asText();
        mvc.perform(get("/api/v1/projects/SHOP/test-cases/" + key).header("Authorization", dev))
                .andExpect(jsonPath("$.automation.gitProject.label", is("kerware / saucedemo-e2e")))
                .andExpect(jsonPath("$.automation.repositoryUrl", is("https://github.com/kerware/saucedemo-e2e")))
                .andExpect(jsonPath("$.automation.branch", is("master")));
        // passage en SSH : l'adresse de clonage suit, sans toucher aux tests
        mvc.perform(patch("/api/v1/git-sources/" + sourceId).header("Authorization", admin).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("authType", "SSH_KEY", "secret", "-----BEGIN OPENSSH PRIVATE KEY-----\r\nabc\r\n-----END OPENSSH PRIVATE KEY-----"))))
                .andExpect(status().isOk()).andExpect(jsonPath("$.authType", is("SSH_KEY")));
        mvc.perform(get("/api/v1/projects/SHOP/test-cases/" + key).header("Authorization", dev))
                .andExpect(jsonPath("$.automation.repositoryUrl", is("git@github.com:kerware/saucedemo-e2e.git")));

        // projet utilisé, dépôt non vide : suppression refusée
        mvc.perform(delete("/api/v1/git-projects/" + projectId).header("Authorization", admin))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code", is("GIT_PROJECT_IN_USE")));
        mvc.perform(delete("/api/v1/git-sources/" + sourceId).header("Authorization", admin))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code", is("GIT_SOURCE_IN_USE")));
        // retour à une adresse libre : le projet est libéré
        mvc.perform(patch("/api/v1/projects/SHOP/test-cases/" + key).header("Authorization", dev).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("repositoryUrl", "https://git.example.com/autre.git"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.automation.gitProject").doesNotExist())
                .andExpect(jsonPath("$.automation.repositoryUrl", is("https://git.example.com/autre.git")));
        mvc.perform(delete("/api/v1/git-projects/" + projectId).header("Authorization", admin)).andExpect(status().isNoContent());
        mvc.perform(get("/api/v1/git-sources").header("Authorization", admin)).andExpect(jsonPath("$[0].projects").isEmpty());
    }
}
