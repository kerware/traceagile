package com.traceagile.executionserver.tool;

import com.traceagile.executionserver.process.Platform;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * ADR-0026 un outil que le serveur sait détecter et, s'il est installable, installer sous {@code toolsDir}.
 *
 * @param id            identifiant stable (« playwright », « robot-browser »…)
 * @param category      regroupement de l'interface : Prérequis, Java, Navigateur, Python, Robot Framework, Performance
 * @param prerequisite  outil de la machine (Java, Node.js, Python, Git) : détecté et expliqué, jamais installé par le serveur
 * @param dependencies  outils à installer avant celui-ci
 * @param frameworks    frameworks de TraceAgile qu'il permet d'exécuter (capacités annoncées)
 * @param detect        commande de version (ligne de commande du shell de la plateforme)
 * @param versionPattern expression dont le premier groupe extrait la version de la sortie de {@code detect}
 * @param unix          script d'installation bash (Linux, macOS) ; null si non installable
 * @param windows       script d'installation PowerShell ; null si non installable
 * @param help          aide : prérequis, effets de l'installation, installation manuelle
 * @param docs          documentation officielle
 */
public record ToolDefinition(
        String id,
        String name,
        String category,
        String description,
        boolean prerequisite,
        List<String> dependencies,
        List<String> frameworks,
        String detect,
        String versionPattern,
        String unix,
        String windows,
        String help,
        String docs) {

    public boolean installable(Platform platform) {
        return script(platform) != null;
    }

    public String script(Platform platform) {
        return platform.windows() ? windows : unix;
    }

    /** Version lue dans la sortie de la commande de détection, ou null. */
    public String version(String output) {
        if (output == null) {
            return null;
        }
        Matcher matcher = Pattern.compile(versionPattern, Pattern.MULTILINE).matcher(output);
        return matcher.find() ? matcher.group(1) : null;
    }
}
