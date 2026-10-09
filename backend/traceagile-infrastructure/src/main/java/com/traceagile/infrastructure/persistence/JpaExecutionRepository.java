package com.traceagile.infrastructure.persistence;

import com.traceagile.application.execution.ExecutionRepository;
import com.traceagile.domain.execution.Execution;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link ExecutionRepository}. */
public interface JpaExecutionRepository extends JpaRepository<Execution, UUID>, ExecutionRepository {
}
