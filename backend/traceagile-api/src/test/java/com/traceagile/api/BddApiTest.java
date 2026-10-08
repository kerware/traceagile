package com.traceagile.api;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.traceagile.domain.administration.ProjectRole;
import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;

/** §6.2 BDD intégré : génération depuis un critère (F-REQ-11), tags (F-AUT-06), import / export (F-AUT-07), découverte (F-AUT-08). */
class BddApiTest extends AbstractApiTest {

    static final String TESTS = "/api/v1/projects/SHOP/test-cases";
    static final String SCENARIO = """
            Scénario: livraison gratuite au seuil
              Étant donné un panier de 50 €
              Quand je valide ma commande
              Alors la livraison est offerte""";

    String qa;
    String criterionId;

    @BeforeEach
    void data() throws Exception {
        user("po", false);
        user("qa1", false);
        user("dev", false);
        project("SHOP", Map.of("po", ProjectRole.PRODUCT_OWNER, "qa1", ProjectRole.TESTER, "dev", ProjectRole.DEVELOPER));
        qa = bearer("qa1");
        String po = bearer("po");
        mvc.perform(post("/api/v1/projects/SHOP/requirements").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("type", "EPIC", "title", "Livraison"))));
        String json = mvc.perform(post("/api/v1/projects/SHOP/requirements/REQ-1/acceptance-criteria").header("Authorization", po)
                        .contentType(MediaType.APPLICATION_JSON).content(toJson(Map.of("format", "GHERKIN", "content", SCENARIO))))
                .andReturn().getResponse().getContentAsString();
        criterionId = readJson(json).get("id").asText();
    }

    @Test
    @DisplayName("Lot 2 — critère de fin : F-REQ-11 « Générer un test BDD » depuis un critère Gherkin")
    void generateFromCriterion() throws Exception {
        mvc.perform(post("/api/v1/projects/SHOP/acceptance-criteria/" + criterionId + "/generate-test").header("Authorization", qa))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$[0].key", is("TC-1")))
                .andExpect(jsonPath("$[0].kind", is("AUTOMATED")))
                .andExpect(jsonPath("$[0].title", is("Livraison gratuite au seuil")))
                .andExpect(jsonPath("$[0].automation.technique", is("BDD")))
                .andExpect(jsonPath("$[0].automation.framework", is("Cucumber-JVM")))
                .andExpect(jsonPath("$[0].automation.testIdentifier", is("livraison gratuite au seuil")))
                .andExpect(jsonPath("$[0].automation.featureName", is("Livraison")))
                .andExpect(jsonPath("$[0].automation.path", is("src/test/resources/features/req-1-livraison.feature")))
                .andExpect(jsonPath("$[0].automation.gherkinSource", containsString("@REQ-1 @AC-1-1")))
                .andExpect(jsonPath("$[0].requirements[0].requirementKey", is("REQ-1")))
                .andExpect(jsonPath("$[0].requirements[0].criterionPositions", contains(1)));

        mvc.perform(get("/api/v1/projects/SHOP/requirements/REQ-1/test-cases").header("Authorization", qa))
                .andExpect(jsonPath("$[0].key", is("TC-1")));
        mvc.perform(post("/api/v1/projects/SHOP/acceptance-criteria/" + criterionId + "/generate-test").header("Authorization", bearer("po")))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("F-AUT-06 les tags @REQ créent les liens à l'enregistrement ; un tag inconnu produit un avertissement")
    void gherkinTags() throws Exception {
        String source = "# language: fr\nFonctionnalité: Livraison\n\n  @REQ-1 @REQ-99 @AC-1-1\n" + SCENARIO.indent(2);
        mvc.perform(post(TESTS).header("Authorization", bearer("dev")).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("kind", "AUTOMATED", "title", "Livraison offerte", "technique", "BDD",
                                "gherkinSource", source))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.automation.testIdentifier", is("livraison gratuite au seuil")))
                .andExpect(jsonPath("$.requirements[0].requirementKey", is("REQ-1")))
                .andExpect(jsonPath("$.requirements[0].criterionPositions", contains(1)))
                .andExpect(jsonPath("$.warnings[0]", containsString("@REQ-99")));
    }

    @Test
    @DisplayName("F-AUT-04 Gherkin invalide refusé ; étapes déjà utilisées proposées à l'autocomplétion")
    void validationAndSteps() throws Exception {
        mvc.perform(post(TESTS).header("Authorization", bearer("dev")).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("kind", "AUTOMATED", "title", "Cassé", "technique", "BDD",
                                "gherkinSource", "Fonctionnalité: x\n  Scénario: y\n    Étant donné a\n      | a | b |\n      | 1 |"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("GHERKIN_INVALID")));

        mvc.perform(get("/api/v1/projects/SHOP/gherkin/steps?q=panier").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].text", hasItem("un panier de 50 €")));
    }

    @Test
    @DisplayName("F-AUT-05 / F-AUT-07 import d'un .feature à deux scénarios puis export en zip, regroupé par fichier")
    void importExport() throws Exception {
        String feature = """
                # language: fr
                Fonctionnalité: Paiement
                  Scénario: carte acceptée
                    Soit une carte valide
                    Alors la commande est payée

                  @REQ-1
                  Scénario: carte refusée
                    Soit une carte refusée
                    Alors le panier est conservé
                """;
        MockMultipartFile file = new MockMultipartFile("files", "features/paiement.feature", "text/plain",
                feature.getBytes(StandardCharsets.UTF_8));
        mvc.perform(multipart(TESTS + "/import-feature").file(file).header("Authorization", bearer("dev")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.created", contains("TC-1", "TC-2")));
        mvc.perform(get(TESTS + "/TC-2").header("Authorization", qa))
                .andExpect(jsonPath("$.automation.path", is("features/paiement.feature")))
                .andExpect(jsonPath("$.requirements[0].requirementKey", is("REQ-1")));
        // Réimport : mise à jour, pas de doublon.
        mvc.perform(multipart(TESTS + "/import-feature").file(file).header("Authorization", bearer("dev")))
                .andExpect(jsonPath("$.updated", contains("TC-1", "TC-2")));

        byte[] zip = mvc.perform(get(TESTS + "/export-feature").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Type", "application/zip"))
                .andReturn().getResponse().getContentAsByteArray();
        Map<String, String> entries = unzip(zip);
        assertThat(entries).containsOnlyKeys("features/paiement.feature");
        assertThat(entries.get("features/paiement.feature"))
                .contains("# language: fr", "Fonctionnalité: Paiement", "Scénario: carte acceptée", "Scénario: carte refusée");

        MockMultipartFile broken = new MockMultipartFile("files", "x.feature", "text/plain", "n'importe quoi".getBytes(StandardCharsets.UTF_8));
        mvc.perform(multipart(TESTS + "/import-feature").file(broken).header("Authorization", bearer("dev")))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("FEATURE_INVALID")));
    }

    @Test
    @DisplayName("F-AUT-08 / F-AUT-09 découverte : tests créés, mis à jour, disparus signalés ; exigences annotées liées")
    void discovery() throws Exception {
        Map<String, Object> report = Map.of("repositoryUrl", "https://git.example.com/shop.git", "branch", "main",
                "tests", List.of(
                        Map.of("technique", "UNIT", "framework", "JUnit 5", "language", "java", "path", "src/test/java/CartTest.java",
                                "testIdentifier", "CartTest#total", "tags", List.of("smoke"), "requirements", List.of("REQ-1", "REQ-42")),
                        Map.of("technique", "UI", "framework", "Playwright", "path", "e2e/cart.spec.ts",
                                "testIdentifier", "panier vide", "title", "Le panier vide affiche un message")));
        mvc.perform(post(TESTS + "/discovery").header("Authorization", bearer("dev")).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(report)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.created", contains("TC-1", "TC-2")))
                .andExpect(jsonPath("$.warnings[0]", containsString("REQ-42")));
        mvc.perform(get(TESTS + "/TC-1").header("Authorization", qa))
                .andExpect(jsonPath("$.status", is("READY")))
                .andExpect(jsonPath("$.requirements[0].requirementKey", is("REQ-1")));

        Map<String, Object> second = new HashMap<>(report);
        second.put("tests", List.of(((List<?>) report.get("tests")).get(0)));
        mvc.perform(post(TESTS + "/discovery").header("Authorization", bearer("dev")).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(second)))
                .andExpect(jsonPath("$.updated", contains("TC-1")))
                .andExpect(jsonPath("$.disappeared", contains("TC-2")));
        mvc.perform(get(TESTS + "/TC-2").header("Authorization", qa))
                .andExpect(jsonPath("$.automation.missingInRepository", is(true)));
    }

    @Test
    @DisplayName("F-AUT-10 modifier la source Gherkin crée une nouvelle version")
    void gherkinChangeVersion() throws Exception {
        mvc.perform(post("/api/v1/projects/SHOP/acceptance-criteria/" + criterionId + "/generate-test").header("Authorization", qa));
        String source = mvc.perform(get(TESTS + "/TC-1").header("Authorization", qa)).andReturn().getResponse().getContentAsString();
        String gherkin = readJson(source).get("automation").get("gherkinSource").asText().replace("50 €", "60 €");
        mvc.perform(patch(TESTS + "/TC-1").header("Authorization", qa).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("gherkinSource", gherkin))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currentVersion", is(2)));
    }

    private static Map<String, String> unzip(byte[] zip) throws Exception {
        Map<String, String> entries = new HashMap<>();
        try (ZipInputStream in = new ZipInputStream(new ByteArrayInputStream(zip))) {
            ZipEntry entry;
            while ((entry = in.getNextEntry()) != null) {
                entries.put(entry.getName(), new String(in.readAllBytes(), StandardCharsets.UTF_8));
            }
        }
        return entries;
    }
}
