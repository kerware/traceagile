package com.traceagile.application.planning;

import com.traceagile.domain.planning.PlanningStatus;
import com.traceagile.domain.planning.Sprint;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

/** Port de persistance des sprints et de leur périmètre (§8.2). */
public interface SprintRepository {

    List<Sprint> findByProject_KeyOrderByStartDateAsc(String projectKey);

    List<Sprint> findByProject_KeyAndStatusInOrderByStartDateAsc(String projectKey, Collection<PlanningStatus> statuses);

    Optional<Sprint> findByProject_KeyAndKey(String projectKey, String key);

    Sprint save(Sprint sprint);
}
