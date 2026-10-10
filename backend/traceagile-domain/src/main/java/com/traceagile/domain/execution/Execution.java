package com.traceagile.domain.execution;

import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.testcase.DataSetRow;
import com.traceagile.domain.testcase.ManualStep;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestParameter;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * §3.1 Execution : une tentative (F-EXE-04) d'un test d'une campagne. Manuelle : pas copiés de la
 * version exécutée (§3.3-5), paramètres résolus par la ligne du jeu de données choisi (ADR-0013),
 * statut déduit des pas ou forcé avec commentaire (F-EXE-02). Automatisée ou importée : résultat seul.
 */
@Entity
@Table(name = "executions")
public class Execution extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "campaign_item_id")
    private CampaignItem item;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "test_case_id")
    private TestCase testCase;

    @Column(nullable = false)
    private int attempt;

    @Column(name = "test_case_version", nullable = false)
    private int testCaseVersion;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private ExecutionStatus status;

    @Column(name = "status_overridden", nullable = false)
    private boolean statusOverridden;

    @Column(name = "started_at", nullable = false)
    private Instant startedAt;

    @Column(name = "ended_at")
    private Instant endedAt;

    @Column(name = "duration_ms")
    private Long durationMs;

    @Column(length = 2000)
    private String comment;

    @Column(name = "executed_by", length = 32)
    private String executedBy;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private ExecutionOrigin origin;

    @Column(name = "data_set_name", length = 100)
    private String dataSetName;

    @Column(name = "data_set_row")
    private Integer dataSetRow;

    /** Valeurs des paramètres utilisées (défauts, puis ligne du jeu de données). */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "parameter_values", nullable = false, columnDefinition = "jsonb")
    private Map<String, String> parameterValues = new LinkedHashMap<>();

    @OneToMany(mappedBy = "execution", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("position ASC")
    private List<StepResult> steps = new ArrayList<>();

    protected Execution() {
    }

    private Execution(CampaignItem item, ExecutionOrigin origin, String executedBy, Instant startedAt) {
        this.item = Objects.requireNonNull(item);
        this.testCase = item.getTestCase();
        this.attempt = item.nextAttempt();
        this.testCaseVersion = testCase.getCurrentVersion();
        this.origin = origin;
        this.executedBy = executedBy;
        this.startedAt = Objects.requireNonNull(startedAt);
        this.status = ExecutionStatus.RUNNING;
    }

    /**
     * F-EXE-01 nouvelle tentative d'un test manuel. {@code dataSetName} / {@code row} (base 0) :
     * ligne du jeu de données dont les valeurs remplacent les défauts des paramètres.
     */
    public static Execution manual(CampaignItem item, String executedBy, Instant now, String dataSetName, Integer row) {
        TestCase test = item.getTestCase();
        if (test.getKind() != TestKind.MANUAL) {
            throw new BusinessRuleException("EXECUTION_KIND_INVALID",
                    test.getKey() + " est un test " + test.getKind() + " : l'exécution pas à pas concerne les tests manuels.");
        }
        Execution execution = new Execution(item, ExecutionOrigin.MANUAL, executedBy, now);
        Map<String, String> values = new LinkedHashMap<>();
        for (TestParameter parameter : test.getParameters()) {
            if (parameter.defaultValue() != null) {
                values.put(parameter.name(), parameter.defaultValue());
            }
        }
        // ADR-0018 la ligne choisie dans la campagne s'impose ; une autre ligne demandée est refusée
        if (item.getDataSetName() != null) {
            if (dataSetName != null && (!dataSetName.equalsIgnoreCase(item.getDataSetName())
                    || (row == null ? 0 : row) != item.getDataSetRow())) {
                throw new BusinessRuleException("EXECUTION_DATASET_BOUND", test.getKey() + " est prévu avec la ligne "
                        + (item.getDataSetRow() + 1) + " du jeu « " + item.getDataSetName() + " » dans cette campagne.");
            }
            dataSetName = item.getDataSetName();
            row = item.getDataSetRow();
        }
        if (dataSetName != null) {
            DataSetRow data = DataSetRow.of(test, dataSetName, row);
            values.putAll(data.values());
            execution.dataSetName = data.dataSetName();
            execution.dataSetRow = data.row();
        }
        execution.parameterValues = values;
        execution.unfold(test, values, null, new ArrayDeque<>());
        item.attach(execution);
        return execution;
    }

    /**
     * ADR-0018 pas à jouer : ceux du test, un appel étant remplacé par les pas (courants) du test
     * appelé. Valeurs de l'appelé : ses défauts, puis toutes les valeurs de l'appelant (même nom),
     * puis les valeurs de l'appel (où les {@code ${nom}} de l'appelant sont remplacés).
     */
    private void unfold(TestCase test, Map<String, String> values, String from, Deque<TestCase> path) {
        path.push(test);
        for (ManualStep step : test.getSteps()) {
            TestCase called = step.getCalledTest();
            if (called == null) {
                steps.add(new StepResult(this, steps.size() + 1, ParameterResolver.resolve(step.getAction(), values),
                        ParameterResolver.resolve(step.getExpectedResult(), values), ParameterResolver.resolve(step.getTestData(), values), from));
                continue;
            }
            if (path.contains(called)) {
                throw new BusinessRuleException("TEST_CALL_CYCLE", "Boucle d'appels entre " + test.getKey() + " et " + called.getKey() + ".");
            }
            Map<String, String> calledValues = new LinkedHashMap<>();
            for (TestParameter parameter : called.getParameters()) {
                if (parameter.defaultValue() != null) {
                    calledValues.put(parameter.name(), parameter.defaultValue());
                }
            }
            // toutes les valeurs de l'appelant descendent, y compris vers les appels imbriqués
            calledValues.putAll(values);
            step.getCallParameters().forEach((name, value) -> calledValues.put(name, ParameterResolver.resolve(value, values)));
            String label = called.getKey() + " " + called.getTitle();
            unfold(called, calledValues, from == null ? label : from + " › " + label, path);
        }
        path.pop();
    }

    /**
     * F-EXP-05 tentative d'une charte exploratoire, portée par une session (ADR-0019) : en cours
     * jusqu'à la fin de session, qui en fixe le statut et la durée active.
     */
    public static Execution exploratory(CampaignItem item, String tester, Instant now) {
        TestCase test = item.getTestCase();
        if (test.getKind() != TestKind.EXPLORATORY) {
            throw new BusinessRuleException("SESSION_NOT_A_CHARTER", test.getKey() + " n'est pas une charte exploratoire.");
        }
        Execution latest = item.latest();
        if (latest != null && latest.getStatus() == ExecutionStatus.RUNNING) {
            throw new BusinessRuleException("EXECUTION_IN_PROGRESS",
                    "La session " + latest.getAttempt() + " est en cours : terminez-la avant d'en commencer une autre.");
        }
        Execution execution = new Execution(item, ExecutionOrigin.MANUAL, tester, now);
        item.attach(execution);
        return execution;
    }

    /** F-EXP-09 fin de session : statut choisi par le testeur, durée = temps actif (pauses exclues). */
    public void finishSession(ExecutionStatus status, Instant endedAt, long activeMs) {
        if (testCase.getKind() != TestKind.EXPLORATORY || this.status != ExecutionStatus.RUNNING) {
            throw new BusinessRuleException("EXECUTION_STATUS_INVALID", "Seule une session exploratoire en cours se termine ainsi.");
        }
        this.status = status;
        this.endedAt = endedAt;
        this.durationMs = activeMs;
    }

    /** Résultat enregistré sans saisie pas à pas (run automatisé, import de rapport, démonstration). */
    public static Execution recorded(CampaignItem item, ExecutionOrigin origin, ExecutionStatus status, String executedBy,
                                     Instant startedAt, Instant endedAt, String comment) {
        Execution execution = new Execution(item, origin, executedBy, startedAt);
        execution.status = Objects.requireNonNull(status);
        execution.comment = comment;
        if (status != ExecutionStatus.RUNNING) {
            execution.finish(endedAt == null ? startedAt : endedAt);
        }
        item.attach(execution);
        return execution;
    }

    /** F-EXE-01 saisie d'un pas ; le statut global est recalculé sauf s'il a été forcé. */
    public void recordStep(int position, ExecutionStatus stepStatus, String actualResult, Instant now) {
        if (!ExecutionRules.isStepStatus(stepStatus)) {
            throw new BusinessRuleException("EXECUTION_STATUS_INVALID", "Statut de pas invalide : " + stepStatus + ".");
        }
        StepResult step = steps.stream().filter(s -> s.getPosition() == position).findFirst()
                .orElseThrow(() -> new BusinessRuleException("EXECUTION_STEP_UNKNOWN", "Pas n° " + position + " inconnu."));
        step.record(stepStatus, actualResult);
        if (!statusOverridden) {
            apply(derivedStatus(), now);
        }
    }

    /** F-EXE-02 statut forcé : commentaire obligatoire s'il diffère du statut déduit des pas. */
    public void override(ExecutionStatus target, String comment, Instant now) {
        if (target == null || target == ExecutionStatus.RUNNING || target == ExecutionStatus.NOT_RUN) {
            throw new BusinessRuleException("EXECUTION_STATUS_INVALID", "Un statut final est attendu (réussi, échoué, bloqué, ignoré, erreur).");
        }
        boolean differs = steps.isEmpty() || target != derivedStatus();
        if (differs && (comment == null || comment.isBlank())) {
            throw new BusinessRuleException("EXECUTION_COMMENT_REQUIRED", "Un commentaire est obligatoire pour modifier le statut de l'exécution.");
        }
        this.comment = comment == null || comment.isBlank() ? this.comment : comment.strip();
        this.statusOverridden = differs;
        apply(target, now);
    }

    public ExecutionStatus derivedStatus() {
        return ExecutionRules.derive(steps.stream().map(StepResult::getStatus).toList());
    }

    private void apply(ExecutionStatus target, Instant now) {
        status = target;
        if (target == ExecutionStatus.RUNNING) {
            endedAt = null;
            durationMs = null;
        } else {
            finish(now);
        }
    }

    private void finish(Instant at) {
        endedAt = at;
        durationMs = Math.max(0, Duration.between(startedAt, at).toMillis());
    }

    public boolean isFinal() {
        return status != ExecutionStatus.RUNNING && status != ExecutionStatus.NOT_RUN;
    }

    /** F-EXE-03 premier pas en échec (pré-remplissage de l'anomalie). */
    public Optional<StepResult> firstFailedStep() {
        return steps.stream().filter(s -> s.getStatus() == ExecutionStatus.FAILED).findFirst();
    }

    public CampaignItem getItem() {
        return item;
    }

    public TestCase getTestCase() {
        return testCase;
    }

    public int getAttempt() {
        return attempt;
    }

    public int getTestCaseVersion() {
        return testCaseVersion;
    }

    public ExecutionStatus getStatus() {
        return status;
    }

    public boolean isStatusOverridden() {
        return statusOverridden;
    }

    public Instant getStartedAt() {
        return startedAt;
    }

    public Instant getEndedAt() {
        return endedAt;
    }

    public Long getDurationMs() {
        return durationMs;
    }

    public String getComment() {
        return comment;
    }

    public String getExecutedBy() {
        return executedBy;
    }

    public ExecutionOrigin getOrigin() {
        return origin;
    }

    public String getDataSetName() {
        return dataSetName;
    }

    public Integer getDataSetRow() {
        return dataSetRow;
    }

    public Map<String, String> getParameterValues() {
        return Map.copyOf(parameterValues);
    }

    public List<StepResult> getSteps() {
        return List.copyOf(steps);
    }
}
