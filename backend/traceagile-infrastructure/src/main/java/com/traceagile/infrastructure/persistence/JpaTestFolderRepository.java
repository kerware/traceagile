package com.traceagile.infrastructure.persistence;

import com.traceagile.application.testcase.TestFolderRepository;
import com.traceagile.domain.testcase.TestFolder;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link TestFolderRepository}. */
public interface JpaTestFolderRepository extends JpaRepository<TestFolder, UUID>, TestFolderRepository {
}
