package com.traceagile.api;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.traceagile.domain.administration.ProjectRole;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

/** ADR-0013 dossiers de tests explicites : création, renommage / déplacement, suppression, arbre. */
class TestFolderApiTest extends AbstractApiTest {

    static final String FOLDERS = "/api/v1/projects/SHOP/test-folders";
    static final String TESTS = "/api/v1/projects/SHOP/test-cases";
    String qa;

    @BeforeEach
    void data() throws Exception {
        user("qa1", false);
        user("dev", false);
        user("viewer", false);
        project("SHOP", Map.of("qa1", ProjectRole.TESTER, "dev", ProjectRole.DEVELOPER, "viewer", ProjectRole.VIEWER));
        qa = bearer("qa1");
    }

    void folder(String login, String path) throws Exception {
        mvc.perform(post(FOLDERS).header("Authorization", bearer(login)).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("path", path)))).andExpect(status().isCreated());
    }

    void manual(String title, String folder) throws Exception {
        mvc.perform(post(TESTS).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("kind", "MANUAL", "title", title, "folder", folder)))).andExpect(status().isCreated());
    }

    @Test
    @DisplayName("ADR-0013 un dossier vide apparaît dans l'arbre ; doublon → 409 ; lecteur → 403 ; nom vide → 400")
    void create() throws Exception {
        folder("qa1", " Panier / Remises ");
        mvc.perform(get(TESTS + "/tree").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].name", is("Panier/Remises")))
                .andExpect(jsonPath("$[0].tests.length()", is(0)));
        mvc.perform(get(FOLDERS).header("Authorization", qa))
                .andExpect(jsonPath("$", contains("Panier", "Panier/Remises")));
        mvc.perform(post(FOLDERS).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("path", "panier/remises"))))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code", is("TEST_FOLDER_EXISTS")));
        mvc.perform(post(FOLDERS).header("Authorization", bearer("viewer")).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("path", "X")))).andExpect(status().isForbidden());
        mvc.perform(post(FOLDERS).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("path", " ")))).andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("ADR-0013 renommer un dossier reclasse ses tests et sous-dossiers ; pas dans lui-même (422)")
    void move() throws Exception {
        folder("qa1", "Panier/Vide");
        manual("Ajouter", "Panier/Ajout");
        manual("Autre", "Paniers");
        mvc.perform(post(FOLDERS + "/move").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("from", "Panier", "to", "Commande/Caddie"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.movedTests", is(1)));
        mvc.perform(get(TESTS + "/TC-1").header("Authorization", qa)).andExpect(jsonPath("$.folder", is("Commande/Caddie/Ajout")));
        mvc.perform(get(TESTS + "/TC-2").header("Authorization", qa)).andExpect(jsonPath("$.folder", is("Paniers")));
        mvc.perform(get(FOLDERS).header("Authorization", qa)).andExpect(jsonPath("$", hasItem("Commande/Caddie/Vide")));
        mvc.perform(post(FOLDERS + "/move").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("from", "Commande", "to", "Commande/Sous"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_FOLDER_MOVE_INTO_ITSELF")));
    }

    @Test
    @DisplayName("§2.2 le développeur ne peut pas déplacer un dossier contenant des tests manuels")
    void moveRights() throws Exception {
        manual("Ajouter", "Panier");
        mvc.perform(post(FOLDERS + "/move").header("Authorization", bearer("dev")).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("from", "Panier", "to", "Caddie"))))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("ADR-0013 on ne supprime qu'un dossier vide (422 TEST_FOLDER_NOT_EMPTY) ; inconnu → 404")
    void deleteFolder() throws Exception {
        folder("qa1", "Vide/Sous");
        manual("Ajouter", "Panier");
        mvc.perform(delete(FOLDERS).param("path", "Panier").header("Authorization", qa))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_FOLDER_NOT_EMPTY")));
        mvc.perform(delete(FOLDERS).param("path", "Vide").header("Authorization", qa)).andExpect(status().isNoContent());
        mvc.perform(get(FOLDERS).header("Authorization", qa)).andExpect(jsonPath("$", is(List.of("Panier"))));
        mvc.perform(delete(FOLDERS).param("path", "Inconnu").header("Authorization", qa)).andExpect(status().isNotFound());
    }
}
