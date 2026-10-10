package com.traceagile.api;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
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
import org.springframework.test.web.servlet.ResultActions;

/** §4.4 atelier Example Mapping (F-REQ-13 à F-REQ-15) et §13.2 commentaires (ADR-0024). */
class WorkshopApiTest extends AbstractApiTest {

    static final String P = "/api/v1/projects/SHOP";

    String po;
    String qa;

    @BeforeEach
    void data() throws Exception {
        user("po", false);
        user("qa1", false);
        user("dev", false);
        user("viewer", false);
        project("SHOP", Map.of("po", ProjectRole.PRODUCT_OWNER, "qa1", ProjectRole.TESTER, "dev", ProjectRole.DEVELOPER, "viewer", ProjectRole.VIEWER));
        po = bearer("po");
        qa = bearer("qa1");
        send(po, P + "/requirements", Map.of("type", "FEATURE", "title", "Livraison")).andExpect(status().isCreated());
        send(po, P + "/requirements", Map.of("type", "USER_STORY", "title", "Calculer les frais de port", "parentKey", "REQ-1", "storyPoints", 3,
                "criteria", List.of(Map.of("format", "TEXT", "content", "Les frais s'affichent")))).andExpect(status().isCreated());
    }

    ResultActions send(String token, String url, Object body) throws Exception {
        return mvc.perform(post(url).header("Authorization", token).contentType(MediaType.APPLICATION_JSON).content(toJson(body)));
    }

    String id(ResultActions result) throws Exception {
        return readJson(result.andReturn().getResponse().getContentAsString()).get("id").asText();
    }

    @Test
    @DisplayName("§13.2 commentaires : tous les membres sauf le lecteur commentent ; seul l'auteur modifie ou supprime")
    void comments() throws Exception {
        send(bearer("viewer"), P + "/requirements/REQ-2/comments", Map.of("text", "x")).andExpect(status().isForbidden());
        send(qa, P + "/requirements/REQ-2/comments", Map.of("text", " ")).andExpect(status().isBadRequest());
        String id = id(send(bearer("dev"), P + "/requirements/REQ-2/comments", Map.of("text", "Le transporteur facture **au poids**"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.author", is("dev")))
                .andExpect(jsonPath("$.question", is(false))));
        mvc.perform(put(P + "/comments/" + id).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("text", "piraté")))).andExpect(status().isForbidden());
        mvc.perform(put(P + "/comments/" + id).header("Authorization", bearer("dev")).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("text", "Le transporteur facture au poids et au volume"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.editedAt").exists());
        send(qa, P + "/comments/" + id + "/resolve", Map.of("resolved", true))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("COMMENT_NOT_A_QUESTION")));
        mvc.perform(get(P + "/requirements/REQ-2/comments").header("Authorization", bearer("viewer")))
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].text", is("Le transporteur facture au poids et au volume")));
        mvc.perform(delete(P + "/comments/" + id).header("Authorization", qa)).andExpect(status().isForbidden());
        mvc.perform(delete(P + "/comments/" + id).header("Authorization", bearer("dev"))).andExpect(status().isNoContent());
    }

    @Test
    @DisplayName("F-REQ-13 / F-REQ-14 atelier : règles, exemples rattachés, questions ; conversion en règle métier enfant et en critère Gherkin")
    void exampleMapping() throws Exception {
        String rule = id(send(qa, P + "/requirements/REQ-2/example-cards", Map.of("kind", "RULE", "text", "Livraison gratuite dès 50 €"))
                .andExpect(status().isCreated()));
        send(qa, P + "/requirements/REQ-2/example-cards", Map.of("kind", "EXAMPLE", "text", "Sans règle"))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("EXAMPLE_RULE_REQUIRED")));
        String example = id(send(qa, P + "/requirements/REQ-2/example-cards",
                Map.of("kind", "EXAMPLE", "ruleId", rule, "text", "Panier de 50 € : livraison offerte")).andExpect(status().isCreated()));
        send(qa, P + "/requirements/REQ-2/example-cards", Map.of("kind", "EXAMPLE", "ruleId", rule, "text", "Panier de 49,99 € : frais de 4,90 €"))
                .andExpect(jsonPath("$.position", is(2)));
        send(qa, P + "/requirements/REQ-2/comments", Map.of("text", "Et les DOM-TOM ?", "question", true)).andExpect(status().isCreated());
        send(bearer("dev"), P + "/requirements/REQ-2/example-cards", Map.of("kind", "RULE", "text", "x")).andExpect(status().isForbidden());
        send(qa, P + "/requirements/REQ-1/example-cards", Map.of("kind", "RULE", "text", "x"))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("EXAMPLE_MAPPING_STORY_ONLY")));

        mvc.perform(get(P + "/requirements/REQ-2/example-map").header("Authorization", bearer("viewer")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.storyKey", is("REQ-2")))
                .andExpect(jsonPath("$.rules[0].rule.text", is("Livraison gratuite dès 50 €")))
                .andExpect(jsonPath("$.rules[0].examples[*].position", contains(1, 2)))
                .andExpect(jsonPath("$.questions[0].text", is("Et les DOM-TOM ?")))
                .andExpect(jsonPath("$.openQuestions", is(1)));

        // F-REQ-14 : un exemple devient un critère Gherkin (testeur) ; une règle une exigence enfant (PO seulement)
        mvc.perform(post(P + "/example-cards/" + example + "/convert").header("Authorization", qa))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.criterionPosition", is(2)))
                .andExpect(jsonPath("$.card.convertedTo", is("Critère 2")));
        mvc.perform(get(P + "/requirements/REQ-2/acceptance-criteria").header("Authorization", qa))
                .andExpect(jsonPath("$[1].format", is("GHERKIN")))
                .andExpect(jsonPath("$[1].content", startsWith("Scénario: Panier de 50 € : livraison offerte")));
        mvc.perform(post(P + "/example-cards/" + example + "/convert").header("Authorization", qa))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("EXAMPLE_CARD_ALREADY_CONVERTED")));
        mvc.perform(post(P + "/example-cards/" + rule + "/convert").header("Authorization", qa)).andExpect(status().isForbidden());
        mvc.perform(post(P + "/example-cards/" + rule + "/convert").header("Authorization", po))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.requirementKey", is("REQ-3")));
        mvc.perform(get(P + "/requirements/REQ-3").header("Authorization", po))
                .andExpect(jsonPath("$.type", is("BUSINESS_RULE")))
                .andExpect(jsonPath("$.parent.key", is("REQ-2")));

        mvc.perform(put(P + "/example-cards/" + rule).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("text", "Livraison offerte dès 50 € TTC")))).andExpect(jsonPath("$.text", is("Livraison offerte dès 50 € TTC")));
        mvc.perform(delete(P + "/example-cards/" + rule).header("Authorization", qa)).andExpect(status().isNoContent());
        mvc.perform(get(P + "/requirements/REQ-2/example-map").header("Authorization", qa)).andExpect(jsonPath("$.rules", hasSize(0)));
    }

    @Test
    @DisplayName("F-REQ-15 une question ouverte bloque READY (avertissement) ; le PO passe outre ; résolue, elle ne bloque plus")
    void openQuestionsBlockReady() throws Exception {
        String question = id(send(qa, P + "/requirements/REQ-2/comments", Map.of("text", "Quel transporteur ?", "question", true)));
        send(po, P + "/requirements/REQ-2/status", Map.of("status", "READY"))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("CHECKLIST_ACKNOWLEDGEMENT_REQUIRED")))
                .andExpect(jsonPath("$.unmetItems", hasItem("1 question(s) ouverte(s) (Example Mapping)")));
        send(qa, P + "/comments/" + question + "/resolve", Map.of("resolved", true))
                .andExpect(jsonPath("$.open", is(false)))
                .andExpect(jsonPath("$.resolvedBy", is("qa1")));
        JsonNode response = readJson(send(po, P + "/requirements/REQ-2/status", Map.of("status", "READY")).andReturn().getResponse().getContentAsString());
        // sans question ouverte, seuls les items manuels de la DoR restent à acquitter (selon la configuration)
        if (response.has("code")) {
            org.assertj.core.api.Assertions.assertThat(response.get("unmetItems").toString()).doesNotContain("question");
        }
        send(qa, P + "/comments/" + question + "/resolve", Map.of("resolved", false)).andExpect(jsonPath("$.open", is(true)));
        send(po, P + "/requirements/REQ-2/status", Map.of("status", "READY", "acknowledgeUnmet", true))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("READY")));
    }
}
