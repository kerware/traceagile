package com.traceagile.infrastructure.persistence;

import com.traceagile.application.testcase.TestCaseRepository;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestKind;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

/** Adaptateur Spring Data du port {@link TestCaseRepository} ; la recherche vient du fragment. */
public interface JpaTestCaseRepository extends JpaRepository<TestCase, UUID>, JpaSpecificationExecutor<TestCase>,
        TestCaseRepository, TestCaseSearchFragment {

    /**
     * NF-01 / ADR-0024 tous les tests d'un projet avec leur charte et leur définition automatisée : ces
     * {@code @OneToOne} inverses ne se chargent pas paresseusement (deux requêtes par test sinon).
     */
    @Override
    @Query("select t from TestCase t left join fetch t.charter left join fetch t.automation where t.project.key = :projectKey order by t.keyNumber")
    List<TestCase> findByProject_KeyOrderByKeyNumberAsc(@Param("projectKey") String projectKey);

    @Override
    @Query("select t from TestCase t left join fetch t.charter left join fetch t.automation where t.project.key = :projectKey and t.kind = :kind"
            + " order by t.keyNumber")
    List<TestCase> findByProject_KeyAndKindOrderByKeyNumberAsc(@Param("projectKey") String projectKey, @Param("kind") TestKind kind);

    /** Même raison pour un lot de tests (matrice, campagnes, anomalies). */
    @Override
    @Query("select t from TestCase t left join fetch t.charter left join fetch t.automation where t.id in :ids")
    List<TestCase> findByIdIn(@Param("ids") Collection<UUID> ids);
}
