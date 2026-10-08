package com.traceagile.api;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping;

/**
 * NF-08 Contrôle d'accès vérifié sur chaque endpoint : tout endpoint de l'API porte une règle
 * {@code @PreAuthorize}, hormis la liste explicite des endpoints publics ou simplement authentifiés.
 */
class EndpointSecurityTest extends AbstractApiTest {

    /** Endpoints sans @PreAuthorize (classe.méthode). Toute addition doit être justifiée. */
    static final Set<String> EXEMPT = Set.of(
            "AuthController.login",     // public
            "AuthController.refresh",   // public, authentifié par le cookie de rafraîchissement
            "AuthController.logout",    // public, idem
            "MeController.me");         // tout utilisateur authentifié

    @Autowired
    @Qualifier("requestMappingHandlerMapping")
    RequestMappingHandlerMapping mapping;

    @Test
    @DisplayName("NF-08 chaque endpoint /api/v1 déclare sa règle d'autorisation")
    void everyEndpointIsProtected() {
        List<String> unprotected = new ArrayList<>();
        mapping.getHandlerMethods().forEach((info, method) -> {
            if (!method.getBeanType().getPackageName().startsWith("com.traceagile.api")) {
                return;
            }
            String name = method.getBeanType().getSimpleName() + "." + method.getMethod().getName();
            boolean annotated = method.hasMethodAnnotation(PreAuthorize.class)
                    || method.getBeanType().isAnnotationPresent(PreAuthorize.class);
            if (!annotated && !EXEMPT.contains(name)) {
                unprotected.add(name + " " + info);
            }
        });
        assertThat(unprotected).isEmpty();
    }
}
