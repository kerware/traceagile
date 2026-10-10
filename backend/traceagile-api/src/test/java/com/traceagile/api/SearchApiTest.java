package com.traceagile.api;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.traceagile.domain.administration.ProjectRole;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

/** §13.1 recherche globale, aperçu des clés, notifications ; §12 filtre « verification » du backlog (ADR-0024). */
class SearchApiTest extends AbstractApiTest {

    static final String P = "/api/v1/projects/SHOP";

    String po;
    String qa;

    @BeforeEach
    void data() throws Exception {
        user("po", false);
        user("qa1", false);
        user("intrus", false);
        project("SHOP", Map.of("po", ProjectRole.PRODUCT_OWNER, "qa1", ProjectRole.TESTER));
        project("BANK", Map.of("intrus", ProjectRole.VIEWER));
        po = bearer("po");
        qa = bearer("qa1");
        send(po, P + "/requirements", Map.of("type", "FEATURE", "title", "Paiement"));
        send(po, P + "/requirements", Map.of("type", "USER_STORY", "title", "Payer par carte", "parentKey", "REQ-1"));
        send(po, P + "/requirements", Map.of("type", "USER_STORY", "title", "Suivre sa commande", "parentKey", "REQ-1"));
        send(qa, P + "/test-cases", Map.of("kind", "MANUAL", "title", "Payer avec une carte valide",
                "steps", List.of(Map.of("action", "Payer", "expectedResult", "OK")),
                "links", List.of(Map.of("requirementKey", "REQ-2", "linkType", "VERIFIES"))));
        send(qa, P + "/test-cases/TC-1/status", Map.of("status", "READY"));
        send(qa, P + "/campaigns", Map.of("name", "Recette paiement", "scopeType", "REGRESSION"));
        send(qa, P + "/defects", Map.of("title", "Paiement refusé à tort", "severity", "BLOCKER"));
    }

    JsonNode send(String token, String url, Object body) throws Exception {
        String text = mvc.perform(post(url).header("Authorization", token).contentType(MediaType.APPLICATION_JSON).content(toJson(body)))
                .andExpect(status().is2xxSuccessful()).andReturn().getResponse().getContentAsString();
        return text.isBlank() ? null : readJson(text);
    }

    @Test
    @DisplayName("§13.1 recherche : clé exacte d'abord, puis titres de tous les types ; 2 caractères minimum ; jokers littéraux ; projet cloisonné")
    void search() throws Exception {
        mvc.perform(get(P + "/search").param("q", "pai").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].key", contains("REQ-1", "CMP-1", "DEF-1")))
                .andExpect(jsonPath("$[2].detail", is("BLOCKER")));
        mvc.perform(get(P + "/search").param("q", "payer").header("Authorization", qa))
                .andExpect(jsonPath("$[*].key", contains("REQ-2", "TC-1")))
                .andExpect(jsonPath("$[0].type", is("REQUIREMENT")))
                .andExpect(jsonPath("$[1].type", is("TEST")));
        mvc.perform(get(P + "/search").param("q", "req-2").header("Authorization", qa))
                .andExpect(jsonPath("$[0].key", is("REQ-2")))
                .andExpect(jsonPath("$[0].title", is("Payer par carte")));
        mvc.perform(get(P + "/search").param("q", "p").header("Authorization", qa)).andExpect(jsonPath("$", hasSize(0)));
        mvc.perform(get(P + "/search").param("q", "%%").header("Authorization", qa)).andExpect(jsonPath("$", hasSize(0)));
        mvc.perform(get(P + "/search").param("q", "pai").header("Authorization", bearer("intrus"))).andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("§13.1 aperçu d'une clé au survol : type, titre, précision, statut ; clé inconnue ou mal formée : 404")
    void items() throws Exception {
        mvc.perform(get(P + "/items/TC-1").header("Authorization", po))
                .andExpect(jsonPath("$.type", is("TEST")))
                .andExpect(jsonPath("$.title", is("Payer avec une carte valide")))
                .andExpect(jsonPath("$.detail", is("MANUAL")))
                .andExpect(jsonPath("$.status", is("READY")));
        mvc.perform(get(P + "/items/def-1").header("Authorization", po)).andExpect(jsonPath("$.key", is("DEF-1")));
        mvc.perform(get(P + "/items/REQ-99").header("Authorization", po)).andExpect(status().isNotFound());
        mvc.perform(get(P + "/items/n'importe").header("Authorization", po)).andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("§12 filtre « verification » du backlog sur le statut calculé (combinable avec les autres filtres)")
    void verificationFilter() throws Exception {
        mvc.perform(get(P + "/requirements").param("verification", "NOT_COVERED").param("type", "USER_STORY").header("Authorization", po))
                .andExpect(jsonPath("$.content[*].key", contains("REQ-3")));
        mvc.perform(get(P + "/requirements").param("verification", "NOT_RUN", "NOT_COVERED").header("Authorization", po))
                .andExpect(jsonPath("$.content[*].key", containsInAnyOrder("REQ-1", "REQ-2", "REQ-3")));
        mvc.perform(get(P + "/requirements").param("verification", "VALIDATED").header("Authorization", po))
                .andExpect(jsonPath("$.totalElements", is(0)));
    }

    @Test
    @DisplayName("§13.1 notifications : tests qui me sont affectés, anomalies bloquantes ; sprint actif")
    void notifications() throws Exception {
        send(qa, P + "/campaigns/CMP-1/items/select", Map.of("strategy", "MANUAL", "testKeys", List.of("TC-1")));
        String item = readJson(mvc.perform(get(P + "/campaigns/CMP-1").header("Authorization", qa)).andReturn().getResponse().getContentAsString())
                .get("items").get(0).get("id").asText();
        mvc.perform(patch(P + "/campaign-items/" + item).header("Authorization", qa).contentType("application/merge-patch+json")
                .content(toJson(Map.of("assignee", "qa1")))).andExpect(status().isOk());
        mvc.perform(get(P + "/notifications").header("Authorization", qa))
                .andExpect(jsonPath("$.myTests", is(1)))
                .andExpect(jsonPath("$.blockingDefects", is(1)))
                .andExpect(jsonPath("$.failedRuns", is(0)))
                .andExpect(jsonPath("$.activeSprintKey").doesNotExist());
        mvc.perform(get(P + "/notifications").header("Authorization", po)).andExpect(jsonPath("$.myTests", is(0)));
    }
}
