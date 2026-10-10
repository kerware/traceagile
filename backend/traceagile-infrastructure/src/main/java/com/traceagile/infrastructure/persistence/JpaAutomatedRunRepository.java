package com.traceagile.infrastructure.persistence;

import com.traceagile.application.automation.AutomationRepositories.AutomatedRunRepository;
import com.traceagile.domain.automation.AutomatedRun;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link AutomatedRunRepository}. */
public interface JpaAutomatedRunRepository extends JpaRepository<AutomatedRun, UUID>, AutomatedRunRepository {
}
