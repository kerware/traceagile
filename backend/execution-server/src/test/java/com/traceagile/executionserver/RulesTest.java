package com.traceagile.executionserver;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.executionserver.job.JobSpec;
import com.traceagile.executionserver.job.executor.JUnitReports;
import com.traceagile.executionserver.process.Platform;
import com.traceagile.executionserver.tool.ToolCatalog;
import com.traceagile.executionserver.tool.ToolDefinition;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

/** Règles pures du serveur d'exécution (ADR-0026). */
class RulesTest {

    @Test
    @DisplayName("Rapports JUnit : statut par cas, choix du cas par identifiant (Playwright, classe#méthode, nœud pytest), synthèse")
    void junitReports(@TempDir Path dir) throws Exception {
        Files.writeString(dir.resolve("report.xml"), """
                <testsuites><testsuite name="s">
                  <testcase classname="panier.spec.ts" name="Panier › visualise le contenu du panier" time="1.5"/>
                  <testcase classname="panier.spec.ts" name="Panier › problem_user retire un produit @fail" time="2">
                    <failure message="badge">AssertionError</failure></testcase>
                  <testcase classname="com.shop.CartApiTest" name="add" time="0.1"><skipped/></testcase>
                  <testcase classname="tests.test_login" name="test_locked" time="0.2"><error message="boom">Traceback</error></testcase>
                </testsuite></testsuites>""");
        List<JUnitReports.Case> cases = JUnitReports.read(dir);
        assertThat(cases).hasSize(4);
        assertThat(cases.getFirst().durationMs()).isEqualTo(1500);
        assertThat(JUnitReports.matching(cases, "Panier › problem_user retire un produit @fail")).singleElement()
                .satisfies(c -> assertThat(c.status()).isEqualTo("FAILED"));
        assertThat(JUnitReports.matching(cases, "com.shop.CartApiTest#add")).singleElement().satisfies(c -> assertThat(c.status()).isEqualTo("SKIPPED"));
        assertThat(JUnitReports.matching(cases, "tests/test_login.py::test_locked")).singleElement().satisfies(c -> assertThat(c.message()).isEqualTo("boom"));
        assertThat(JUnitReports.matching(cases, "inconnu")).hasSize(4);
        assertThat(JUnitReports.status(cases)).isEqualTo("ERROR");
        assertThat(JUnitReports.status(List.of())).isNull();
        assertThat(JUnitReports.lastSegment("A › B › titre")).isEqualTo("titre");
    }

    @Test
    @DisplayName("Job : lecture du corps du contrat (dépôt, options bornées) ; runId, callbackUrl et tests obligatoires")
    void jobSpec() {
        JobSpec spec = JobSpec.from(Map.of("runId", "SHOP/RUN-1", "callbackUrl", "http://t/cb",
                "repository", Map.of("url", "https://git/x.git", "branch", "main"),
                "tests", List.of(Map.of("executionId", "e-1", "testKey", "TC-1", "parameters", Map.of("jdk", 17))),
                "options", Map.of("parallelism", 99, "retryFailed", -2)));
        assertThat(spec.repositoryUrl()).isEqualTo("https://git/x.git");
        assertThat(spec.parallelism()).isEqualTo(32);
        assertThat(spec.retryFailed()).isZero();
        assertThat(spec.timeoutMinutes()).isEqualTo(30);
        assertThat(spec.tests().getFirst().parameter("jdk")).isEqualTo("17");
        assertThatThrownBy(() -> JobSpec.from(Map.of("runId", "R"))).isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("ADR-0026 jar multiplateforme : Windows → cmd et PowerShell, sinon bash ; chemins d'environnement Python")
    void platforms() {
        assertThat(Platform.of("Windows 11")).isEqualTo(Platform.WINDOWS);
        assertThat(Platform.of("Mac OS X")).isEqualTo(Platform.MAC);
        assertThat(Platform.of("Linux")).isEqualTo(Platform.LINUX);
        assertThat(Platform.WINDOWS.shell("npm ci")).startsWith("cmd.exe");
        assertThat(Platform.LINUX.shell("npm ci")).containsExactly("bash", "-lc", "npm ci");
        assertThat(Platform.WINDOWS.script("x").getLast()).contains("function Check").endsWith("x");
        assertThat(Platform.LINUX.script("x").getLast()).startsWith("set -euo pipefail");
        assertThat(Platform.WINDOWS.venvBin(Path.of("p"))).isEqualTo(Path.of("p", "Scripts"));
    }

    @Test
    @DisplayName("Catalogue : dépendances connues, chaque outil installable a sa recette Windows et Unix, versions lues par le motif")
    void catalog() {
        ToolCatalog catalog = new ToolCatalog();
        for (ToolDefinition tool : catalog.all()) {
            tool.dependencies().forEach(d -> assertThat(catalog.find(d)).as(tool.id() + " → " + d).isPresent());
            if (!tool.prerequisite()) {
                assertThat(tool.unix()).as(tool.id()).isNotBlank();
                assertThat(tool.windows()).as(tool.id()).isNotBlank();
            }
        }
        assertThat(catalog.all()).extracting(ToolDefinition::id).contains("playwright", "selenium", "cypress", "junit", "maven", "jdk-17", "gatling",
                "robotframework", "robot-selenium", "robot-browser");
        assertThat(catalog.find("maven").orElseThrow().version("Apache Maven 3.9.9 (8e8579a9)")).isEqualTo("3.9.9");
        assertThat(catalog.find("java").orElseThrow().version("openjdk version \"21.0.5\" 2024-10-15")).isEqualTo("21.0.5");
        assertThat(catalog.find("cypress").orElseThrow().version("Cypress package version: 13.17.0\nCypress binary version: 13.17.0")).isEqualTo("13.17.0");
    }
}
