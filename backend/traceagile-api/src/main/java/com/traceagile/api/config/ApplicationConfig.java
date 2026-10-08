package com.traceagile.api.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import java.time.Clock;
import java.util.Optional;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

@Configuration
@EnableJpaAuditing
public class ApplicationConfig {

    /** Acteur inscrit dans createdBy / updatedBy hors requête authentifiée (démarrage, tâches). */
    static final String SYSTEM_ACTOR = "system";

    @Bean
    Clock clock() {
        return Clock.systemUTC();
    }

    /** §3 createdBy / updatedBy : login de l'utilisateur authentifié. */
    @Bean
    AuditorAware<String> auditorAware() {
        return () -> Optional.ofNullable(SecurityContextHolder.getContext().getAuthentication())
                .filter(Authentication::isAuthenticated)
                .map(Authentication::getName)
                .or(() -> Optional.of(SYSTEM_ACTOR));
    }

    /** §11.1 springdoc-openapi : schéma Bearer appliqué par défaut à toute l'API. */
    @Bean
    OpenAPI openApi() {
        return new OpenAPI()
                .info(new Info().title("TraceAgile API").version("v1")
                        .description("API de gestion des exigences agiles et des tests (prototype)."))
                .components(new Components().addSecuritySchemes("bearerAuth",
                        new SecurityScheme().type(SecurityScheme.Type.HTTP).scheme("bearer").bearerFormat("JWT")))
                .addSecurityItem(new SecurityRequirement().addList("bearerAuth"));
    }
}
