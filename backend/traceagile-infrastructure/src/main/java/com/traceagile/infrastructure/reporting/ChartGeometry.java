package com.traceagile.infrastructure.reporting;

import com.traceagile.application.reporting.ReportDocument.Chart;
import com.traceagile.application.reporting.ReportDocument.Series;
import com.traceagile.application.reporting.ReportDocumentBuilder;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * ADR-0023 géométrie des graphiques HTML / PDF dessinés en CSS (barres, colonnes) : pas de script ni
 * d'image, rendu identique dans le navigateur et dans OpenHTMLtoPDF. Utilisé par le gabarit.
 */
public class ChartGeometry {

    static final int COLUMN_HEIGHT = 140;

    public record Bar(String label, String value, String width, String color) {
    }

    public record Column(String value, int height, String color) {
    }

    public record ColumnGroup(String label, List<Column> columns) {
    }

    /** Barres horizontales de la première série, largeur en % de la plus grande valeur. */
    public List<Bar> bars(Chart chart) {
        double max = chart.max();
        Series series = chart.series().getFirst();
        List<Bar> bars = new ArrayList<>();
        for (int i = 0; i < chart.categories().size(); i++) {
            Double v = i < series.values().size() ? series.values().get(i) : null;
            double value = v == null ? 0 : v;
            String width = String.format(Locale.ROOT, "%.1f%%", max <= 0 ? 0 : value * 100 / max);
            bars.add(new Bar(chart.categories().get(i), ReportDocumentBuilder.number(value), width, series.color()));
        }
        return bars;
    }

    /** Colonnes groupées par catégorie (une par série) ; une valeur absente donne une colonne vide. */
    public List<ColumnGroup> columns(Chart chart) {
        double max = chart.max();
        List<ColumnGroup> groups = new ArrayList<>();
        for (int i = 0; i < chart.categories().size(); i++) {
            List<Column> columns = new ArrayList<>();
            for (Series series : chart.series()) {
                Double v = i < series.values().size() ? series.values().get(i) : null;
                int height = v == null || max <= 0 ? 0 : (int) Math.max(1, Math.round(v * COLUMN_HEIGHT / max));
                columns.add(new Column(v == null ? "" : series.name() + " : " + ReportDocumentBuilder.number(v), height, series.color()));
            }
            groups.add(new ColumnGroup(chart.categories().get(i), columns));
        }
        return groups;
    }
}
