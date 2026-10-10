package com.traceagile.infrastructure.persistence;

import com.traceagile.application.automation.AutomationRepositories.ExecutionServerRepository;
import com.traceagile.domain.automation.ExecutionServer;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link ExecutionServerRepository}. */
public interface JpaExecutionServerRepository extends JpaRepository<ExecutionServer, UUID>, ExecutionServerRepository {
}
