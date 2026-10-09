package com.traceagile.api;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.traceagile.domain.administration.ProjectRole;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

/** §8.1 releases et §8.2 sprints (critère de fin du lot 4 : release de 3 sprints créée et planifiée). */
class PlanningApiTest extends AbstractApiTest {

    static final String P = "/api/v1/projects/SHOP";
    String po;

    @BeforeEach
    void data() throws Exception {
        user("po", false);
        user("qa1", false);
        user("viewer", false);
        project("SHOP", Map.of("po", ProjectRole.PRODUCT_OWNER, "qa1", ProjectRole.TESTER, "viewer", ProjectRole.VIEWER));
        po = bearer("po");
        // REQ-1 feature > REQ-2 (5 pts), REQ-3 (13 pts) prêtes ; REQ-4 brouillon
        send(P + "/requirements", Map.of("type", "FEATURE", "title", "Panier"));
        story("Ajouter au panier", 5, true);
        story("Payer par carte", 13, true);
        story("Vider le panier", 3, false);
    }

    void send(String url, Map<String, Object> body) throws Exception {
        mvc.perform(post(url).header("Authorization", po)
                .contentType(MediaType.APPLICATION_JSON).content(toJson(body))).andExpect(status().is2xxSuccessful());
    }

    void story(String title, int points, boolean ready) throws Exception {
        String json = mvc.perform(post(P + "/requirements")
                        .header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("type", "USER_STORY", "title", title, "parentKey", "REQ-1", "storyPoints", points,
                                "criteria", List.of(Map.of("format", "TEXT", "content", "OK"))))))
                .andReturn().getResponse().getContentAsString();
        if (ready) {
            String key = readJson(json).get("key").asText();
            send(P + "/requirements/" + key + "/status", Map.of("status", "READY", "acknowledgeUnmet", true));
        }
    }

    void release() throws Exception {
        mvc.perform(post(P + "/releases").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("name", "Version 2.0", "goal", "Paiement", "startDate", "2026-10-12", "endDate", "2026-11-22"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.key", is("REL-1")))
                .andExpect(jsonPath("$.status", is("PLANNED")));
    }

    void generate() throws Exception {
        mvc.perform(post(P + "/releases/REL-1/generate-sprints").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("count", 3, "durationWeeks", 2, "capacityPoints", 15))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sprints[*].key", contains("SPR-1", "SPR-2", "SPR-3")))
                .andExpect(jsonPath("$.sprints[*].startDate", contains("2026-10-12", "2026-10-26", "2026-11-09")))
                .andExpect(jsonPath("$.sprints[2].endDate", is("2026-11-22")))
                .andExpect(jsonPath("$.sprints[0].capacityPoints", is(15)));
    }

    void scope(String sprint, List<String> keys) throws Exception {
        mvc.perform(put(P + "/sprints/" + sprint + "/scope").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("requirementKeys", keys)))).andExpect(status().isOk());
    }

    @Test
    @DisplayName("Lot 4 — critère de fin : release de 3 sprints créée, générée et planifiée ; feuille de route (F-PLN-01, F-PLN-02)")
    void releaseOfThreeSprints() throws Exception {
        release();
        generate();
        mvc.perform(put(P + "/sprints/SPR-1/scope").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("requirementKeys", List.of("REQ-3", "REQ-2")))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.scope[*].key", contains("REQ-3", "REQ-2")))
                .andExpect(jsonPath("$.sprint.loadPoints", is(18)))
                .andExpect(jsonPath("$.sprint.loadPercent", is(120)))
                .andExpect(jsonPath("$.sprint.overCapacity", is(true)))
                .andExpect(jsonPath("$.nextSprintKey", is("SPR-2")));
        mvc.perform(get(P + "/releases").header("Authorization", bearer("viewer")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].sprints", hasSize(3)))
                .andExpect(jsonPath("$[0].sprints[0].requirementCount", is(2)))
                .andExpect(jsonPath("$[0].sprints[0].requirementKeys", contains("REQ-3", "REQ-2")));
        mvc.perform(get(P + "/requirements").param("sprint", "SPR-1").header("Authorization", po))
                .andExpect(jsonPath("$.content[*].key", contains("REQ-2", "REQ-3")));
    }

    @Test
    @DisplayName("§3.3-3 sprint hors de la release ou chevauchant un autre sprint → 422 ; sprint libre puis rattaché")
    void sprintRules() throws Exception {
        release();
        generate();
        mvc.perform(post(P + "/sprints").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("name", "Hotfix", "startDate", "2026-10-20", "endDate", "2026-10-24", "releaseKey", "REL-1"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("SPRINT_OVERLAP")));
        mvc.perform(post(P + "/sprints").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("name", "Hors release", "startDate", "2026-12-07", "endDate", "2026-12-18", "capacityPoints", 10))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.sprint.key", is("SPR-4")))
                .andExpect(jsonPath("$.sprint.releaseKey").doesNotExist());
        mvc.perform(patch(P + "/sprints/SPR-4").header("Authorization", po).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("releaseKey", "REL-1"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("SPRINT_OUTSIDE_RELEASE")));
        mvc.perform(patch(P + "/releases/REL-1").header("Authorization", po).header("If-Match", "\"9\"")
                        .contentType("application/merge-patch+json").content(toJson(Map.of("endDate", "2026-12-20"))))
                .andExpect(status().isPreconditionFailed());
        mvc.perform(patch(P + "/releases/REL-1").header("Authorization", po)
                        .contentType("application/merge-patch+json").content(toJson(Map.of("endDate", "2026-12-20"))))
                .andExpect(status().isOk())
                .andExpect(header().exists("ETag"));
        mvc.perform(patch(P + "/sprints/SPR-4").header("Authorization", po).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("releaseKey", "REL-1"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sprint.releaseKey", is("REL-1")));
    }

    @Test
    @DisplayName("F-PLN-05 seules les exigences prêtes se planifient, dans un seul sprint ouvert")
    void scopeRules() throws Exception {
        release();
        generate();
        mvc.perform(put(P + "/sprints/SPR-1/scope").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("requirementKeys", List.of("REQ-4")))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("SPRINT_SCOPE_NOT_READY")));
        mvc.perform(put(P + "/sprints/SPR-1/scope").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("requirementKeys", List.of("REQ-1")))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("SPRINT_SCOPE_TYPE_INVALID")));
        scope("SPR-1", List.of("REQ-2"));
        mvc.perform(put(P + "/sprints/SPR-2/scope").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("requirementKeys", List.of("REQ-2")))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("REQ_ALREADY_PLANNED")));
    }

    @Test
    @DisplayName("F-PLN-06 démarrer (stories IN_SPRINT, un seul sprint actif) puis clôturer avec report et renvoi")
    void startAndClose() throws Exception {
        release();
        generate();
        scope("SPR-1", List.of("REQ-2", "REQ-3"));
        mvc.perform(post(P + "/sprints/SPR-1/start").header("Authorization", po))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sprint.status", is("ACTIVE")))
                .andExpect(jsonPath("$.scope[*].status", contains("IN_SPRINT", "IN_SPRINT")));
        mvc.perform(get(P + "/releases/REL-1").header("Authorization", po)).andExpect(jsonPath("$.status", is("ACTIVE")));
        mvc.perform(post(P + "/sprints/SPR-2/start").header("Authorization", po))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("SPRINT_ALREADY_ACTIVE")));

        mvc.perform(post(P + "/sprints/SPR-1/close").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("decisions", List.of(Map.of("requirementKey", "REQ-3", "action", "NEXT_SPRINT"))))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sprint.status", is("CLOSED")))
                .andExpect(jsonPath("$.scope[*].outcome", contains("RETURNED", "CARRIED_OVER")));
        mvc.perform(get(P + "/sprints/SPR-2").header("Authorization", po))
                .andExpect(jsonPath("$.scope[*].key", contains("REQ-3")))
                .andExpect(jsonPath("$.scope[0].status", is("READY")));
        mvc.perform(patch(P + "/sprints/SPR-1").header("Authorization", po).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("name", "Renommé"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("SPRINT_CLOSED")));
    }

    @Test
    @DisplayName("F-PLN-03 clôturer une release : sprints clos exigés, bilan figé, lecture seule")
    void closeRelease() throws Exception {
        release();
        mvc.perform(post(P + "/releases/REL-1/generate-sprints").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("count", 1, "durationWeeks", 2)))).andExpect(status().isOk());
        scope("SPR-1", List.of("REQ-2"));
        mvc.perform(post(P + "/releases/REL-1/close").header("Authorization", po))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("RELEASE_SPRINTS_NOT_CLOSED")));
        mvc.perform(post(P + "/sprints/SPR-1/start").header("Authorization", po)).andExpect(status().isOk());
        mvc.perform(post(P + "/sprints/SPR-1/close").header("Authorization", po)).andExpect(status().isOk());
        mvc.perform(post(P + "/releases/REL-1/close").header("Authorization", po))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("CLOSED")))
                .andExpect(jsonPath("$.closedAt", notNullValue()))
                .andExpect(jsonPath("$.closingReport.sprints[0].key", is("SPR-1")))
                .andExpect(jsonPath("$.closingReport.committedPoints", is(5)))
                .andExpect(jsonPath("$.closingReport.coverage.design", is(0.0)));
        mvc.perform(patch(P + "/releases/REL-1").header("Authorization", po).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("name", "V3"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("RELEASE_CLOSED")));
    }

    @Test
    @DisplayName("§2.2 le testeur lit la planification sans la modifier ; validation 400 ; inconnu 404")
    void rightsAndValidation() throws Exception {
        release();
        mvc.perform(get(P + "/releases/REL-1").header("Authorization", bearer("qa1"))).andExpect(status().isOk());
        mvc.perform(post(P + "/releases").header("Authorization", bearer("qa1")).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("name", "V3", "startDate", "2026-10-12", "endDate", "2026-11-22"))))
                .andExpect(status().isForbidden());
        mvc.perform(post(P + "/releases/REL-1/generate-sprints").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("count", 3, "durationWeeks", 5))))
                .andExpect(status().isBadRequest());
        mvc.perform(post(P + "/releases").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("name", "V3", "startDate", "2026-10-12", "endDate", "2026-10-01"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("PLANNING_DATES_INVALID")));
        mvc.perform(get(P + "/sprints/SPR-9").header("Authorization", po)).andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("§7.2 périmètre de couverture par sprint et par release")
    void coverageScopes() throws Exception {
        release();
        generate();
        scope("SPR-1", List.of("REQ-2"));
        scope("SPR-2", List.of("REQ-3"));
        mvc.perform(get(P + "/coverage").param("scope", "sprint:SPR-1").header("Authorization", po))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.requirements[*].key", contains("REQ-2")))
                .andExpect(jsonPath("$.design.denominator", is(1.0)));
        mvc.perform(get(P + "/traceability/matrix").param("scope", "release:REL-1").header("Authorization", po))
                .andExpect(jsonPath("$.requirements[*].key", contains("REQ-2", "REQ-3")));
        mvc.perform(get(P + "/coverage").param("scope", "release:REL-9").header("Authorization", po))
                .andExpect(status().isNotFound());
    }
}
