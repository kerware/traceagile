package com.traceagile.infrastructure.persistence;

import com.traceagile.application.testcase.TestCaseFilter;
import com.traceagile.domain.testcase.TestCase;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

/** Fragment Spring Data : recherche du référentiel de tests. */
public interface TestCaseSearchFragment {

    Page<TestCase> search(String projectKey, TestCaseFilter filter, Pageable pageable);
}
