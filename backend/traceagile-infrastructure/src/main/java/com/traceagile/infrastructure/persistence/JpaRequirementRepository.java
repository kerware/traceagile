package com.traceagile.infrastructure.persistence;

import com.traceagile.application.requirement.RequirementRepository;
import com.traceagile.domain.requirement.Requirement;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/** Adaptateur Spring Data du port {@link RequirementRepository} ; la recherche vient du fragment. */
public interface JpaRequirementRepository extends JpaRepository<Requirement, UUID>, JpaSpecificationExecutor<Requirement>,
        RequirementRepository, RequirementSearchFragment {

    @Override
    @Query("select new com.traceagile.application.requirement.RequirementRepository$TreeLink(r.id, p.id) from Requirement r left join r.parent p"
            + " where r.project.key = :projectKey")
    List<TreeLink> treeOf(@Param("projectKey") String projectKey);
}
