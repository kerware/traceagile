package com.traceagile.api.traceability;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.traceagile.application.common.Csv;
import com.traceagile.application.traceability.TraceabilityService.Matrix;
import com.traceagile.application.traceability.TraceabilityService.MatrixCell;
import com.traceagile.application.traceability.TraceabilityService.MatrixColumn;
import com.traceagile.application.traceability.TraceabilityService.MatrixRow;
import com.traceagile.domain.traceability.LinkType;
import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

/**
 * F-TRA-08 export de la matrice. Cellule : type de lien abrégé (V, PV, R), « ! » si suspect, puis
 * le dernier résultat. CSV : une ligne par exigence, une colonne par test. PDF : A4 paysage, tests
 * répartis par tranches de {@value #PDF_COLUMNS} colonnes (ADR-0014).
 */
@Component
public class MatrixExporter {

    static final int PDF_COLUMNS = 18;

    public static String code(LinkType type) {
        return switch (type) {
            case VERIFIES -> "V";
            case PARTIALLY_VERIFIES -> "PV";
            case RELATES_TO -> "R";
        };
    }

    static String cell(MatrixCell cell) {
        if (cell == null) {
            return "";
        }
        String text = code(cell.link().getLinkType()) + (cell.link().isSuspect() ? " !" : "");
        return cell.lastResult() == null ? text : text + " " + cell.lastResult().name();
    }

    private static Map<String, MatrixCell> index(Matrix matrix) {
        Map<String, MatrixCell> cells = new HashMap<>();
        matrix.cells().forEach(c -> cells.put(c.requirement().getKey() + "|" + c.test().getKey(), c));
        return cells;
    }

    public String csv(Matrix matrix) {
        Map<String, MatrixCell> cells = index(matrix);
        List<List<String>> rows = new ArrayList<>();
        List<String> header = new ArrayList<>(List.of("Exigence", "Titre", "Type", "Vérification"));
        matrix.columns().forEach(c -> header.add(c.test().getKey()));
        rows.add(header);
        for (MatrixRow row : matrix.rows()) {
            List<String> line = new ArrayList<>(List.of(row.requirement().getKey(), "  ".repeat(row.depth()) + row.requirement().getTitle(),
                    row.requirement().getType().name(), row.status().name()));
            matrix.columns().forEach(c -> line.add(cell(cells.get(row.requirement().getKey() + "|" + c.test().getKey()))));
            rows.add(line);
        }
        return Csv.write(rows);
    }

    public byte[] pdf(Matrix matrix, String projectKey) {
        Map<String, MatrixCell> cells = index(matrix);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4.rotate(), 24, 24, 24, 24);
        PdfWriter.getInstance(document, out);
        document.open();
        Font title = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 13);
        Font small = FontFactory.getFont(FontFactory.HELVETICA, 6.5f);
        Font smallBold = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 6.5f);
        List<MatrixColumn> columns = matrix.columns();
        int slices = Math.max(1, (columns.size() + PDF_COLUMNS - 1) / PDF_COLUMNS);
        for (int slice = 0; slice < slices; slice++) {
            if (slice > 0) {
                document.newPage();
            }
            List<MatrixColumn> part = columns.subList(slice * PDF_COLUMNS, Math.min(columns.size(), (slice + 1) * PDF_COLUMNS));
            document.add(new Paragraph("Matrice de traçabilité — " + projectKey + " (" + matrix.scope() + ")"
                    + (slices > 1 ? " — tests " + (slice + 1) + "/" + slices : ""), title));
            document.add(new Paragraph("V : vérifie · PV : vérifie partiellement · R : informatif · ! : suspect", small));
            PdfPTable table = new PdfPTable(2 + part.size());
            table.setWidthPercentage(100);
            table.setSpacingBefore(6);
            float[] widths = new float[2 + part.size()];
            widths[0] = 3.2f;
            widths[1] = 10f;
            for (int i = 2; i < widths.length; i++) {
                widths[i] = 1.6f;
            }
            table.setWidths(widths);
            table.setHeaderRows(1);
            table.addCell(header("Exigence", smallBold));
            table.addCell(header("Titre", smallBold));
            part.forEach(c -> table.addCell(header(c.test().getKey(), smallBold)));
            for (MatrixRow row : matrix.rows()) {
                table.addCell(new PdfPCell(new Phrase(row.requirement().getKey(), row.leaf() ? small : smallBold)));
                table.addCell(new PdfPCell(new Phrase("  ".repeat(row.depth()) + row.requirement().getTitle(), small)));
                for (MatrixColumn column : part) {
                    MatrixCell cell = cells.get(row.requirement().getKey() + "|" + column.test().getKey());
                    PdfPCell pdfCell = new PdfPCell(new Phrase(cell(cell), small));
                    pdfCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    if (cell != null) {
                        pdfCell.setBackgroundColor(cell.link().isSuspect() ? new Color(0xE5, 0xDB, 0xFF)
                                : cell.link().getLinkType().countsForCoverage() ? new Color(0xD3, 0xF9, 0xD8) : new Color(0xF1, 0xF3, 0xF5));
                    }
                    table.addCell(pdfCell);
                }
            }
            document.add(table);
        }
        document.close();
        return out.toByteArray();
    }

    private static PdfPCell header(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(new Color(0xE9, 0xEC, 0xEF));
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        return cell;
    }
}
