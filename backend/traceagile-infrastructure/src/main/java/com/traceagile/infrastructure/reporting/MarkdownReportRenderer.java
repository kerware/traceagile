package com.traceagile.infrastructure.reporting;

import com.traceagile.application.reporting.ReportData;
import com.traceagile.application.reporting.ReportDocument;
import com.traceagile.application.reporting.ReportDocument.Block;
import com.traceagile.application.reporting.ReportDocument.Bullets;
import com.traceagile.application.reporting.ReportDocument.Callout;
import com.traceagile.application.reporting.ReportDocument.Chart;
import com.traceagile.application.reporting.ReportDocument.KeyFigures;
import com.traceagile.application.reporting.ReportDocument.Paragraph;
import com.traceagile.application.reporting.ReportDocument.Table;
import com.traceagile.application.reporting.ReportRenderer;
import com.traceagile.domain.reporting.ReportFormat;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;

/** ADR-0023 rapport Markdown (wiki, dépôt) : les graphiques deviennent des tableaux. */
@Component
public class MarkdownReportRenderer implements ReportRenderer {

    @Override
    public ReportFormat format() {
        return ReportFormat.MARKDOWN;
    }

    @Override
    public byte[] render(ReportDocument document, ReportData data) {
        StringBuilder md = new StringBuilder();
        md.append("# ").append(inline(document.title())).append("\n\n");
        document.meta().forEach(m -> md.append("- **").append(inline(m.label())).append("** : ").append(inline(m.value())).append('\n'));
        md.append('\n');
        for (ReportDocument.Section section : document.sections()) {
            md.append("## ").append(inline(section.title())).append("\n\n");
            section.blocks().forEach(block -> block(md, block));
        }
        md.append("---\n\n_").append(inline(document.footer())).append("_\n");
        return md.toString().getBytes(StandardCharsets.UTF_8);
    }

    private static void block(StringBuilder md, Block block) {
        switch (block) {
            case Paragraph p -> md.append(inline(p.text())).append("\n\n");
            case KeyFigures k -> {
                k.figures().forEach(f -> md.append("- ").append(inline(f.label())).append(" : **").append(inline(f.value())).append("**\n"));
                md.append('\n');
            }
            case Callout c -> md.append("> **").append(inline(c.title())).append("**  \n> ").append(inline(c.text())).append("\n\n");
            case Bullets b -> {
                b.items().forEach(i -> md.append("- ").append(inline(i)).append('\n'));
                md.append('\n');
            }
            case Table t -> table(md, t);
            case Chart c -> table(md, c.asTable());
        }
    }

    private static void table(StringBuilder md, Table table) {
        if (table.caption() != null) {
            md.append("**").append(inline(table.caption())).append("**\n\n");
        }
        md.append(row(table.headers())).append(row(table.headers().stream().map(h -> "---").toList()));
        table.rows().forEach(r -> md.append(row(r)));
        md.append('\n');
    }

    private static String row(List<String> cells) {
        return "| " + cells.stream().map(c -> inline(c).replace("|", "\\|")).collect(Collectors.joining(" | ")) + " |\n";
    }

    private static String inline(String text) {
        return text == null ? "" : text.replace("\r", "").replace("\n", " ");
    }
}
