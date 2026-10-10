package com.traceagile.application.exploratory;

import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.audit.AuditService;
import com.traceagile.application.campaign.CampaignRepository;
import com.traceagile.application.campaign.CampaignService;
import com.traceagile.application.common.ForbiddenException;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.defect.DefectService;
import com.traceagile.application.defect.DefectService.DefectCommand;
import com.traceagile.application.planning.PlanningService;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.application.testcase.TestCasePatch;
import com.traceagile.application.testcase.TestCaseService;
import com.traceagile.application.testcase.TestCaseService.CreateTestCaseCommand;
import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.application.traceability.TraceLinkService.LinkDraft;
import com.traceagile.application.traceability.TraceabilityService;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.audit.AuditAction;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.defect.Defect;
import com.traceagile.domain.defect.DefectDraft;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.exploratory.CharterProposal;
import com.traceagile.domain.exploratory.CharterProposals;
import com.traceagile.domain.exploratory.ExploratoryMetrics;
import com.traceagile.domain.exploratory.ExploratorySession;
import com.traceagile.domain.exploratory.NoteType;
import com.traceagile.domain.exploratory.Proof;
import com.traceagile.domain.exploratory.SessionDefectDraft;
import com.traceagile.domain.exploratory.SessionNote;
import com.traceagile.domain.exploratory.SessionState;
import com.traceagile.domain.exploratory.Tbs;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.testcase.ExploratoryCharter;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestKind;
import java.time.Clock;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.function.Predicate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §5 tests exploratoires (ADR-0019) : sessions chronométrées d'une charte de campagne, notes, anomalies
 * depuis une note BUG, fin (TBS), débriefing PROOF et approbation, chartes de suivi, génération de
 * chartes depuis une exigence, heuristiques du projet et métriques.
 */
@Service
@Transactional
public class ExploratoryService {

    public static final String AUDIT_TYPE = "SESSION";
    private static final int TITLE_MAX = 200;

    public record DraftForNote(DefectDraft draft, List<String> requirementKeys) {
    }

    public record Heuristics(List<String> suggested, List<String> custom) {
    }

    private final ExploratorySessionRepository sessions;
    private final CampaignService campaigns;
    private final CampaignRepository campaignRepository;
    private final DefectService defects;
    private final TestCaseService tests;
    private final TraceLinkService links;
    private final RequirementService requirements;
    private final PlanningService planning;
    private final ProjectRepository projects;
    private final AuditService audit;
    private final Clock clock;

    public ExploratoryService(ExploratorySessionRepository sessions, CampaignService campaigns, CampaignRepository campaignRepository,
                              DefectService defects, TestCaseService tests, TraceLinkService links, RequirementService requirements,
                              PlanningService planning, ProjectRepository projects, AuditService audit, Clock clock) {
        this.sessions = sessions;
        this.campaigns = campaigns;
        this.campaignRepository = campaignRepository;
        this.defects = defects;
        this.tests = tests;
        this.links = links;
        this.requirements = requirements;
        this.planning = planning;
        this.projects = projects;
        this.audit = audit;
        this.clock = clock;
    }

    // ---------------------------------------------------------------- sessions (F-EXP-05 à F-EXP-10)

    /** F-EXP-05 démarre une session (nouvelle tentative) sur une charte de la campagne. */
    public ExploratorySession start(String projectKey, UUID itemId, String login) {
        CampaignItem item = campaigns.item(projectKey, itemId);
        ExploratorySession session = sessions.save(ExploratorySession.start(item, login, clock.instant()));
        record(session, AuditAction.CREATED, Map.of());
        return session;
    }

    @Transactional(readOnly = true)
    public ExploratorySession get(String projectKey, UUID id) {
        return sessions.findByExecution_Id(id)
                .filter(s -> s.getExecution().getItem().getCampaign().getProject().getKey().equals(projectKey))
                .orElseThrow(() -> new NotFoundException("SESSION_NOT_FOUND", "Session exploratoire introuvable."));
    }

    /** Sessions du projet, filtrées par état, les plus récentes d'abord. */
    @Transactional(readOnly = true)
    public List<ExploratorySession> list(String projectKey, Set<SessionState> states) {
        return sessions.findByExecution_Item_Campaign_Project_Key(projectKey).stream()
                .filter(s -> states == null || states.isEmpty() || states.contains(s.getState()))
                .sorted(Comparator.comparing(ExploratorySession::getStartedAt).reversed())
                .toList();
    }

    /** F-EXP-05 pause / reprise ; F-EXP-10 brouillon de note ({@code null} = inchangé). */
    public ExploratorySession update(String projectKey, UUID id, String login, Boolean paused, Optional<String> draft) {
        ExploratorySession session = owned(projectKey, id, login);
        if (paused != null) {
            if (paused) {
                session.pause(clock.instant());
            } else {
                session.resume(clock.instant());
            }
        }
        if (draft != null) {
            session.saveDraft(draft.orElse(null));
        }
        return session;
    }

    public SessionNote addNote(String projectKey, UUID id, String login, NoteType type, String text) {
        ExploratorySession session = owned(projectKey, id, login);
        SessionNote note = session.addNote(type, text, clock.instant());
        sessions.flush();
        return note;
    }

    /** F-EXP-07 anomalie proposée pour une note BUG, avec les exigences que la charte couvre. */
    @Transactional(readOnly = true)
    public DraftForNote defectDraft(String projectKey, UUID id, UUID noteId) {
        ExploratorySession session = get(projectKey, id);
        SessionNote note = bugNote(session, noteId);
        return new DraftForNote(SessionDefectDraft.from(session, note), coveredRequirements(session.getCharter()));
    }

    /** F-EXP-07 crée l'anomalie d'une note BUG (liée à la tentative et, par défaut, aux exigences de la charte). */
    public Defect convertNote(String projectKey, UUID id, UUID noteId, DefectCommand command) {
        ExploratorySession session = get(projectKey, id);
        SessionNote note = bugNote(session, noteId);
        if (note.getDefect() != null) {
            throw new BusinessRuleException("SESSION_NOTE_ALREADY_CONVERTED", "Cette note a déjà donné l'anomalie " + note.getDefect().getKey() + ".");
        }
        Defect defect = defects.createFromExecution(projectKey, session.getExecution().getId(), command);
        note.attachDefect(defect);
        return defect;
    }

    /** F-EXP-09 fin de session. */
    public ExploratorySession finish(String projectKey, UUID id, String login, Tbs tbs, List<String> areas, ExecutionStatus status) {
        ExploratorySession session = owned(projectKey, id, login);
        Map<String, Object> before = snapshot(session);
        session.finish(tbs, areas, status, clock.instant());
        record(session, AuditAction.STATUS_CHANGED, before);
        return session;
    }

    // ---------------------------------------------------------------- débriefing (F-EXP-11 à F-EXP-13)

    public ExploratorySession debrief(String projectKey, UUID id, String login, Proof proof) {
        ExploratorySession session = owned(projectKey, id, login);
        Map<String, Object> before = snapshot(session);
        session.debrief(proof, login, clock.instant());
        record(session, AuditAction.UPDATED, before);
        return session;
    }

    public ExploratorySession approve(String projectKey, UUID id, String login) {
        ExploratorySession session = get(projectKey, id);
        Map<String, Object> before = snapshot(session);
        session.approve(login, clock.instant());
        record(session, AuditAction.STATUS_CHANGED, before);
        return session;
    }

    /**
     * F-EXP-12 une charte de suivi par mission de l'Outlook : même « avec », « pour découvrir »,
     * zones, heuristiques et durée que la charte de la session, liée aux mêmes exigences.
     */
    public List<TestCase> followUp(String projectKey, UUID id, List<String> missions) {
        ExploratorySession session = get(projectKey, id);
        TestCase source = session.getCharter();
        ExploratoryCharter charter = source.getCharter();
        List<LinkDraft> drafts = links.requirementsOf(source).stream()
                .map(l -> new LinkDraft(l.requirement().getKey(), l.linkType(), l.criteria().stream().map(AcceptanceCriterion::getPosition).toList()))
                .toList();
        List<TestCase> created = new ArrayList<>();
        for (String mission : missions == null ? List.<String>of() : missions) {
            if (mission == null || mission.isBlank()) {
                continue;
            }
            String explore = mission.strip().replaceFirst("(?i)^explorer\\s+", "");
            String title = "Explorer " + explore;
            TestCasePatch details = TestCasePatch.builder()
                    .mission(explore, charter.getWith(), charter.getToDiscover())
                    .areas(charter.getAreas()).heuristics(charter.getHeuristics()).timeboxMin(charter.getTimeboxMin())
                    .setupNotes("Suite de la session " + source.getKey() + " (tentative " + session.getExecution().getAttempt() + ").")
                    .build();
            created.add(tests.create(projectKey, new CreateTestCaseCommand(TestKind.EXPLORATORY,
                    title.length() <= TITLE_MAX ? title : title.substring(0, TITLE_MAX - 1) + "…", null, null, details, drafts)).testCase());
        }
        if (created.isEmpty()) {
            throw new BusinessRuleException("SESSION_FOLLOW_UP_EMPTY", "Indiquez au moins une mission de suivi.");
        }
        return created;
    }

    // ---------------------------------------------------------------- chartes et heuristiques (F-EXP-02, F-EXP-04)

    @Transactional(readOnly = true)
    public List<CharterProposal> proposals(String projectKey, String requirementKey) {
        Requirement requirement = requirements.get(projectKey, requirementKey);
        return CharterProposals.from(requirement, requirements.applicableTransverseNfrs(requirement));
    }

    @Transactional(readOnly = true)
    public Heuristics heuristics(String projectKey) {
        return new Heuristics(ExploratoryCharter.SUGGESTED_HEURISTICS, project(projectKey).getCustomHeuristics());
    }

    public Heuristics setHeuristics(String projectKey, List<String> custom) {
        Project project = project(projectKey);
        project.setCustomHeuristics(custom);
        return new Heuristics(ExploratoryCharter.SUGGESTED_HEURISTICS, project.getCustomHeuristics());
    }

    // ---------------------------------------------------------------- métriques (§5.4)

    /** {@code scope} : {@code campaign:CMP-n}, {@code sprint:SPR-n}, {@code release:REL-n} ; absent = projet. */
    @Transactional(readOnly = true)
    public ExploratoryMetrics metrics(String projectKey, String scope) {
        Predicate<Campaign> inScope = campaignScope(projectKey, scope);
        List<ExploratorySession> scoped = sessions.findByExecution_Item_Campaign_Project_Key(projectKey).stream()
                .filter(s -> inScope.test(s.getExecution().getItem().getCampaign())).toList();
        List<CampaignItem> planned = campaignRepository.findByProject_KeyOrderByKeyNumberDesc(projectKey).stream().filter(inScope)
                .flatMap(c -> c.getItems().stream()).filter(i -> i.getTestCase().getKind() == TestKind.EXPLORATORY).toList();
        Map<UUID, Defect> found = new LinkedHashMap<>();
        scoped.stream().filter(s -> !s.getState().isOpen())
                .forEach(s -> defects.ofExecution(s.getExecution()).forEach(d -> found.putIfAbsent(d.getId(), d)));
        return ExploratoryMetrics.of(scoped, planned, found.size());
    }

    private Predicate<Campaign> campaignScope(String projectKey, String scope) {
        if (scope == null || scope.isBlank() || scope.equals("project")) {
            return c -> true;
        }
        String value = scope.contains(":") ? scope.substring(scope.indexOf(':') + 1) : "";
        if (scope.startsWith("campaign:")) {
            Campaign campaign = campaigns.get(projectKey, value);
            return c -> c.getId().equals(campaign.getId());
        }
        if (scope.startsWith("sprint:")) {
            planning.sprint(projectKey, value);
        } else if (scope.startsWith("release:")) {
            planning.release(projectKey, value);
        } else {
            throw new BusinessRuleException("SCOPE_INVALID", "Périmètre inconnu : « " + scope + " » (project, campaign:CMP-n, sprint:SPR-n, release:REL-n).");
        }
        return TraceabilityService.executionScope(scope);
    }

    // ---------------------------------------------------------------- outils

    /** Les anomalies liées à la tentative de la session. */
    @Transactional(readOnly = true)
    public List<Defect> defectsOf(ExploratorySession session) {
        return defects.ofExecution(session.getExecution());
    }

    private ExploratorySession owned(String projectKey, UUID id, String login) {
        ExploratorySession session = get(projectKey, id);
        if (!session.getTester().equals(login)) {
            throw new ForbiddenException("SESSION_NOT_OWNER", "Seul " + session.getTester() + ", qui mène la session, peut la modifier.");
        }
        return session;
    }

    private static SessionNote bugNote(ExploratorySession session, UUID noteId) {
        SessionNote note = session.note(noteId);
        if (note.getType() != NoteType.BUG) {
            throw new BusinessRuleException("SESSION_NOTE_NOT_BUG", "Seule une note de type BUG devient une anomalie.");
        }
        return note;
    }

    private List<String> coveredRequirements(TestCase charter) {
        return links.requirementsOf(charter).stream().filter(l -> l.linkType().countsForCoverage()).map(l -> l.requirement().getKey()).toList();
    }

    private Project project(String projectKey) {
        return projects.findByKey(projectKey)
                .orElseThrow(() -> new NotFoundException("PROJECT_NOT_FOUND", "Projet « " + projectKey + " » introuvable."));
    }

    private void record(ExploratorySession session, AuditAction action, Map<String, Object> before) {
        audit.record(session.getExecution().getItem().getCampaign().getProject().getId(), AUDIT_TYPE, session.getId(),
                session.getCharter().getKey() + "#" + session.getExecution().getAttempt(), action, before, snapshot(session));
    }

    static Map<String, Object> snapshot(ExploratorySession session) {
        Map<String, Object> s = new LinkedHashMap<>();
        s.put("state", session.getState().name());
        s.put("status", session.getExecution().getStatus().name());
        s.put("tbs", session.getTbs() == null ? null : session.getTbs().testPct() + "/" + session.getTbs().bugPct() + "/" + session.getTbs().setupPct());
        s.put("areasCovered", session.getAreasCovered());
        s.put("feelings", session.getProof() == null ? null : session.getProof().feelings());
        s.put("approvedBy", session.getApprovedBy());
        return s;
    }
}
