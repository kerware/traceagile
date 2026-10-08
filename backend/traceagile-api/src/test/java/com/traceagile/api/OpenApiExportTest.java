package com.traceagile.api;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * §11.1 Documentation API (springdoc) ; le client front est généré depuis cette description, que ce
 * test exporte dans {@code frontend/openapi/traceagile-api.json} (ADR-0007).
 */
class OpenApiExportTest extends AbstractApiTest {

    static final Path EXPORT = Path.of("..", "..", "frontend", "openapi", "traceagile-api.json");

    @Test
    @DisplayName("§11.1 la description OpenAPI est publiée et exportée pour le client front")
    void exportOpenApi() throws Exception {
        String body = mvc.perform(get("/v3/api-docs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.paths['/api/v1/auth/login']").exists())
                .andExpect(jsonPath("$.components.securitySchemes.bearerAuth").exists())
                .andReturn().getResponse().getContentAsString(StandardCharsets.UTF_8);

        Files.createDirectories(EXPORT.getParent());
        Files.writeString(EXPORT, json.writerWithDefaultPrettyPrinter().writeValueAsString(json.readTree(body)) + "\n");
    }

    @Test
    @DisplayName("§11.1 Swagger UI disponible sur /swagger-ui.html")
    void swaggerUi() throws Exception {
        mvc.perform(get("/swagger-ui.html")).andExpect(status().is3xxRedirection());
    }
}
