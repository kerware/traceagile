package com.traceagile.application.defect;

import com.traceagile.domain.defect.Defect;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** Port de persistance des anomalies (§8.6). */
public interface DefectRepository {

    List<Defect> findByProject_KeyOrderByKeyNumberDesc(String projectKey);

    Optional<Defect> findByProject_KeyAndKey(String projectKey, String key);

    List<Defect> findByRequirements_IdOrderByKeyNumberDesc(UUID requirementId);

    List<Defect> findByExecutions_Id(UUID executionId);

    List<Defect> findDistinctByExecutions_TestCase_IdInOrderByKeyNumberDesc(Collection<UUID> testIds);

    boolean existsByProject_Key(String projectKey);

    Defect save(Defect defect);
}
