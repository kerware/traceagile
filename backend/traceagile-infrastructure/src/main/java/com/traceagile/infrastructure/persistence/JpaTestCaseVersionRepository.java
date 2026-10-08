package com.traceagile.infrastructure.persistence;

import com.traceagile.application.testcase.TestCaseVersionRepository;
import com.traceagile.domain.testcase.TestCaseVersion;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link TestCaseVersionRepository}. */
public interface JpaTestCaseVersionRepository extends JpaRepository<TestCaseVersion, UUID>, TestCaseVersionRepository {
}
