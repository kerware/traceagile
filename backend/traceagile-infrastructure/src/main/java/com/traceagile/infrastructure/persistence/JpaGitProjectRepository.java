package com.traceagile.infrastructure.persistence;

import com.traceagile.application.git.GitRepositories.GitProjectRepository;
import com.traceagile.domain.git.GitProject;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/** ADR-0030 adaptateur Spring Data du port {@link GitProjectRepository}. */
public interface JpaGitProjectRepository extends JpaRepository<GitProject, UUID>, GitProjectRepository {

    @Override
    @Query("select count(d) from AutomatedTestDefinition d where d.gitProject = :project")
    long countTestsUsing(@Param("project") GitProject project);
}
