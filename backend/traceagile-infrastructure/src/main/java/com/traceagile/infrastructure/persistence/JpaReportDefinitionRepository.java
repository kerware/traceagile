package com.traceagile.infrastructure.persistence;

import com.traceagile.application.reporting.ReportDefinitionRepository;
import com.traceagile.domain.reporting.ReportDefinition;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link ReportDefinitionRepository}. */
public interface JpaReportDefinitionRepository extends JpaRepository<ReportDefinition, UUID>, ReportDefinitionRepository {
}
