package com.traceagile.application.requirement;

import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementType;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

/** Port de persistance des exigences. */
public interface RequirementRepository {

    Optional<Requirement> findByProject_KeyAndKey(String projectKey, String key);

    /** Tout le backlog dans l'ordre du rang (vue arbre, export). */
    List<Requirement> findByProject_KeyOrderByRankAsc(String projectKey);

    Optional<Requirement> findFirstByProject_KeyOrderByRankDesc(String projectKey);

    Optional<Requirement> findFirstByProject_KeyAndRankGreaterThanOrderByRankAsc(String projectKey, String rank);

    List<Requirement> findByProject_KeyAndTypeAndTransverseTrue(String projectKey, RequirementType type);

    boolean existsByProject_Key(String projectKey);

    List<Requirement> findByIdIn(java.util.Collection<java.util.UUID> ids);

    /** F-REQ-01 / F-REQ-04 liste filtrée, paginée et triée. */
    Page<Requirement> search(String projectKey, RequirementFilter filter, Pageable pageable);

    Requirement save(Requirement requirement);

    void delete(Requirement requirement);
}
