package com.traceagile.infrastructure.persistence;

import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.domain.administration.Project;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link ProjectRepository}. */
public interface JpaProjectRepository extends JpaRepository<Project, UUID>, ProjectRepository {
}
