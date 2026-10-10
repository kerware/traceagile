package com.traceagile.application.reporting;

import com.traceagile.application.reporting.ReportData.BurnChart;
import com.traceagile.application.reporting.ReportData.BurnPoint;
import com.traceagile.application.reporting.ReportData.CoverageSection;
import com.traceagile.application.reporting.ReportData.DefectSection;
import com.traceagile.application.reporting.ReportData.Delivery;
import com.traceagile.application.reporting.ReportData.ExecutionSection;
import com.traceagile.application.reporting.ReportData.ExploratorySection;
import com.traceagile.application.reporting.ReportData.Header;
import com.traceagile.application.reporting.ReportData.Indicator;
import com.traceagile.application.reporting.ReportData.RegressionSection;
import com.traceagile.application.reporting.ReportData.UnmetRequirement;
import com.traceagile.application.reporting.ReportData.Summary;
import com.traceagile.application.reporting.ReportDocument.Block;
import com.traceagile.application.reporting.ReportDocument.Bullets;
import com.traceagile.application.reporting.ReportDocument.Callout;
import com.traceagile.application.reporting.ReportDocument.Chart;
import com.traceagile.application.reporting.ReportDocument.ChartType;
import com.traceagile.application.reporting.ReportDocument.Figure;
import com.traceagile.application.reporting.ReportDocument.KeyFigures;
import com.traceagile.application.reporting.ReportDocument.Meta;
import com.traceagile.application.reporting.ReportDocument.Paragraph;
import com.traceagile.application.reporting.ReportDocument.Section;
import com.traceagile.application.reporting.ReportDocument.Series;
import com.traceagile.application.reporting.ReportDocument.Table;
import com.traceagile.domain.reporting.ReportSection;
import com.traceagile.domain.reporting.Verdict;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.function.Function;

/**
 * ADR-0023 transforme les données d'un rapport en document (titres, indicateurs, tableaux,
 * graphiques), en français, dans l'ordre des sections choisies.
 */
public final class ReportDocumentBuilder {

    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.FRANCE);
    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm", Locale.FRANCE)
            .withZone(ZoneId.of("Europe/Paris"));
    private static final String BLUE = "228BE6";
    private static final String GREEN = "40C057";
    private static final String RED = "FA5252";
    private static final String GRAY = "ADB5BD";
    private static final String ORANGE = "FD7E14";

    /**
     * Ce qui entoure les données : clé et titre du rapport, sections, options, verdict retenu.
     *
     * @param verdict        verdict retenu (modifié par le PO ou calculé)
     * @param verdictComment commentaire du PO quand il a modifié le verdict
     */
    public record View(String key, String title, String definitionName, List<ReportSection> sections, boolean includeCharts,
                       boolean includeDetails, Verdict verdict, Verdict computedVerdict, String verdictComment, String verdictBy,
                       boolean frozen, Instant frozenAt) {
    }

    private ReportDocumentBuilder() {
    }

    public static ReportDocument build(View view, ReportData data) {
        Header h = data.header();
        List<Meta> meta = new ArrayList<>();
        meta.add(new Meta("Projet", h.projectKey() + " — " + h.projectName()));
        meta.add(new Meta("Périmètre", h.scopeLabel()));
        if (h.startDate() != null) {
            meta.add(new Meta("Période", "du " + date(h.startDate()) + " au " + date(h.endDate())));
        }
        if (h.status() != null) {
            meta.add(new Meta("Statut", Labels.planning(h.status())));
        }
        meta.add(new Meta("Modèle", view.definitionName()));
        meta.add(new Meta("Généré le", dateTime(h.generatedAt()) + (h.generatedBy() == null ? "" : " par " + h.generatedBy())));
        if (view.frozen()) {
            meta.add(new Meta("Figé le", view.frozenAt() == null ? "oui" : DATE_TIME.format(view.frozenAt())));
        }
        List<Section> sections = new ArrayList<>();
        int number = 1;
        for (ReportSection id : view.sections()) {
            List<Block> blocks = blocks(id, view, data);
            if (blocks != null) {
                sections.add(new Section(id.name(), number++ + ". " + Labels.section(id), blocks));
            }
        }
        String footer = "TraceAgile — " + (view.key() == null ? "aperçu non enregistré" : view.key()) + " — " + h.scopeLabel();
        Verdict verdict = view.verdict() != null ? view.verdict() : view.computedVerdict();
        return new ReportDocument(view.key(), view.title(), h.scopeLabel(), meta, sections, footer, verdict == null ? null : verdict.name());
    }

    /** Blocs d'une section, {@code null} si la section n'a pas été calculée (sans objet pour le périmètre). */
    private static List<Block> blocks(ReportSection id, View view, ReportData d) {
        return switch (id) {
            case SUMMARY -> d.summary() == null ? null : summary(view, d.summary());
            case DELIVERY -> d.delivery() == null ? null : delivery(view, d.delivery());
            case BURNDOWN -> d.burndown() == null ? null : burn(d.burndown());
            case COVERAGE -> d.coverage() == null ? null : coverage(view, d.coverage());
            case EXECUTION -> d.execution() == null ? null : execution(view, d.execution());
            case EXPLORATORY -> d.exploratory() == null ? null : exploratory(view, d.exploratory());
            case DEFECTS -> d.defects() == null ? null : defects(view, d.defects());
            case RISKS -> d.risks() == null ? null : d.risks().isEmpty()
                    ? List.of(new Paragraph("Aucune exigence à risque élevé ou critique non validée."))
                    : List.of(table(null, List.of("Exigence", "Titre", "Risque", "Statut"), d.risks(),
                    r -> List.of(r.key(), r.title(), Labels.risk(r.risk()), Labels.verification(r.status()))));
            case SPRINT_TREND -> d.sprintTrend() == null ? null : sprintTrend(view, d);
            case REGRESSION -> d.regression() == null
                    ? (view.sections().contains(ReportSection.REGRESSION) && d.header().scope().startsWith("release")
                    ? List.of(new Paragraph("Aucune campagne de régression rattachée à la release.")) : null)
                    : regression(d.regression());
            case NFR -> d.nfr() == null ? null : d.nfr().isEmpty() ? List.of(new Paragraph("Aucune exigence non fonctionnelle."))
                    : List.of(table(null, List.of("ENF", "Titre", "Catégorie", "Seuil", "Cible", "Mesuré", "Statut"), d.nfr(),
                    n -> List.of(n.key(), n.title(), Labels.of(n.category()), Labels.of(n.threshold()), Labels.of(n.target()),
                            n.measured() == null ? "non mesuré" : n.measured(), Labels.verification(n.status()))));
            case REQUIREMENTS -> d.requirements() == null ? null
                    : List.of(table(null, List.of("Exigence", "Titre", "Type", "Risque", "Tests", "Exécutés", "Réussis", "Statut"), d.requirements(),
                    r -> List.of(r.key(), r.title(), Labels.requirementType(r.type()), Labels.risk(r.risk()), String.valueOf(r.tests()),
                            String.valueOf(r.executed()), String.valueOf(r.passed()), Labels.verification(r.status()))));
            case DEFECT_LIST -> d.defectList() == null ? null : d.defectList().isEmpty() ? List.of(new Paragraph("Aucune anomalie."))
                    : List.of(table(null, List.of("Anomalie", "Titre", "Sévérité", "Statut", "Exigences", "Créée le"), d.defectList(),
                    x -> List.of(x.key(), x.title(), Labels.severity(x.severity()), Labels.defectStatus(x.status()), Labels.of(x.requirements()),
                            date(x.createdAt()))));
            case TEST_RESULTS -> d.testResults() == null ? null : d.testResults().isEmpty() ? List.of(new Paragraph("Aucun test planifié."))
                    : List.of(table(null, List.of("Campagne", "Test", "Titre", "Type", "Résultat", "Par", "Le"), d.testResults(),
                    x -> List.of(x.campaign(), x.test(), x.title(), Labels.kind(x.kind()), Labels.execution(x.status()), Labels.of(x.executedBy()),
                            date(x.date()))));
            case RECOMMENDATION -> d.recommendation() == null ? null : recommendation(view, d.recommendation().reasons());
        };
    }

    // ---------------------------------------------------------------- sections

    private static List<Block> summary(View view, Summary s) {
        List<Block> blocks = new ArrayList<>();
        blocks.add(new Paragraph("Objectif : " + (s.goal() == null || s.goal().isBlank() ? "non renseigné" : s.goal())));
        Verdict verdict = view.verdict() == null ? Verdict.valueOf(s.verdict()) : view.verdict();
        blocks.add(new Callout(tone(verdict), "Objectif " + Labels.objective(verdict.objective().name()).toLowerCase(Locale.FRANCE),
                verdictText(view, verdict)));
        blocks.add(new KeyFigures(List.of(
                new Figure("Taux de validation", percent(s.validationPercent()), toneOf(s.validationPercent())),
                new Figure("Vélocité", s.velocity() == null ? "—" : s.velocity() + " pts", "neutral"),
                new Figure("Anomalies ouvertes", String.valueOf(s.openDefects()), s.openDefects() == 0 ? "good" : "warn"),
                new Figure("Bloquantes / critiques", String.valueOf(s.openBlockingDefects()), s.openBlockingDefects() == 0 ? "good" : "bad"))));
        return blocks;
    }

    private static String verdictText(View view, Verdict verdict) {
        String text = "Verdict : " + Labels.verdict(verdict.name());
        if (view.computedVerdict() != null && view.verdict() != null && view.verdict() != view.computedVerdict()) {
            text += " (modifié par " + Labels.of(view.verdictBy()) + ", verdict calculé : " + Labels.verdict(view.computedVerdict().name())
                    + ") — " + Labels.of(view.verdictComment());
        }
        return text;
    }

    private static List<Block> delivery(View view, Delivery d) {
        List<Block> blocks = new ArrayList<>();
        blocks.add(new KeyFigures(List.of(
                new Figure("Stories engagées", d.committedStories() + " (" + d.committedPoints() + " pts)", "neutral"),
                new Figure("Terminées", d.doneStories() + " (" + d.donePoints() + " pts)", d.doneStories() == d.committedStories() ? "good" : "warn"),
                new Figure("Acceptées", String.valueOf(d.acceptedStories()), "neutral"),
                new Figure("Reportées", String.valueOf(d.carriedOverStories()), d.carriedOverStories() == 0 ? "good" : "warn"))));
        blocks.add(new Paragraph("Vélocité (points des stories terminées) : " + d.donePoints() + " pts. Renvoyées au backlog : "
                + d.returnedStories() + " ; abandonnées : " + d.droppedStories() + "."));
        if (view.includeDetails() && !d.stories().isEmpty()) {
            blocks.add(table("Stories du périmètre", List.of("Sprint", "Story", "Titre", "Points", "Statut", "Issue"), d.stories(),
                    s -> List.of(s.sprint(), s.key(), s.title(), s.points() == null ? "" : String.valueOf(s.points()), Labels.requirementStatus(s.status()),
                            Labels.outcome(s.outcome()))));
        }
        return blocks;
    }

    private static List<Block> burn(BurnChart chart) {
        boolean down = chart.kind().equals("BURNDOWN");
        List<String> categories = chart.points().stream().map(p -> down ? shortDate(p.label()) : p.label()).toList();
        Chart c = new Chart(down ? "Burndown du sprint (points restants)" : "Burnup de la release (points terminés cumulés)", ChartType.LINE,
                categories, List.of(new Series(down ? "Restant" : "Terminé", chart.points().stream().map(BurnPoint::actual).toList(), BLUE),
                new Series(down ? "Idéal" : "Total engagé", chart.points().stream().map(BurnPoint::reference).toList(), GRAY)), "pts");
        return List.of(c);
    }

    private static List<Block> coverage(View view, CoverageSection c) {
        List<Block> blocks = new ArrayList<>();
        blocks.add(new KeyFigures(List.of(
                figure("Couverture de conception", c.design()), figure("Couverture des critères", c.criteria()),
                figure("Couverture d'exécution", c.execution()), figure("Taux de validation", c.validation()),
                figure("Couverture pondérée par le risque", c.riskWeighted()))));
        if (view.includeCharts()) {
            List<Indicator> all = List.of(c.design(), c.criteria(), c.execution(), c.validation(), c.riskWeighted());
            blocks.add(new Chart("Indicateurs de couverture (%)", ChartType.BAR,
                    List.of("Conception", "Critères", "Exécution", "Validation", "Pondérée risque"),
                    List.of(new Series("%", all.stream().map(i -> i.percent() == null ? 0.0 : i.percent()).toList(), BLUE)), "%"));
        }
        blocks.add(refs("Exigences non couvertes", c.uncovered()));
        blocks.add(refs("Exigences en échec ou bloquées", c.failing()));
        return blocks;
    }

    private static Block refs(String caption, List<UnmetRequirement> refs) {
        if (refs.isEmpty()) {
            return new Paragraph(caption + " : aucune.");
        }
        return table(caption, List.of("Exigence", "Titre", "Statut"), refs, r -> List.of(r.key(), r.title(), Labels.verification(r.status())));
    }

    private static List<Block> execution(View view, ExecutionSection e) {
        List<Block> blocks = new ArrayList<>();
        int passed = e.byStatus().getOrDefault("PASSED", 0);
        int notRun = e.byStatus().getOrDefault("NOT_RUN", 0);
        int executed = e.items() - notRun;
        blocks.add(new KeyFigures(List.of(
                new Figure("Tests planifiés", String.valueOf(e.items()), "neutral"),
                new Figure("Exécutés", String.valueOf(executed), executed == e.items() ? "good" : "warn"),
                new Figure("Taux de réussite", executed == 0 ? "—" : percent(passed * 100.0 / executed), toneOf(executed == 0 ? null : passed * 100.0 / executed)),
                new Figure("Tentatives", String.valueOf(e.attempts()), "neutral"))));
        if (view.includeCharts() && !e.byStatus().isEmpty()) {
            List<String> statuses = new ArrayList<>(e.byStatus().keySet());
            blocks.add(new Chart("Dernier résultat par statut", ChartType.BAR, statuses.stream().map(Labels::execution).toList(),
                    List.of(new Series("Tests", statuses.stream().map(s -> (double) e.byStatus().get(s)).toList(), BLUE)), "tests"));
        }
        if (!e.byKind().isEmpty()) {
            blocks.add(table("Par type de test", List.of("Type", "Planifiés", "Réussis", "En échec", "Non exécutés", "Autres"), e.byKind(),
                    k -> List.of(Labels.kind(k.kind()), String.valueOf(k.total()), String.valueOf(k.passed()), String.valueOf(k.failed()),
                            String.valueOf(k.notRun()), String.valueOf(k.other()))));
        }
        if (view.includeCharts() && !e.attemptsByDay().isEmpty()) {
            blocks.add(new Chart("Tendance des tentatives", ChartType.COLUMN, e.attemptsByDay().stream().map(x -> shortDate(x.date())).toList(),
                    List.of(new Series("Réussies", e.attemptsByDay().stream().map(x -> (double) x.passed()).toList(), GREEN),
                            new Series("En échec", e.attemptsByDay().stream().map(x -> (double) x.failed()).toList(), RED),
                            new Series("Total", e.attemptsByDay().stream().map(x -> (double) x.attempts()).toList(), GRAY)), "tentatives"));
        }
        blocks.add(e.flaky().isEmpty() ? new Paragraph("Tests instables : aucun.")
                : table("Tests instables (F-EXE-11)", List.of("Test", "Titre"), e.flaky(), t -> List.of(t.key(), t.title())));
        return blocks;
    }

    private static List<Block> exploratory(View view, ExploratorySection x) {
        List<Block> blocks = new ArrayList<>();
        blocks.add(new KeyFigures(List.of(
                new Figure("Sessions", x.sessions() + " (" + x.debriefed() + " débriefées)", "neutral"),
                new Figure("Durée totale", x.totalMinutes() + " min", "neutral"),
                new Figure("Chartes exécutées", x.chartersExecuted() + " / " + x.chartersPlanned(), "neutral"),
                new Figure("Anomalies par heure", x.defectsPerHour() == null ? "—" : number(x.defectsPerHour()), "neutral"))));
        blocks.add(new Paragraph("Répartition TBS : test " + percent(x.testPct()) + ", investigation des bugs " + percent(x.bugPct())
                + ", mise en place " + percent(x.setupPct()) + ". Confiance moyenne : "
                + (x.averageConfidence() == null ? "—" : number(x.averageConfidence()) + " / 5") + "."));
        if (x.neverExploredAreas() != null && !x.neverExploredAreas().isEmpty()) {
            blocks.add(new Paragraph("Zones jamais explorées : " + String.join(", ", x.neverExploredAreas()) + "."));
        }
        if (!x.findings().isEmpty()) {
            blocks.add(view.includeDetails()
                    ? table("Principaux constats des débriefings", List.of("Charte", "Testeur", "Résultats", "Obstacles"), x.findings(),
                    f -> List.of(f.charter(), Labels.of(f.tester()), Labels.of(f.results()), Labels.of(f.obstacles())))
                    : new Bullets(x.findings().stream().filter(f -> f.results() != null).map(f -> f.charter() + " : " + f.results()).limit(5).toList()));
        }
        return blocks;
    }

    private static List<Block> defects(View view, DefectSection d) {
        List<Block> blocks = new ArrayList<>();
        blocks.add(new KeyFigures(List.of(
                new Figure("Créées", String.valueOf(d.created()), "neutral"),
                new Figure("Résolues", String.valueOf(d.resolved()), "neutral"),
                new Figure("Ouvertes", String.valueOf(d.open()), d.open() == 0 ? "good" : "warn"),
                new Figure("Bloquantes restantes", String.valueOf(d.blocking().size()), d.blocking().isEmpty() ? "good" : "bad"))));
        if (view.includeCharts()) {
            List<String> severities = new ArrayList<>(d.openBySeverity().keySet());
            blocks.add(new Chart("Anomalies ouvertes par sévérité", ChartType.BAR, severities.stream().map(Labels::severity).toList(),
                    List.of(new Series("Ouvertes", severities.stream().map(s -> (double) d.openBySeverity().get(s)).toList(), ORANGE)), "anomalies"));
        } else {
            blocks.add(table("Anomalies ouvertes par sévérité", List.of("Sévérité", "Ouvertes"), new ArrayList<>(d.openBySeverity().entrySet()),
                    (Map.Entry<String, Integer> e) -> List.of(Labels.severity(e.getKey()), String.valueOf(e.getValue()))));
        }
        blocks.add(d.blocking().isEmpty() ? new Paragraph("Anomalies bloquantes ou critiques restantes : aucune.")
                : table("Anomalies bloquantes ou critiques restantes", List.of("Anomalie", "Titre", "Sévérité", "Statut"), d.blocking(),
                x -> List.of(x.key(), x.title(), Labels.severity(x.severity()), Labels.defectStatus(x.status()))));
        return blocks;
    }

    private static List<Block> sprintTrend(View view, ReportData d) {
        List<Block> blocks = new ArrayList<>();
        if (d.sprintTrend().isEmpty()) {
            return List.of(new Paragraph("Aucun sprint."));
        }
        if (view.includeCharts()) {
            blocks.add(new Chart("Points engagés et terminés par sprint", ChartType.COLUMN, d.sprintTrend().stream().map(r -> r.key()).toList(),
                    List.of(new Series("Engagés", d.sprintTrend().stream().map(r -> (double) r.committedPoints()).toList(), GRAY),
                            new Series("Terminés", d.sprintTrend().stream().map(r -> (double) r.donePoints()).toList(), BLUE)), "pts"));
        }
        if (d.burndown() != null && !view.sections().contains(ReportSection.BURNDOWN)) {
            blocks.addAll(burn(d.burndown()));
        }
        blocks.add(table(null, List.of("Sprint", "Nom", "Statut", "Engagés", "Terminés", "Validation", "Anomalies créées", "Anomalies fermées"),
                d.sprintTrend(), r -> List.of(r.key(), r.name(), Labels.planning(r.status()), String.valueOf(r.committedPoints()),
                        String.valueOf(r.donePoints()), percent(r.validationPercent()), String.valueOf(r.defectsCreated()), String.valueOf(r.defectsClosed()))));
        return blocks;
    }

    private static List<Block> regression(RegressionSection r) {
        return List.of(new Paragraph(r.campaignKey() + " « " + r.name() + " » — " + Labels.campaign(r.status())),
                new KeyFigures(List.of(new Figure("Tests", String.valueOf(r.total()), "neutral"),
                        new Figure("Réussis", String.valueOf(r.passed()), "good"),
                        new Figure("En échec", String.valueOf(r.failed()), r.failed() == 0 ? "good" : "bad"),
                        new Figure("Taux de réussite", percent(r.passRate()), toneOf(r.passRate())))));
    }

    private static List<Block> recommendation(View view, List<String> reasons) {
        Verdict verdict = view.verdict() == null ? view.computedVerdict() : view.verdict();
        List<Block> blocks = new ArrayList<>();
        blocks.add(new Callout(tone(verdict), "Recommandation : " + Labels.verdict(verdict.name()), verdictText(view, verdict)));
        blocks.add(new Bullets(reasons));
        return blocks;
    }

    // ---------------------------------------------------------------- outils

    private static <T> Table table(String caption, List<String> headers, List<T> rows, Function<T, List<String>> row) {
        return new Table(caption, headers, rows.stream().map(row).map(cells -> cells.stream().map(c -> c == null ? "" : c).toList()).toList());
    }

    private static Figure figure(String label, Indicator indicator) {
        String value = percent(indicator.percent());
        if (indicator.denominator() > 0) {
            value += " (" + number(indicator.numerator()) + " / " + number(indicator.denominator()) + ")";
        }
        return new Figure(label, value, toneOf(indicator.percent()));
    }

    private static String tone(Verdict verdict) {
        return switch (verdict) {
            case GO -> "good";
            case GO_WITH_RESERVATIONS -> "warn";
            case NO_GO -> "bad";
        };
    }

    private static String toneOf(Double percent) {
        if (percent == null) {
            return "neutral";
        }
        return percent >= 95 ? "good" : percent >= 80 ? "warn" : "bad";
    }

    static String percent(Double value) {
        return value == null ? "—" : number(value) + " %";
    }

    /** Nombre au format français, sans décimale inutile. */
    public static String number(double value) {
        double rounded = Math.round(value * 10) / 10.0;
        return rounded == Math.rint(rounded) ? String.valueOf((long) rounded) : String.valueOf(rounded).replace('.', ',');
    }

    private static String date(String iso) {
        return iso == null ? "" : LocalDate.parse(iso).format(DATE);
    }

    private static String shortDate(String iso) {
        return LocalDate.parse(iso).format(DateTimeFormatter.ofPattern("dd/MM", Locale.FRANCE));
    }

    private static String dateTime(String iso) {
        return iso == null ? "" : DATE_TIME.format(Instant.parse(iso));
    }
}
