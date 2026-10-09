package com.traceagile.application.campaign;

import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.administration.ProjectService;
import com.traceagile.application.administration.UserRepository;
import com.traceagile.application.audit.AuditService;
import com.traceagile.application.common.KeyGenerator;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.common.VersionConflictException;
import com.traceagile.application.planning.ReleaseRepository;
import com.traceagile.application.planning.SprintRepository;
import com.traceagile.application.requirement.RequirementRepository;
import com.traceagile.application.testcase.TestCaseRepository;
import com.traceagile.application.traceability.TraceLinkRepository;
import com.traceagile.application.traceability.TraceabilityService;
import com.traceagile.domain.administration.Permission;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.administration.User;
import com.traceagile.domain.audit.AuditAction;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.campaign.CampaignScope;
import com.traceagile.domain.campaign.RiskPriority;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.planning.Release;
import com.traceagile.domain.planning.Sprint;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RiskLevel;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.traceability.TraceEntityType;
import com.traceagile.domain.traceability.TraceLink;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §8.3 campagnes : création (F-CMP-01), sélection cumulable (F-CMP-02), priorisation par le risque
 * (F-CMP-03), affectation (F-CMP-04), charge par testeur (F-CMP-05), avancement.
 */
@Service
@Transactional
public class CampaignService {

    public static final String AUDIT_TYPE = "CAMPAIGN";

    public record CampaignCommand(String name, CampaignScope scopeType, String sprintKey, String releaseKey, String environment,
                                  String buildVersion, LocalDate plannedStart, LocalDate plannedEnd) {
    }

    /** Merge-patch : {@code null} = inchangé, {@link Optional#empty()} = effacé. */
    public record CampaignPatch(Optional<String> name, Optional<String> environment, Optional<String> buildVersion,
                                Optional<LocalDate> plannedStart, Optional<LocalDate> plannedEnd) {
    }

    /** F-CMP-02 moyens de sélection, cumulables. */
    public enum Strategy { SPRINT_REQUIREMENTS, TAG, IMPACT, MANUAL, FAILED_IN_CAMPAIGN }

    public record SelectionParams(String sprintKey, String tag, List<String> testKeys, List<String> requirementKeys, String campaignKey) {
    }

    public record Skipped(String testKey, String reason) {
    }

    public record SelectionResult(Campaign campaign, List<String> added, List<Skipped> skipped) {
    }

    public record Progress(int total, Map<ExecutionStatus, Integer> byStatus, int executed, Double executedPercent, Double passRate) {
    }

    /** F-CMP-05 charge d'un testeur (ou non affecté : {@code assignee == null}) en minutes. */
    public record Workload(User assignee, int manualMinutes, int exploratoryMinutes, int tests, int unestimated) {
    }

    private final CampaignRepository campaigns;
    private final CampaignItemRepository items;
    private final ProjectRepository projects;
    private final ProjectService projectService;
    private final UserRepository users;
    private final SprintRepository sprints;
    private final ReleaseRepository releases;
    private final TestCaseRepository tests;
    private final RequirementRepository requirements;
    private final TraceLinkRepository links;
    private final TraceabilityService traceability;
    private final KeyGenerator keys;
    private final AuditService audit;

    public CampaignService(CampaignRepository campaigns, CampaignItemRepository items, ProjectRepository projects,
                           ProjectService projectService, UserRepository users, SprintRepository sprints, ReleaseRepository releases,
                           TestCaseRepository tests, RequirementRepository requirements, TraceLinkRepository links,
                           TraceabilityService traceability, KeyGenerator keys, AuditService audit) {
        this.campaigns = campaigns;
        this.items = items;
        this.projects = projects;
        this.projectService = projectService;
        this.users = users;
        this.sprints = sprints;
        this.releases = releases;
        this.tests = tests;
        this.requirements = requirements;
        this.links = links;
        this.traceability = traceability;
        this.keys = keys;
        this.audit = audit;
    }

    // ---------------------------------------------------------------- lecture

    @Transactional(readOnly = true)
    public List<Campaign> list(String projectKey) {
        return campaigns.findByProject_KeyOrderByKeyNumberDesc(projectKey);
    }

    @Transactional(readOnly = true)
    public Campaign get(String projectKey, String key) {
        return campaigns.findByProject_KeyAndKey(projectKey, key)
                .orElseThrow(() -> new NotFoundException("CAMPAIGN_NOT_FOUND", "Campagne « " + key + " » introuvable."));
    }

    @Transactional(readOnly = true)
    public CampaignItem item(String projectKey, UUID itemId) {
        return items.findById(itemId).filter(i -> i.getCampaign().getProject().getKey().equals(projectKey))
                .orElseThrow(() -> new NotFoundException("CAMPAIGN_ITEM_NOT_FOUND", "Test de campagne introuvable."));
    }

    /** Avancement : statut de la dernière tentative de chaque test. */
    public static Progress progress(Campaign campaign) {
        Map<ExecutionStatus, Integer> byStatus = new EnumMap<>(ExecutionStatus.class);
        for (ExecutionStatus status : ExecutionStatus.values()) {
            byStatus.put(status, 0);
        }
        campaign.getItems().forEach(i -> byStatus.merge(i.lastStatus(), 1, Integer::sum));
        int total = campaign.getItems().size();
        int executed = (int) campaign.getItems().stream().filter(i -> i.latest() != null && i.latest().isFinal()).count();
        int passed = byStatus.get(ExecutionStatus.PASSED);
        return new Progress(total, byStatus, executed, total == 0 ? null : round(executed * 100.0 / total),
                executed == 0 ? null : round(passed * 100.0 / executed));
    }

    /** F-CMP-05 durée estimée des tests manuels et timebox des chartes, par testeur (non affectés à part). */
    public static List<Workload> workload(Campaign campaign) {
        Map<String, List<CampaignItem>> byAssignee = new LinkedHashMap<>();
        Map<String, User> usersByLogin = new HashMap<>();
        for (CampaignItem item : campaign.getItems()) {
            if (item.isExecutedByServer()) {
                continue;
            }
            String login = item.getAssignee() == null ? "" : item.getAssignee().getLogin();
            if (item.getAssignee() != null) {
                usersByLogin.put(login, item.getAssignee());
            }
            byAssignee.computeIfAbsent(login, l -> new ArrayList<>()).add(item);
        }
        List<Workload> result = new ArrayList<>();
        byAssignee.forEach((login, list) -> {
            int manual = 0;
            int exploratory = 0;
            int unestimated = 0;
            for (CampaignItem item : list) {
                TestCase test = item.getTestCase();
                if (test.getKind() == TestKind.EXPLORATORY) {
                    exploratory += test.getCharter().getTimeboxMin();
                } else if (test.getEstimatedDurationMin() != null) {
                    manual += test.getEstimatedDurationMin();
                } else {
                    unestimated++;
                }
            }
            result.add(new Workload(usersByLogin.get(login), manual, exploratory, list.size(), unestimated));
        });
        result.sort(Comparator.comparing((Workload w) -> w.assignee() == null).thenComparing(w -> w.assignee() == null ? "" : w.assignee().getLogin()));
        return result;
    }

    // ---------------------------------------------------------------- écriture (F-CMP-01)

    public Campaign create(String projectKey, CampaignCommand command) {
        Project project = projects.findByKey(projectKey)
                .orElseThrow(() -> new NotFoundException("PROJECT_NOT_FOUND", "Projet « " + projectKey + " » introuvable."));
        Sprint sprint = command.sprintKey() == null ? null : sprint(projectKey, command.sprintKey());
        Release release = command.releaseKey() == null ? null : release(projectKey, command.releaseKey());
        LocalDate start = command.plannedStart() != null ? command.plannedStart() : sprint != null ? sprint.getStartDate()
                : release != null ? release.getStartDate() : null;
        LocalDate end = command.plannedEnd() != null ? command.plannedEnd() : sprint != null ? sprint.getEndDate()
                : release != null ? release.getEndDate() : null;
        Campaign campaign = campaigns.save(new Campaign(project, keys.next(project, "CMP"), command.name(), command.scopeType(), sprint,
                release, command.environment(), command.buildVersion(), start, end));
        record(campaign, AuditAction.CREATED, Map.of());
        return campaign;
    }

    public Campaign update(String projectKey, String key, CampaignPatch patch, Long expectedVersion) {
        Campaign campaign = get(projectKey, key);
        VersionConflictException.check(expectedVersion, campaign.getVersion());
        Map<String, Object> before = snapshot(campaign);
        if (patch.name() != null) {
            campaign.rename(patch.name().orElse(null));
        }
        if (patch.environment() != null || patch.buildVersion() != null) {
            campaign.describeTarget(merge(patch.environment(), campaign.getEnvironment()), merge(patch.buildVersion(), campaign.getBuildVersion()));
        }
        if (patch.plannedStart() != null || patch.plannedEnd() != null) {
            campaign.schedule(merge(patch.plannedStart(), campaign.getPlannedStart()), merge(patch.plannedEnd(), campaign.getPlannedEnd()));
        }
        record(campaign, AuditAction.UPDATED, before);
        return campaign;
    }

    public Campaign start(String projectKey, String key) {
        Campaign campaign = get(projectKey, key);
        Map<String, Object> before = snapshot(campaign);
        campaign.start();
        record(campaign, AuditAction.STATUS_CHANGED, before);
        return campaign;
    }

    public Campaign complete(String projectKey, String key) {
        Campaign campaign = get(projectKey, key);
        Map<String, Object> before = snapshot(campaign);
        campaign.complete();
        record(campaign, AuditAction.STATUS_CHANGED, before);
        return campaign;
    }

    public Campaign abort(String projectKey, String key) {
        Campaign campaign = get(projectKey, key);
        Map<String, Object> before = snapshot(campaign);
        campaign.abort();
        record(campaign, AuditAction.STATUS_CHANGED, before);
        return campaign;
    }

    // ---------------------------------------------------------------- sélection (F-CMP-02, F-CMP-03)

    /**
     * F-CMP-02 ajoute les tests trouvés par la stratégie (cumulable avec les sélections précédentes).
     * Seuls les tests READY sont retenus ; les autres sont signalés. Les nouveaux tests arrivent en
     * fin de campagne, triés par score de risque (F-CMP-03).
     */
    public SelectionResult select(String projectKey, String key, Strategy strategy, SelectionParams params) {
        Campaign campaign = get(projectKey, key);
        Map<String, Object> before = snapshot(campaign);
        SelectionParams p = params == null ? new SelectionParams(null, null, null, null, null) : params;
        List<TestCase> found = switch (Objects.requireNonNull(strategy)) {
            case SPRINT_REQUIREMENTS -> linkedTo(projectKey, sprintRequirements(projectKey, campaign, p.sprintKey()));
            case TAG -> byTag(projectKey, p.tag());
            case IMPACT -> impacted(projectKey, p.requirementKeys());
            case MANUAL -> (p.testKeys() == null ? List.<String>of() : p.testKeys()).stream()
                    .map(testKey -> tests.findByProject_KeyAndKey(projectKey, testKey)
                            .orElseThrow(() -> new NotFoundException("TEST_NOT_FOUND", "Test « " + testKey + " » introuvable.")))
                    .toList();
            case FAILED_IN_CAMPAIGN -> failedIn(projectKey, p.campaignKey());
        };
        Map<UUID, Integer> scores = riskScores(projectKey);
        List<String> added = new ArrayList<>();
        List<Skipped> skipped = new ArrayList<>();
        List<TestCase> eligible = new ArrayList<>();
        for (TestCase test : found.stream().distinct().toList()) {
            if (campaign.contains(test)) {
                skipped.add(new Skipped(test.getKey(), "ALREADY_SELECTED"));
            } else if (test.getStatus() != TestCaseStatus.READY) {
                skipped.add(new Skipped(test.getKey(), "NOT_READY_" + test.getStatus().name()));
            } else {
                eligible.add(test);
            }
        }
        eligible.sort(Comparator.comparingInt((TestCase t) -> -score(scores, t)).thenComparingInt(TestCase::getKeyNumber));
        for (TestCase test : eligible) {
            campaign.add(test, score(scores, test));
            added.add(test.getKey());
        }
        if (!added.isEmpty()) {
            campaigns.flush();
            record(campaign, AuditAction.UPDATED, before);
        }
        return new SelectionResult(campaign, added, skipped);
    }

    public Campaign sortByRisk(String projectKey, String key) {
        Campaign campaign = get(projectKey, key);
        campaign.sortByRisk();
        return campaign;
    }

    public Campaign reorder(String projectKey, String key, List<UUID> itemIds) {
        Campaign campaign = get(projectKey, key);
        Map<UUID, CampaignItem> byId = campaign.getItems().stream().collect(Collectors.toMap(CampaignItem::getId, Function.identity()));
        List<CampaignItem> ordered = new ArrayList<>();
        for (UUID id : itemIds) {
            CampaignItem item = byId.get(id);
            if (item == null) {
                throw new BusinessRuleException("CAMPAIGN_ORDER_INVALID", "Élément inconnu dans l'ordre demandé.");
            }
            ordered.add(item);
        }
        campaign.reorder(ordered);
        return campaign;
    }

    public void removeItem(String projectKey, UUID itemId) {
        CampaignItem item = item(projectKey, itemId);
        Campaign campaign = item.getCampaign();
        Map<String, Object> before = snapshot(campaign);
        campaign.remove(item);
        record(campaign, AuditAction.UPDATED, before);
    }

    /** F-CMP-04 affectation à un membre du projet qui peut exécuter ; {@code null} = désaffecter. */
    public CampaignItem assign(String projectKey, UUID itemId, String login) {
        CampaignItem item = item(projectKey, itemId);
        User user = null;
        if (login != null) {
            user = users.findByLogin(login).orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Utilisateur « " + login + " » introuvable."));
            if (!projectService.isAllowed(login, projectKey, Permission.EXECUTION_WRITE)) {
                throw new BusinessRuleException("ASSIGNEE_CANNOT_EXECUTE", login + " ne peut pas exécuter de tests dans ce projet.");
            }
        }
        item.assign(user);
        return item;
    }

    /** Membres du projet qui peuvent exécuter (choix de l'affectation). */
    @Transactional(readOnly = true)
    public List<User> testers(String projectKey) {
        Project project = projects.findByKey(projectKey)
                .orElseThrow(() -> new NotFoundException("PROJECT_NOT_FOUND", "Projet « " + projectKey + " » introuvable."));
        return project.getMembers().stream().filter(m -> m.getRole().permissions().contains(Permission.EXECUTION_WRITE))
                .map(m -> m.getUser()).sorted(Comparator.comparing(User::getLogin)).toList();
    }

    // ---------------------------------------------------------------- stratégies

    private Set<UUID> sprintRequirements(String projectKey, Campaign campaign, String sprintKey) {
        List<Sprint> scope;
        if (sprintKey != null) {
            scope = List.of(sprint(projectKey, sprintKey));
        } else if (campaign.getScopeType() == CampaignScope.SPRINT) {
            scope = List.of(campaign.getSprint());
        } else if (campaign.getScopeType() == CampaignScope.RELEASE) {
            scope = campaign.getRelease().getSprints();
        } else {
            throw new BusinessRuleException("SELECTION_SPRINT_REQUIRED", "Indiquez le sprint dont les exigences sont à couvrir.");
        }
        Set<UUID> ids = new LinkedHashSet<>();
        scope.forEach(s -> s.requirements().forEach(r -> ids.add(r.getId())));
        return ids;
    }

    /** Tests liés (vérifie, vérifie partiellement) à ces exigences. */
    private List<TestCase> linkedTo(String projectKey, Set<UUID> requirementIds) {
        if (requirementIds.isEmpty()) {
            return List.of();
        }
        Set<UUID> testIds = links.findByTargetTypeAndTargetIdIn(TraceEntityType.REQUIREMENT, requirementIds).stream()
                .filter(l -> l.getLinkType().countsForCoverage()).map(TraceLink::getSourceId).collect(Collectors.toSet());
        return sorted(tests.findByIdIn(testIds));
    }

    private List<TestCase> byTag(String projectKey, String tag) {
        if (tag == null || tag.isBlank()) {
            throw new BusinessRuleException("SELECTION_TAG_REQUIRED", "Indiquez le tag recherché.");
        }
        String wanted = tag.strip().toLowerCase(Locale.ROOT);
        return tests.findByProject_KeyOrderByKeyNumberAsc(projectKey).stream()
                .filter(t -> t.getTags().contains(wanted)
                        || (t.getAutomation() != null && t.getAutomation().getExecutionTags().contains(wanted)))
                .toList();
    }

    /** Analyse d'impact des exigences données, sinon tests dont un lien est suspect (§3.3-7). */
    private List<TestCase> impacted(String projectKey, List<String> requirementKeys) {
        if (requirementKeys == null || requirementKeys.isEmpty()) {
            Set<UUID> suspect = links.findByProject_Key(projectKey).stream().filter(TraceLink::isSuspect)
                    .map(TraceLink::getSourceId).collect(Collectors.toSet());
            return sorted(tests.findByIdIn(suspect));
        }
        List<TestCase> result = new ArrayList<>();
        for (String key : requirementKeys) {
            traceability.impact(projectKey, key).tests().forEach(i -> result.add(i.test()));
        }
        return result;
    }

    private List<TestCase> failedIn(String projectKey, String campaignKey) {
        if (campaignKey == null) {
            throw new BusinessRuleException("SELECTION_CAMPAIGN_REQUIRED", "Indiquez la campagne dont reprendre les tests en échec.");
        }
        return get(projectKey, campaignKey).getItems().stream()
                .filter(i -> i.lastStatus() == ExecutionStatus.FAILED || i.lastStatus() == ExecutionStatus.ERROR)
                .map(CampaignItem::getTestCase).toList();
    }

    /** F-CMP-03 score de chaque test : risque maximal de ses exigences couvertes × sa priorité. */
    private Map<UUID, Integer> riskScores(String projectKey) {
        Map<UUID, Set<UUID>> requirementsByTest = new HashMap<>();
        links.findByProject_Key(projectKey).stream()
                .filter(l -> l.getTargetType() == TraceEntityType.REQUIREMENT && l.getLinkType().countsForCoverage())
                .forEach(l -> requirementsByTest.computeIfAbsent(l.getSourceId(), id -> new LinkedHashSet<>()).add(l.getTargetId()));
        Map<UUID, Requirement> byId = requirements.findByIdIn(requirementsByTest.values().stream().flatMap(Set::stream).collect(Collectors.toSet()))
                .stream().collect(Collectors.toMap(Requirement::getId, Function.identity()));
        Map<UUID, Integer> scores = new HashMap<>();
        for (TestCase test : tests.findByProject_KeyOrderByKeyNumberAsc(projectKey)) {
            RiskLevel risk = requirementsByTest.getOrDefault(test.getId(), Set.of()).stream().map(byId::get).filter(Objects::nonNull)
                    .map(Requirement::getRiskLevel).filter(Objects::nonNull).max(Comparator.naturalOrder()).orElse(null);
            scores.put(test.getId(), RiskPriority.score(risk, test.getPriority()));
        }
        return scores;
    }

    private static int score(Map<UUID, Integer> scores, TestCase test) {
        return scores.getOrDefault(test.getId(), RiskPriority.score(null, test.getPriority()));
    }

    // ---------------------------------------------------------------- outils

    private Sprint sprint(String projectKey, String key) {
        return sprints.findByProject_KeyAndKey(projectKey, key)
                .orElseThrow(() -> new NotFoundException("SPRINT_NOT_FOUND", "Sprint « " + key + " » introuvable."));
    }

    private Release release(String projectKey, String key) {
        return releases.findByProject_KeyAndKey(projectKey, key)
                .orElseThrow(() -> new NotFoundException("RELEASE_NOT_FOUND", "Release « " + key + " » introuvable."));
    }

    private static List<TestCase> sorted(List<TestCase> list) {
        return list.stream().sorted(Comparator.comparingInt(TestCase::getKeyNumber)).toList();
    }

    private static <T> T merge(Optional<T> field, T current) {
        return field == null ? current : field.orElse(null);
    }

    private static double round(double value) {
        return Math.round(value * 10) / 10.0;
    }

    private void record(Campaign campaign, AuditAction action, Map<String, Object> before) {
        audit.record(campaign.getProject().getId(), AUDIT_TYPE, campaign.getId(), campaign.getKey(), action, before, snapshot(campaign));
    }

    static Map<String, Object> snapshot(Campaign campaign) {
        Map<String, Object> s = new LinkedHashMap<>();
        s.put("name", campaign.getName());
        s.put("scopeType", campaign.getScopeType().name());
        s.put("sprint", campaign.getSprint() == null ? null : campaign.getSprint().getKey());
        s.put("release", campaign.getRelease() == null ? null : campaign.getRelease().getKey());
        s.put("environment", campaign.getEnvironment());
        s.put("buildVersion", campaign.getBuildVersion());
        s.put("status", campaign.getStatus().name());
        s.put("tests", campaign.getItems().stream().map(i -> i.getTestCase().getKey()).toList());
        return s;
    }
}
