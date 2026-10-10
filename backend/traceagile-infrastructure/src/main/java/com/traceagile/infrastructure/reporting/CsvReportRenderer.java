package com.traceagile.infrastructure.reporting;

import com.traceagile.application.common.Csv;
import com.traceagile.application.reporting.ReportData;
import com.traceagile.application.reporting.ReportDocument;
import com.traceagile.application.reporting.ReportDocument.Chart;
import com.traceagile.application.reporting.ReportDocument.KeyFigures;
import com.traceagile.application.reporting.ReportDocument.Table;
import com.traceagile.application.reporting.ReportRenderer;
import com.traceagile.domain.reporting.ReportFormat;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Component;

/**
 * F-RPT-03 export CSV des données détaillées (ADR-0023) : chaque tableau, indicateur ou graphique
 * devient un bloc « section ; tableau » suivi de ses lignes ; séparateur « ; », UTF-8 avec BOM.
 */
@Component
public class CsvReportRenderer implements ReportRenderer {

    @Override
    public ReportFormat format() {
        return ReportFormat.CSV;
    }

    @Override
    public byte[] render(ReportDocument document, ReportData data) {
        List<List<String>> rows = new ArrayList<>();
        rows.add(List.of(document.title()));
        document.meta().forEach(m -> rows.add(List.of(m.label(), m.value())));
        for (ReportDocument.Section section : document.sections()) {
            for (ReportDocument.Block block : section.blocks()) {
                switch (block) {
                    case KeyFigures k -> {
                        rows.add(List.of());
                        rows.add(List.of(section.title(), "Indicateurs"));
                        k.figures().forEach(f -> rows.add(List.of(f.label(), f.value())));
                    }
                    case Table t -> table(rows, section.title(), t);
                    case Chart c -> table(rows, section.title(), c.asTable());
                    default -> {
                        // paragraphes, encadrés et listes : texte du document, pas des données
                    }
                }
            }
        }
        return Csv.write(rows).getBytes(StandardCharsets.UTF_8);
    }

    private static void table(List<List<String>> rows, String section, Table table) {
        rows.add(List.of());
        rows.add(List.of(section, table.caption() == null ? "" : table.caption()));
        rows.add(table.headers());
        rows.addAll(table.rows());
    }
}
