package com.traceagile.application.testcase;

import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseVersion;
import java.util.List;
import java.util.Optional;

/** Port de persistance des versions de test (F-AUT-10). */
public interface TestCaseVersionRepository {

    List<TestCaseVersion> findByTestCaseOrderByVersionNumberDesc(TestCase testCase);

    Optional<TestCaseVersion> findByTestCaseAndVersionNumber(TestCase testCase, int versionNumber);

    TestCaseVersion save(TestCaseVersion version);
}
