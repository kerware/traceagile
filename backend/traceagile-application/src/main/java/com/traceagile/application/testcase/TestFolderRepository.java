package com.traceagile.application.testcase;

import com.traceagile.domain.testcase.TestFolder;
import java.util.List;

/** Port de persistance des dossiers de tests explicites (ADR-0013). */
public interface TestFolderRepository {

    List<TestFolder> findByProject_KeyOrderByPathAsc(String projectKey);

    TestFolder save(TestFolder folder);

    void delete(TestFolder folder);
}
