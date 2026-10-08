package com.traceagile.infrastructure.persistence;

import com.traceagile.application.requirement.RequirementRepository;
import com.traceagile.domain.requirement.Requirement;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

/** Adaptateur Spring Data du port {@link RequirementRepository} ; la recherche vient du fragment. */
public interface JpaRequirementRepository extends JpaRepository<Requirement, UUID>, JpaSpecificationExecutor<Requirement>,
        RequirementRepository, RequirementSearchFragment {
}
