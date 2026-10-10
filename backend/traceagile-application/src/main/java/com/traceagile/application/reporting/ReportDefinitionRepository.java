package com.traceagile.application.reporting;

import com.traceagile.domain.reporting.ReportDefinition;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** Port des définitions de rapports (ADR-0023). */
public interface ReportDefinitionRepository {

    List<ReportDefinition> findByProject_KeyOrderByBuiltInDescNameAsc(String projectKey);

    Optional<ReportDefinition> findByIdAndProject_Key(UUID id, String projectKey);

    Optional<ReportDefinition> findByProject_KeyAndName(String projectKey, String name);

    boolean existsByProject_KeyAndNameIgnoreCase(String projectKey, String name);

    ReportDefinition save(ReportDefinition definition);

    void delete(ReportDefinition definition);
}
