package com.traceagile.infrastructure.persistence;

import com.traceagile.application.planning.ReleaseRepository;
import com.traceagile.domain.planning.Release;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link ReleaseRepository}. */
public interface JpaReleaseRepository extends JpaRepository<Release, UUID>, ReleaseRepository {
}
