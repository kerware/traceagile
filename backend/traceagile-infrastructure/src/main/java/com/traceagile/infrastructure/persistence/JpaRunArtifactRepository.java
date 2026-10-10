package com.traceagile.infrastructure.persistence;

import com.traceagile.application.automation.AutomationRepositories.RunArtifactRepository;
import com.traceagile.domain.automation.RunArtifact;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link RunArtifactRepository}. */
public interface JpaRunArtifactRepository extends JpaRepository<RunArtifact, UUID>, RunArtifactRepository {
}
