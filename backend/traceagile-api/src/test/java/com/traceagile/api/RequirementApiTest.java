package com.traceagile.api;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
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

/** §12 Exigences : backlog, fiche, hiérarchie, rang, statut, suppression (§3, §4). */
class RequirementApiTest extends AbstractApiTest {

    static final String BASE = "/api/v1/projects/SHOP/requirements";
    String po;

    @BeforeEach
    void data() throws Exception {
        user("admin", true);
        user("po", false);
        user("qa1", false);
        user("viewer", false);
        user("outsider", false);
        project("SHOP", Map.of("po", ProjectRole.PRODUCT_OWNER, "qa1", ProjectRole.TESTER, "viewer", ProjectRole.VIEWER));
        project("BANK", Map.of("outsider", ProjectRole.PRODUCT_OWNER));
        po = bearer("po");
    }

    String create(String type, String title, String parentKey) throws Exception {
        Map<String, Object> body = new HashMap<>(Map.of("type", type, "title", title));
        if (parentKey != null) {
            body.put("parentKey", parentKey);
        }
        String json = mvc.perform(post(BASE).header("Authorization", po).contentType(MediaType.APPLICATION_JSON).content(toJson(body)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return readJson(json).get("key").asText();
    }

    @Test
    @DisplayName("F-REQ-02 création : clé séquentielle REQ-n, Location, statut DRAFT")
    void createSequentialKeys() throws Exception {
        assertKey(create("EPIC", "Catalogue", null), "REQ-1");
        mvc.perform(post(BASE).header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("type", "FEATURE", "title", "Recherche", "parentKey", "REQ-1",
                                "priority", "MUST", "riskLevel", "HIGH", "tags", List.of("SEO", "recherche")))))
                .andExpect(status().isCreated())
                .andExpect(header().string("Location", BASE + "/REQ-2"))
                .andExpect(jsonPath("$.key", is("REQ-2")))
                .andExpect(jsonPath("$.status", is("DRAFT")))
                .andExpect(jsonPath("$.parent.key", is("REQ-1")))
                .andExpect(jsonPath("$.priority", is("MUST")))
                .andExpect(jsonPath("$.tags", contains("recherche", "seo")));
    }

    private static void assertKey(String actual, String expected) {
        org.assertj.core.api.Assertions.assertThat(actual).isEqualTo(expected);
    }

    @Test
    @DisplayName("§3.3-1 une USER_STORY sans parent → 422 REQ_PARENT_REQUIRED")
    void storyWithoutParent() throws Exception {
        mvc.perform(post(BASE).header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("type", "USER_STORY", "title", "Orpheline"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("REQ_PARENT_REQUIRED")));
    }

    @Test
    @DisplayName("§15.2 validation : type et titre obligatoires → 400")
    void createValidation() throws Exception {
        mvc.perform(post(BASE).header("Authorization", po).contentType(MediaType.APPLICATION_JSON).content("{}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.type").exists())
                .andExpect(jsonPath("$.errors.title").exists());
    }

    @Test
    @DisplayName("§2.2 le lecteur et le testeur ne créent pas d'exigence ; un non-membre ne lit pas → 403")
    void accessControl() throws Exception {
        create("EPIC", "Catalogue", null);
        for (String login : List.of("viewer", "qa1")) {
            mvc.perform(post(BASE).header("Authorization", bearer(login)).contentType(MediaType.APPLICATION_JSON)
                            .content(toJson(Map.of("type", "EPIC", "title", "Interdit"))))
                    .andExpect(status().isForbidden());
        }
        mvc.perform(get(BASE + "/REQ-1").header("Authorization", bearer("viewer"))).andExpect(status().isOk());
        mvc.perform(get(BASE + "/REQ-1").header("Authorization", bearer("outsider"))).andExpect(status().isForbidden());
        mvc.perform(get(BASE).header("Authorization", bearer("outsider"))).andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("F-REQ-05 à F-REQ-07 fiche : phrase de la story, alerte « à découper », transitions possibles")
    void detail() throws Exception {
        create("EPIC", "Panier et commande", null);
        create("FEATURE", "Panier", "REQ-1");
        String story = create("USER_STORY", "Livraison gratuite", "REQ-2");
        mvc.perform(patch(BASE + "/" + story).header("Authorization", po).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("asA", "client", "iWant", "la livraison offerte dès 50 €", "soThat", "commander plus",
                                "storyPoints", 13, "businessValue", 80))))
                .andExpect(status().isOk());

        mvc.perform(get(BASE + "/" + story).header("Authorization", po))
                .andExpect(status().isOk())
                .andExpect(header().string("ETag", "\"1\""))
                .andExpect(jsonPath("$.userStory.sentence",
                        is("En tant que client, je veux la livraison offerte dès 50 € afin de commander plus.")))
                .andExpect(jsonPath("$.storyPoints", is(13)))
                .andExpect(jsonPath("$.needsSplitting", is(true)))
                .andExpect(jsonPath("$.allowedTransitions", containsInAnyOrder("TO_REFINE", "READY", "REJECTED", "OBSOLETE")))
                .andExpect(jsonPath("$.parent.key", is("REQ-2")));
    }

    @Test
    @DisplayName("§12 PATCH merge-patch : null efface, absent conserve ; If-Match périmé → 412")
    void patchSemantics() throws Exception {
        create("EPIC", "Catalogue", null);
        mvc.perform(patch(BASE + "/REQ-1").header("Authorization", po).contentType("application/merge-patch+json")
                        .content("{\"externalRef\":\"JIRA-12\",\"businessValue\":40}"))
                .andExpect(status().isOk());

        mvc.perform(patch(BASE + "/REQ-1").header("Authorization", po).header("If-Match", "\"1\"")
                        .contentType("application/merge-patch+json").content("{\"externalRef\":null}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.externalRef", nullValue()))
                .andExpect(jsonPath("$.businessValue", is(40)))
                .andExpect(header().string("ETag", "\"2\""));

        mvc.perform(patch(BASE + "/REQ-1").header("Authorization", po).header("If-Match", "\"1\"")
                        .contentType("application/merge-patch+json").content("{\"title\":\"Autre\"}"))
                .andExpect(status().isPreconditionFailed());
    }

    @Test
    @DisplayName("F-REQ-06 PATCH avec des points hors Fibonacci → 422 REQ_POINTS_INVALID")
    void invalidPoints() throws Exception {
        create("EPIC", "Catalogue", null);
        create("FEATURE", "Recherche", "REQ-1");
        create("USER_STORY", "Chercher", "REQ-2");
        mvc.perform(patch(BASE + "/REQ-3").header("Authorization", po).contentType("application/merge-patch+json")
                        .content("{\"storyPoints\":4}"))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("REQ_POINTS_INVALID")));
    }

    @Test
    @DisplayName("F-REQ-01 liste filtrée et paginée, tri par clé numérique ; F-REQ-04 recherche plein texte")
    void listFiltersAndSearch() throws Exception {
        create("EPIC", "Catalogue", null);
        for (int i = 2; i <= 11; i++) {
            create("FEATURE", "Fonction " + i, "REQ-1");
        }
        mvc.perform(patch(BASE + "/REQ-5").header("Authorization", po).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("title", "Livraison gratuite", "description", "Les livraisons sont offertes dès 50 €",
                                "tags", List.of("panier"), "priority", "MUST"))))
                .andExpect(status().isOk());

        mvc.perform(get(BASE + "?type=FEATURE&sort=key,desc&size=3").header("Authorization", po))
                .andExpect(jsonPath("$.totalElements", is(10)))
                .andExpect(jsonPath("$.content[*].key", contains("REQ-11", "REQ-10", "REQ-9")));
        mvc.perform(get(BASE + "?priority=MUST&tag=panier").header("Authorization", po))
                .andExpect(jsonPath("$.content[*].key", contains("REQ-5")));
        mvc.perform(get(BASE + "?q=livraison").header("Authorization", po))
                .andExpect(jsonPath("$.content[*].key", contains("REQ-5")));
        mvc.perform(get(BASE + "?q=offertes 50").header("Authorization", po))
                .andExpect(jsonPath("$.content[*].key", contains("REQ-5")));
        mvc.perform(get(BASE + "?q=REQ-1").header("Authorization", po))
                .andExpect(jsonPath("$.content[*].key", hasItem("REQ-11")));
        mvc.perform(get(BASE + "?q=introuvable").header("Authorization", po))
                .andExpect(jsonPath("$.totalElements", is(0)));
    }

    @Test
    @DisplayName("F-REQ-01 vue arbre : épic > feature > story, enfants triés par rang")
    void tree() throws Exception {
        create("EPIC", "Catalogue", null);
        create("FEATURE", "Recherche", "REQ-1");
        create("USER_STORY", "Chercher", "REQ-2");
        create("FEATURE", "Fiche produit", "REQ-1");
        create("EPIC", "Compte", null);

        mvc.perform(get(BASE + "/tree").header("Authorization", po))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].key", contains("REQ-1", "REQ-5")))
                .andExpect(jsonPath("$[0].children[*].key", contains("REQ-2", "REQ-4")))
                .andExpect(jsonPath("$[0].children[0].children[0].key", is("REQ-3")));
    }

    @Test
    @DisplayName("F-REQ-02 / F-REQ-03 déplacer : nouveau parent et position entre deux voisins")
    void move() throws Exception {
        create("EPIC", "Catalogue", null);
        create("EPIC", "Compte", null);
        create("FEATURE", "Recherche", "REQ-1");
        create("FEATURE", "Profil", "REQ-2");
        create("FEATURE", "Adresses", "REQ-2");

        mvc.perform(post(BASE + "/REQ-3/move").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("parentKey", "REQ-2", "afterKey", "REQ-4", "beforeKey", "REQ-5"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.parent.key", is("REQ-2")));
        mvc.perform(get(BASE + "/tree").header("Authorization", po))
                .andExpect(jsonPath("$[1].children[*].key", contains("REQ-4", "REQ-3", "REQ-5")))
                .andExpect(jsonPath("$[0].children", hasSize(0)));

        mvc.perform(post(BASE + "/REQ-3/move").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("parentKey", "REQ-4"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("REQ_PARENT_INVALID")));
    }

    @Test
    @DisplayName("F-REQ-03 réordonner sans changer de parent : rang strictement entre les voisins")
    void reorderRoot() throws Exception {
        create("EPIC", "A", null);
        create("EPIC", "B", null);
        create("EPIC", "C", null);

        mvc.perform(post(BASE + "/REQ-3/move").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("beforeKey", "REQ-1"))))
                .andExpect(status().isOk());

        mvc.perform(get(BASE).header("Authorization", po))
                .andExpect(jsonPath("$.content[*].key", contains("REQ-3", "REQ-1", "REQ-2")));
    }

    @Test
    @DisplayName("F-REQ-02 dupliquer : copie juste après l'original, critères compris")
    void duplicate() throws Exception {
        create("EPIC", "A", null);
        create("EPIC", "B", null);
        mvc.perform(post(BASE + "/REQ-1/acceptance-criteria").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("format", "TEXT", "content", "Le catalogue s'affiche"))))
                .andExpect(status().isCreated());

        mvc.perform(post(BASE + "/REQ-1/duplicate").header("Authorization", po))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.key", is("REQ-3")))
                .andExpect(jsonPath("$.title", is("Copie de A")))
                .andExpect(jsonPath("$.criteria[0].content", is("Le catalogue s'affiche")));
        mvc.perform(get(BASE).header("Authorization", po))
                .andExpect(jsonPath("$.content[*].key", contains("REQ-1", "REQ-3", "REQ-2")));
    }

    @Test
    @DisplayName("§3.3-6 suppression : refusée avec des enfants, sinon 204 puis 404")
    void deletion() throws Exception {
        create("EPIC", "Catalogue", null);
        create("FEATURE", "Recherche", "REQ-1");

        mvc.perform(delete(BASE + "/REQ-1").header("Authorization", po))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("REQ_HAS_CHILDREN")));
        mvc.perform(delete(BASE + "/REQ-2").header("Authorization", po)).andExpect(status().isNoContent());
        mvc.perform(get(BASE + "/REQ-2").header("Authorization", po))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code", is("REQ_NOT_FOUND")));
    }

    @Test
    @DisplayName("F-REQ-16 / F-REQ-17 ENF : catégorie, Planguage ; ENF transverse visible sur les stories de la feature")
    void nonFunctional() throws Exception {
        create("EPIC", "Catalogue", null);
        create("FEATURE", "Recherche", "REQ-1");
        create("USER_STORY", "Chercher", "REQ-2");
        mvc.perform(post(BASE).header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("type", "NON_FUNCTIONAL", "title", "Temps de réponse de la recherche", "parentKey", "REQ-2",
                                "category", "PERFORMANCE", "transverse", true, "scale", "p95 de la recherche",
                                "measurementMethod", "Gatling", "minimumThreshold", "800", "target", "300", "unit", "ms"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.category", is("PERFORMANCE")))
                .andExpect(jsonPath("$.planguage.target", is("300")))
                .andExpect(jsonPath("$.transverse", is(true)));

        mvc.perform(get(BASE + "/REQ-3").header("Authorization", po))
                .andExpect(jsonPath("$.applicableTransverseNfrs[*].key", contains("REQ-4")));
        mvc.perform(post(BASE).header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("type", "EPIC", "title", "Pas une ENF", "category", "SECURITY"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("REQ_CATEGORY_NFR_ONLY")));
    }

    @Test
    @DisplayName("F-REQ-07 INVEST coché par le testeur ; le lecteur ne peut pas")
    void invest() throws Exception {
        create("EPIC", "Catalogue", null);
        create("FEATURE", "Recherche", "REQ-1");
        create("USER_STORY", "Chercher", "REQ-2");
        Map<String, Boolean> invest = Map.of("independent", true, "negotiable", true, "valuable", true,
                "estimable", false, "small", true, "testable", true);

        mvc.perform(put(BASE + "/REQ-3/invest", "qa1", invest))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.invest.small", is(true)))
                .andExpect(jsonPath("$.invest.estimable", is(false)));
        mvc.perform(put(BASE + "/REQ-3/invest", "viewer", invest)).andExpect(status().isForbidden());
    }

    private org.springframework.test.web.servlet.RequestBuilder put(String url, String login, Object body) throws Exception {
        return org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put(url)
                .header("Authorization", bearer(login)).contentType(MediaType.APPLICATION_JSON).content(toJson(body));
    }

    @Test
    @DisplayName("NF-16 historique : création et modifications, avec auteur et différences")
    void history() throws Exception {
        create("EPIC", "Catalogue", null);
        mvc.perform(patch(BASE + "/REQ-1").header("Authorization", po).contentType("application/merge-patch+json")
                        .content("{\"title\":\"Catalogue produits\"}"))
                .andExpect(status().isOk());

        mvc.perform(get(BASE + "/REQ-1/history").header("Authorization", bearer("viewer")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].action", is("UPDATED")))
                .andExpect(jsonPath("$.content[0].actor", is("po")))
                .andExpect(jsonPath("$.content[0].changes[0].field", is("title")))
                .andExpect(jsonPath("$.content[0].changes[0].before", is("Catalogue")))
                .andExpect(jsonPath("$.content[0].changes[0].after", is("Catalogue produits")))
                .andExpect(jsonPath("$.content[1].action", is("CREATED")))
                .andExpect(jsonPath("$.content[1].timestamp", startsWith("20")));
    }
}
