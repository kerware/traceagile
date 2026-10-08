package com.traceagile.infrastructure.persistence;

import com.traceagile.application.testcase.TestCaseRepository;
import com.traceagile.domain.testcase.TestCase;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

/** Adaptateur Spring Data du port {@link TestCaseRepository} ; la recherche vient du fragment. */
public interface JpaTestCaseRepository extends JpaRepository<TestCase, UUID>, JpaSpecificationExecutor<TestCase>,
        TestCaseRepository, TestCaseSearchFragment {
}
