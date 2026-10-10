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
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.ss.util.WorkbookUtil;
import org.apache.poi.xddf.usermodel.chart.XDDFDataSource;
import org.apache.poi.xddf.usermodel.chart.XDDFDataSourcesFactory;
import org.apache.poi.xddf.usermodel.chart.XDDFNumericalDataSource;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFChart;
import org.apache.poi.xssf.usermodel.XSSFClientAnchor;
import org.apache.poi.xssf.usermodel.XSSFDrawing;
import org.apache.poi.xssf.usermodel.XSSFFont;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Component;

/**
 * ADR-0023 classeur Excel (.xlsx) : feuille « Synthèse » (en-tête et sommaire) puis une feuille par
 * section ; les valeurs des tableaux et graphiques sont des nombres quand c'est possible ; les
 * graphiques natifs pointent sur leurs cellules.
 */
@Component
public class XlsxReportRenderer implements ReportRenderer {

    private static final int CHART_ROWS = 16;
    private static final int CHART_COLUMNS = 8;

    @Override
    public ReportFormat format() {
        return ReportFormat.XLSX;
    }

    private record Styles(XSSFCellStyle title, XSSFCellStyle bold, XSSFCellStyle header, XSSFCellStyle section) {
    }

    @Override
    public byte[] render(ReportDocument document, ReportData data) {
        try (XSSFWorkbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Styles styles = styles(workbook);
            Set<String> names = new HashSet<>();
            XSSFSheet summary = workbook.createSheet(sheetName("Synthèse", names));
            int r = 0;
            write(summary, r++, styles.title(), document.title());
            write(summary, r++, null, document.subtitle());
            r++;
            for (ReportDocument.Meta m : document.meta()) {
                XSSFRow row = summary.createRow(r++);
                cell(row, 0, m.label(), styles.bold());
                cell(row, 1, m.value(), null);
            }
            r++;
            write(summary, r++, styles.section(), "Sommaire");
            for (ReportDocument.Section section : document.sections()) {
                write(summary, r++, null, section.title());
            }
            summary.setColumnWidth(0, 26 * 256);
            summary.setColumnWidth(1, 60 * 256);

            for (ReportDocument.Section section : document.sections()) {
                XSSFSheet sheet = workbook.createSheet(sheetName(section.title(), names));
                int row = 0;
                write(sheet, row++, styles.title(), section.title());
                row++;
                for (Block block : section.blocks()) {
                    row = block(sheet, row, block, styles) + 1;
                }
                for (int c = 0; c < 8; c++) {
                    sheet.setColumnWidth(c, (c == 1 ? 40 : 16) * 256);
                }
            }
            workbook.write(out);
            return out.toByteArray();
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    /** Écrit un bloc à partir de la ligne {@code row} ; renvoie la ligne suivante. */
    private static int block(XSSFSheet sheet, int row, Block block, Styles styles) {
        return switch (block) {
            case Paragraph p -> {
                write(sheet, row, null, p.text());
                yield row + 1;
            }
            case Callout c -> {
                write(sheet, row, styles.bold(), c.title());
                write(sheet, row + 1, null, c.text());
                yield row + 2;
            }
            case Bullets b -> {
                int r = row;
                for (String item : b.items()) {
                    write(sheet, r++, null, "• " + item);
                }
                yield r;
            }
            case KeyFigures k -> {
                int r = row;
                for (ReportDocument.Figure f : k.figures()) {
                    XSSFRow line = sheet.createRow(r++);
                    cell(line, 0, f.label(), styles.bold());
                    cell(line, 1, f.value(), null);
                }
                yield r;
            }
            case Table t -> table(sheet, row, t, styles);
            case Chart c -> {
                int start = row;
                int end = table(sheet, row, c.asTable(), styles);
                XSSFDrawing drawing = sheet.createDrawingPatriarch();
                XSSFClientAnchor anchor = drawing.createAnchor(0, 0, 0, 0, c.series().size() + 2, start, c.series().size() + 2 + CHART_COLUMNS,
                        start + CHART_ROWS);
                XSSFChart chart = drawing.createChart(anchor);
                int first = start + (c.title() == null ? 1 : 2);
                int last = first + c.categories().size() - 1;
                XDDFDataSource<String> categories = XDDFDataSourcesFactory.fromStringCellRange(sheet, new CellRangeAddress(first, last, 0, 0));
                List<XDDFNumericalDataSource<Double>> series = new ArrayList<>();
                for (int i = 0; i < c.series().size(); i++) {
                    series.add(XDDFDataSourcesFactory.fromNumericCellRange(sheet, new CellRangeAddress(first, last, i + 1, i + 1)));
                }
                OfficeCharts.plot(chart, c, categories, series);
                yield Math.max(end, start + CHART_ROWS + 1);
            }
        };
    }

    private static int table(XSSFSheet sheet, int row, Table t, Styles styles) {
        int r = row;
        if (t.caption() != null) {
            write(sheet, r++, styles.bold(), t.caption());
        }
        XSSFRow header = sheet.createRow(r++);
        for (int c = 0; c < t.headers().size(); c++) {
            cell(header, c, t.headers().get(c), styles.header());
        }
        for (List<String> values : t.rows()) {
            XSSFRow line = sheet.getRow(r) == null ? sheet.createRow(r) : sheet.getRow(r);
            r++;
            for (int c = 0; c < values.size(); c++) {
                cell(line, c, values.get(c), null);
            }
        }
        return r;
    }

    // ---------------------------------------------------------------- outils

    private static void write(XSSFSheet sheet, int row, XSSFCellStyle style, String text) {
        XSSFRow line = sheet.getRow(row) == null ? sheet.createRow(row) : sheet.getRow(row);
        cell(line, 0, text, style);
    }

    /** Une valeur numérique (« 12 », « 87,5 ») devient un nombre, le reste du texte. */
    private static void cell(XSSFRow row, int column, String value, XSSFCellStyle style) {
        XSSFCell cell = row.createCell(column);
        Double number = number(value);
        if (number != null) {
            cell.setCellValue(number);
        } else if (value != null && !value.isEmpty()) {
            cell.setCellValue(value);
        }
        if (style != null) {
            cell.setCellStyle(style);
        }
    }

    static Double number(String value) {
        if (value == null || !value.matches("-?\\d+(,\\d+)?")) {
            return null;
        }
        return Double.parseDouble(value.replace(',', '.'));
    }

    /** Nom de feuille Excel valide et unique (31 caractères, sans « []:*?/\ »). */
    static String sheetName(String title, Set<String> used) {
        String base = WorkbookUtil.createSafeSheetName(title.replaceFirst("^\\d+\\.\\s*", ""));
        base = base.length() > 28 ? base.substring(0, 28) : base;
        String name = base;
        for (int n = 2; used.contains(name.toLowerCase()); n++) {
            name = base + " " + n;
        }
        used.add(name.toLowerCase());
        return name;
    }

    private static Styles styles(XSSFWorkbook workbook) {
        XSSFFont titleFont = workbook.createFont();
        titleFont.setBold(true);
        titleFont.setFontHeightInPoints((short) 14);
        XSSFCellStyle title = workbook.createCellStyle();
        title.setFont(titleFont);
        XSSFFont boldFont = workbook.createFont();
        boldFont.setBold(true);
        XSSFCellStyle bold = workbook.createCellStyle();
        bold.setFont(boldFont);
        XSSFCellStyle header = workbook.createCellStyle();
        header.setFont(boldFont);
        header.setFillForegroundColor(IndexedColors.PALE_BLUE.getIndex());
        header.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        XSSFFont sectionFont = workbook.createFont();
        sectionFont.setBold(true);
        sectionFont.setUnderline(Font.U_SINGLE);
        XSSFCellStyle section = workbook.createCellStyle();
        section.setFont(sectionFont);
        return new Styles(title, bold, header, section);
    }
}
