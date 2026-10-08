package com.traceagile.mockserver;

import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

/** §10.2 Simulateur : GET /api/v1/health (heartbeat). Les autres endpoints arrivent au lot 7. */
@SpringBootTest
@AutoConfigureMockMvc
class HealthApiTest {

    @Autowired
    MockMvc mvc;

    @Test
    @DisplayName("§10.2 GET /api/v1/health : état et version du serveur d'exécution")
    void health() throws Exception {
        mvc.perform(get("/api/v1/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("UP")))
                .andExpect(jsonPath("$.name", is("mock-execution-server")))
                .andExpect(jsonPath("$.version").isString());
    }
}
