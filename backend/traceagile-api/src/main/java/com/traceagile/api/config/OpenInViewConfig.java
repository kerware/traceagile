package com.traceagile.api.config;

import jakarta.persistence.EntityManagerFactory;
import org.springframework.context.annotation.Configuration;
import org.springframework.orm.jpa.support.OpenEntityManagerInViewInterceptor;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * « Open in view » (le mapping DTO se fait dans les contrôleurs, ADR-0002) sauf pour les flux
 * Server-Sent Events (F-EXE-07) : une requête asynchrone garderait sa connexion JDBC jusqu'à la
 * fermeture du flux (30 min), et quelques onglets ouverts épuiseraient le pool. Remplace
 * {@code spring.jpa.open-in-view}, désactivé dans application.yml.
 */
@Configuration
public class OpenInViewConfig implements WebMvcConfigurer {

    static final String[] STREAMS = {"/api/v1/projects/*/runs/*/events", "/api/v1/projects/*/campaigns/*/run-events"};

    private final EntityManagerFactory entityManagerFactory;

    public OpenInViewConfig(EntityManagerFactory entityManagerFactory) {
        this.entityManagerFactory = entityManagerFactory;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        OpenEntityManagerInViewInterceptor interceptor = new OpenEntityManagerInViewInterceptor();
        interceptor.setEntityManagerFactory(entityManagerFactory);
        registry.addWebRequestInterceptor(interceptor).excludePathPatterns(STREAMS);
    }
}
