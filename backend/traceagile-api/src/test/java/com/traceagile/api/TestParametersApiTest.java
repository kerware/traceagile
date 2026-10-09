package com.traceagile.api;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.traceagile.domain.administration.ProjectRole;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

/** ADR-0013 / F-MAN-01 / §6.1 paramètres et jeux de données nommés d'un test, manuel ou automatisé. */
class TestParametersApiTest extends AbstractApiTest {

    static final String BASE = "/api/v1/projects/SHOP/test-cases";
    String qa;

    @BeforeEach
    void data() throws Exception {
        user("qa1", false);
        user("viewer", false);
        project("SHOP", Map.of("qa1", ProjectRole.TESTER, "viewer", ProjectRole.VIEWER));
        qa = bearer("qa1");
    }

    void createManual() throws Exception {
        mvc.perform(post(BASE).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("kind", "MANUAL", "title", "Prix affiché",
                                "steps", List.of(Map.of("action", "Ouvrir ${nom-produit}", "expectedResult", "Le prix ${prix_ttc} s'affiche"))))))
                .andExpect(status().isCreated());
    }

    @Test
    @DisplayName("F-MAN-01 les ${nom-parametre} des pas sont détectés ; paramètres déclarés et jeux nommés enregistrés")
    void manualParameters() throws Exception {
        createManual();
        mvc.perform(patch(BASE + "/TC-1").header("Authorization", qa).contentType("application/merge-patch+json")
                        .content(toJson(Map.of(
                                "parameters", List.of(
                                        Map.of("name", "prix_ttc", "defaultValue", "2,50 €", "description", "Prix TTC"),
                                        Map.of("name", "devise", "defaultValue", "EUR")),
                                "dataSets", List.of(
                                        Map.of("name", "Recette", "rows", List.of(Map.of("nom-produit", "Stylo", "prix_ttc", "2,50 €"))),
                                        Map.of("name", "Limites", "rows", List.of(Map.of("nom-produit", "", "quantite", 999))))))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.parameters[*].name", contains("nom-produit", "prix_ttc", "devise", "quantite")))
                .andExpect(jsonPath("$.parameters[1].defaultValue", is("2,50 €")))
                .andExpect(jsonPath("$.parameters[1].detected", is(true)))
                .andExpect(jsonPath("$.parameters[2].detected", is(false)))
                .andExpect(jsonPath("$.dataSets[*].name", contains("Recette", "Limites")))
                .andExpect(jsonPath("$.dataSets[1].rows[0].quantite", is(999)))
                .andExpect(jsonPath("$.currentVersion", is(2)));
    }

    @Test
    @DisplayName("§6.1 un test automatisé porte des paramètres et des jeux typés ; configuration technique distincte")
    void automatedParameters() throws Exception {
        mvc.perform(post(BASE).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("kind", "AUTOMATED", "title", "Frais de port", "technique", "DATA_DRIVEN",
                                "parameters", List.of(Map.of("name", "montant"), Map.of("name", "frais")),
                                "dataSets", List.of(Map.of("name", "Seuils", "rows", List.of(
                                        Map.of("montant", 49.99, "frais", 4.9), Map.of("montant", 50, "frais", 0)))),
                                "configuration", Map.of("timeoutMs", 3000)))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.parameters[*].name", contains("montant", "frais")))
                .andExpect(jsonPath("$.dataSets[0].rows[1].montant", is(50)))
                .andExpect(jsonPath("$.automation.configuration.timeoutMs", is(3000)));
    }

    @Test
    @DisplayName("ADR-0013 nom de paramètre invalide ou jeu en double → 422")
    void rules() throws Exception {
        createManual();
        mvc.perform(patch(BASE + "/TC-1").header("Authorization", qa).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("parameters", List.of(Map.of("name", "avec espace"))))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_PARAMETER_NAME_INVALID")));
        mvc.perform(patch(BASE + "/TC-1").header("Authorization", qa).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("dataSets", List.of(
                                Map.of("name", "A", "rows", List.of()), Map.of("name", "a", "rows", List.of()))))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_DATASET_DUPLICATED")));
    }

    @Test
    @DisplayName("ADR-0013 jeu sans nom → 400 ; lecteur → 403")
    void validationAndRights() throws Exception {
        createManual();
        Map<String, Object> unnamed = new HashMap<>();
        unnamed.put("rows", List.of());
        mvc.perform(patch(BASE + "/TC-1").header("Authorization", qa).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("dataSets", List.of(unnamed)))))
                .andExpect(status().isBadRequest());
        mvc.perform(patch(BASE + "/TC-1").header("Authorization", bearer("viewer")).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("parameters", List.of()))))
                .andExpect(status().isForbidden());
    }
}
