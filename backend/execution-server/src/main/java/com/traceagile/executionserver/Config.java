package com.traceagile.executionserver;

import java.time.Clock;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/** Horloge injectable (tests) et routage de l'interface monopage. */
@Configuration
public class Config implements WebMvcConfigurer {

    @Bean
    Clock clock() {
        return Clock.systemUTC();
    }

    /** Les routes de l'interface (/jobs/…, /tools…) renvoient index.html ; React Router prend le relais. */
    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        for (String route : new String[] {"/", "/login", "/jobs", "/jobs/{id}", "/tools", "/tokens", "/settings", "/logs"}) {
            registry.addViewController(route).setViewName("forward:/index.html");
        }
    }

    /** §10.2 santé (public) : version et nom du serveur. */
    @RestController
    static class HealthController {

        private final ServerProperties properties;

        HealthController(ServerProperties properties) {
            this.properties = properties;
        }

        @GetMapping("/api/v1/health")
        java.util.Map<String, String> health() {
            String version = Config.class.getPackage().getImplementationVersion();
            return java.util.Map.of("status", "UP", "version", version == null ? "dev" : version, "name", properties.serverName());
        }
    }
}
