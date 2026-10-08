package com.traceagile.infrastructure.persistence;

import com.traceagile.application.requirement.RequirementFilter;
import com.traceagile.domain.requirement.Requirement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

/** Fragment Spring Data : F-REQ-01 filtres et F-REQ-04 recherche plein texte. */
public interface RequirementSearchFragment {

    Page<Requirement> search(String projectKey, RequirementFilter filter, Pageable pageable);
}
