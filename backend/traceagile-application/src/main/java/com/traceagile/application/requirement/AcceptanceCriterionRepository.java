package com.traceagile.application.requirement;

import com.traceagile.domain.requirement.AcceptanceCriterion;
import java.util.Optional;
import java.util.UUID;

/** Port de lecture des critères (leur cycle de vie suit l'exigence, en cascade). */
public interface AcceptanceCriterionRepository {

    Optional<AcceptanceCriterion> findById(UUID id);
}
