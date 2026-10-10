package com.traceagile.infrastructure.reporting;

import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import com.traceagile.application.reporting.ReportData;
import com.traceagile.application.reporting.ReportDocument;
import com.traceagile.application.reporting.ReportRenderer;
import com.traceagile.domain.reporting.ReportFormat;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UncheckedIOException;
import org.springframework.stereotype.Component;

/**
 * F-RPT-03 PDF généré côté serveur depuis le gabarit HTML (OpenHTMLtoPDF, §11.1). Polices PDF de base :
 * aucune police système requise dans l'image Docker (ADR-0023).
 */
@Component
public class PdfReportRenderer implements ReportRenderer {

    private final HtmlReportRenderer html;

    public PdfReportRenderer(HtmlReportRenderer html) {
        this.html = html;
    }

    @Override
    public ReportFormat format() {
        return ReportFormat.PDF;
    }

    @Override
    public byte[] render(ReportDocument document, ReportData data) {
        String content = html.html(document, true);
        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            PdfRendererBuilder builder = new PdfRendererBuilder();
            builder.useFastMode();
            builder.withHtmlContent(content, null);
            builder.toStream(out);
            builder.run();
            return out.toByteArray();
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }
}
