package com.traceagile.application.requirement;

import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementVersion;
import java.util.List;
import java.util.Optional;

/** Port de persistance des versions figées (F-REQ-21). */
public interface RequirementVersionRepository {

    List<RequirementVersion> findByRequirementOrderByVersionNumberDesc(Requirement requirement);

    Optional<RequirementVersion> findByRequirementAndVersionNumber(Requirement requirement, int versionNumber);

    RequirementVersion save(RequirementVersion version);
}
