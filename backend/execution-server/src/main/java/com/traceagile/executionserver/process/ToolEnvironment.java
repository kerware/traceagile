package com.traceagile.executionserver.process;

import com.traceagile.executionserver.ServerProperties;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

/**
 * ADR-0026 environnement commun aux installations et aux exécutions : tous les outils vivent sous
 * {@code toolsDir} (préfixe npm, environnement virtuel Python, Maven, JDK supplémentaires, Gatling,
 * navigateurs Playwright et Cypress, dépôt Maven local) et passent devant le PATH de la machine.
 */
@Component
public class ToolEnvironment {

    private final Path tools;
    private final Platform platform;

    @org.springframework.beans.factory.annotation.Autowired
    public ToolEnvironment(ServerProperties properties) {
        this(properties.toolsDir().toAbsolutePath().normalize(), Platform.current());
    }

    public ToolEnvironment(Path tools, Platform platform) {
        this.tools = tools;
        this.platform = platform;
    }

    public Platform platform() {
        return platform;
    }

    public Path tools() {
        return tools;
    }

    public Path path(String relative) {
        return tools.resolve(relative);
    }

    public Path python() {
        return path("python");
    }

    public Path npmPrefix() {
        return path("npm");
    }

    /** Exécutable de l'environnement Python des outils (python, pip, robot…). */
    public Path pythonExecutable(String name) {
        return platform.venvBin(python()).resolve(platform.windows() ? name + ".exe" : name);
    }

    public Map<String, String> variables() {
        Map<String, String> env = new LinkedHashMap<>();
        List<String> path = new ArrayList<>();
        path.add(platform.venvBin(python()).toString());
        path.add(platform.npmBin(npmPrefix()).toString());
        path.add(path("maven").resolve("bin").toString());
        path.add(path("gatling").resolve("bin").toString());
        path.add(path("bin").toString());
        String current = System.getenv(platform.windows() ? "Path" : "PATH");
        if (current == null) {
            current = System.getenv("PATH");
        }
        if (current != null) {
            path.add(current);
        }
        env.put(platform.windows() ? "Path" : "PATH", String.join(platform.pathSeparator(), path));
        env.put("npm_config_prefix", npmPrefix().toString());
        env.put("npm_config_cache", path("npm-cache").toString());
        env.put("npm_config_update_notifier", "false");
        env.put("PLAYWRIGHT_BROWSERS_PATH", path("ms-playwright").toString());
        env.put("CYPRESS_CACHE_FOLDER", path("cypress-cache").toString());
        env.put("MAVEN_OPTS", "-Dmaven.repo.local=" + path("m2"));
        env.put("PIP_DISABLE_PIP_VERSION_CHECK", "1");
        env.put("PYTHONUNBUFFERED", "1");
        env.put("CI", "true");
        env.put("TOOLS_DIR", tools.toString());
        return env;
    }

    /** JAVA_HOME pour une version de JDK installée par le serveur (17, 21…), sinon celui de la machine. */
    public Map<String, String> withJdk(Map<String, String> base, String version) {
        if (version == null || version.isBlank()) {
            return base;
        }
        Path home = path("jdk-" + version.strip());
        if (!Files.isDirectory(home)) {
            return base;
        }
        Map<String, String> env = new LinkedHashMap<>(base);
        env.put("JAVA_HOME", home.toString());
        String key = platform.windows() ? "Path" : "PATH";
        env.put(key, home.resolve("bin") + platform.pathSeparator() + env.get(key));
        return env;
    }
}
