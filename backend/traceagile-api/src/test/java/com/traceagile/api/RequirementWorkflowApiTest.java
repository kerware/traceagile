package com.traceagile.api;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.traceagile.domain.administration.ProjectRole;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;

/**
 * §4.3 critères, §4.6 DoR / DoD, §4.7 versions et import / export, et parcours §15.3 étape 1 côté API.
 */
class RequirementWorkflowApiTest extends AbstractApiTest {

    static final String BASE = "/api/v1/projects/SHOP/requirements";
    static final String GHERKIN_1 = """
            Scénario: livraison gratuite au seuil
              Étant donné un panier de 50 €
              Quand je valide ma commande
              Alors la livraison est offerte""";
    static final String GHERKIN_2 = """
            Scénario: livraison payante sous le seuil
              Étant donné un panier de 49,99 €
              Alors la livraison coûte 4,90 €""";

    String po;

    @BeforeEach
    void data() throws Exception {
        user("admin", true);
        user("po", false);
        user("qa1", false);
        user("viewer", false);
        project("SHOP", Map.of("po", ProjectRole.PRODUCT_OWNER, "qa1", ProjectRole.TESTER, "viewer", ProjectRole.VIEWER));
        po = bearer("po");
        createRequirement("EPIC", "Panier et commande", null);
        createRequirement("FEATURE", "Panier", "REQ-1");
    }

    void createRequirement(String type, String title, String parentKey) throws Exception {
        String body = parentKey == null ? toJson(Map.of("type", type, "title", title))
                : toJson(Map.of("type", type, "title", title, "parentKey", parentKey));
        mvc.perform(post(BASE).header("Authorization", po).contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isCreated());
    }

    String addCriterion(String key, String format, String text, String login) throws Exception {
        String json = mvc.perform(post(BASE + "/" + key + "/acceptance-criteria").header("Authorization", bearer(login))
                        .contentType(MediaType.APPLICATION_JSON).content(toJson(Map.of("format", format, "content", text))))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return readJson(json).get("id").asText();
    }

    @Test
    @DisplayName("Parcours §15.3 étape 1 (API) : le PO crée une story avec deux critères Gherkin et la passe à READY")
    void journeyStep1() throws Exception {
        mvc.perform(post(BASE).header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("type", "USER_STORY", "title", "Livraison gratuite dès 50 €", "parentKey", "REQ-2",
                                "asA", "client", "iWant", "la livraison offerte dès 50 €", "soThat", "commander davantage",
                                "priority", "MUST", "storyPoints", 5))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.key", is("REQ-3")));
        addCriterion("REQ-3", "GHERKIN", GHERKIN_1, "po");
        addCriterion("REQ-3", "GHERKIN", GHERKIN_2, "po");

        // La DoR a un item manuel non coché : confirmation demandée.
        mvc.perform(statusChange("REQ-3", "READY", false))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("CHECKLIST_ACKNOWLEDGEMENT_REQUIRED")))
                .andExpect(jsonPath("$.unmetItems", contains("Story comprise et acceptée par l'équipe")));
        mvc.perform(statusChange("REQ-3", "READY", true))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("READY")))
                .andExpect(jsonPath("$.currentVersion", is(1)));

        // F-REQ-21 version figée automatiquement au passage à READY.
        mvc.perform(get(BASE + "/REQ-3/versions").header("Authorization", po))
                .andExpect(jsonPath("$[0].versionNumber", is(1)))
                .andExpect(jsonPath("$[0].changeComment", is("Passage à READY")))
                .andExpect(jsonPath("$[0].snapshot.status", is("READY")));
        // L'ajout au sprint SPR-2 viendra au lot 4 (planification), voir ADR-0009.
    }

    private org.springframework.test.web.servlet.RequestBuilder statusChange(String key, String target, boolean acknowledge) {
        try {
            return post(BASE + "/" + key + "/status").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                    .content(toJson(Map.of("status", target, "acknowledgeUnmet", acknowledge)));
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    @Test
    @DisplayName("§3.3-2 / F-REQ-20 READY sans critère : la DoR bloque → 422 CHECKLIST_NOT_SATISFIED")
    void readyWithoutCriterion() throws Exception {
        mvc.perform(statusChange("REQ-2", "READY", true))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("CHECKLIST_NOT_SATISFIED")))
                .andExpect(jsonPath("$.unmetItems", contains("Au moins un critère d'acceptation")));
    }

    @Test
    @DisplayName("§3.2 transition interdite → 422 REQ_STATUS_TRANSITION_INVALID")
    void invalidTransition() throws Exception {
        mvc.perform(statusChange("REQ-2", "ACCEPTED", true))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("REQ_STATUS_TRANSITION_INVALID")));
    }

    @Test
    @DisplayName("F-REQ-19 un item manuel coché satisfait la DoR ; évaluation visible sur la fiche")
    void manualChecklistItem() throws Exception {
        addCriterion("REQ-2", "TEXT", "Le panier affiche le total", "po");
        String checklists = mvc.perform(get(BASE + "/REQ-2/checklists").header("Authorization", po))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.dor[0].outcome", is("SATISFIED")))
                .andExpect(jsonPath("$.dor[2].automatic", is(false)))
                .andExpect(jsonPath("$.dor[2].outcome", is("UNSATISFIED")))
                // Lot 2 : « au moins un test lié » est évalué ; « tests passés » attend les exécutions (lot 5).
                .andExpect(jsonPath("$.dod[0].outcome", is("UNSATISFIED")))
                .andExpect(jsonPath("$.dod[1].outcome", is("NOT_EVALUATED")))
                .andReturn().getResponse().getContentAsString();
        String manualId = readJson(checklists).get("dor").get(2).get("id").asText();

        mvc.perform(put(BASE + "/REQ-2/checklists/" + manualId).header("Authorization", bearer("qa1"))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"checked\":true}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.dor[2].outcome", is("SATISFIED")));
        mvc.perform(statusChange("REQ-2", "READY", false)).andExpect(status().isOk());
    }

    @Test
    @DisplayName("F-REQ-19 DoR / DoD paramétrables par projet (administrateur du projet)")
    void projectChecklists() throws Exception {
        mvc.perform(get("/api/v1/projects/SHOP/checklists").header("Authorization", po))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.dor[*].label", hasItem("Estimation renseignée")))
                .andExpect(jsonPath("$.dod[*].rule", hasItem("ALL_LINKED_TESTS_PASSED")));
        List<Map<String, Object>> dor = List.of(
                Map.of("label", "Au moins un critère d'acceptation", "rule", "HAS_ACCEPTANCE_CRITERION"),
                Map.of("label", "Maquettes validées"));

        mvc.perform(put("/api/v1/projects/SHOP/checklists/DOR").header("Authorization", po)
                        .contentType(MediaType.APPLICATION_JSON).content(toJson(dor)))
                .andExpect(status().isForbidden());
        mvc.perform(put("/api/v1/projects/SHOP/checklists/DOR").header("Authorization", bearer("admin"))
                        .contentType(MediaType.APPLICATION_JSON).content(toJson(dor)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].label", contains("Au moins un critère d'acceptation", "Maquettes validées")));
    }

    @Test
    @DisplayName("F-REQ-09 critères : ajout par le testeur (proposition), modification, réordonnancement, suppression")
    void criteria() throws Exception {
        String a = addCriterion("REQ-2", "TEXT", "A", "qa1");
        String b = addCriterion("REQ-2", "TEXT", "B", "po");
        mvc.perform(post(BASE + "/REQ-2/acceptance-criteria").header("Authorization", bearer("viewer"))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"format\":\"TEXT\",\"content\":\"X\"}"))
                .andExpect(status().isForbidden());

        mvc.perform(patch("/api/v1/projects/SHOP/acceptance-criteria/" + a).header("Authorization", po)
                        .contentType("application/merge-patch+json").content("{\"content\":\"A modifié\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", is("A modifié")));
        mvc.perform(put(BASE + "/REQ-2/acceptance-criteria/order").header("Authorization", po)
                        .contentType(MediaType.APPLICATION_JSON).content(toJson(Map.of("ids", List.of(b, a)))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].content", contains("B", "A modifié")));
        mvc.perform(delete("/api/v1/projects/SHOP/acceptance-criteria/" + b).header("Authorization", po))
                .andExpect(status().isNoContent());
        mvc.perform(get(BASE + "/REQ-2/acceptance-criteria").header("Authorization", po))
                .andExpect(jsonPath("$[*].content", contains("A modifié")))
                .andExpect(jsonPath("$[0].position", is(1)));
    }

    @Test
    @DisplayName("F-REQ-10 un critère Gherkin invalide est refusé avec les erreurs positionnées")
    void invalidGherkin() throws Exception {
        mvc.perform(post(BASE + "/REQ-2/acceptance-criteria").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("format", "GHERKIN", "content", "Scénario: x\n  Étant donné les produits\n    | a | b |\n    | 1 |"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("GHERKIN_INVALID")))
                .andExpect(jsonPath("$.gherkinErrors[0].line", is(4)));
    }

    @Test
    @DisplayName("F-REQ-10 §12 POST /gherkin/validate")
    void validateEndpoint() throws Exception {
        mvc.perform(post("/api/v1/gherkin/validate").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("source", GHERKIN_1))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.valid", is(true)))
                .andExpect(jsonPath("$.language", is("fr")));
    }

    @Test
    @DisplayName("F-REQ-21 version à la demande et comparaison de deux versions")
    void versionsDiff() throws Exception {
        mvc.perform(post(BASE + "/REQ-2/versions").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"comment\":\"Avant atelier\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.versionNumber", is(1)));
        mvc.perform(patch(BASE + "/REQ-2").header("Authorization", po).contentType("application/merge-patch+json")
                        .content("{\"title\":\"Panier d'achat\",\"priority\":\"MUST\"}"))
                .andExpect(status().isOk());
        addCriterion("REQ-2", "TEXT", "Le total est affiché", "po");
        mvc.perform(post(BASE + "/REQ-2/versions").header("Authorization", po).contentType(MediaType.APPLICATION_JSON).content("{}"))
                .andExpect(jsonPath("$.versionNumber", is(2)));

        mvc.perform(get(BASE + "/REQ-2/versions/1/diff/2").header("Authorization", bearer("viewer")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].field", contains("title", "priority", "criteria")))
                .andExpect(jsonPath("$[0].before", is("Panier")))
                .andExpect(jsonPath("$[0].after", is("Panier d'achat")))
                .andExpect(jsonPath("$[2].after", is("[TEXT] Le total est affiché")));
        mvc.perform(get(BASE + "/REQ-2/versions/9/diff/2").header("Authorization", po))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("F-REQ-23 import CSV puis export du backlog filtré")
    void csvImportExport() throws Exception {
        String csv = "type;parent key;title;asA;iWant;soThat;priority;points;tags;acceptance criteria\n"
                + "USER_STORY;REQ-2;Vider le panier;client;vider mon panier;recommencer;COULD;2;panier;"
                + "\"Le panier est vide || Scénario: vider\n  Étant donné un panier rempli\n  Alors il est vide\"\n";
        MockMultipartFile file = new MockMultipartFile("file", "backlog.csv", "text/csv", csv.getBytes(StandardCharsets.UTF_8));

        mvc.perform(multipart(BASE + "/import").file(file).header("Authorization", po))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.created", contains("REQ-3")));
        mvc.perform(get(BASE + "/REQ-3/acceptance-criteria").header("Authorization", po))
                .andExpect(jsonPath("$[*].format", contains("TEXT", "GHERKIN")));

        mvc.perform(get(BASE + "/export?type=USER_STORY").header("Authorization", bearer("viewer")))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith("text/csv"))
                .andExpect(header().string("Content-Disposition", org.hamcrest.Matchers.containsString("SHOP-backlog.csv")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("REQ-3;USER_STORY;REQ-2;Vider le panier")));

        MockMultipartFile broken = new MockMultipartFile("file", "b.csv", "text/csv",
                "type;title\nUSER_STORY;Sans parent\n".getBytes(StandardCharsets.UTF_8));
        mvc.perform(multipart(BASE + "/import").file(broken).header("Authorization", po))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("CSV_INVALID")))
                .andExpect(jsonPath("$.lineErrors[0].line", is(2)));
        mvc.perform(multipart(BASE + "/import").file(file).header("Authorization", bearer("viewer")))
                .andExpect(status().isForbidden());
    }
}
