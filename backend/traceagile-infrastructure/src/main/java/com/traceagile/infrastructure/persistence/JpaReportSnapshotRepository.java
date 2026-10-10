package com.traceagile.infrastructure.persistence;

import com.traceagile.application.reporting.ReportSnapshotRepository;
import com.traceagile.domain.reporting.ReportSnapshot;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link ReportSnapshotRepository}. */
public interface JpaReportSnapshotRepository extends JpaRepository<ReportSnapshot, UUID>, ReportSnapshotRepository {
}
