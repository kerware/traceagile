package com.traceagile.infrastructure.persistence;

import com.traceagile.application.git.GitRepositories.GitSourceRepository;
import com.traceagile.domain.git.GitSource;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** ADR-0030 adaptateur Spring Data du port {@link GitSourceRepository}. */
public interface JpaGitSourceRepository extends JpaRepository<GitSource, UUID>, GitSourceRepository {
}
