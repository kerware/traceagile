package com.traceagile.domain.testcase;

import com.traceagile.domain.common.AuditableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.LinkedHashMap;
import java.util.Map;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/** F-AUT-10 version d'un test : instantané figé à la création puis à chaque modification significative. */
@Entity
@Table(name = "test_case_versions")
public class TestCaseVersion extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "test_case_id")
    private TestCase testCase;

    @Column(name = "version_number", nullable = false)
    private int versionNumber;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private Map<String, Object> snapshot = new LinkedHashMap<>();

    protected TestCaseVersion() {
    }

    /** Fige l'état courant sous le numéro de version courant du test. */
    public static TestCaseVersion of(TestCase testCase) {
        TestCaseVersion version = new TestCaseVersion();
        version.testCase = testCase;
        version.versionNumber = testCase.getCurrentVersion();
        version.snapshot = testCase.snapshot();
        return version;
    }

    public TestCase getTestCase() {
        return testCase;
    }

    public int getVersionNumber() {
        return versionNumber;
    }

    public Map<String, Object> getSnapshot() {
        return snapshot;
    }
}
