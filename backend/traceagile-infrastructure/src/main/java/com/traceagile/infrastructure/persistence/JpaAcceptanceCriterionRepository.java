package com.traceagile.infrastructure.persistence;

import com.traceagile.application.requirement.AcceptanceCriterionRepository;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link AcceptanceCriterionRepository}. */
public interface JpaAcceptanceCriterionRepository extends JpaRepository<AcceptanceCriterion, UUID>, AcceptanceCriterionRepository {
}
