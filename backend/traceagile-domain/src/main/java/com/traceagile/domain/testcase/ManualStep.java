package com.traceagile.domain.testcase;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;

/** §3.1 ManualStep : pas ordonné d'un test manuel (F-MAN-01). */
@Entity
@Table(name = "manual_steps")
public class ManualStep extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "test_case_id")
    private TestCase testCase;

    @Column(nullable = false)
    private int position;

    @Column(nullable = false, columnDefinition = "text")
    private String action;

    @Column(name = "expected_result", columnDefinition = "text")
    private String expectedResult;

    @Column(name = "test_data", columnDefinition = "text")
    private String testData;

    protected ManualStep() {
    }

    ManualStep(TestCase testCase, int position, String action, String expectedResult, String testData) {
        this.testCase = testCase;
        this.position = position;
        rewriteFields(action, expectedResult, testData);
    }

    /** Passe par le test pour respecter son statut ; F-AUT-10 change sa version. */
    public void rewrite(String action, String expectedResult, String testData) {
        testCase.ensureEditable();
        rewriteFields(action, expectedResult, testData);
    }

    private void rewriteFields(String action, String expectedResult, String testData) {
        if (action == null || action.isBlank()) {
            throw new BusinessRuleException("TEST_STEP_ACTION_REQUIRED", "L'action du pas est obligatoire.");
        }
        this.action = action.strip();
        this.expectedResult = blankToNull(expectedResult);
        this.testData = blankToNull(testData);
    }

    public TestCase getTestCase() {
        return testCase;
    }

    public int getPosition() {
        return position;
    }

    void setPosition(int position) {
        this.position = position;
    }

    public String getAction() {
        return action;
    }

    public String getExpectedResult() {
        return expectedResult;
    }

    public String getTestData() {
        return testData;
    }

    /** Contenu du pas, pour l'empreinte de version et les instantanés. */
    List<String> content() {
        return Arrays.asList(action, expectedResult, testData);
    }

    String describe() {
        return position + ". " + action + (expectedResult == null ? "" : " → " + expectedResult)
                + (testData == null ? "" : " [" + testData + "]");
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.strip();
    }

    @Override
    public String toString() {
        return Objects.toString(describe());
    }
}
