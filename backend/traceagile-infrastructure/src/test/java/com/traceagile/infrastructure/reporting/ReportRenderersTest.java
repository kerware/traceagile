package com.traceagile.infrastructure.reporting;

import static org.assertj.core.api.Assertions.assertThat;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.application.reporting.ReportData;
import com.traceagile.application.reporting.ReportData.BurnChart;
import com.traceagile.application.reporting.ReportData.BurnPoint;
import com.traceagile.application.reporting.ReportData.CoverageSection;
import com.traceagile.application.reporting.ReportData.BlockingDefect;
import com.traceagile.application.reporting.ReportData.DefectRow;
import com.traceagile.application.reporting.ReportData.DefectSection;
import com.traceagile.application.reporting.ReportData.Delivery;
import com.traceagile.application.reporting.ReportData.ExecutionSection;
import com.traceagile.application.reporting.ReportData.ExploratorySection;
import com.traceagile.application.reporting.ReportData.Finding;
import com.traceagile.application.reporting.ReportData.Header;
import com.traceagile.application.reporting.ReportData.Indicator;
import com.traceagile.application.reporting.ReportData.KindRow;
import com.traceagile.application.reporting.ReportData.DayRow;
import com.traceagile.application.reporting.ReportData.NfrRow;
import com.traceagile.application.reporting.ReportData.Recommendation;
import com.traceagile.application.reporting.ReportData.UnmetRequirement;
import com.traceagile.application.reporting.ReportData.RequirementRow;
import com.traceagile.application.reporting.ReportData.RiskItem;
import com.traceagile.application.reporting.ReportData.StoryRow;
import com.traceagile.application.reporting.ReportData.Summary;
import com.traceagile.application.reporting.ReportData.FlakyTest;
import com.traceagile.application.reporting.ReportData.TestResultRow;
import com.traceagile.application.reporting.ReportDocument;
import com.traceagile.application.reporting.ReportDocumentBuilder;
import com.traceagile.domain.reporting.ReportSection;
import com.traceagile.domain.reporting.Verdict;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** F-RPT-03 / ADR-0023 : un même rapport rendu en HTML, PDF, Word, Excel, Markdown, CSV et JSON. */
class ReportRenderersTest {

    static final List<ReportSection> ALL = List.of(ReportSection.SUMMARY, ReportSection.DELIVERY, ReportSection.BURNDOWN, ReportSection.COVERAGE,
            ReportSection.EXECUTION, ReportSection.EXPLORATORY, ReportSection.DEFECTS, ReportSection.RISKS, ReportSection.NFR,
            ReportSection.REQUIREMENTS, ReportSection.DEFECT_LIST, ReportSection.TEST_RESULTS, ReportSection.RECOMMENDATION);

    static ReportData data() {
        Map<String, Integer> byStatus = new LinkedHashMap<>();
        byStatus.put("PASSED", 7);
        byStatus.put("FAILED", 2);
        byStatus.put("NOT_RUN", 3);
        Map<String, Integer> severities = new LinkedHashMap<>();
        severities.put("BLOCKER", 1);
        severities.put("CRITICAL", 0);
        severities.put("MAJOR", 2);
        Indicator half = new Indicator(4, 8, 50.0);
        return new ReportData(
                new Header("SHOP", "Boutique", "sprint:SPR-2", "SPR-2 — Sprint 2", "Payer en ligne", "2026-10-12", "2026-10-25", "ACTIVE",
                        "2026-10-20T08:30:00Z", "po"),
                new Summary("Payer en ligne", "NOT_ACHIEVED", "NO_GO", 50.0, 8, 3, 1),
                new Delivery(4, 13, 2, 8, 1, 0, 0, 0, List.of(new StoryRow("REQ-12", "Payer par carte", 5, "DONE", "PLANNED", "SPR-2"))),
                new BurnChart("BURNDOWN", List.of(new BurnPoint("2026-10-12", 13.0, 13.0), new BurnPoint("2026-10-13", 8.0, 6.5),
                        new BurnPoint("2026-10-14", null, 0.0))),
                new CoverageSection(new Indicator(6, 8, 75.0), half, half, half, new Indicator(10, 16, 62.5),
                        List.of(new UnmetRequirement("REQ-14", "Vider le panier", "NOT_COVERED")), List.of(new UnmetRequirement("REQ-12", "Payer par carte", "FAILED"))),
                new ExecutionSection(12, 14, byStatus, List.of(new KindRow("MANUAL", 8, 5, 1, 2, 0), new KindRow("AUTOMATED", 4, 2, 1, 1, 0)),
                        List.of(new DayRow("2026-10-13", 6, 5, 1), new DayRow("2026-10-14", 8, 6, 2)), List.of(new FlakyTest("TC-31", "Paiement API @flaky"))),
                new ExploratorySection(2, 2, 110, 55.0, 70.0, 20.0, 10.0, 1.1, 2, 2, 4.0, List.of("Accessibilité"),
                        List.of(new Finding("Explorer le paiement", "qa1", "Pas de défaut bloquant", "Carte de test expirée"))),
                new DefectSection(3, 1, 2, severities, List.of(new BlockingDefect("DEF-3", "Paiement refusé à tort", "BLOCKER", "IN_PROGRESS"))),
                List.of(new RiskItem("REQ-12", "Payer par carte", "CRITICAL", "FAILED")),
                null, null,
                List.of(new NfrRow("REQ-40", "Temps de réponse du paiement", "PERFORMANCE", "2 s", "1 s", "1,4 s", "THRESHOLD_MET", "NOT_RUN")),
                List.of(new RequirementRow("REQ-12", "Payer par carte", "USER_STORY", "CRITICAL", 3, 3, 2, "FAILED")),
                List.of(new DefectRow("DEF-3", "Paiement refusé à tort", "BLOCKER", "IN_PROGRESS", "REQ-12", "2026-10-14")),
                List.of(new TestResultRow("CMP-2", "TC-7", "Ajouter un produit au panier", "MANUAL", "PASSED", "qa1", "2026-10-13")),
                new Recommendation("NO_GO", List.of("taux de validation 50 % < 95 %", "1 anomalie(s) BLOCKER ouverte(s)")));
    }

    static ReportDocument document() {
        return ReportDocumentBuilder.build(new ReportDocumentBuilder.View("RPT-4", "Bilan de sprint — SPR-2", "Bilan de sprint", ALL, true, true,
                Verdict.GO_WITH_RESERVATIONS, Verdict.NO_GO, "Contournement validé avec le métier", "po", true,
                java.time.Instant.parse("2026-10-25T16:00:00Z")), data());
    }

    @Test
    @DisplayName("ADR-0023 document : sections numérotées dans l'ordre choisi, verdict du PO avec le verdict calculé et son commentaire")
    void document_() {
        ReportDocument doc = document();
        assertThat(doc.sections()).extracting(ReportDocument.Section::title).startsWith("1. Synthèse", "2. Livraison", "3. Burndown / burnup");
        assertThat(doc.verdict()).isEqualTo("GO_WITH_RESERVATIONS");
        assertThat(doc.meta()).extracting(ReportDocument.Meta::value).contains("du 12/10/2026 au 25/10/2026");
        ReportDocument.Callout callout = (ReportDocument.Callout) doc.sections().getFirst().blocks().get(1);
        assertThat(callout.title()).isEqualTo("Objectif partiellement atteint");
        assertThat(callout.text()).contains("Go sous réserve", "modifié par po", "verdict calculé : No go", "Contournement validé");
    }

    @Test
    @DisplayName("F-RPT-03 HTML autonome : sommaire, graphiques en barres CSS, tableaux, échappement")
    void html() {
        String html = new String(new HtmlReportRenderer().render(document(), data()), StandardCharsets.UTF_8);
        assertThat(html).contains("<h1>Bilan de sprint — SPR-2</h1>", "Sommaire", "1. Synthèse", "Recommandation : Go sous réserve",
                "class=\"bar\" style=\"width:100.0%;background:#228BE6\"", "Ajouter un produit au panier");
        assertThat(html).doesNotContain("th:text", "th:each", "xmlns:th");
    }

    @Test
    @DisplayName("F-RPT-03 PDF côté serveur (OpenHTMLtoPDF) : texte accentué lisible, plusieurs pages numérotées")
    void pdf() throws IOException {
        byte[] pdf = new PdfReportRenderer(new HtmlReportRenderer()).render(document(), data());
        assertThat(new String(pdf, 0, 5, StandardCharsets.US_ASCII)).isEqualTo("%PDF-");
        try (PDDocument doc = PDDocument.load(pdf)) {
            String text = new PDFTextStripper().getText(doc);
            assertThat(text).contains("Bilan de sprint — SPR-2", "Synthèse", "Taux de validation", "Objectif partiellement atteint",
                    "Exigences non fonctionnelles", "Page 1 / ");
            assertThat(doc.getNumberOfPages()).isGreaterThan(1);
        }
    }

    @Test
    @DisplayName("ADR-0023 Word : titres stylés (navigation), tableaux, graphiques natifs (burndown, statuts, tentatives, sévérités)")
    void docx() throws IOException {
        byte[] docx = new DocxReportRenderer().render(document(), data());
        try (XWPFDocument doc = new XWPFDocument(new ByteArrayInputStream(docx))) {
            List<String> headings = doc.getParagraphs().stream().filter(p -> "Heading1".equals(p.getStyle())).map(XWPFParagraph::getText).toList();
            assertThat(headings).startsWith("1. Synthèse", "2. Livraison");
            assertThat(doc.getCharts()).hasSizeGreaterThanOrEqualTo(4);
            assertThat(doc.getCharts().getFirst().getCTChart().toString()).contains("Burndown du sprint (points restants)");
            assertThat(doc.getTables()).isNotEmpty();
        }
    }

    @Test
    @DisplayName("ADR-0023 Excel : feuille Synthèse puis une feuille par section, nombres numériques, graphiques reliés aux cellules")
    void xlsx() throws IOException {
        byte[] xlsx = new XlsxReportRenderer().render(document(), data());
        try (XSSFWorkbook workbook = new XSSFWorkbook(new ByteArrayInputStream(xlsx))) {
            assertThat(workbook.getSheetName(0)).isEqualTo("Synthèse");
            assertThat(workbook.getSheetName(1)).isEqualTo("Synthèse 2");
            XSSFSheet execution = workbook.getSheet("Exécution");
            assertThat(execution.getDrawingPatriarch().getCharts()).hasSizeGreaterThanOrEqualTo(2);
            XSSFSheet burndown = workbook.getSheetAt(3);
            assertThat(burndown.getSheetName()).startsWith("Burndown");
            // titre, ligne vide, légende du graphique, en-têtes, puis un jour par ligne ; jour futur sans valeur
            assertThat(burndown.getRow(4).getCell(1).getNumericCellValue()).isEqualTo(13.0);
            assertThat(burndown.getRow(6).getCell(1).getCellType()).isEqualTo(org.apache.poi.ss.usermodel.CellType.BLANK);
            assertThat(burndown.getDrawingPatriarch().getCharts()).hasSize(1);
        }
    }

    @Test
    @DisplayName("ADR-0023 Markdown : titres, listes, tableaux (graphiques en tableaux)")
    void markdown() {
        String md = new String(new MarkdownReportRenderer().render(document(), data()), StandardCharsets.UTF_8);
        assertThat(md).startsWith("# Bilan de sprint — SPR-2").contains("## 1. Synthèse", "| Exigence | Titre | Risque | Statut |",
                "| 13/10 | 8 | 6,5 |", "> **Recommandation : Go sous réserve**");
    }

    @Test
    @DisplayName("F-RPT-03 CSV des données détaillées : BOM, séparateur « ; », un bloc par tableau")
    void csv() {
        String csv = new String(new CsvReportRenderer().render(document(), data()), StandardCharsets.UTF_8);
        assertThat(csv).startsWith("﻿Bilan de sprint — SPR-2").contains("8. Risques résiduels;", "REQ-12;Payer par carte;Critique;En échec");
    }

    @Test
    @DisplayName("F-RPT-03 JSON de l'instantané : verdict retenu, sections, données brutes relisibles")
    void json() throws IOException {
        JsonNode json = new ObjectMapper().readTree(new JsonReportRenderer().render(document(), data()));
        assertThat(json.get("key").asText()).isEqualTo("RPT-4");
        assertThat(json.get("verdict").asText()).isEqualTo("GO_WITH_RESERVATIONS");
        assertThat(json.get("data").get("coverage").get("validation").get("percent").asDouble()).isEqualTo(50.0);
        assertThat(new ObjectMapper().treeToValue(json.get("data"), ReportData.class).summary().verdict()).isEqualTo("NO_GO");
    }
}
