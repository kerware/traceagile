package com.traceagile.mockserver;

import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * §10.5 réglages du simulateur. {@code adminUser} / {@code adminPassword} protègent l'émission des
 * jetons (ADR-0020) ; {@code passRate} / {@code errorRate} tirent les résultats ; délai par test aléatoire.
 */
@ConfigurationProperties(prefix = "simulator")
public record SimulatorProperties(
        String adminUser,
        String adminPassword,
        double passRate,
        double errorRate,
        long minDelayMs,
        long maxDelayMs,
        List<String> techniques,
        List<String> frameworks,
        List<String> environments,
        int agents) {

    public SimulatorProperties {
        adminUser = adminUser == null ? "admin" : adminUser;
        adminPassword = adminPassword == null ? "simulateur" : adminPassword;
        techniques = techniques == null ? List.of("API", "BDD", "UNIT", "UI", "KEYWORD", "DATA_DRIVEN", "PERFORMANCE", "CONTRACT") : techniques;
        frameworks = frameworks == null ? List.of() : frameworks;
        environments = environments == null ? List.of() : environments;
    }
}
