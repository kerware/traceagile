package com.traceagile.infrastructure.persistence;

import com.traceagile.application.traceability.TraceLinkRepository;
import com.traceagile.domain.traceability.TraceLink;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link TraceLinkRepository}. */
public interface JpaTraceLinkRepository extends JpaRepository<TraceLink, UUID>, TraceLinkRepository {
}
