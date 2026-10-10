package com.traceagile.infrastructure.reporting;

import com.traceagile.application.reporting.ReportData;
import com.traceagile.application.reporting.ReportDocument;
import com.traceagile.application.reporting.ReportRenderer;
import com.traceagile.domain.reporting.ReportFormat;
import java.nio.charset.StandardCharsets;
import org.springframework.stereotype.Component;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;
import org.thymeleaf.templatemode.TemplateMode;
import org.thymeleaf.templateresolver.ClassLoaderTemplateResolver;

/** F-RPT-03 / ADR-0023 rapport HTML autonome (gabarit Thymeleaf {@code templates/reports/report.html}, §11.1). */
@Component
public class HtmlReportRenderer implements ReportRenderer {

    private final TemplateEngine engine;
    private final ChartGeometry charts = new ChartGeometry();

    public HtmlReportRenderer() {
        ClassLoaderTemplateResolver resolver = new ClassLoaderTemplateResolver();
        resolver.setPrefix("templates/reports/");
        resolver.setSuffix(".html");
        resolver.setTemplateMode(TemplateMode.HTML);
        resolver.setCharacterEncoding("UTF-8");
        resolver.setCacheable(true);
        this.engine = new TemplateEngine();
        engine.setTemplateResolver(resolver);
    }

    @Override
    public ReportFormat format() {
        return ReportFormat.HTML;
    }

    @Override
    public byte[] render(ReportDocument document, ReportData data) {
        return html(document, false).getBytes(StandardCharsets.UTF_8);
    }

    /** Le même gabarit sert au PDF ({@code pdf} : pied de page courant, numéros de page). */
    String html(ReportDocument document, boolean pdf) {
        Context context = new Context();
        context.setVariable("doc", document);
        context.setVariable("charts", charts);
        context.setVariable("pdf", pdf);
        return engine.process("report", context);
    }
}
