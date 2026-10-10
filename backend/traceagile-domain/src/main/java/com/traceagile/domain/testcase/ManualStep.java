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
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.TreeMap;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

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

    /** ADR-0018 cas de test appelé par ce pas (réutilisation) ; {@code null} = pas ordinaire. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "called_test_case_id")
    private TestCase calledTest;

    /** ADR-0018 valeurs des paramètres de l'appelé ; peuvent citer les paramètres de l'appelant. */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "call_parameters", nullable = false, columnDefinition = "jsonb")
    private Map<String, String> callParameters = new LinkedHashMap<>();

    protected ManualStep() {
    }

    ManualStep(TestCase testCase, int position, StepContent content) {
        this.testCase = testCase;
        this.position = position;
        rewriteFields(content);
    }

    /** Passe par le test pour respecter son statut ; F-AUT-10 change sa version. */
    public void rewrite(String action, String expectedResult, String testData) {
        testCase.ensureEditable();
        rewriteFields(new StepContent(action, expectedResult, testData, calledTest, callParameters));
    }

    private void rewriteFields(StepContent content) {
        boolean call = content.calledTest() != null;
        if (!call && (content.action() == null || content.action().isBlank())) {
            throw new BusinessRuleException("TEST_STEP_ACTION_REQUIRED", "L'action du pas est obligatoire.");
        }
        this.action = blankToNull(content.action());
        this.expectedResult = blankToNull(content.expectedResult());
        this.testData = blankToNull(content.testData());
        this.calledTest = content.calledTest();
        this.callParameters = new LinkedHashMap<>();
        if (call) {
            new TreeMap<>(content.callParameters()).forEach((name, value) -> {
                if (name != null && !name.isBlank() && value != null && !value.isBlank()) {
                    callParameters.put(name.strip(), value.strip());
                }
            });
        }
    }

    StepContent toContent() {
        return new StepContent(action, expectedResult, testData, calledTest, callParameters);
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

    public TestCase getCalledTest() {
        return calledTest;
    }

    public Map<String, String> getCallParameters() {
        return Collections.unmodifiableMap(callParameters);
    }

    public boolean isCall() {
        return calledTest != null;
    }

    /** Contenu du pas, pour l'empreinte de version et les instantanés. */
    List<String> content() {
        return Arrays.asList(action, expectedResult, testData, calledTest == null ? null : calledTest.getKey(),
                callParameters.isEmpty() ? null : callParameters.toString());
    }

    String describe() {
        if (calledTest != null) {
            return position + ". ↳ " + calledTest.getKey() + (callParameters.isEmpty() ? "" : " " + callParameters)
                    + (action == null ? "" : " — " + action) + (expectedResult == null ? "" : " → " + expectedResult);
        }
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
