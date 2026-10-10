package com.traceagile.application.reporting;

import com.traceagile.domain.reporting.ReportFormat;

/** §11.3 port {@code ReportRenderer} : un adaptateur par format de sortie (ADR-0023). */
public interface ReportRenderer {

    ReportFormat format();

    /** {@code data} sert au JSON (instantané brut) ; les autres formats rendent le document. */
    byte[] render(ReportDocument document, ReportData data);
}
