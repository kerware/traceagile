package com.traceagile.domain.exploratory;

import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.testcase.ExploratoryCharter;
import com.traceagile.domain.testcase.TestCase;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * §3.1 ExploratorySession (SBTM) : exécution chronométrée d'une charte d'une campagne. Elle porte une
 * tentative ({@link Execution}, F-EXE-04) dont elle fixe le statut à la fin ; notes horodatées en temps
 * actif (pauses exclues), répartition TBS, zones couvertes, débriefing PROOF et approbation.
 */
@Entity
@Table(name = "exploratory_sessions")
public class ExploratorySession extends AuditableEntity {

    static final Set<ExecutionStatus> FINAL_STATUSES = Set.of(ExecutionStatus.PASSED, ExecutionStatus.FAILED, ExecutionStatus.BLOCKED);

    @OneToOne(fetch = FetchType.LAZY, optional = false, cascade = CascadeType.ALL)
    @JoinColumn(name = "execution_id")
    private Execution execution;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private SessionState state;

    @Column(name = "timebox_min", nullable = false)
    private int timeboxMin;

    /** Temps actif cumulé jusqu'à la dernière pause. */
    @Column(name = "active_seconds", nullable = false)
    private long activeSeconds;

    /** Reprise en cours ({@code null} en pause ou terminée). */
    @Column(name = "resumed_at")
    private Instant resumedAt;

    /** F-EXP-10 note en cours de saisie, sauvegardée automatiquement. */
    @Column(columnDefinition = "text")
    private String draft;

    @OneToMany(mappedBy = "session", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("offsetSeconds ASC, notedAt ASC")
    private List<SessionNote> notes = new ArrayList<>();

    @Column(name = "test_pct")
    private Integer testPct;

    @Column(name = "bug_pct")
    private Integer bugPct;

    @Column(name = "setup_pct")
    private Integer setupPct;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "areas_covered", nullable = false, columnDefinition = "jsonb")
    private List<String> areasCovered = new ArrayList<>();

    @Column(name = "proof_past", columnDefinition = "text")
    private String proofPast;

    @Column(name = "proof_results", columnDefinition = "text")
    private String proofResults;

    @Column(name = "proof_obstacles", columnDefinition = "text")
    private String proofObstacles;

    @Column(name = "proof_outlook", columnDefinition = "text")
    private String proofOutlook;

    @Column(name = "proof_feelings")
    private Integer proofFeelings;

    @Column(name = "debriefed_by", length = 32)
    private String debriefedBy;

    @Column(name = "debriefed_at")
    private Instant debriefedAt;

    @Column(name = "approved_by", length = 32)
    private String approvedBy;

    @Column(name = "approved_at")
    private Instant approvedAt;

    protected ExploratorySession() {
    }

    /** F-EXP-05 démarre une session (nouvelle tentative) sur une charte planifiée dans une campagne. */
    public static ExploratorySession start(CampaignItem item, String tester, Instant now) {
        ExploratorySession session = new ExploratorySession();
        session.execution = Execution.exploratory(item, tester, now);
        session.state = SessionState.RUNNING;
        session.resumedAt = now;
        ExploratoryCharter charter = item.getTestCase().getCharter();
        session.timeboxMin = charter.getTimeboxMin();
        return session;
    }

    // ---------------------------------------------------------------- chronomètre (F-EXP-05)

    public void pause(Instant now) {
        ensureOpen();
        if (resumedAt != null) {
            activeSeconds += seconds(resumedAt, now);
            resumedAt = null;
            state = SessionState.PAUSED;
        }
    }

    public void resume(Instant now) {
        ensureOpen();
        if (resumedAt == null) {
            resumedAt = now;
            state = SessionState.RUNNING;
        }
    }

    /** Temps actif à l'instant donné (pauses exclues). */
    public long elapsedSeconds(Instant now) {
        return activeSeconds + (resumedAt == null ? 0 : seconds(resumedAt, now));
    }

    // ---------------------------------------------------------------- notes (F-EXP-06, F-EXP-10)

    public SessionNote addNote(NoteType type, String text, Instant now) {
        ensureOpen();
        if (text == null || text.isBlank()) {
            throw new BusinessRuleException("SESSION_NOTE_REQUIRED", "La note est vide.");
        }
        SessionNote note = new SessionNote(this, type, elapsedSeconds(now), text.strip(), now);
        notes.add(note);
        draft = null;
        return note;
    }

    public void saveDraft(String text) {
        ensureOpen();
        this.draft = text == null || text.isEmpty() ? null : text;
    }

    // ---------------------------------------------------------------- fin (F-EXP-09)

    public void finish(Tbs tbs, List<String> areas, ExecutionStatus status, Instant now) {
        ensureOpen();
        tbs.validate();
        if (!FINAL_STATUSES.contains(status)) {
            throw new BusinessRuleException("SESSION_STATUS_INVALID", "Une session se termine réussie, en échec ou bloquée.");
        }
        pause(now);
        this.testPct = tbs.testPct();
        this.bugPct = tbs.bugPct();
        this.setupPct = tbs.setupPct();
        Map<String, String> unique = new LinkedHashMap<>();
        (areas == null ? List.<String>of() : areas).stream().filter(Objects::nonNull).map(String::strip).filter(a -> !a.isEmpty())
                .forEach(a -> unique.putIfAbsent(a.toLowerCase(), a));
        this.areasCovered = new ArrayList<>(unique.values());
        this.state = SessionState.FINISHED;
        this.draft = null;
        execution.finishSession(status, now, activeSeconds * 1000);
    }

    // ---------------------------------------------------------------- débriefing (F-EXP-11, F-EXP-13)

    /** Saisi ou corrigé par le testeur tant qu'il n'est pas approuvé. */
    public void debrief(Proof proof, String author, Instant now) {
        if (state == SessionState.DEBRIEFED) {
            throw new BusinessRuleException("SESSION_CLOSED", "Le débriefing est approuvé : la session est close.");
        }
        if (state != SessionState.FINISHED) {
            throw new BusinessRuleException("SESSION_NOT_FINISHED", "Terminez la session avant son débriefing.");
        }
        proof.validate();
        this.proofPast = proof.past();
        this.proofResults = proof.results();
        this.proofObstacles = proof.obstacles();
        this.proofOutlook = proof.outlook();
        this.proofFeelings = proof.feelings();
        this.debriefedBy = author;
        this.debriefedAt = now;
    }

    /** F-EXP-13 validation par un second utilisateur (PO ou responsable des tests). */
    public void approve(String approver, Instant now) {
        if (state == SessionState.DEBRIEFED) {
            throw new BusinessRuleException("SESSION_CLOSED", "Le débriefing est déjà approuvé.");
        }
        if (state != SessionState.FINISHED || proofFeelings == null) {
            throw new BusinessRuleException("SESSION_DEBRIEF_MISSING", "Le débriefing n'a pas encore été saisi.");
        }
        if (approver.equals(getTester())) {
            throw new BusinessRuleException("SESSION_SELF_APPROVAL", "Le débriefing est approuvé par un autre utilisateur que le testeur.");
        }
        this.approvedBy = approver;
        this.approvedAt = now;
        this.state = SessionState.DEBRIEFED;
    }

    private void ensureOpen() {
        if (!state.isOpen()) {
            throw new BusinessRuleException("SESSION_CLOSED", "La session est terminée.");
        }
    }

    private static long seconds(Instant from, Instant to) {
        return Math.max(0, Duration.between(from, to).getSeconds());
    }

    // ---------------------------------------------------------------- accès

    public Execution getExecution() {
        return execution;
    }

    public TestCase getCharter() {
        return execution.getTestCase();
    }

    public String getTester() {
        return execution.getExecutedBy();
    }

    public Instant getStartedAt() {
        return execution.getStartedAt();
    }

    public SessionState getState() {
        return state;
    }

    public int getTimeboxMin() {
        return timeboxMin;
    }

    public long getActiveSeconds() {
        return activeSeconds;
    }

    public Instant getResumedAt() {
        return resumedAt;
    }

    /** Durée active arrondie à la minute (sessions terminées). */
    public Integer getDurationMin() {
        return state.isOpen() ? null : (int) Math.round(activeSeconds / 60.0);
    }

    public String getDraft() {
        return draft;
    }

    public List<SessionNote> getNotes() {
        return List.copyOf(notes);
    }

    public SessionNote note(UUID id) {
        return notes.stream().filter(n -> id.equals(n.getId())).findFirst()
                .orElseThrow(() -> new BusinessRuleException("SESSION_NOTE_UNKNOWN", "Note inconnue dans cette session."));
    }

    public Tbs getTbs() {
        return testPct == null ? null : new Tbs(testPct, bugPct, setupPct);
    }

    public List<String> getAreasCovered() {
        return List.copyOf(areasCovered);
    }

    public Proof getProof() {
        return proofFeelings == null ? null : new Proof(proofPast, proofResults, proofObstacles, proofOutlook, proofFeelings);
    }

    public String getDebriefedBy() {
        return debriefedBy;
    }

    public Instant getDebriefedAt() {
        return debriefedAt;
    }

    public String getApprovedBy() {
        return approvedBy;
    }

    public Instant getApprovedAt() {
        return approvedAt;
    }
}
