package com.traceagile.executionserver.tool;

import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Component;

/**
 * ADR-0026 catalogue des outils. Les prérequis (Java, Node.js, Python, Git) sont détectés et expliqués ;
 * les autres s'installent sous {@code toolsDir} sans droits d'administrateur. Versions figées pour des
 * installations reproductibles.
 *
 * <p>Jetons des commandes, remplacés par {@link ToolService} : {@code {tools}} dossier des outils,
 * {@code {python}} Python des outils, {@code {os}} / {@code {arch}} système et architecture au sens
 * d'Adoptium, {@code {strip}} niveaux à retirer d'une archive de JDK (3 sous macOS). Les scripts
 * Windows appellent {@code Check} après chaque programme externe (arrêt sur code de retour non nul).
 */
@Component
public class ToolCatalog {

    static final String MAVEN = "3.9.9";
    static final String JUNIT = "1.11.4";
    static final String GATLING = "3.10.5";
    static final String PLAYWRIGHT = "1.63.0";
    static final String CYPRESS = "13.17.0";
    static final String SELENIUM = "4.27.1";
    static final String PYTEST = "8.3.4";
    static final String ROBOT = "7.1.1";
    static final String ROBOT_SELENIUM = "6.7.0";

    private static final String PIP = "\"{python}\" -m pip install ";
    private static final String PIP_WIN = "& \"{python}\" -m pip install ";

    private final List<ToolDefinition> tools = List.of(
            // ---------------------------------------------------------------------------- prérequis
            prerequisite("java", "Java (JDK)", "Exécute le serveur, Maven, JUnit et Gatling.", List.of("JUnit 5", "REST Assured", "Cucumber-JVM"),
                    "java -version", "version \"([^\"]+)\"",
                    "Le serveur tourne déjà sur Java 21. Pour d'autres versions, installez « JDK 17 » ou « JDK 21 » ci-dessous.",
                    "https://adoptium.net/"),
            prerequisite("node", "Node.js", "Exécute Playwright, Cypress, Cucumber-JS et la bibliothèque Browser de Robot Framework.", List.of(),
                    "node --version", "v(\\S+)",
                    "Installez Node.js 20 ou 22 (LTS) : https://nodejs.org (Windows : winget install OpenJS.NodeJS.LTS ; Linux : paquet nodejs de NodeSource), puis relancez la détection.",
                    "https://nodejs.org/"),
            prerequisite("python", "Python 3", "Base de l'environnement Python des outils (Selenium, pytest, Robot Framework).", List.of(),
                    "python3 --version || python --version", "Python (\\S+)",
                    "Installez Python 3.10 ou plus (Windows : winget install Python.Python.3.12 ; Debian/Ubuntu : apt install python3 python3-venv), puis relancez la détection.",
                    "https://www.python.org/downloads/"),
            prerequisite("git", "Git", "Récupère les dépôts de tests des jobs (clone superficiel de la branche).", List.of(),
                    "git --version", "git version (\\S+)",
                    "Installez Git (Windows : winget install Git.Git ; Debian/Ubuntu : apt install git). Les identifiants des dépôts privés se règlent dans Paramètres.",
                    "https://git-scm.com/downloads"),

            // ---------------------------------------------------------------------------------- Java
            new ToolDefinition("jdk-17", "JDK 17 (Temurin)", "Java", "JDK supplémentaire, choisi par un test avec le paramètre « jdk: 17 ».", false,
                    List.of(), List.of(), "\"{tools}/jdk-17/bin/java\" -version", "version \"([^\"]+)\"",
                    "rm -rf \"{tools}/jdk-17\" && mkdir -p \"{tools}/jdk-17\" && curl -fsSL \"https://api.adoptium.net/v3/binary/latest/17/ga/{os}/{arch}/jdk/hotspot/normal/eclipse\""
                            + " | tar -xz --strip-components={strip} -C \"{tools}/jdk-17\"",
                    jdkWindows("17"),
                    "Télécharge l'archive Temurin d'Adoptium (environ 190 Mo) dans le dossier des outils. Aucun droit d'administrateur.",
                    "https://adoptium.net/temurin/releases/?version=17"),
            new ToolDefinition("jdk-21", "JDK 21 (Temurin)", "Java", "JDK 21 propre au serveur, choisi avec le paramètre « jdk: 21 ».", false,
                    List.of(), List.of(), "\"{tools}/jdk-21/bin/java\" -version", "version \"([^\"]+)\"",
                    "rm -rf \"{tools}/jdk-21\" && mkdir -p \"{tools}/jdk-21\" && curl -fsSL \"https://api.adoptium.net/v3/binary/latest/21/ga/{os}/{arch}/jdk/hotspot/normal/eclipse\""
                            + " | tar -xz --strip-components={strip} -C \"{tools}/jdk-21\"",
                    jdkWindows("21"),
                    "Télécharge l'archive Temurin d'Adoptium (environ 200 Mo) dans le dossier des outils.",
                    "https://adoptium.net/temurin/releases/?version=21"),
            new ToolDefinition("maven", "Apache Maven", "Java", "Construit et lance les tests Java : JUnit 5, REST Assured, Cucumber-JVM, Gatling (plugin).", false,
                    List.of("java"), List.of("JUnit 5", "REST Assured", "Cucumber-JVM", "Spring Cloud Contract", "Kotest", "Pact"),
                    "mvn -v", "Apache Maven (\\S+)",
                    "rm -rf \"{tools}/maven\" && mkdir -p \"{tools}/maven\" && curl -fsSL https://archive.apache.org/dist/maven/maven-3/" + MAVEN
                            + "/binaries/apache-maven-" + MAVEN + "-bin.tar.gz | tar -xz --strip-components=1 -C \"{tools}/maven\"",
                    "$zip = Join-Path $env:TEMP 'maven.zip'; Invoke-WebRequest 'https://archive.apache.org/dist/maven/maven-3/" + MAVEN
                            + "/binaries/apache-maven-" + MAVEN + "-bin.zip' -OutFile $zip; Remove-Item -Recurse -Force '{tools}/maven','{tools}/maven-tmp' -ErrorAction SilentlyContinue;"
                            + " Expand-Archive $zip '{tools}/maven-tmp'; Move-Item '{tools}/maven-tmp/apache-maven-" + MAVEN + "' '{tools}/maven';"
                            + " Remove-Item -Recurse -Force '{tools}/maven-tmp', $zip",
                    "Maven " + MAVEN + " (10 Mo). Le dépôt local des dépendances est placé dans le dossier des outils (m2), partagé par tous les jobs.",
                    "https://maven.apache.org/"),
            new ToolDefinition("junit", "JUnit Platform Console", "Java", "Lance des tests JUnit 5 déjà compilés, sans Maven.", false,
                    List.of("java"), List.of("JUnit 5"),
                    "ls \"{tools}/junit\"", "junit-platform-console-standalone-(\\S+)\\.jar",
                    "mkdir -p \"{tools}/junit\" && curl -fsSLo \"{tools}/junit/junit-platform-console-standalone-" + JUNIT + ".jar\""
                            + " https://repo1.maven.org/maven2/org/junit/platform/junit-platform-console-standalone/" + JUNIT
                            + "/junit-platform-console-standalone-" + JUNIT + ".jar",
                    "New-Item -ItemType Directory -Force '{tools}/junit' | Out-Null; Invoke-WebRequest 'https://repo1.maven.org/maven2/org/junit/platform/junit-platform-console-standalone/"
                            + JUNIT + "/junit-platform-console-standalone-" + JUNIT + ".jar' -OutFile '{tools}/junit/junit-platform-console-standalone-" + JUNIT + ".jar'",
                    "Pour un projet Maven, Maven suffit : JUnit vient des dépendances du projet.",
                    "https://junit.org/junit5/docs/current/user-guide/#running-tests-console-launcher"),
            new ToolDefinition("gatling", "Gatling", "Performance", "Tests de charge ; les métriques (p95, débit) alimentent les ENF de TraceAgile.", false,
                    List.of("java"), List.of("Gatling"),
                    "ls \"{tools}/gatling/lib\"", "gatling-core-(\\d\\S*)\\.jar",
                    "cd \"{tools}\" && rm -rf gatling gatling.zip && curl -fsSLo gatling.zip https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/"
                            + GATLING + "/gatling-charts-highcharts-bundle-" + GATLING + "-bundle.zip && unzip -q gatling.zip && mv gatling-charts-highcharts-bundle-" + GATLING
                            + " gatling && rm gatling.zip && chmod +x gatling/bin/*.sh",
                    "$zip = Join-Path $env:TEMP 'gatling.zip'; Invoke-WebRequest 'https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/"
                            + GATLING + "/gatling-charts-highcharts-bundle-" + GATLING + "-bundle.zip' -OutFile $zip; Remove-Item -Recurse -Force '{tools}/gatling' -ErrorAction SilentlyContinue;"
                            + " Expand-Archive $zip '{tools}'; Move-Item '{tools}/gatling-charts-highcharts-bundle-" + GATLING + "' '{tools}/gatling'; Remove-Item $zip",
                    "Bundle Gatling " + GATLING + " (70 Mo, nécessite unzip sous Linux). Un projet Maven avec le plugin Gatling n'en a pas besoin : Maven suffit.",
                    "https://docs.gatling.io/"),

            // ---------------------------------------------------------------------------- navigateur
            new ToolDefinition("playwright", "Playwright", "Navigateur", "Tests d'interface et d'API en TypeScript / JavaScript, navigateur Chromium.", false,
                    List.of("node"), List.of("Playwright"),
                    "playwright --version", "Version (\\S+)",
                    "npm install -g @playwright/test@" + PLAYWRIGHT + " && playwright install chromium",
                    "npm install -g @playwright/test@" + PLAYWRIGHT + "; Check; playwright install chromium; Check",
                    "Installe Playwright " + PLAYWRIGHT + " et Chromium (150 Mo) dans le dossier des outils. Sous Linux hors de l'image Docker, les bibliothèques"
                            + " système des navigateurs s'installent une fois avec les droits d'administrateur : sudo npx playwright install-deps chromium."
                            + " Chaque job installe aussi les navigateurs de la version de Playwright de son dépôt (en cache).",
                    "https://playwright.dev/docs/intro"),
            new ToolDefinition("cypress", "Cypress", "Navigateur", "Tests d'interface Cypress (navigateur Electron intégré).", false,
                    List.of("node"), List.of("Cypress"),
                    "cypress --version", "Cypress package version: (\\S+)",
                    "npm install -g cypress@" + CYPRESS + " && cypress install && cypress verify",
                    "npm install -g cypress@" + CYPRESS + "; Check; cypress install; Check; cypress verify; Check",
                    "Cypress " + CYPRESS + " (500 Mo avec son binaire). Sous Linux hors de l'image Docker : sudo apt-get install libgtk-3-0 libgbm1 libnss3 libxss1 libasound2 libxtst6 xauth xvfb.",
                    "https://docs.cypress.io/app/get-started/install-cypress"),

            // -------------------------------------------------------------------------------- Python
            new ToolDefinition("python-env", "Environnement Python des outils", "Python", "Environnement virtuel où s'installent Selenium, pytest et Robot Framework.", false,
                    List.of("python"), List.of(),
                    "\"{python}\" --version", "Python (\\S+)",
                    "rm -rf \"{tools}/python\" && (python3 -m venv \"{tools}/python\" || python -m venv \"{tools}/python\") && \"{python}\" -m pip install --upgrade pip",
                    "Remove-Item -Recurse -Force '{tools}/python' -ErrorAction SilentlyContinue; python -m venv '{tools}/python'; Check; & \"{python}\" -m pip install --upgrade pip; Check",
                    "Crée un environnement virtuel isolé : les paquets n'affectent pas le Python de la machine.",
                    "https://docs.python.org/3/library/venv.html"),
            new ToolDefinition("selenium", "Selenium (Python) + pytest", "Python", "Tests Selenium WebDriver écrits avec pytest.", false,
                    List.of("python-env"), List.of("Selenium", "pytest", "pytest + requests"),
                    "\"{python}\" -c \"import selenium, pytest; print('selenium ' + selenium.__version__)\"", "selenium (\\S+)",
                    PIP + "selenium==" + SELENIUM + " pytest==" + PYTEST + " requests",
                    PIP_WIN + "selenium==" + SELENIUM + " pytest==" + PYTEST + " requests; Check",
                    "Selenium Manager télécharge au premier test le pilote et un navigateur Chrome for Testing compatibles (accès Internet nécessaire).",
                    "https://www.selenium.dev/documentation/webdriver/getting_started/"),

            // ----------------------------------------------------------------------- Robot Framework
            new ToolDefinition("robotframework", "Robot Framework", "Robot Framework", "Tests par mots-clés (fichiers .robot).", false,
                    List.of("python-env"), List.of("Robot Framework"),
                    "\"{python}\" -m robot --version", "Robot Framework (\\S+)",
                    PIP + "robotframework==" + ROBOT,
                    PIP_WIN + "robotframework==" + ROBOT + "; Check",
                    "Robot Framework " + ROBOT + " dans l'environnement Python des outils. Ajoutez une bibliothèque de navigateur : SeleniumLibrary ou Browser (Playwright).",
                    "https://robotframework.org/"),
            new ToolDefinition("robot-selenium", "Robot Framework SeleniumLibrary", "Robot Framework", "Mots-clés Selenium pour Robot Framework.", false,
                    List.of("robotframework"), List.of("Robot Framework"),
                    "\"{python}\" -c \"import SeleniumLibrary; print('SeleniumLibrary ' + SeleniumLibrary.__version__)\"", "SeleniumLibrary (\\S+)",
                    PIP + "robotframework-seleniumlibrary==" + ROBOT_SELENIUM,
                    PIP_WIN + "robotframework-seleniumlibrary==" + ROBOT_SELENIUM + "; Check",
                    "Installe aussi Selenium ; le navigateur est obtenu par Selenium Manager au premier test.",
                    "https://robotframework.org/SeleniumLibrary/"),
            new ToolDefinition("robot-browser", "Robot Framework Browser (Playwright)", "Robot Framework", "Mots-clés Playwright pour Robot Framework.", false,
                    List.of("robotframework", "node"), List.of("Robot Framework"),
                    "\"{python}\" -c \"import Browser; print('Browser ' + Browser.__version__)\"", "Browser (\\S+)",
                    PIP + "robotframework-browser && \"{tools}/python/bin/rfbrowser\" init chromium",
                    PIP_WIN + "robotframework-browser; Check; & '{tools}/python/Scripts/rfbrowser.exe' init chromium; Check",
                    "Installe la bibliothèque Browser puis « rfbrowser init chromium » (dépendances Node.js et Chromium, environ 300 Mo).",
                    "https://robotframework-browser.org/"));

    public List<ToolDefinition> all() {
        return tools;
    }

    public Optional<ToolDefinition> find(String id) {
        return tools.stream().filter(t -> t.id().equals(id)).findFirst();
    }

    private static ToolDefinition prerequisite(String id, String name, String description, List<String> frameworks, String detect, String pattern,
                                               String help, String docs) {
        return new ToolDefinition(id, name, "Prérequis", description, true, List.of(), frameworks, detect, pattern, null, null, help, docs);
    }

    private static String jdkWindows(String version) {
        return "$zip = Join-Path $env:TEMP 'jdk-" + version + ".zip'; Invoke-WebRequest 'https://api.adoptium.net/v3/binary/latest/" + version
                + "/ga/windows/{arch}/jdk/hotspot/normal/eclipse' -OutFile $zip; Remove-Item -Recurse -Force '{tools}/jdk-" + version + "','{tools}/jdk-tmp'"
                + " -ErrorAction SilentlyContinue; Expand-Archive $zip '{tools}/jdk-tmp'; Move-Item (Get-ChildItem '{tools}/jdk-tmp' | Select-Object -First 1).FullName"
                + " '{tools}/jdk-" + version + "'; Remove-Item -Recurse -Force '{tools}/jdk-tmp', $zip";
    }
}
