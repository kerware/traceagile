package com.traceagile.executionserver;

import java.nio.file.Path;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Réglages du serveur d'exécution (ADR-0026).
 *
 * @param adminUser      administrateur du serveur : interface et émission des jetons (HTTP Basic)
 * @param adminPassword  son mot de passe
 * @param dataDir        données persistantes : base H2, espaces de travail des jobs, artefacts, journaux
 * @param toolsDir       outils installés à chaud (volume) : npm global, environnement Python, Maven, JDK…
 * @param agents         nombre de tests exécutés en même temps sur le serveur, tous jobs confondus
 * @param retentionDays  durée de conservation des espaces de travail et des artefacts
 * @param serverName     nom affiché dans l'interface et donné comme agent aux webhooks
 */
@ConfigurationProperties(prefix = "execution-server")
public record ServerProperties(
        String adminUser,
        String adminPassword,
        Path dataDir,
        Path toolsDir,
        int agents,
        int retentionDays,
        String serverName) {

    public ServerProperties {
        adminUser = adminUser == null || adminUser.isBlank() ? "admin" : adminUser;
        adminPassword = adminPassword == null || adminPassword.isBlank() ? "executeur" : adminPassword;
        dataDir = dataDir == null ? Path.of("data") : dataDir;
        toolsDir = toolsDir == null ? Path.of("tools") : toolsDir;
        agents = agents <= 0 ? 4 : agents;
        retentionDays = retentionDays <= 0 ? 14 : retentionDays;
        serverName = serverName == null || serverName.isBlank() ? "executeur" : serverName;
    }

    public Path jobsDir() {
        return dataDir.resolve("jobs");
    }

    public Path toolLogsDir() {
        return dataDir.resolve("tool-logs");
    }
}
