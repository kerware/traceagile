package com.traceagile.api;

import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

/** §12 Administration : GET/POST /users, PATCH /users/{id} (réservé à l'administrateur, §2.2). */
class UserApiTest extends AbstractApiTest {

    @BeforeEach
    void data() {
        user("admin", true);
        user("qa1", false);
    }

    @Test
    @DisplayName("§12 GET /users : liste paginée {content, page, size, totalElements}")
    void list() throws Exception {
        mvc.perform(get("/api/v1/users?page=0&size=1&sort=login,asc").header("Authorization", bearer("admin")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].login", is("admin")))
                .andExpect(jsonPath("$.content[0].passwordHash").doesNotExist())
                .andExpect(jsonPath("$.page", is(0)))
                .andExpect(jsonPath("$.size", is(1)))
                .andExpect(jsonPath("$.totalElements", is(2)));
    }

    @Test
    @DisplayName("§2.2 GET /users par un non-administrateur → 403 ACCESS_DENIED")
    void listForbidden() throws Exception {
        mvc.perform(get("/api/v1/users").header("Authorization", bearer("qa1")))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code", is("ACCESS_DENIED")))
                .andExpect(jsonPath("$.detail").isString());
    }

    @Test
    @DisplayName("§12 POST /users : création → 201 + Location")
    void create() throws Exception {
        mvc.perform(post("/api/v1/users").header("Authorization", bearer("admin"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("login", "qa2", "email", "qa2@example.com",
                                "displayName", "Testeur 2", "password", "secret-123"))))
                .andExpect(status().isCreated())
                .andExpect(header().exists("Location"))
                .andExpect(jsonPath("$.login", is("qa2")))
                .andExpect(jsonPath("$.active", is(true)));
    }

    @Test
    @DisplayName("§12 POST /users : login déjà pris → 409 USER_LOGIN_TAKEN")
    void createDuplicate() throws Exception {
        mvc.perform(post("/api/v1/users").header("Authorization", bearer("admin"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("login", "qa1", "email", "x@example.com", "password", "secret-123"))))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code", is("USER_LOGIN_TAKEN")));
    }

    @Test
    @DisplayName("§15.2 POST /users invalide → 400 avec le détail par champ")
    void createInvalid() throws Exception {
        mvc.perform(post("/api/v1/users").header("Authorization", bearer("admin"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("login", "Pas Valide", "email", "nope", "password", "court"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code", is("VALIDATION_FAILED")))
                .andExpect(jsonPath("$.errors.login").exists())
                .andExpect(jsonPath("$.errors.email").exists())
                .andExpect(jsonPath("$.errors.password").exists());
    }

    @Test
    @DisplayName("§12 PATCH /users/{id} (merge-patch) avec If-Match correct → 200 et nouvel ETag")
    void patchWithVersion() throws Exception {
        String admin = bearer("admin");
        String id = idOf("qa1", admin);

        mvc.perform(patch("/api/v1/users/" + id).header("Authorization", admin)
                        .header("If-Match", "\"0\"")
                        .contentType("application/merge-patch+json")
                        .content(toJson(Map.of("displayName", "Testeur principal", "active", false))))
                .andExpect(status().isOk())
                .andExpect(header().string("ETag", "\"1\""))
                .andExpect(jsonPath("$.displayName", is("Testeur principal")))
                .andExpect(jsonPath("$.active", is(false)));
    }

    @Test
    @DisplayName("§12 PATCH /users/{id} avec une version périmée → 412 VERSION_CONFLICT")
    void patchStaleVersion() throws Exception {
        String admin = bearer("admin");
        String id = idOf("qa1", admin);

        mvc.perform(patch("/api/v1/users/" + id).header("Authorization", admin)
                        .header("If-Match", "\"7\"")
                        .contentType("application/merge-patch+json")
                        .content(toJson(Map.of("displayName", "X"))))
                .andExpect(status().isPreconditionFailed())
                .andExpect(jsonPath("$.code", is("VERSION_CONFLICT")));
    }

    @Test
    @DisplayName("§3.1 un utilisateur désactivé ne peut plus se connecter")
    void deactivatedUserCannotLogin() throws Exception {
        String admin = bearer("admin");
        String id = idOf("qa1", admin);
        mvc.perform(patch("/api/v1/users/" + id).header("Authorization", admin)
                        .contentType("application/merge-patch+json")
                        .content(toJson(Map.of("active", false))))
                .andExpect(status().isOk());

        mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("login", "qa1", "password", PASSWORD))))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("§12 PATCH /users/{id} inconnu → 404 USER_NOT_FOUND")
    void patchUnknown() throws Exception {
        mvc.perform(patch("/api/v1/users/00000000-0000-0000-0000-000000000000").header("Authorization", bearer("admin"))
                        .contentType("application/merge-patch+json").content("{}"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code", is("USER_NOT_FOUND")));
    }

    private String idOf(String login, String admin) throws Exception {
        String body = mvc.perform(get("/api/v1/users?size=50").header("Authorization", admin))
                .andReturn().getResponse().getContentAsString();
        for (var node : readJson(body).get("content")) {
            if (node.get("login").asText().equals(login)) {
                return node.get("id").asText();
            }
        }
        throw new IllegalStateException(login);
    }
}
