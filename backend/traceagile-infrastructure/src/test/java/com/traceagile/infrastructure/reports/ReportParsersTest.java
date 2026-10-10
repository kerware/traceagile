package com.traceagile.infrastructure.reports;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.application.automation.ReportParser.ReportFormat;
import com.traceagile.application.automation.ReportParser.ReportResult;
import com.traceagile.domain.execution.ExecutionStatus;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** F-EXE-10 import de rapports : un fichier exemple par format (§15.2). */
class ReportParsersTest {

    final ReportParsers parsers = new ReportParsers();

    byte[] sample(String name) throws IOException {
        try (InputStream in = getClass().getResourceAsStream("/reports/" + name)) {
            return in.readAllBytes();
        }
    }

    @Test
    @DisplayName("F-EXE-10 JUnit XML : « Classe#méthode », échec, erreur technique, ignoré, durée")
    void junit() throws IOException {
        List<ReportResult> results = parsers.parse(ReportFormat.JUNIT, sample("junit.xml"));
        assertThat(results).extracting(ReportResult::status)
                .containsExactly(ExecutionStatus.PASSED, ExecutionStatus.FAILED, ExecutionStatus.ERROR, ExecutionStatus.SKIPPED);
        ReportResult add = results.getFirst();
        assertThat(add.identifiers()).containsExactly("com.shop.CartApiTest#add", "CartApiTest#add", "add");
        assertThat(add.durationMs()).isEqualTo(812L);
        assertThat(results.get(1).message()).isEqualTo("expected: 0 but was: 1");
        assertThat(results.get(2).message()).isEqualTo("Connection refused");
    }

    @Test
    @DisplayName("F-EXE-10 Cucumber JSON : un résultat par scénario (identifiant = nom), tags d'exigence, durée en nanosecondes")
    void cucumber() throws IOException {
        List<ReportResult> results = parsers.parse(ReportFormat.CUCUMBER, sample("cucumber.json"));
        assertThat(results).extracting(ReportResult::identifier).containsExactly("Livraison gratuite au seuil", "Code promo expiré");
        assertThat(results.getFirst().status()).isEqualTo(ExecutionStatus.PASSED);
        assertThat(results.getFirst().durationMs()).isEqualTo(2_000L);
        assertThat(results.getFirst().requirementKeys()).containsExactly("REQ-12");
        assertThat(results.get(1).status()).isEqualTo(ExecutionStatus.FAILED);
        assertThat(results.get(1).message()).isEqualTo("Expected refusal");
    }

    @Test
    @DisplayName("F-EXE-10 Robot output.xml : suites imbriquées, PASS / FAIL / SKIP, durées des deux formats d'horodatage")
    void robot() throws IOException {
        List<ReportResult> results = parsers.parse(ReportFormat.ROBOT, sample("robot-output.xml"));
        assertThat(results).extracting(ReportResult::identifier).containsExactly("Connexion valide", "Mot de passe faible refusé", "Inscription");
        assertThat(results).extracting(ReportResult::status).containsExactly(ExecutionStatus.PASSED, ExecutionStatus.FAILED, ExecutionStatus.SKIPPED);
        assertThat(results.getFirst().durationMs()).isEqualTo(2_500L);
        assertThat(results.getFirst().requirementKeys()).containsExactly("REQ-21");
        assertThat(results.get(1).message()).isEqualTo("Le formulaire a été accepté");
        assertThat(results.get(2).durationMs()).isEqualTo(250L);
    }

    @Test
    @DisplayName("F-EXE-10 Playwright JSON : dernière tentative retenue, timedOut = échec, tags dans le titre ou la liste")
    void playwright() throws IOException {
        List<ReportResult> results = parsers.parse(ReportFormat.PLAYWRIGHT, sample("playwright.json"));
        assertThat(results).hasSize(2);
        ReportResult add = results.getFirst();
        assertThat(add.identifiers()).containsExactly("panier.spec.ts › Panier › ajoute un produit", "Panier › ajoute un produit", "ajoute un produit");
        assertThat(add.status()).isEqualTo(ExecutionStatus.PASSED);
        assertThat(add.durationMs()).isEqualTo(1_200L);
        assertThat(add.requirementKeys()).containsExactly("REQ-12");
        ReportResult empty = results.get(1);
        assertThat(empty.status()).isEqualTo(ExecutionStatus.FAILED);
        assertThat(empty.requirementKeys()).containsExactly("REQ-13");
        assertThat(empty.message()).contains("timeout");
    }

    @Test
    @DisplayName("F-EXE-10 fichier d'un autre format ou vide : 422 REPORT_INVALID")
    void invalid() {
        byte[] json = "{\"a\": 1}".getBytes(StandardCharsets.UTF_8);
        assertThatThrownBy(() -> parsers.parse(ReportFormat.JUNIT, json)).hasFieldOrPropertyWithValue("code", "REPORT_INVALID");
        assertThatThrownBy(() -> parsers.parse(ReportFormat.CUCUMBER, "<xml/>".getBytes(StandardCharsets.UTF_8)))
                .hasFieldOrPropertyWithValue("code", "REPORT_INVALID");
        assertThatThrownBy(() -> parsers.parse(ReportFormat.PLAYWRIGHT, json)).hasFieldOrPropertyWithValue("code", "REPORT_INVALID");
        assertThatThrownBy(() -> parsers.parse(ReportFormat.ROBOT, new byte[0])).hasFieldOrPropertyWithValue("code", "REPORT_INVALID");
    }
}
