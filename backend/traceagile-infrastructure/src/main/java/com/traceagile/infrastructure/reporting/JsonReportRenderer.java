package com.traceagile.infrastructure.reporting;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.traceagile.application.reporting.ReportData;
import com.traceagile.application.reporting.ReportDocument;
import com.traceagile.application.reporting.ReportRenderer;
import com.traceagile.domain.reporting.ReportFormat;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.stereotype.Component;

/** F-RPT-03 export JSON de l'instantané : titre, verdict et données brutes de chaque section. */
@Component
public class JsonReportRenderer implements ReportRenderer {

    private static final ObjectMapper JSON = JsonMapper.builder().enable(SerializationFeature.INDENT_OUTPUT).build();

    @Override
    public ReportFormat format() {
        return ReportFormat.JSON;
    }

    @Override
    public byte[] render(ReportDocument document, ReportData data) {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("key", document.key());
        out.put("title", document.title());
        out.put("verdict", document.verdict());
        out.put("sections", document.sections().stream().map(ReportDocument.Section::id).toList());
        out.put("data", data);
        try {
            return JSON.writeValueAsBytes(out);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
    }
}
