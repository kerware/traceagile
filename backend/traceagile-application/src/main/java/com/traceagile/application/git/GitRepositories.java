package com.traceagile.application.git;

import com.traceagile.domain.git.GitProject;
import com.traceagile.domain.git.GitSource;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** ADR-0030 ports de persistance des dépôts Git déclarés et de leurs projets. */
public final class GitRepositories {

    private GitRepositories() {
    }

    public interface GitSourceRepository {

        List<GitSource> findAllByOrderByNameAsc();

        Optional<GitSource> findById(UUID id);

        boolean existsByNameIgnoreCase(String name);

        GitSource save(GitSource source);

        void delete(GitSource source);
    }

    public interface GitProjectRepository {

        List<GitProject> findAllByOrderByNameAsc();

        Optional<GitProject> findById(UUID id);

        boolean existsBySourceAndNameIgnoreCase(GitSource source, String name);

        long countBySource(GitSource source);

        /** Tests automatisés qui référencent ce projet. */
        long countTestsUsing(GitProject project);

        GitProject save(GitProject project);

        void delete(GitProject project);
    }
}
