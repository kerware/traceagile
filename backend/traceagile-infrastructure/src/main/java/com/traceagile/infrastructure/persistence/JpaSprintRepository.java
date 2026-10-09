package com.traceagile.infrastructure.persistence;

import com.traceagile.application.planning.SprintRepository;
import com.traceagile.domain.planning.Sprint;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link SprintRepository}. */
public interface JpaSprintRepository extends JpaRepository<Sprint, UUID>, SprintRepository {
}
