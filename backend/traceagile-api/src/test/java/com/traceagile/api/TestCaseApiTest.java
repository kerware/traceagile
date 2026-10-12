package com.traceagile.api;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
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

/** §12 Cas de test : référentiel, trois natures (critère de fin du lot 2), droits §2.2, versions F-AUT-10. */
class TestCaseApiTest extends AbstractApiTest {

    static final String BASE = "/api/v1/projects/SHOP/test-cases";
    String qa;

    @BeforeEach
    void data() throws Exception {
        user("admin", true);
        user("po", false);
        user("qa1", false);
        user("dev", false);
        user("viewer", false);
        project("SHOP", Map.of("po", ProjectRole.PRODUCT_OWNER, "qa1", ProjectRole.TESTER, "dev", ProjectRole.DEVELOPER,
                "viewer", ProjectRole.VIEWER));
        qa = bearer("qa1");
        String po = bearer("po");
        mvc.perform(post("/api/v1/projects/SHOP/requirements").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("type", "EPIC", "title", "Panier et commande",
                        "criteria", List.of(Map.of("format", "TEXT", "content", "Le panier est accessible"))))));
        mvc.perform(post("/api/v1/projects/SHOP/requirements").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("type", "FEATURE", "title", "Panier", "parentKey", "REQ-1"))));
    }

    String create(String login, Map<String, Object> body) throws Exception {
        String json = mvc.perform(post(BASE).header("Authorization", bearer(login)).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(body)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return readJson(json).get("key").asText();
    }

    @Test
    @DisplayName("Lot 2 — critère de fin : création d'un test manuel avec ses pas (F-MAN-01)")
    void createManual() throws Exception {
        mvc.perform(post(BASE).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("kind", "MANUAL", "title", "Ajouter un produit au panier", "folder", "Panier / Ajout",
                                "priority", "MUST", "estimatedDurationMin", 10, "tags", List.of("Smoke"),
                                "steps", List.of(
                                        Map.of("action", "Ouvrir la fiche de ${produit}", "expectedResult", "La fiche s'affiche"),
                                        Map.of("action", "Cliquer « Ajouter au panier »", "expectedResult", "Le panier contient 1 article")),
                                "dataSets", List.of(Map.of("name", "Recette", "rows", List.of(Map.of("produit", "Stylo bleu"))))))))
                .andExpect(status().isCreated())
                .andExpect(header().string("Location", BASE + "/TC-1"))
                .andExpect(jsonPath("$.key", is("TC-1")))
                .andExpect(jsonPath("$.kind", is("MANUAL")))
                .andExpect(jsonPath("$.status", is("DRAFT")))
                .andExpect(jsonPath("$.currentVersion", is(1)))
                .andExpect(jsonPath("$.folder", is("Panier/Ajout")))
                .andExpect(jsonPath("$.tags", contains("smoke")))
                .andExpect(jsonPath("$.steps[1].position", is(2)))
                .andExpect(jsonPath("$.parameters[0].name", is("produit")))
                .andExpect(jsonPath("$.parameters[0].detected", is(true)))
                .andExpect(jsonPath("$.dataSets[0].rows[0].produit", is("Stylo bleu")));
    }

    @Test
    @DisplayName("Lot 2 — critère de fin : création d'une charte exploratoire liée à une exigence (F-EXP-01 à F-EXP-03)")
    void createCharter() throws Exception {
        mvc.perform(post(BASE).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("kind", "EXPLORATORY", "title", "Explorer le panier",
                                "explore", "le panier", "with", "des produits en rupture", "toDiscover", "les incohérences de total",
                                "timeboxMin", 60, "heuristics", List.of("SFDIPOT"), "areas", List.of("Panier", "Stock"),
                                "links", List.of(Map.of("requirementKey", "REQ-2", "linkType", "VERIFIES"))))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.charter.missionSentence",
                        is("Explorer le panier avec des produits en rupture pour découvrir les incohérences de total.")))
                .andExpect(jsonPath("$.charter.timeboxMin", is(60)))
                .andExpect(jsonPath("$.requirements[0].requirementKey", is("REQ-2")));
    }

    @Test
    @DisplayName("Lot 2 — critère de fin : création d'un test automatisé API (§6.1, F-AUT-02, F-AUT-03)")
    void createAutomated() throws Exception {
        mvc.perform(post(BASE).header("Authorization", bearer("dev")).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("kind", "AUTOMATED", "title", "API panier : ajout", "technique", "API",
                                "repositoryUrl", "https://git.example.com/shop/tests.git", "branch", "main",
                                "path", "src/test/java/shop/CartApiTest.java", "testIdentifier", "CartApiTest#addItem",
                                "executionTags", List.of("Smoke", "regression"),
                                "environmentRequirements", Map.of("base", "postgres"),
                                "configuration", Map.of("baseUrl", "https://recette.shop.example", "authRequired", true)))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.automation.technique", is("API")))
                .andExpect(jsonPath("$.automation.framework", is("REST Assured")))
                .andExpect(jsonPath("$.automation.executionTags", contains("smoke", "regression")))
                .andExpect(jsonPath("$.automation.environmentRequirements.base", is("postgres")))
                .andExpect(jsonPath("$.automation.configuration.authRequired", is(true)));
    }

    @Test
    @DisplayName("§2.2 droits : le développeur ne crée que des tests automatisés ; PO et lecteur en lecture seule")
    void permissions() throws Exception {
        Map<String, Object> manual = Map.of("kind", "MANUAL", "title", "Manuel");
        mvc.perform(post(BASE).header("Authorization", bearer("dev")).contentType(MediaType.APPLICATION_JSON).content(toJson(manual)))
                .andExpect(status().isForbidden());
        for (String login : List.of("po", "viewer")) {
            mvc.perform(post(BASE).header("Authorization", bearer(login)).contentType(MediaType.APPLICATION_JSON)
                            .content(toJson(Map.of("kind", "AUTOMATED", "title", "x", "technique", "UNIT"))))
                    .andExpect(status().isForbidden());
        }
        String key = create("qa1", manual);
        mvc.perform(get(BASE + "/" + key).header("Authorization", bearer("viewer"))).andExpect(status().isOk());
        mvc.perform(patch(BASE + "/" + key).header("Authorization", bearer("dev")).contentType("application/merge-patch+json")
                        .content("{\"title\":\"Modifié\"}"))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("§15.2 validation : nature et titre obligatoires → 400 ; champs d'une autre nature → 422")
    void validation() throws Exception {
        mvc.perform(post(BASE).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON).content("{}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.kind").exists())
                .andExpect(jsonPath("$.errors.title").exists());
        String key = create("qa1", Map.of("kind", "MANUAL", "title", "Manuel"));
        mvc.perform(patch(BASE + "/" + key).header("Authorization", qa).contentType("application/merge-patch+json")
                        .content("{\"timeboxMin\":60}"))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_FIELD_KIND_MISMATCH")));
    }

    @Test
    @DisplayName("F-AUT-10 une modification significative incrémente la version, pas une modification de titre ; If-Match")
    void versioning() throws Exception {
        String key = create("qa1", Map.of("kind", "MANUAL", "title", "Manuel",
                "steps", List.of(Map.of("action", "Ouvrir", "expectedResult", "OK"))));
        mvc.perform(patch(BASE + "/" + key).header("Authorization", qa).header("If-Match", "\"0\"")
                        .contentType("application/merge-patch+json").content("{\"title\":\"Renommé\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currentVersion", is(1)));
        mvc.perform(patch(BASE + "/" + key).header("Authorization", qa).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("steps", List.of(Map.of("action", "Ouvrir la page", "expectedResult", "OK"))))))
                .andExpect(jsonPath("$.currentVersion", is(2)));
        mvc.perform(patch(BASE + "/" + key).header("Authorization", qa).header("If-Match", "\"0\"")
                        .contentType("application/merge-patch+json").content("{\"title\":\"x\"}"))
                .andExpect(status().isPreconditionFailed());

        mvc.perform(get(BASE + "/" + key + "/versions").header("Authorization", qa))
                .andExpect(jsonPath("$[*].versionNumber", contains(2, 1)));
        mvc.perform(get(BASE + "/" + key + "/versions/1/diff/2").header("Authorization", qa))
                .andExpect(jsonPath("$[*].field", hasItem("steps")));
    }

    @Test
    @DisplayName("§3.2 statut : READY seulement si le test est exécutable")
    void statusTransitions() throws Exception {
        String key = create("qa1", Map.of("kind", "MANUAL", "title", "Manuel"));
        mvc.perform(post(BASE + "/" + key + "/status").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"READY\"}"))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_NOT_READY")));
        mvc.perform(patch(BASE + "/" + key).header("Authorization", qa).contentType("application/merge-patch+json")
                .content(toJson(Map.of("steps", List.of(Map.of("action", "Ouvrir"))))));
        mvc.perform(post(BASE + "/" + key + "/status").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"READY\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("READY")));
    }

    @Test
    @DisplayName("ADR-0029 lignes nommées ; un pas appelle un test avec un jeu de données nommé de l'appelé (422 si inconnu)")
    void callWithNamedDataSet() throws Exception {
        String login = create("qa1", Map.of("kind", "MANUAL", "title", "Se connecter",
                "steps", List.of(Map.of("action", "Saisir ${login}")),
                "dataSets", List.of(Map.of("name", "Comptes", "rows", List.of(Map.of("login", "alice"), Map.of("login", "bob")),
                        "rowNames", List.of("", "Client bloqué")))));
        mvc.perform(get(BASE + "/" + login).header("Authorization", qa))
                .andExpect(jsonPath("$.dataSets[0].rowNames", contains("alice", "Client bloqué")));
        String caller = create("qa1", Map.of("kind", "MANUAL", "title", "Commander",
                "steps", List.of(Map.of("calledTestKey", login, "callDataSet", "comptes", "callRow", "client bloqué"))));
        mvc.perform(get(BASE + "/" + caller).header("Authorization", qa))
                .andExpect(jsonPath("$.steps[0].callDataSet", is("Comptes")))
                .andExpect(jsonPath("$.steps[0].callRow", is("Client bloqué")));
        mvc.perform(patch(BASE + "/" + caller).header("Authorization", qa).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("steps", List.of(Map.of("calledTestKey", login, "callDataSet", "Comptes", "callRow", "carole"))))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_CALL_DATASET_UNKNOWN")));
        mvc.perform(patch(BASE + "/" + login).header("Authorization", qa).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("dataSets", List.of(Map.of("name", "Comptes", "rows", List.of(Map.of("login", "a"), Map.of("login", "b")),
                                "rowNames", List.of("Même", "même")))))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_DATASET_ROW_NAME_DUPLICATED")));
    }

    @Test
    @DisplayName("ADR-0028 422 TEST_DATASET_REQUIRED : test manuel à paramètres sans jeu de données passé à READY")
    void readyRequiresDataSet() throws Exception {
        String key = create("qa1", Map.of("kind", "MANUAL", "title", "Connexion",
                "steps", List.of(Map.of("action", "Se connecter avec ${login}"))));
        mvc.perform(post(BASE + "/" + key + "/status").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"READY\"}"))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_DATASET_REQUIRED")));
        mvc.perform(patch(BASE + "/" + key).header("Authorization", qa).contentType("application/merge-patch+json")
                .content(toJson(Map.of("dataSets", List.of(Map.of("name", "Comptes", "rows", List.of(Map.of("login", "alice"))))))));
        mvc.perform(post(BASE + "/" + key + "/status").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"READY\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("READY")));
    }

    @Test
    @DisplayName("§12 filtres kind, technique, tag, requirement, orphan, candidats (F-MAN-02) ; arbre par dossier")
    void filters() throws Exception {
        create("qa1", Map.of("kind", "MANUAL", "title", "Ajout panier", "folder", "Panier", "tags", List.of("smoke"),
                "priority", "MUST", "automationCandidate", true, "automationJustification", "Exécuté à chaque sprint",
                "links", List.of(Map.of("requirementKey", "REQ-2", "linkType", "VERIFIES"))));
        create("qa1", Map.of("kind", "MANUAL", "title", "Vider panier", "folder", "Panier/Vidage"));
        create("dev", Map.of("kind", "AUTOMATED", "title", "API panier", "technique", "API", "testIdentifier", "CartApi#add"));

        mvc.perform(get(BASE + "?kind=MANUAL").header("Authorization", qa)).andExpect(jsonPath("$.totalElements", is(2)));
        mvc.perform(get(BASE + "?technique=API").header("Authorization", qa)).andExpect(jsonPath("$.content[*].key", contains("TC-3")));
        mvc.perform(get(BASE + "?tag=smoke").header("Authorization", qa)).andExpect(jsonPath("$.content[*].key", contains("TC-1")));
        mvc.perform(get(BASE + "?requirement=REQ-2").header("Authorization", qa)).andExpect(jsonPath("$.content[*].key", contains("TC-1")));
        mvc.perform(get(BASE + "?orphan=true").header("Authorization", qa)).andExpect(jsonPath("$.content[*].key", contains("TC-2", "TC-3")));
        mvc.perform(get(BASE + "?automationCandidate=true").header("Authorization", qa))
                .andExpect(jsonPath("$.content[*].key", contains("TC-1")))
                .andExpect(jsonPath("$.content[0].automationCandidate", is(true)));
        mvc.perform(get(BASE + "?folder=Panier&q=vider").header("Authorization", qa))
                .andExpect(jsonPath("$.content[*].key", contains("TC-2")));
        mvc.perform(get(BASE + "/tree?groupBy=folder").header("Authorization", qa))
                .andExpect(jsonPath("$[*].name", contains("Panier", "Panier/Vidage", "")))
                .andExpect(jsonPath("$[0].tests[0].key", is("TC-1")));
    }

    @Test
    @DisplayName("F-TRA-01 / F-TRA-03 liens depuis la fiche test, critères précisés ; visibles côté exigence ; DoR « test lié »")
    void links() throws Exception {
        String key = create("qa1", Map.of("kind", "MANUAL", "title", "Accès au panier"));
        mvc.perform(put(BASE + "/" + key + "/requirements").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(List.of(Map.of("requirementKey", "REQ-1", "linkType", "PARTIALLY_VERIFIES",
                                "criterionPositions", List.of(1))))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].requirementKey", is("REQ-1")))
                .andExpect(jsonPath("$[0].linkType", is("PARTIALLY_VERIFIES")))
                .andExpect(jsonPath("$[0].criterionPositions", contains(1)));

        mvc.perform(get("/api/v1/projects/SHOP/requirements/REQ-1/test-cases").header("Authorization", bearer("po")))
                .andExpect(jsonPath("$[0].key", is(key)))
                .andExpect(jsonPath("$[0].criterionPositions", contains(1)));
        mvc.perform(get("/api/v1/projects/SHOP/requirements/REQ-1/checklists").header("Authorization", bearer("po")))
                .andExpect(jsonPath("$.dod[0].outcome", is("SATISFIED")));
        mvc.perform(put(BASE + "/" + key + "/requirements").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(List.of(Map.of("requirementKey", "REQ-1", "linkType", "VERIFIES", "criterionPositions", List.of(9))))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("CRITERION_POSITION_UNKNOWN")));
    }

    @Test
    @DisplayName("§12 DELETE : test supprimé avec ses liens ; historique audité (NF-16)")
    void deleteAndHistory() throws Exception {
        String key = create("qa1", Map.of("kind", "MANUAL", "title", "Temporaire",
                "links", List.of(Map.of("requirementKey", "REQ-2", "linkType", "VERIFIES"))));
        mvc.perform(get(BASE + "/" + key + "/history").header("Authorization", qa))
                .andExpect(jsonPath("$.content[0].action", is("CREATED")))
                .andExpect(jsonPath("$.content[0].actor", is("qa1")));
        mvc.perform(delete(BASE + "/" + key).header("Authorization", qa)).andExpect(status().isNoContent());
        mvc.perform(get(BASE + "/" + key).header("Authorization", qa)).andExpect(status().isNotFound());
        mvc.perform(get("/api/v1/projects/SHOP/requirements/REQ-2/test-cases").header("Authorization", qa))
                .andExpect(jsonPath("$.length()", is(0)));
    }

    @Test
    @DisplayName("F-AUT-01 frameworks de référence : lus par tous, modifiés par l'administrateur")
    void frameworks() throws Exception {
        mvc.perform(get("/api/v1/reference/frameworks").header("Authorization", qa))
                .andExpect(jsonPath("$[?(@.technique == 'BDD')].name", hasItem("Cucumber-JVM")));
        mvc.perform(put("/api/v1/reference/frameworks/PERFORMANCE").header("Authorization", qa)
                        .contentType(MediaType.APPLICATION_JSON).content(toJson(List.of("Gatling"))))
                .andExpect(status().isForbidden());
        mvc.perform(put("/api/v1/reference/frameworks/PERFORMANCE").header("Authorization", bearer("admin"))
                        .contentType(MediaType.APPLICATION_JSON).content(toJson(List.of("Gatling", "Locust"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].name", containsInAnyOrder("Gatling", "Locust")));
    }
}
