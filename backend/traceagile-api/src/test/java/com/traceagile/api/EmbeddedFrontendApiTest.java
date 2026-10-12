package com.traceagile.api;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.forwardedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * Installation hors Docker (docs/installation.md) : le jar distribuable sert l'interface React (routes de
 * l'application → index.html, guide → /guide/index.html) avec les en-têtes de sécurité que donnait nginx ;
 * l'API reste protégée.
 */
class EmbeddedFrontendApiTest extends AbstractApiTest {

    @Test
    @DisplayName("NF-09 routes de l'application : index.html, sans authentification, avec CSP et no-cache")
    void applicationRoutes() throws Exception {
        for (String route : new String[] {"/", "/login", "/projects", "/p/SHOP/backlog", "/p/SHOP/requirements/REQ-3", "/admin/users"}) {
            mvc.perform(get(route)).andExpect(status().isOk()).andExpect(forwardedUrl("/index.html"))
                    .andExpect(header().string("Content-Security-Policy", containsString("default-src 'self'")))
                    .andExpect(header().string("Cache-Control", containsString("no-cache")));
        }
    }

    @Test
    @DisplayName("Menu Documentation : /guide/ sert le guide HTML, polices Google Fonts autorisées, aucun script")
    void guide() throws Exception {
        mvc.perform(get("/guide/")).andExpect(forwardedUrl("/guide/index.html"))
                .andExpect(header().string("Content-Security-Policy", containsString("script-src 'none'")))
                .andExpect(header().string("Content-Security-Policy", containsString("https://fonts.googleapis.com")));
    }

    @Test
    @DisplayName("NF-08 l'API n'est pas servie par l'interface : sans jeton, 401")
    void apiStaysProtected() throws Exception {
        mvc.perform(get("/api/v1/projects")).andExpect(status().isUnauthorized());
        mvc.perform(get("/api/v1/inconnu")).andExpect(status().isUnauthorized());
    }
}
