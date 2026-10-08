package com.traceagile.infrastructure.persistence;

import com.traceagile.application.testcase.AutomationFrameworkRepository;
import com.traceagile.domain.testcase.AutomationFramework;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link AutomationFrameworkRepository}. */
public interface JpaAutomationFrameworkRepository extends JpaRepository<AutomationFramework, UUID>, AutomationFrameworkRepository {
}
