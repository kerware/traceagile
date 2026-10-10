package com.traceagile.domain.reporting;

/** F-RPT-03 / ADR-0023 formats de sortie d'un rapport. */
public enum ReportFormat {
    HTML("text/html;charset=UTF-8", "html"),
    PDF("application/pdf", "pdf"),
    DOCX("application/vnd.openxmlformats-officedocument.wordprocessingml.document", "docx"),
    XLSX("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "xlsx"),
    MARKDOWN("text/markdown;charset=UTF-8", "md"),
    CSV("text/csv;charset=UTF-8", "csv"),
    JSON("application/json", "json");

    private final String contentType;
    private final String extension;

    ReportFormat(String contentType, String extension) {
        this.contentType = contentType;
        this.extension = extension;
    }

    public String contentType() {
        return contentType;
    }

    public String extension() {
        return extension;
    }
}
