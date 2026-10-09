package com.traceagile.domain.execution;

import com.traceagile.domain.common.AuditableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.Objects;

/**
 * §3.1 StepResult : un pas de l'exécution, copié de la version exécutée du test (paramètres résolus,
 * §3.3-5), avec son statut et le résultat obtenu (F-EXE-01).
 */
@Entity
@Table(name = "step_results")
public class StepResult extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "execution_id")
    private Execution execution;

    @Column(nullable = false)
    private int position;

    @Column(nullable = false, columnDefinition = "text")
    private String action;

    @Column(name = "expected_result", columnDefinition = "text")
    private String expectedResult;

    @Column(name = "test_data", columnDefinition = "text")
    private String testData;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private ExecutionStatus status = ExecutionStatus.NOT_RUN;

    @Column(name = "actual_result", columnDefinition = "text")
    private String actualResult;

    protected StepResult() {
    }

    StepResult(Execution execution, int position, String action, String expectedResult, String testData) {
        this.execution = Objects.requireNonNull(execution);
        this.position = position;
        this.action = action;
        this.expectedResult = expectedResult;
        this.testData = testData;
    }

    void record(ExecutionStatus status, String actualResult) {
        this.status = status;
        this.actualResult = actualResult == null || actualResult.isBlank() ? null : actualResult.strip();
    }

    public Execution getExecution() {
        return execution;
    }

    public int getPosition() {
        return position;
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

    public ExecutionStatus getStatus() {
        return status;
    }

    public String getActualResult() {
        return actualResult;
    }
}
