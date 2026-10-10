package com.traceagile.domain.campaign;

import com.traceagile.domain.administration.User;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.testcase.DataSetRow;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestKind;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * §3.1 CampaignItem : un test de la campagne, la version sélectionnée, l'affectation (F-CMP-04),
 * l'ordre et le score de risque (F-CMP-03) ; ses exécutions successives (tentatives, F-EXE-04).
 */
@Entity
@Table(name = "campaign_items")
public class CampaignItem extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "campaign_id")
    private Campaign campaign;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "test_case_id")
    private TestCase testCase;

    @Column(name = "test_case_version", nullable = false)
    private int testCaseVersion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assignee_id")
    private User assignee;

    @Column(nullable = false)
    private int position;

    @Column(name = "risk_score", nullable = false)
    private int riskScore;

    /** ADR-0018 ligne de jeu de données prévue pour ce test dans la campagne ; {@code null} = valeurs par défaut. */
    @Column(name = "data_set_name", length = 100)
    private String dataSetName;

    @Column(name = "data_set_row")
    private Integer dataSetRow;

    @OneToMany(mappedBy = "item", cascade = CascadeType.ALL)
    @OrderBy("attempt ASC")
    private List<Execution> executions = new ArrayList<>();

    protected CampaignItem() {
    }

    CampaignItem(Campaign campaign, TestCase testCase, int position, int riskScore) {
        this.campaign = Objects.requireNonNull(campaign);
        this.testCase = Objects.requireNonNull(testCase);
        this.testCaseVersion = testCase.getCurrentVersion();
        this.position = position;
        this.riskScore = riskScore;
    }

    /** Validé par {@link DataSetRow} ; {@code name} {@code null} = valeurs par défaut des paramètres. */
    void bindDataSet(String name, Integer row) {
        if (name == null) {
            this.dataSetName = null;
            this.dataSetRow = null;
            return;
        }
        if (testCase.getKind() != TestKind.MANUAL) {
            throw new BusinessRuleException("EXECUTION_DATASET_UNKNOWN",
                    testCase.getKey() + " n'est pas un test manuel : pas de jeu de données à l'exécution.");
        }
        DataSetRow data = DataSetRow.of(testCase, name, row);
        this.dataSetName = data.dataSetName();
        this.dataSetRow = data.row();
    }

    /** Même test et même ligne de jeu de données (ou tous deux sans jeu). */
    boolean matches(TestCase test, String name, Integer row) {
        boolean sameTest = testCase == test || (testCase.getId() != null && testCase.getId().equals(test.getId()));
        if (!sameTest) {
            return false;
        }
        if (dataSetName == null || name == null) {
            return dataSetName == null && name == null;
        }
        return dataSetName.equalsIgnoreCase(name) && dataSetRow == (row == null ? 0 : row);
    }

    /** Valeurs de la ligne prévue (vide sans jeu de données). */
    public Map<String, String> dataSetValues() {
        if (dataSetName == null) {
            return Map.of();
        }
        try {
            return DataSetRow.of(testCase, dataSetName, dataSetRow).values();
        } catch (BusinessRuleException e) {
            return Map.of(); // jeu modifié depuis la sélection : l'exécution le signalera
        }
    }

    void moveTo(int position) {
        this.position = position;
    }

    /** Un test automatisé est exécuté par le serveur d'exécution (lot 7). */
    public boolean isExecutedByServer() {
        return testCase.getKind() == TestKind.AUTOMATED;
    }

    /** F-CMP-04 testeur (test manuel ou charte) ; {@code null} = non affecté. */
    public void assign(User user) {
        campaign.ensureOpen();
        if (user != null && isExecutedByServer()) {
            throw new BusinessRuleException("CAMPAIGN_ITEM_AUTOMATED",
                    testCase.getKey() + " est automatisé : il est exécuté par le serveur d'exécution, pas par un testeur.");
        }
        this.assignee = user;
    }

    /** Ajoute une exécution (nouvelle tentative) ; la campagne démarre à la première. */
    public void attach(Execution execution) {
        campaign.ensureOpen();
        if (campaign.getStatus() == CampaignStatus.PLANNED) {
            campaign.start();
        }
        executions.add(execution);
    }

    public int nextAttempt() {
        return executions.size() + 1;
    }

    public Execution latest() {
        return executions.isEmpty() ? null : executions.getLast();
    }

    /** Statut affiché : celui de la dernière tentative, NOT_RUN sans exécution. */
    public ExecutionStatus lastStatus() {
        Execution latest = latest();
        return latest == null ? ExecutionStatus.NOT_RUN : latest.getStatus();
    }

    public Campaign getCampaign() {
        return campaign;
    }

    public TestCase getTestCase() {
        return testCase;
    }

    public int getTestCaseVersion() {
        return testCaseVersion;
    }

    public User getAssignee() {
        return assignee;
    }

    public int getPosition() {
        return position;
    }

    public int getRiskScore() {
        return riskScore;
    }

    public String getDataSetName() {
        return dataSetName;
    }

    public Integer getDataSetRow() {
        return dataSetRow;
    }

    public List<Execution> getExecutions() {
        return List.copyOf(executions);
    }
}
