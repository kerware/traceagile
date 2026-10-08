package com.traceagile.application.administration;

import com.traceagile.domain.administration.Project;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

/** Port de persistance des projets (et de leurs membres, en cascade). */
public interface ProjectRepository {

    Optional<Project> findByKey(String key);

    boolean existsByKey(String key);

    Page<Project> findAll(Pageable pageable);

    /** Projets dont l'utilisateur est membre (§2.2). */
    Page<Project> findDistinctByMembers_User_Login(String login, Pageable pageable);

    Project save(Project project);
}
