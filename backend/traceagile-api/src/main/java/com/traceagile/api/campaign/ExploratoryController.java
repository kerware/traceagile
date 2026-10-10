package com.traceagile.api.campaign;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.api.campaign.CampaignDtos.CreateDefectRequest;
import com.traceagile.api.campaign.CampaignDtos.DefectDetail;
import com.traceagile.api.campaign.CampaignDtos.DefectDraftResponse;
import com.traceagile.api.campaign.ExploratoryDtos.CharterProposalResponse;
import com.traceagile.api.campaign.ExploratoryDtos.DebriefRequest;
import com.traceagile.api.campaign.ExploratoryDtos.ExploratoryMetricsResponse;
import com.traceagile.api.campaign.ExploratoryDtos.FinishSessionRequest;
import com.traceagile.api.campaign.ExploratoryDtos.FollowUpRequest;
import com.traceagile.api.campaign.ExploratoryDtos.FollowUpResponse;
import com.traceagile.api.campaign.ExploratoryDtos.HeuristicsRequest;
import com.traceagile.api.campaign.ExploratoryDtos.HeuristicsResponse;
import com.traceagile.api.campaign.ExploratoryDtos.ProofResponse;
import com.traceagile.api.campaign.ExploratoryDtos.SessionDetail;
import com.traceagile.api.campaign.ExploratoryDtos.SessionNoteRequest;
import com.traceagile.api.campaign.ExploratoryDtos.SessionNoteResponse;
import com.traceagile.api.campaign.ExploratoryDtos.SessionPatchRequest;
import com.traceagile.api.campaign.ExploratoryDtos.SessionSummary;
import com.traceagile.api.campaign.ExploratoryDtos.TbsAverageResponse;
import com.traceagile.api.campaign.ExploratoryDtos.TbsResponse;
import com.traceagile.api.web.MergePatch;
import com.traceagile.application.defect.DefectService.DefectCommand;
import com.traceagile.application.exploratory.ExploratoryService;
import com.traceagile.application.exploratory.ExploratoryService.DraftForNote;
import com.traceagile.application.exploratory.ExploratoryService.Heuristics;
import com.traceagile.domain.defect.Defect;
import com.traceagile.domain.exploratory.ExploratoryMetrics;
import com.traceagile.domain.exploratory.ExploratorySession;
import com.traceagile.domain.exploratory.NoteType;
import com.traceagile.domain.exploratory.Proof;
import com.traceagile.domain.exploratory.SessionNote;
import com.traceagile.domain.exploratory.SessionState;
import com.traceagile.domain.exploratory.Tbs;
import com.traceagile.domain.testcase.ExploratoryCharter;
import com.traceagile.domain.testcase.TestCase;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.Validator;
import java.net.URI;
import java.time.Clock;
import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** §12 Sessions exploratoires (§5.2, §5.3), génération de chartes (F-EXP-04), heuristiques (F-EXP-02), métriques (§5.4). */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}")
@Tag(name = "Exploratoire")
public class ExploratoryController {

    static final String READ = "hasPermission(#projectKey, 'Project', 'EXECUTION_READ')";
    static final String WRITE = "hasPermission(#projectKey, 'Project', 'EXECUTION_WRITE')";
    /** F-EXP-13 approbation par le PO ou un responsable des tests. */
    static final String APPROVE = "hasPermission(#projectKey, 'Project', 'REQUIREMENT_WRITE') or hasPermission(#projectKey, 'Project', 'CAMPAIGN_WRITE')";
    static final String TEST_READ = "hasPermission(#projectKey, 'Project', 'TEST_READ')";
    static final String TEST_WRITE = "hasPermission(#projectKey, 'Project', 'TEST_WRITE')";

    private final ExploratoryService exploratory;
    private final CampaignMapper mapper;
    private final ObjectMapper json;
    private final Validator validator;
    private final Clock clock;

    public ExploratoryController(ExploratoryService exploratory, CampaignMapper mapper, ObjectMapper json, Validator validator, Clock clock) {
        this.exploratory = exploratory;
        this.mapper = mapper;
        this.json = json;
        this.validator = validator;
        this.clock = clock;
    }

    // ---------------------------------------------------------------- sessions

    /** F-EXP-05 démarrer une session sur une charte de la campagne (nouvelle tentative). */
    @PostMapping("/campaign-items/{id}/sessions")
    @PreAuthorize(WRITE)
    public ResponseEntity<SessionDetail> start(@PathVariable String projectKey, @PathVariable UUID id, Authentication authentication) {
        ExploratorySession session = exploratory.start(projectKey, id, authentication.getName());
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/sessions/" + session.getExecution().getId()))
                .body(detail(session, authentication));
    }

    /** Sessions du projet, filtrées par état (en cours : RUNNING, PAUSED ; à débriefer : FINISHED). */
    @GetMapping("/sessions")
    @PreAuthorize(READ)
    public List<SessionSummary> list(@PathVariable String projectKey, @RequestParam(required = false) Set<SessionState> state) {
        Instant now = clock.instant();
        return exploratory.list(projectKey, state).stream().map(s -> summary(s, now)).toList();
    }

    @GetMapping("/sessions/{id}")
    @PreAuthorize(READ)
    public SessionDetail get(@PathVariable String projectKey, @PathVariable UUID id, Authentication authentication) {
        return detail(exploratory.get(projectKey, id), authentication);
    }

    /** F-EXP-05 pause / reprise ; F-EXP-10 sauvegarde automatique de la note en cours. */
    @PatchMapping(path = "/sessions/{id}", consumes = {"application/merge-patch+json", "application/json"})
    @PreAuthorize(WRITE)
    public SessionDetail update(@PathVariable String projectKey, @PathVariable UUID id, Authentication authentication,
                                @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(
                                        schema = @Schema(implementation = SessionPatchRequest.class)))
                                @RequestBody JsonNode body) {
        MergePatch f = MergePatch.of(body, SessionPatchRequest.class, json, validator);
        var paused = f.field("paused", Boolean.class);
        ExploratorySession session = exploratory.update(projectKey, id, authentication.getName(),
                paused == null ? null : paused.orElse(false), f.field("draft", String.class));
        return detail(session, authentication);
    }

    /** F-EXP-06 note horodatée. */
    @PostMapping("/sessions/{id}/notes")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize(WRITE)
    public SessionNoteResponse addNote(@PathVariable String projectKey, @PathVariable UUID id, Authentication authentication,
                                       @Valid @RequestBody SessionNoteRequest r) {
        return note(exploratory.addNote(projectKey, id, authentication.getName(), r.type(), r.text()));
    }

    /** F-EXP-07 anomalie proposée pour une note BUG. */
    @GetMapping("/sessions/{id}/notes/{noteId}/defect-draft")
    @PreAuthorize(READ)
    public DefectDraftResponse defectDraft(@PathVariable String projectKey, @PathVariable UUID id, @PathVariable UUID noteId) {
        DraftForNote d = exploratory.defectDraft(projectKey, id, noteId);
        return new DefectDraftResponse(d.draft().title(), d.draft().description(), d.draft().severity(), d.requirementKeys());
    }

    /** F-EXP-07 convertir une note BUG en anomalie (liée à la tentative et aux exigences de la charte). */
    @PostMapping("/sessions/{id}/notes/{noteId}/defects")
    @PreAuthorize(WRITE)
    public ResponseEntity<DefectDetail> convert(@PathVariable String projectKey, @PathVariable UUID id, @PathVariable UUID noteId,
                                                @Valid @RequestBody CreateDefectRequest r) {
        Defect defect = exploratory.convertNote(projectKey, id, noteId,
                new DefectCommand(r.title(), r.description(), r.severity(), r.externalRef(), r.requirementKeys()));
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/defects/" + defect.getKey())).body(mapper.defect(defect));
    }

    /** F-EXP-09 fin de session : TBS, zones couvertes, statut. */
    @PostMapping("/sessions/{id}/finish")
    @PreAuthorize(WRITE)
    public SessionDetail finish(@PathVariable String projectKey, @PathVariable UUID id, Authentication authentication,
                                @Valid @RequestBody FinishSessionRequest r) {
        return detail(exploratory.finish(projectKey, id, authentication.getName(), new Tbs(r.testPct(), r.bugPct(), r.setupPct()),
                r.areasCovered(), r.status()), authentication);
    }

    /** F-EXP-11 débriefing PROOF (modifiable jusqu'à l'approbation). */
    @PostMapping("/sessions/{id}/debrief")
    @PreAuthorize(WRITE)
    public SessionDetail debrief(@PathVariable String projectKey, @PathVariable UUID id, Authentication authentication,
                                 @Valid @RequestBody DebriefRequest r) {
        return detail(exploratory.debrief(projectKey, id, authentication.getName(),
                new Proof(r.past(), r.results(), r.obstacles(), r.outlook(), r.feelings())), authentication);
    }

    /** F-EXP-13 approbation du débriefing par un autre utilisateur : la session est « débriefée ». */
    @PostMapping("/sessions/{id}/debrief/approve")
    @PreAuthorize(APPROVE)
    public SessionDetail approve(@PathVariable String projectKey, @PathVariable UUID id, Authentication authentication) {
        return detail(exploratory.approve(projectKey, id, authentication.getName()), authentication);
    }

    /** F-EXP-12 chartes de suivi créées depuis l'Outlook. */
    @PostMapping("/sessions/{id}/follow-up-charters")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize(TEST_WRITE)
    public FollowUpResponse followUp(@PathVariable String projectKey, @PathVariable UUID id, @Valid @RequestBody FollowUpRequest r) {
        return new FollowUpResponse(exploratory.followUp(projectKey, id, r.missions()).stream().map(TestCase::getKey).toList());
    }

    // ---------------------------------------------------------------- chartes, heuristiques, métriques

    /** F-EXP-04 chartes proposées depuis une exigence (une par critère, une par ENF transverse). */
    @GetMapping("/requirements/{key}/charter-proposals")
    @PreAuthorize(TEST_READ)
    public List<CharterProposalResponse> proposals(@PathVariable String projectKey, @PathVariable String key) {
        return exploratory.proposals(projectKey, key).stream()
                .map(p -> new CharterProposalResponse(p.source(), p.criterionPosition(), p.title(), p.explore(), p.with(), p.toDiscover(),
                        p.areas(), p.heuristics(), p.requirementKeys()))
                .toList();
    }

    /** F-EXP-02 heuristiques suggérées et propres au projet. */
    @GetMapping("/heuristics")
    @PreAuthorize(TEST_READ)
    public HeuristicsResponse heuristics(@PathVariable String projectKey) {
        return heuristics(exploratory.heuristics(projectKey));
    }

    @PutMapping("/heuristics")
    @PreAuthorize(TEST_WRITE)
    public HeuristicsResponse setHeuristics(@PathVariable String projectKey, @Valid @RequestBody HeuristicsRequest r) {
        return heuristics(exploratory.setHeuristics(projectKey, r.custom()));
    }

    /** §5.4 {@code scope} : {@code campaign:CMP-n}, {@code sprint:SPR-n}, {@code release:REL-n} ; absent = projet. */
    @GetMapping("/exploratory/metrics")
    @PreAuthorize(READ)
    public ExploratoryMetricsResponse metrics(@PathVariable String projectKey, @RequestParam(required = false) String scope) {
        ExploratoryMetrics m = exploratory.metrics(projectKey, scope);
        return new ExploratoryMetricsResponse(m.sessions(), m.inProgress(), m.awaitingApproval(), m.debriefed(), m.totalMinutes(),
                m.averageMinutes(), m.averageTimeboxMin(), m.durationVsTargetPct(),
                m.averageTbs() == null ? null : new TbsAverageResponse(m.averageTbs().testPct(), m.averageTbs().bugPct(), m.averageTbs().setupPct()),
                m.defectsPerHour(), m.chartersPlanned(), m.chartersExecuted(), m.averageConfidence(), m.neverExploredAreas());
    }

    // ---------------------------------------------------------------- correspondance

    private static HeuristicsResponse heuristics(Heuristics h) {
        return new HeuristicsResponse(h.suggested(), h.custom());
    }

    private SessionNoteResponse note(SessionNote n) {
        return new SessionNoteResponse(n.getId(), n.getType(), n.getOffsetSeconds(), n.offsetLabel(), n.getText(), n.getNotedAt(),
                n.getDefect() == null ? null : mapper.defectRef(n.getDefect()));
    }

    private SessionDetail detail(ExploratorySession s, Authentication authentication) {
        Instant now = clock.instant();
        ExploratoryCharter charter = s.getCharter().getCharter();
        Tbs tbs = s.getTbs();
        Proof proof = s.getProof();
        return new SessionDetail(s.getExecution().getId(), s.getExecution().getItem().getId(), mapper.test(s.getCharter()),
                charter.missionSentence(), charter.getAreas(), charter.getHeuristics(), charter.getSetupNotes(), charter.getTargetedRisk(),
                s.getTimeboxMin(), mapper.ref(s.getExecution().getItem().getCampaign()), s.getExecution().getAttempt(), s.getTester(),
                s.getState(), s.getExecution().getStatus(), s.getStartedAt(), s.getExecution().getEndedAt(), s.elapsedSeconds(now), now,
                s.getDurationMin(), s.getDraft(), s.getNotes().stream().map(this::note).toList(),
                tbs == null ? null : new TbsResponse(tbs.testPct(), tbs.bugPct(), tbs.setupPct()), s.getAreasCovered(),
                proof == null ? null : new ProofResponse(proof.past(), proof.results(), proof.obstacles(), proof.outlook(), proof.feelings(),
                        proof.outlookItems()),
                s.getDebriefedBy(), s.getDebriefedAt(), s.getApprovedBy(), s.getApprovedAt(),
                exploratory.defectsOf(s).stream().map(mapper::defectRef).toList(),
                s.getTester().equals(authentication.getName()), s.getVersion());
    }

    private SessionSummary summary(ExploratorySession s, Instant now) {
        List<SessionNote> notes = s.getNotes();
        return new SessionSummary(s.getExecution().getId(), mapper.test(s.getCharter()), mapper.ref(s.getExecution().getItem().getCampaign()),
                s.getExecution().getAttempt(), s.getTester(), s.getState(), s.getExecution().getStatus(), s.getStartedAt(),
                s.elapsedSeconds(now), s.getTimeboxMin(), s.getDurationMin(), notes.size(),
                (int) notes.stream().filter(n -> n.getType() == NoteType.BUG).count(), s.getProof() != null,
                s.getProof() == null ? null : s.getProof().feelings(), s.getApprovedBy());
    }
}
