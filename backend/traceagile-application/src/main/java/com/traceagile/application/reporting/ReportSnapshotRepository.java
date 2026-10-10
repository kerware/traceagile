package com.traceagile.application.reporting;

import com.traceagile.domain.reporting.ReportSnapshot;
import java.util.List;
import java.util.Optional;

/** Port des rapports générés {@code RPT-n} (ADR-0023). */
public interface ReportSnapshotRepository {

    List<ReportSnapshot> findByProject_KeyOrderByKeyNumberDesc(String projectKey);

    Optional<ReportSnapshot> findByProject_KeyAndKey(String projectKey, String key);

    ReportSnapshot save(ReportSnapshot snapshot);

    void delete(ReportSnapshot snapshot);
}
