package com.traceagile.api;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
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

/** §12 Administration : GET/POST /projects, PUT /projects/{key}/members ; §2.2 visibilité par rôle. */
class ProjectApiTest extends AbstractApiTest {

    @BeforeEach
    void data() {
        user("admin", true);
        user("po", false);
        user("qa1", false);
        user("lead", false);
        project("SHOP", Map.of("po", ProjectRole.PRODUCT_OWNER, "lead", ProjectRole.ADMINISTRATOR));
        project("BANK", Map.of("qa1", ProjectRole.TESTER));
    }

    @Test
    @DisplayName("Lot 0 — critère de fin : l'administrateur crée un projet → 201")
    void adminCreatesProject() throws Exception {
        mvc.perform(post("/api/v1/projects").header("Authorization", bearer("admin"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("key", "CRM", "name", "Relation client", "description", "Démo"))))
                .andExpect(status().isCreated())
                .andExpect(header().string("Location", "/api/v1/projects/CRM"))
                .andExpect(jsonPath("$.key", is("CRM")))
                .andExpect(jsonPath("$.name", is("Relation client")))
                .andExpect(jsonPath("$.archived", is(false)));
    }

    @Test
    @DisplayName("§2.2 POST /projects par un non-administrateur → 403")
    void nonAdminCannotCreateProject() throws Exception {
        mvc.perform(post("/api/v1/projects").header("Authorization", bearer("po"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("key", "CRM", "name", "Relation client"))))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("§3.1 POST /projects avec une clé invalide → 400")
    void invalidKey() throws Exception {
        mvc.perform(post("/api/v1/projects").header("Authorization", bearer("admin"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("key", "crm1", "name", "Relation client"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.key").exists());
    }

    @Test
    @DisplayName("§3.1 POST /projects avec une clé existante → 409 PROJECT_KEY_TAKEN")
    void duplicateKey() throws Exception {
        mvc.perform(post("/api/v1/projects").header("Authorization", bearer("admin"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("key", "SHOP", "name", "Doublon"))))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code", is("PROJECT_KEY_TAKEN")));
    }

    @Test
    @DisplayName("§2.2 GET /projects : un utilisateur ne voit que ses projets, avec son rôle")
    void listOnlyVisibleProjects() throws Exception {
        mvc.perform(get("/api/v1/projects").header("Authorization", bearer("po")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[*].key", contains("SHOP")))
                .andExpect(jsonPath("$.content[0].myRole", is("PRODUCT_OWNER")))
                .andExpect(jsonPath("$.totalElements", is(1)));
    }

    @Test
    @DisplayName("§2.2 GET /projects : l'administrateur système voit tous les projets")
    void adminListsAllProjects() throws Exception {
        mvc.perform(get("/api/v1/projects?sort=key,asc").header("Authorization", bearer("admin")))
                .andExpect(jsonPath("$.content[*].key", contains("BANK", "SHOP")));
    }

    @Test
    @DisplayName("§2.2 GET /projects/{key} par un non-membre → 403")
    void nonMemberCannotReadProject() throws Exception {
        mvc.perform(get("/api/v1/projects/BANK").header("Authorization", bearer("po")))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code", is("ACCESS_DENIED")));
    }

    @Test
    @DisplayName("§2.2 GET /projects/{key} par un membre → 200")
    void memberReadsProject() throws Exception {
        mvc.perform(get("/api/v1/projects/SHOP").header("Authorization", bearer("po")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.key", is("SHOP")))
                .andExpect(jsonPath("$.memberCount", is(2)));
    }

    @Test
    @DisplayName("§2.2 GET /projects/{key} inconnu pour un non-administrateur → 403 (pas de fuite d'existence)")
    void unknownProjectForMember() throws Exception {
        mvc.perform(get("/api/v1/projects/NOPE").header("Authorization", bearer("po")))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("GET /projects/{key} inconnu pour l'administrateur système → 404 PROJECT_NOT_FOUND")
    void unknownProjectForAdmin() throws Exception {
        mvc.perform(get("/api/v1/projects/NOPE").header("Authorization", bearer("admin")))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code", is("PROJECT_NOT_FOUND")));
    }

    @Test
    @DisplayName("§12 PUT /projects/{key}/members par l'administrateur du projet → remplace les membres")
    void projectAdministratorReplacesMembers() throws Exception {
        mvc.perform(put("/api/v1/projects/SHOP/members").header("Authorization", bearer("lead"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(List.of(
                                Map.of("login", "lead", "role", "ADMINISTRATOR"),
                                Map.of("login", "qa1", "role", "TESTER")))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].login", containsInAnyOrder("lead", "qa1")));

        mvc.perform(get("/api/v1/projects/SHOP/members").header("Authorization", bearer("qa1")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].role", containsInAnyOrder("ADMINISTRATOR", "TESTER")));
        mvc.perform(get("/api/v1/projects/SHOP").header("Authorization", bearer("po")))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("§2.2 PUT /projects/{key}/members par un Product Owner → 403")
    void productOwnerCannotManageMembers() throws Exception {
        mvc.perform(put("/api/v1/projects/SHOP/members").header("Authorization", bearer("po"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(List.of(Map.of("login", "po", "role", "ADMINISTRATOR")))))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("§12 PUT /projects/{key}/members avec un utilisateur inconnu → 404 USER_NOT_FOUND")
    void membersWithUnknownUser() throws Exception {
        mvc.perform(put("/api/v1/projects/SHOP/members").header("Authorization", bearer("admin"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(List.of(Map.of("login", "ghost", "role", "VIEWER")))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code", is("USER_NOT_FOUND")));
    }

    @Test
    @DisplayName("§12 PUT /projects/{key}/members avec un rôle inconnu → 400")
    void membersWithUnknownRole() throws Exception {
        mvc.perform(put("/api/v1/projects/SHOP/members").header("Authorization", bearer("admin"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(List.of(Map.of("login", "po", "role", "CHEF")))))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("§3 champs techniques : createdBy et createdAt renseignés par l'audit JPA")
    void auditFields() throws Exception {
        mvc.perform(post("/api/v1/projects").header("Authorization", bearer("admin"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("key", "CRM", "name", "Relation client"))))
                .andExpect(jsonPath("$.createdBy", is("admin")))
                .andExpect(jsonPath("$.createdAt").isString());
    }
}
