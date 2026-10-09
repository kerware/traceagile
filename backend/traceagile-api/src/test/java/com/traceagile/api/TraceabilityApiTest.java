package com.traceagile.api;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
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

/**
 * §7 traçabilité : liens (F-TRA-01 à F-TRA-03), suspicion (§3.3-7), statut de vérification (§7.3),
 * couverture (§7.2), matrice et export (F-TRA-04, F-TRA-08), arbre (F-TRA-05), orphelins (F-TRA-06),
 * impact (F-TRA-07).
 */
class TraceabilityApiTest extends AbstractApiTest {

    static final String P = "/api/v1/projects/SHOP";
    String po;
    String qa;

    @BeforeEach
    void data() throws Exception {
        user("po", false);
        user("qa1", false);
        user("dev", false);
        user("viewer", false);
        project("SHOP", Map.of("po", ProjectRole.PRODUCT_OWNER, "qa1", ProjectRole.TESTER, "dev", ProjectRole.DEVELOPER,
                "viewer", ProjectRole.VIEWER));
        po = bearer("po");
        qa = bearer("qa1");
        // REQ-1 épic > REQ-2 feature > REQ-3 (2 critères), REQ-4 stories
        requirement(Map.of("type", "EPIC", "title", "Panier"));
        requirement(Map.of("type", "FEATURE", "title", "Gestion du panier", "parentKey", "REQ-1"));
        requirement(Map.of("type", "USER_STORY", "title", "Ajouter au panier", "parentKey", "REQ-2", "riskLevel", "HIGH",
                "criteria", List.of(Map.of("format", "TEXT", "content", "Le produit est ajouté"),
                        Map.of("format", "TEXT", "content", "Le total est recalculé"))));
        requirement(Map.of("type", "USER_STORY", "title", "Vider le panier", "parentKey", "REQ-2"));
        // TC-1 manuel READY, TC-2 manuel, TC-3 automatisé jamais exécuté, sans exigence
        test(Map.of("kind", "MANUAL", "title", "Ajouter un produit", "steps", List.of(Map.of("action", "Ajouter", "expectedResult", "OK"))));
        mvc.perform(post(P + "/test-cases/TC-1/status").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("status", "READY")))).andExpect(status().isOk());
        test(Map.of("kind", "MANUAL", "title", "Vider"));
        test(Map.of("kind", "AUTOMATED", "title", "API panier", "technique", "API"));
    }

    void requirement(Map<String, Object> body) throws Exception {
        mvc.perform(post(P + "/requirements").header("Authorization", po).contentType(MediaType.APPLICATION_JSON).content(toJson(body)))
                .andExpect(status().isCreated());
    }

    void test(Map<String, Object> body) throws Exception {
        mvc.perform(post(P + "/test-cases").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON).content(toJson(body)))
                .andExpect(status().isCreated());
    }

    String link(String test, String requirement, String type, List<Integer> criteria) throws Exception {
        String json = mvc.perform(post(P + "/trace-links").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("testKey", test, "requirementKey", requirement, "linkType", type, "criterionPositions", criteria))))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return readJson(json).get("id").asText();
    }

    @Test
    @DisplayName("F-TRA-01 / F-TRA-03 lien depuis la fiche exigence, avec critères ; doublon 409, droits 403, validation 400 / 422")
    void createLink() throws Exception {
        mvc.perform(post(P + "/trace-links").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("testKey", "TC-1", "requirementKey", "REQ-3", "linkType", "VERIFIES", "criterionPositions", List.of(1)))))
                .andExpect(status().isCreated())
                .andExpect(header().exists("ETag"))
                .andExpect(jsonPath("$.criterionPositions", contains(1)))
                .andExpect(jsonPath("$.suspect", is(false)));
        mvc.perform(get(P + "/requirements/REQ-3/test-cases").header("Authorization", bearer("viewer")))
                .andExpect(jsonPath("$[0].key", is("TC-1")))
                .andExpect(jsonPath("$[0].linkId").exists());

        mvc.perform(post(P + "/trace-links").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("testKey", "TC-1", "requirementKey", "REQ-3", "linkType", "VERIFIES"))))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code", is("LINK_EXISTS")));
        mvc.perform(post(P + "/trace-links").header("Authorization", bearer("viewer")).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("testKey", "TC-2", "requirementKey", "REQ-3", "linkType", "VERIFIES"))))
                .andExpect(status().isForbidden());
        mvc.perform(post(P + "/trace-links").header("Authorization", bearer("dev")).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("testKey", "TC-2", "requirementKey", "REQ-3", "linkType", "VERIFIES"))))
                .andExpect(status().isForbidden());
        mvc.perform(post(P + "/trace-links").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("testKey", "TC-2", "requirementKey", "REQ-3"))))
                .andExpect(status().isBadRequest());
        mvc.perform(post(P + "/trace-links").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("testKey", "TC-2", "requirementKey", "REQ-3", "linkType", "VERIFIES", "criterionPositions", List.of(9)))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("CRITERION_POSITION_UNKNOWN")));
    }

    @Test
    @DisplayName("F-TRA-02 changement de type avec If-Match (412 si périmé), suppression du lien et de ses critères")
    void updateAndDeleteLink() throws Exception {
        String id = link("TC-2", "REQ-3", "VERIFIES", List.of(1, 2));
        mvc.perform(patch(P + "/trace-links/" + id).header("Authorization", qa).header("If-Match", "\"9\"")
                        .contentType(MediaType.APPLICATION_JSON).content(toJson(Map.of("linkType", "RELATES_TO"))))
                .andExpect(status().isPreconditionFailed());
        mvc.perform(patch(P + "/trace-links/" + id).header("Authorization", qa).header("If-Match", "\"0\"")
                        .contentType(MediaType.APPLICATION_JSON).content(toJson(Map.of("linkType", "PARTIALLY_VERIFIES"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.linkType", is("PARTIALLY_VERIFIES")))
                .andExpect(jsonPath("$.criterionPositions", contains(1, 2)));
        mvc.perform(delete(P + "/trace-links/" + id).header("Authorization", qa)).andExpect(status().isNoContent());
        mvc.perform(get(P + "/requirements/REQ-3/trace-tree").header("Authorization", qa))
                .andExpect(jsonPath("$.tests", hasSize(0)))
                .andExpect(jsonPath("$.criteria[0].testKeys", hasSize(0)));
        mvc.perform(delete(P + "/trace-links/" + id).header("Authorization", qa)).andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("§3.3-7 modifier le contenu d'une exigence : tests READY → NEEDS_UPDATE, lien suspect, statut « Suspecte » ; revue")
    void suspicion() throws Exception {
        String id = link("TC-1", "REQ-3", "VERIFIES", List.of());
        mvc.perform(post(P + "/requirements/REQ-3/status").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("status", "TO_REFINE")))).andExpect(status().isOk());
        mvc.perform(get(P + "/test-cases/TC-1").header("Authorization", qa))
                .andExpect(jsonPath("$.status", is("READY")));

        mvc.perform(patch(P + "/requirements/REQ-3").header("Authorization", po).contentType("application/merge-patch+json")
                .content(toJson(Map.of("description", "Le panier est conservé 30 jours")))).andExpect(status().isOk());

        mvc.perform(get(P + "/test-cases/TC-1").header("Authorization", qa))
                .andExpect(jsonPath("$.status", is("NEEDS_UPDATE")))
                .andExpect(jsonPath("$.requirements[0].suspect", is(true)));
        mvc.perform(get(P + "/requirements/REQ-3").header("Authorization", po))
                .andExpect(jsonPath("$.verificationStatus", is("SUSPECT")));
        mvc.perform(get(P + "/traceability/matrix").header("Authorization", po))
                .andExpect(jsonPath("$.cells[0].suspect", is(true)));

        mvc.perform(post(P + "/trace-links/" + id + "/review").header("Authorization", bearer("viewer")))
                .andExpect(status().isForbidden());
        mvc.perform(post(P + "/trace-links/" + id + "/review").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.suspect", is(false)));
        mvc.perform(get(P + "/requirements/REQ-3").header("Authorization", po))
                .andExpect(jsonPath("$.verificationStatus", is("NOT_RUN")));
    }

    @Test
    @DisplayName("§3.3-7 un test remis à READY après revue n'est plus suspect")
    void readyClearsSuspicion() throws Exception {
        link("TC-1", "REQ-3", "VERIFIES", List.of());
        mvc.perform(patch(P + "/requirements/REQ-3").header("Authorization", po).contentType("application/merge-patch+json")
                .content(toJson(Map.of("title", "Ajouter un produit au panier")))).andExpect(status().isOk());
        mvc.perform(post(P + "/test-cases/TC-1/status").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("status", "READY")))).andExpect(status().isOk());
        mvc.perform(get(P + "/requirements/REQ-3/test-cases").header("Authorization", qa))
                .andExpect(jsonPath("$[0].suspect", is(false)));
    }

    @Test
    @DisplayName("F-TRA-04 matrice : ordre de l'arbre, colonnes liées ou toutes, périmètre ; release / sprint au lot 4 (422)")
    void matrix() throws Exception {
        link("TC-1", "REQ-3", "VERIFIES", List.of(1));
        link("TC-2", "REQ-4", "RELATES_TO", List.of());
        mvc.perform(get(P + "/traceability/matrix").header("Authorization", bearer("viewer")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.requirements[*].key", contains("REQ-1", "REQ-2", "REQ-3", "REQ-4")))
                .andExpect(jsonPath("$.requirements[*].depth", contains(0, 1, 2, 2)))
                .andExpect(jsonPath("$.requirements[*].verificationStatus", contains("NOT_RUN", "NOT_RUN", "NOT_RUN", "NOT_COVERED")))
                .andExpect(jsonPath("$.tests[*].key", contains("TC-1", "TC-2")))
                .andExpect(jsonPath("$.cells[0].criterionPositions", contains(1)))
                .andExpect(jsonPath("$.cells[1].linkType", is("RELATES_TO")));
        mvc.perform(get(P + "/traceability/matrix").param("tests", "all").param("kind", "AUTOMATED").header("Authorization", qa))
                .andExpect(jsonPath("$.tests[*].key", contains("TC-3")))
                .andExpect(jsonPath("$.cells", hasSize(0)));
        mvc.perform(get(P + "/traceability/matrix").param("scope", "requirement:REQ-4").header("Authorization", qa))
                .andExpect(jsonPath("$.requirements[*].key", contains("REQ-4")));
        mvc.perform(get(P + "/traceability/matrix").param("scope", "release:REL-1").header("Authorization", qa))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("SCOPE_NOT_AVAILABLE")));
        mvc.perform(get(P + "/traceability/matrix").param("scope", "n'importe").header("Authorization", qa))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("SCOPE_INVALID")));
    }

    @Test
    @DisplayName("F-TRA-08 export de la matrice en CSV et en PDF")
    void export() throws Exception {
        link("TC-1", "REQ-3", "VERIFIES", List.of());
        mvc.perform(get(P + "/traceability/matrix/export").param("format", "csv").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Disposition", containsString("SHOP-matrice.csv")))
                .andExpect(content().string(containsString("Exigence;Titre;Type;Vérification;TC-1")))
                .andExpect(content().string(containsString("REQ-3;    Ajouter au panier;USER_STORY;NOT_RUN;V")));
        byte[] pdf = mvc.perform(get(P + "/traceability/matrix/export").param("format", "pdf").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Type", "application/pdf"))
                .andReturn().getResponse().getContentAsByteArray();
        org.assertj.core.api.Assertions.assertThat(new String(pdf, 0, 4)).isEqualTo("%PDF");
        mvc.perform(get(P + "/traceability/matrix/export").param("format", "docx").header("Authorization", qa))
                .andExpect(status().isUnprocessableEntity());
    }

    @Test
    @DisplayName("§7.2 couverture : conception, critères, exécution, validation, pondérée par le risque ; périmètre")
    void coverage() throws Exception {
        link("TC-1", "REQ-3", "VERIFIES", List.of(1));
        link("TC-2", "REQ-4", "RELATES_TO", List.of());
        mvc.perform(get(P + "/coverage").header("Authorization", bearer("viewer")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.design.numerator", is(1.0)))
                .andExpect(jsonPath("$.design.denominator", is(2.0)))
                .andExpect(jsonPath("$.design.percent", is(50.0)))
                .andExpect(jsonPath("$.criteria.percent", is(50.0)))
                .andExpect(jsonPath("$.execution.percent", is(0.0)))
                .andExpect(jsonPath("$.validation.percent", is(0.0)))
                // REQ-3 HIGH (4) couverte, REQ-4 MEDIUM (2) non couverte
                .andExpect(jsonPath("$.riskWeighted.numerator", is(4.0)))
                .andExpect(jsonPath("$.riskWeighted.denominator", is(6.0)))
                .andExpect(jsonPath("$.requirements[2].coveringTests", is(1)));
        mvc.perform(get(P + "/coverage").param("scope", "requirement:REQ-4").header("Authorization", qa))
                .andExpect(jsonPath("$.design.percent", is(0.0)));
    }

    @Test
    @DisplayName("F-TRA-06 orphelins : exigences sans test, tests sans exigence, automatisés jamais exécutés")
    void orphans() throws Exception {
        link("TC-1", "REQ-3", "VERIFIES", List.of());
        mvc.perform(get(P + "/traceability/orphans").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.requirementsWithoutTests[*].key", contains("REQ-4")))
                .andExpect(jsonPath("$.testsWithoutRequirement[*].key", contains("TC-2", "TC-3")))
                .andExpect(jsonPath("$.automatedNeverExecuted[*].key", contains("TC-3")))
                .andExpect(jsonPath("$.defectsWithoutRequirement", hasSize(0)));
    }

    @Test
    @DisplayName("F-TRA-05 arbre de traçabilité ; F-TRA-07 analyse d'impact ; F-REQ-12 état des critères")
    void treeAndImpact() throws Exception {
        link("TC-1", "REQ-3", "VERIFIES", List.of(2));
        link("TC-2", "REQ-2", "RELATES_TO", List.of());
        mvc.perform(get(P + "/requirements/REQ-3/trace-tree").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.ancestors[*].key", contains("REQ-1", "REQ-2")))
                .andExpect(jsonPath("$.requirement.verificationStatus", is("NOT_RUN")))
                .andExpect(jsonPath("$.criteria[1].testKeys", contains("TC-1")))
                .andExpect(jsonPath("$.criteria[1].status", is("TO_VERIFY")))
                .andExpect(jsonPath("$.tests[0].test.key", is("TC-1")));
        mvc.perform(get(P + "/requirements/REQ-2/impact").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.tests[*].test.key", contains("TC-1", "TC-2")))
                .andExpect(jsonPath("$.tests[0].via.key", is("REQ-3")))
                .andExpect(jsonPath("$.campaigns", hasSize(0)));
        mvc.perform(get(P + "/requirements/REQ-99/impact").header("Authorization", qa)).andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("§7.3 statut de vérification dans la liste, l'arbre et la fiche du backlog")
    void verificationStatusInBacklog() throws Exception {
        link("TC-1", "REQ-3", "VERIFIES", List.of());
        mvc.perform(get(P + "/requirements/tree").header("Authorization", po))
                .andExpect(jsonPath("$[0].verificationStatus", is("NOT_RUN")))
                .andExpect(jsonPath("$[0].children[0].children[1].verificationStatus", is("NOT_COVERED")));
        mvc.perform(get(P + "/requirements").param("sort", "key,asc").header("Authorization", po))
                .andExpect(jsonPath("$.content[3].verificationStatus", is("NOT_COVERED")));
        mvc.perform(get(P + "/requirements/REQ-3").header("Authorization", po))
                .andExpect(jsonPath("$.verificationStatus", is("NOT_RUN")))
                .andExpect(jsonPath("$.criteria[0].status", is("TO_VERIFY")));
    }
}
