package com.traceagile.application.reporting;

import java.util.List;

/**
 * ADR-0023 document intermédiaire, indépendant du format : chaque {@link ReportRenderer} (HTML, PDF,
 * Word, Excel, Markdown, CSV) le rend à sa manière. Textes déjà formatés (libellés français).
 */
public record ReportDocument(String key, String title, String subtitle, List<Meta> meta, List<Section> sections, String footer, String verdict) {

    public record Meta(String label, String value) {
    }

    public record Section(String id, String title, List<Block> blocks) {
    }

    /** Bloc de contenu d'une section. */
    public sealed interface Block permits Paragraph, KeyFigures, Table, Chart, Callout, Bullets {
    }

    public record Paragraph(String text) implements Block {
    }

    /** Indicateurs mis en avant ; {@code tone} : good, warn, bad, neutral. */
    public record KeyFigures(List<Figure> figures) implements Block {
    }

    public record Figure(String label, String value, String tone) {
    }

    public record Table(String caption, List<String> headers, List<List<String>> rows) implements Block {
    }

    /** Message encadré (verdict, avertissement) ; {@code tone} : good, warn, bad, neutral. */
    public record Callout(String tone, String title, String text) implements Block {
    }

    public record Bullets(List<String> items) implements Block {
    }

    /**
     * Graphique : BAR (barres horizontales, une série), COLUMN (colonnes groupées), LINE (courbes). En
     * HTML / PDF, dessiné en CSS ; en Word / Excel, graphique natif ; ailleurs, tableau.
     */
    public record Chart(String title, ChartType type, List<String> categories, List<Series> series, String unit) implements Block {

        /** Le même graphique en tableau (Markdown, CSV, repli). */
        public Table asTable() {
            List<String> headers = new java.util.ArrayList<>();
            headers.add("");
            series.forEach(s -> headers.add(s.name()));
            List<List<String>> rows = new java.util.ArrayList<>();
            for (int i = 0; i < categories.size(); i++) {
                List<String> row = new java.util.ArrayList<>();
                row.add(categories.get(i));
                for (Series s : series) {
                    Double v = i < s.values().size() ? s.values().get(i) : null;
                    row.add(v == null ? "" : ReportDocumentBuilder.number(v));
                }
                rows.add(row);
            }
            return new Table(title, headers, rows);
        }

        /** Plus grande valeur (échelle des barres). */
        public double max() {
            return series.stream().flatMap(s -> s.values().stream()).filter(java.util.Objects::nonNull).mapToDouble(Double::doubleValue)
                    .max().orElse(0);
        }
    }

    public enum ChartType {
        BAR,
        COLUMN,
        LINE
    }

    /** Série d'un graphique ; {@code color} hexadécimal sans « # ». */
    public record Series(String name, List<Double> values, String color) {
    }
}
