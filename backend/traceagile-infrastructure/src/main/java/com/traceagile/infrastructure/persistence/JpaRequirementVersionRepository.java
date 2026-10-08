package com.traceagile.infrastructure.persistence;

import com.traceagile.application.requirement.RequirementVersionRepository;
import com.traceagile.domain.requirement.RequirementVersion;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link RequirementVersionRepository}. */
public interface JpaRequirementVersionRepository extends JpaRepository<RequirementVersion, UUID>, RequirementVersionRepository {
}
