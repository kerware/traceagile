package com.traceagile.domain.automation;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Duration;
import java.time.Instant;
import java.util.Objects;

/**
 * §3.1 AutomatedRun : demande de lancement de tests automatisés d'une campagne sur un serveur
 * d'exécution (F-EXE-06). Les tentatives du run référencent le run ({@code Execution.run}) ; leurs
 * résultats arrivent par webhook (§10.4). Un run sans nouvelles au-delà de {@code timeoutMinutes} +
 * 5 minutes passe {@code TIMEOUT}.
 */
@Entity
@Table(name = "automated_runs")
public class AutomatedRun extends AuditableEntity {

    /** §10.4 marge ajoutée au délai du job avant TIMEOUT. */
    public static final Duration TIMEOUT_GRACE = Duration.ofMinutes(5);

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @Column(name = "run_key", nullable = false, length = 20)
    private String key;

    @Column(name = "key_number", nullable = false)
    private int keyNumber;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "campaign_id")
    private Campaign campaign;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "server_id")
    private ExecutionServer server;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 12)
    private RunStatus status;

    @Column(name = "requested_by", length = 32)
    private String requestedBy;

    @Column(name = "requested_at", nullable = false)
    private Instant requestedAt;

    @Column(name = "dispatched_at")
    private Instant dispatchedAt;

    @Column(name = "started_at")
    private Instant startedAt;

    @Column(name = "ended_at")
    private Instant endedAt;

    @Column(name = "last_event_at")
    private Instant lastEventAt;

    @Column(length = 60)
    private String environment;

    @Column(name = "build_version", length = 60)
    private String buildVersion;

    @Column(name = "external_job_id", length = 100)
    private String externalJobId;

    @Column(length = 100)
    private String agent;

    @Column(name = "logs_url", length = 500)
    private String logsUrl;

    @Column(name = "report_url", length = 500)
    private String reportUrl;

    @Column(name = "timeout_minutes", nullable = false)
    private int timeoutMinutes;

    @Column(name = "error_code", length = 60)
    private String errorCode;

    @Column(name = "error_message", length = 1000)
    private String errorMessage;

    @Column(name = "summary_total")
    private Integer summaryTotal;

    @Column(name = "summary_passed")
    private Integer summaryPassed;

    @Column(name = "summary_failed")
    private Integer summaryFailed;

    @Column(name = "summary_error")
    private Integer summaryError;

    @Column(name = "summary_skipped")
    private Integer summarySkipped;

    /** F-EXE-09 run relancé (seulement ses échecs). */
    @Column(name = "rerun_of", length = 20)
    private String rerunOf;

    protected AutomatedRun() {
    }

    /** F-EXE-06 run QUEUED : environnement et build de la campagne. */
    public static AutomatedRun queue(Project project, String key, Campaign campaign, ExecutionServer server, String requestedBy, Instant now,
                                     int timeoutMinutes) {
        if (timeoutMinutes < 1 || timeoutMinutes > 1440) {
            throw new BusinessRuleException("RUN_TIMEOUT_INVALID", "Le délai d'un run est compris entre 1 et 1440 minutes.");
        }
        AutomatedRun run = new AutomatedRun();
        run.project = Objects.requireNonNull(project);
        run.key = key;
        run.keyNumber = Integer.parseInt(key.substring(key.lastIndexOf('-') + 1));
        run.campaign = campaign;
        run.server = server;
        run.status = RunStatus.QUEUED;
        run.requestedBy = requestedBy;
        run.requestedAt = now;
        run.lastEventAt = now;
        run.environment = campaign.getEnvironment();
        run.buildVersion = campaign.getBuildVersion();
        run.timeoutMinutes = timeoutMinutes;
        return run;
    }

    public void markRerunOf(String runKey) {
        this.rerunOf = runKey;
    }

    // ---------------------------------------------------------------- transitions (§10.3, §10.4)

    public void dispatched(String jobId, Instant now) {
        ensureOpen();
        this.externalJobId = jobId;
        this.dispatchedAt = now;
        if (status == RunStatus.QUEUED) {
            status = RunStatus.DISPATCHED;
        }
        touch(now);
    }

    public void started(String agent, Instant now) {
        ensureOpen();
        this.agent = agent;
        this.startedAt = startedAt == null ? now : startedAt;
        this.status = RunStatus.RUNNING;
        touch(now);
    }

    public void finished(RunStatus outcome, RunSummary summary, String reportUrl, String logsUrl, Instant now) {
        ensureOpen();
        if (outcome != RunStatus.COMPLETED && outcome != RunStatus.FAILED) {
            throw new BusinessRuleException("RUN_STATUS_INVALID", "Un job se termine COMPLETED ou FAILED.");
        }
        this.status = outcome;
        RunSummary s = summary == null ? RunSummary.EMPTY : summary;
        this.summaryTotal = s.total();
        this.summaryPassed = s.passed();
        this.summaryFailed = s.failed();
        this.summaryError = s.error();
        this.summarySkipped = s.skipped();
        this.reportUrl = reportUrl;
        this.logsUrl = logsUrl;
        close(now);
    }

    /** Échec d'envoi ou JOB_ERROR. */
    public void failed(String code, String message, Instant now) {
        ensureOpen();
        this.status = RunStatus.FAILED;
        this.errorCode = code;
        this.errorMessage = message == null || message.length() <= 1000 ? message : message.substring(0, 999) + "…";
        close(now);
    }

    /** F-EXE-08 annulation d'un run non terminé. */
    public void cancel(Instant now) {
        ensureOpen();
        this.status = RunStatus.CANCELLED;
        close(now);
    }

    public void timeout(Instant now) {
        ensureOpen();
        this.status = RunStatus.TIMEOUT;
        this.errorCode = "TIMEOUT";
        this.errorMessage = "Aucun événement du serveur depuis plus de " + (timeoutMinutes + TIMEOUT_GRACE.toMinutes()) + " minutes.";
        close(now);
    }

    public void touch(Instant now) {
        if (lastEventAt == null || now.isAfter(lastEventAt)) {
            this.lastEventAt = now;
        }
    }

    /** §10.4 aucun événement reçu au-delà de {@code timeoutMinutes} + 5 minutes. */
    public boolean isOverdue(Instant now) {
        return !isFinal() && lastEventAt.plus(Duration.ofMinutes(timeoutMinutes)).plus(TIMEOUT_GRACE).isBefore(now);
    }

    public boolean isFinal() {
        return status.isFinal();
    }

    private void close(Instant now) {
        this.endedAt = now;
        touch(now);
    }

    private void ensureOpen() {
        if (isFinal()) {
            throw new BusinessRuleException("RUN_FINISHED", "Le run " + key + " est terminé (" + status + ").");
        }
    }

    // ---------------------------------------------------------------- accès

    public Project getProject() {
        return project;
    }

    public String getKey() {
        return key;
    }

    public int getKeyNumber() {
        return keyNumber;
    }

    public Campaign getCampaign() {
        return campaign;
    }

    public ExecutionServer getServer() {
        return server;
    }

    public RunStatus getStatus() {
        return status;
    }

    public String getRequestedBy() {
        return requestedBy;
    }

    public Instant getRequestedAt() {
        return requestedAt;
    }

    public Instant getDispatchedAt() {
        return dispatchedAt;
    }

    public Instant getStartedAt() {
        return startedAt;
    }

    public Instant getEndedAt() {
        return endedAt;
    }

    public Instant getLastEventAt() {
        return lastEventAt;
    }

    public String getEnvironment() {
        return environment;
    }

    public String getBuildVersion() {
        return buildVersion;
    }

    public String getExternalJobId() {
        return externalJobId;
    }

    public String getAgent() {
        return agent;
    }

    public String getLogsUrl() {
        return logsUrl;
    }

    public String getReportUrl() {
        return reportUrl;
    }

    public int getTimeoutMinutes() {
        return timeoutMinutes;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public RunSummary getSummary() {
        return summaryTotal == null ? null : new RunSummary(summaryTotal, summaryPassed, summaryFailed, summaryError, summarySkipped);
    }

    public String getRerunOf() {
        return rerunOf;
    }
}
