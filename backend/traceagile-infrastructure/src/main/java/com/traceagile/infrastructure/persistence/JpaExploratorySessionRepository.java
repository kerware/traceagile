package com.traceagile.infrastructure.persistence;

import com.traceagile.application.exploratory.ExploratorySessionRepository;
import com.traceagile.domain.exploratory.ExploratorySession;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link ExploratorySessionRepository}. */
public interface JpaExploratorySessionRepository extends JpaRepository<ExploratorySession, UUID>, ExploratorySessionRepository {
}
