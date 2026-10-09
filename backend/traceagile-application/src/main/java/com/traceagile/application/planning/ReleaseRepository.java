package com.traceagile.application.planning;

import com.traceagile.domain.planning.Release;
import java.util.List;
import java.util.Optional;

/** Port de persistance des releases (§8.1). */
public interface ReleaseRepository {

    List<Release> findByProject_KeyOrderByStartDateAsc(String projectKey);

    Optional<Release> findByProject_KeyAndKey(String projectKey, String key);

    boolean existsByProject_Key(String projectKey);

    Release save(Release release);
}
