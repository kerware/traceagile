package com.traceagile.application.testcase;

import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestKind;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

/** Port de persistance des cas de test. */
public interface TestCaseRepository {

    Optional<TestCase> findByProject_KeyAndKey(String projectKey, String key);

    List<TestCase> findByProject_KeyOrderByKeyNumberAsc(String projectKey);

    List<TestCase> findByProject_KeyAndKindOrderByKeyNumberAsc(String projectKey, TestKind kind);

    List<TestCase> findByIdIn(Collection<UUID> ids);

    boolean existsByProject_Key(String projectKey);

    /** Liste filtrée, paginée et triée (§12 GET /test-cases). */
    Page<TestCase> search(String projectKey, TestCaseFilter filter, Pageable pageable);

    TestCase save(TestCase testCase);

    void delete(TestCase testCase);
}
