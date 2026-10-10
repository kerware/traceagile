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
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.util.Units;
import org.apache.poi.xddf.usermodel.chart.XDDFDataSource;
import org.apache.poi.xddf.usermodel.chart.XDDFDataSourcesFactory;
import org.apache.poi.xddf.usermodel.chart.XDDFNumericalDataSource;
import org.apache.poi.xwpf.usermodel.ParagraphAlignment;
import org.apache.poi.xwpf.usermodel.XWPFChart;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFRun;
import org.apache.poi.xwpf.usermodel.XWPFStyle;
import org.apache.poi.xwpf.usermodel.XWPFStyles;
import org.apache.poi.xwpf.usermodel.XWPFTable;
import org.apache.poi.xwpf.usermodel.XWPFTableCell;
import org.apache.poi.xwpf.usermodel.XWPFTableRow;
import org.openxmlformats.schemas.wordprocessingml.x2006.main.CTDecimalNumber;
import org.openxmlformats.schemas.wordprocessingml.x2006.main.CTString;
import org.openxmlformats.schemas.wordprocessingml.x2006.main.CTStyle;
import org.openxmlformats.schemas.wordprocessingml.x2006.main.STStyleType;
import org.openxmlformats.schemas.wordprocessingml.x2006.main.STTblWidth;
import org.springframework.stereotype.Component;

/**
 * ADR-0023 rapport Word (.docx, Apache POI) : styles de titres (volet de navigation, table des
 * matières Word), tableaux, indicateurs, graphiques natifs modifiables.
 */
@Component
public class DocxReportRenderer implements ReportRenderer {

    private static final Map<String, String> TONES = Map.of("good", "EBFBEE", "warn", "FFF4E6", "bad", "FFF5F5", "neutral", "E7F5FF");
    private static final String HEADER_FILL = "E7F5FF";
    private static final int CHART_WIDTH = 15 * Units.EMU_PER_CENTIMETER;
    private static final int CHART_HEIGHT = 7 * Units.EMU_PER_CENTIMETER;

    @Override
    public ReportFormat format() {
        return ReportFormat.DOCX;
    }

    @Override
    public byte[] render(ReportDocument document, ReportData data) {
        try (XWPFDocument doc = new XWPFDocument(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            headingStyles(doc);
            text(doc, "TRACEAGILE", 9, true, "1C7ED6", null);
            heading(doc, document.title(), "Title");
            text(doc, document.subtitle(), 12, false, "495057", null);
            XWPFTable meta = doc.createTable(document.meta().size(), 2);
            for (int i = 0; i < document.meta().size(); i++) {
                cell(meta.getRow(i).getCell(0), document.meta().get(i).label(), true, null);
                cell(meta.getRow(i).getCell(1), document.meta().get(i).value(), false, null);
            }
            borderless(meta);
            for (ReportDocument.Section section : document.sections()) {
                heading(doc, section.title(), "Heading1");
                for (Block block : section.blocks()) {
                    block(doc, block);
                }
            }
            text(doc, document.footer(), 8, false, "868E96", null);
            doc.write(out);
            return out.toByteArray();
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    private void block(XWPFDocument doc, Block block) throws IOException {
        switch (block) {
            case Paragraph p -> text(doc, p.text(), 10, false, null, null);
            case KeyFigures k -> {
                XWPFTable table = doc.createTable(2, k.figures().size());
                for (int i = 0; i < k.figures().size(); i++) {
                    ReportDocument.Figure f = k.figures().get(i);
                    cell(table.getRow(0).getCell(i), f.value(), true, TONES.getOrDefault(f.tone(), null));
                    cell(table.getRow(1).getCell(i), f.label(), false, null);
                }
                fullWidth(table);
                spacer(doc);
            }
            case Callout c -> {
                XWPFTable table = doc.createTable(1, 1);
                XWPFTableCell cell = table.getRow(0).getCell(0);
                cell(cell, c.title(), true, TONES.getOrDefault(c.tone(), null));
                XWPFRun run = cell.addParagraph().createRun();
                run.setText(c.text());
                run.setFontSize(10);
                fullWidth(table);
                spacer(doc);
            }
            case Bullets b -> b.items().forEach(item -> text(doc, "•  " + item, 10, false, null, 360));
            case Table t -> table(doc, t);
            case Chart c -> chart(doc, c);
        }
    }

    private static void table(XWPFDocument doc, Table t) {
        if (t.caption() != null) {
            text(doc, t.caption(), 10, true, null, null);
        }
        XWPFTable table = doc.createTable(t.rows().size() + 1, t.headers().size());
        for (int c = 0; c < t.headers().size(); c++) {
            cell(table.getRow(0).getCell(c), t.headers().get(c), true, HEADER_FILL);
        }
        table.getRow(0).setRepeatHeader(true);
        for (int r = 0; r < t.rows().size(); r++) {
            XWPFTableRow row = table.getRow(r + 1);
            List<String> cells = t.rows().get(r);
            for (int c = 0; c < t.headers().size(); c++) {
                cell(row.getCell(c), c < cells.size() ? cells.get(c) : "", false, null);
            }
        }
        fullWidth(table);
        spacer(doc);
    }

    /** Graphique natif : les données sont dans le classeur incorporé (« Modifier les données » dans Word). */
    private static void chart(XWPFDocument doc, Chart c) throws IOException {
        XWPFChart chart;
        try {
            chart = doc.createChart(CHART_WIDTH, CHART_HEIGHT);
        } catch (org.apache.poi.openxml4j.exceptions.InvalidFormatException e) {
            throw new IOException(e);
        }
        int n = c.categories().size();
        XDDFDataSource<String> categories = XDDFDataSourcesFactory.fromArray(c.categories().toArray(new String[0]),
                chart.formatRange(new CellRangeAddress(1, n, 0, 0)), 0);
        List<XDDFNumericalDataSource<Double>> series = new ArrayList<>();
        for (int i = 0; i < c.series().size(); i++) {
            series.add(XDDFDataSourcesFactory.fromArray(OfficeCharts.values(c, c.series().get(i)),
                    chart.formatRange(new CellRangeAddress(1, n, i + 1, i + 1)), i + 1));
        }
        OfficeCharts.plot(chart, c, categories, series);
        spacer(doc);
    }

    // ---------------------------------------------------------------- mise en forme

    private static void headingStyles(XWPFDocument doc) {
        XWPFStyles styles = doc.createStyles();
        style(styles, "Title", "Titre", 0, 44, "212529");
        style(styles, "Heading1", "Titre 1", 1, 28, "1864AB");
    }

    private static void style(XWPFStyles styles, String id, String name, int level, int halfPoints, String color) {
        CTStyle style = CTStyle.Factory.newInstance();
        style.setStyleId(id);
        style.setType(STStyleType.PARAGRAPH);
        CTString styleName = CTString.Factory.newInstance();
        styleName.setVal(name);
        style.setName(styleName);
        style.addNewQFormat();
        style.addNewPPr().addNewSpacing().setBefore(BigInteger.valueOf(level == 0 ? 0 : 240));
        if (level > 0) {
            CTDecimalNumber outline = CTDecimalNumber.Factory.newInstance();
            outline.setVal(BigInteger.valueOf(level - 1));
            style.getPPr().setOutlineLvl(outline);
            style.getPPr().addNewKeepNext();
        }
        var rPr = style.addNewRPr();
        rPr.addNewB();
        rPr.addNewSz().setVal(BigInteger.valueOf(halfPoints));
        rPr.addNewColor().setVal(color);
        styles.addStyle(new XWPFStyle(style));
    }

    private static void heading(XWPFDocument doc, String text, String style) {
        XWPFParagraph p = doc.createParagraph();
        p.setStyle(style);
        p.createRun().setText(text);
    }

    private static void text(XWPFDocument doc, String text, int size, boolean bold, String color, Integer indent) {
        XWPFParagraph p = doc.createParagraph();
        p.setSpacingAfter(80);
        if (indent != null) {
            p.setIndentationLeft(indent);
        }
        XWPFRun run = p.createRun();
        run.setText(text == null ? "" : text);
        run.setFontSize(size);
        run.setBold(bold);
        if (color != null) {
            run.setColor(color);
        }
    }

    private static void cell(XWPFTableCell cell, String text, boolean bold, String fill) {
        XWPFParagraph p = cell.getParagraphs().getFirst();
        p.setAlignment(ParagraphAlignment.LEFT);
        p.setSpacingAfter(0);
        XWPFRun run = p.createRun();
        run.setText(text == null ? "" : text);
        run.setFontSize(9);
        run.setBold(bold);
        if (fill != null) {
            cell.setColor(fill);
        }
    }

    private static void fullWidth(XWPFTable table) {
        table.setWidth("100%");
        table.getCTTbl().getTblPr().getTblW().setType(STTblWidth.PCT);
    }

    private static void borderless(XWPFTable table) {
        table.removeBorders();
    }

    private static void spacer(XWPFDocument doc) {
        doc.createParagraph().setSpacingAfter(60);
    }
}
