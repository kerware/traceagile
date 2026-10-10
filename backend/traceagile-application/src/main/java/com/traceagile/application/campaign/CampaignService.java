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

    /** {@code folder} : ADR-0018 dossier de l'arbre des campagnes ({@code null} = racine). */
    public record CampaignCommand(String name, CampaignScope scopeType, String sprintKey, String releaseKey, String environment,
                                  String buildVersion, LocalDate plannedStart, LocalDate plannedEnd, String folder) {

        public CampaignCommand(String name, CampaignScope scopeType, String sprintKey, String releaseKey, String environment,
                               String buildVersion, LocalDate plannedStart, LocalDate plannedEnd) {
            this(name, scopeType, sprintKey, releaseKey, environment, buildVersion, plannedStart, plannedEnd, null);
        }
    }

    /** Merge-patch : {@code null} = inchangé, {@link Optional#empty()} = effacé. */
    public record CampaignPatch(Optional<String> name, Optional<String> environment, Optional<String> buildVersion,
                                Optional<LocalDate> plannedStart, Optional<LocalDate> plannedEnd, Optional<String> folder) {

        public CampaignPatch(Optional<String> name, Optional<String> environment, Optional<String> buildVersion,
                             Optional<LocalDate> plannedStart, Optional<LocalDate> plannedEnd) {
            this(name, environment, buildVersion, plannedStart, plannedEnd, null);
        }
    }

    /** F-CMP-02 moyens de sélection, cumulables. */
    public enum Strategy { SPRINT_REQUIREMENTS, TAG, IMPACT, MANUAL, FROM_CAMPAIGN }

    /** {@code statuses} (FROM_CAMPAIGN) : derniers résultats retenus ; vide = échecs (FAILED, ERROR). */
    public record SelectionParams(String sprintKey, String tag, List<String> testKeys, List<String> requirementKeys, String campaignKey,
                                  Set<ExecutionStatus> statuses) {

        public SelectionParams(String sprintKey, String tag, List<String> testKeys, List<String> requirementKeys, String campaignKey) {
            this(sprintKey, tag, testKeys, requirementKeys, campaignKey, null);
        }
    }

    /**
     * ADR-0017 nouvelle campagne à partir d'une autre. Champs {@code null} : repris de la source.
     * {@code statuses} vide : tous les tests (duplication) ; sinon ceux dont la dernière tentative a ce statut.
     */
    public record CopyCommand(String name, CampaignScope scopeType, String sprintKey, String releaseKey, String environment,
                              String buildVersion, Set<ExecutionStatus> statuses, boolean keepAssignees) {
    }

    public record CopyResult(Campaign campaign, List<String> copied, List<Skipped> skipped) {
    }

    static final Set<ExecutionStatus> FAILURES = Set.of(ExecutionStatus.FAILED, ExecutionStatus.ERROR);

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
        campaign.relocate(command.folder());
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
        if (patch.folder() != null) {
            campaign.relocate(patch.folder().orElse(null));
        }
        record(campaign, AuditAction.UPDATED, before);
        return campaign;
    }

    /** ADR-0018 reclassement d'une campagne lors du renommage d'un dossier. */
    void relocate(Campaign campaign, String folder) {
        Map<String, Object> before = snapshot(campaign);
        campaign.relocate(folder);
        record(campaign, AuditAction.UPDATED, before);
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
            case FROM_CAMPAIGN -> fromCampaign(projectKey, p.campaignKey(), p.statuses());
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

    /** ADR-0018 ligne de jeu de données prévue ({@code dataSetName} {@code null} = valeurs par défaut). */
    public CampaignItem bindDataSet(String projectKey, UUID itemId, String dataSetName, Integer row) {
        CampaignItem item = item(projectKey, itemId);
        if (dataSetName == null && row != null) {
            throw new BusinessRuleException("EXECUTION_DATASET_UNKNOWN", "Choisissez le jeu de données de cette ligne.");
        }
        Campaign campaign = item.getCampaign();
        Map<String, Object> before = snapshot(campaign);
        campaign.bindDataSet(item, dataSetName, row);
        record(campaign, AuditAction.UPDATED, before);
        return item;
    }

    /** ADR-0018 décline le test sur toutes les lignes du jeu de données. */
    public Campaign expandDataSet(String projectKey, UUID itemId, String dataSetName) {
        CampaignItem item = item(projectKey, itemId);
        Campaign campaign = item.getCampaign();
        Map<String, Object> before = snapshot(campaign);
        campaign.expandDataSet(item, dataSetName);
        campaigns.flush();
        record(campaign, AuditAction.UPDATED, before);
        return campaign;
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

    /** F-CMP-02 / ADR-0017 tests d'une autre campagne selon leur dernier résultat (par défaut : les échecs). */
    private List<TestCase> fromCampaign(String projectKey, String campaignKey, Set<ExecutionStatus> statuses) {
        if (campaignKey == null) {
            throw new BusinessRuleException("SELECTION_CAMPAIGN_REQUIRED", "Indiquez la campagne dont reprendre les tests.");
        }
        Set<ExecutionStatus> wanted = statuses == null || statuses.isEmpty() ? FAILURES : statuses;
        return get(projectKey, campaignKey).getItems().stream().filter(i -> wanted.contains(i.lastStatus()))
                .map(CampaignItem::getTestCase).toList();
    }

    // ---------------------------------------------------------------- copie (ADR-0017)

    /**
     * Duplique une campagne, ou en génère une avec les tests dont le dernier résultat est dans
     * {@code statuses} : même ordre, même score, affectations conservées si demandé et encore
     * possibles ; seuls les tests READY sont repris. La source peut être terminée.
     */
    public CopyResult copy(String projectKey, String sourceKey, CopyCommand command) {
        Campaign source = get(projectKey, sourceKey);
        boolean sameScope = command.scopeType() == null;
        Campaign target = create(projectKey, new CampaignCommand(command.name(),
                sameScope ? source.getScopeType() : command.scopeType(),
                sameScope ? (source.getSprint() == null ? null : source.getSprint().getKey()) : command.sprintKey(),
                sameScope ? (source.getRelease() == null ? null : source.getRelease().getKey()) : command.releaseKey(),
                command.environment() != null ? command.environment() : source.getEnvironment(),
                command.buildVersion() != null ? command.buildVersion() : source.getBuildVersion(),
                sameScope ? source.getPlannedStart() : null, sameScope ? source.getPlannedEnd() : null, source.getFolder()));
        Map<String, Object> before = snapshot(target);
        Set<ExecutionStatus> statuses = command.statuses() == null ? Set.of() : command.statuses();
        List<String> copied = new ArrayList<>();
        List<Skipped> skipped = new ArrayList<>();
        for (CampaignItem item : source.getItems()) {
            if (!statuses.isEmpty() && !statuses.contains(item.lastStatus())) {
                continue;
            }
            TestCase test = item.getTestCase();
            if (test.getStatus() != TestCaseStatus.READY) {
                skipped.add(new Skipped(test.getKey(), "NOT_READY_" + test.getStatus().name()));
                continue;
            }
            CampaignItem added = target.add(test, item.getRiskScore(), item.getDataSetName(), item.getDataSetRow());
            if (added == null) {
                continue;
            }
            User assignee = item.getAssignee();
            if (command.keepAssignees() && assignee != null && !added.isExecutedByServer()
                    && projectService.isAllowed(assignee.getLogin(), projectKey, Permission.EXECUTION_WRITE)) {
                added.assign(assignee);
            }
            copied.add(test.getKey());
        }
        campaigns.flush();
        if (!copied.isEmpty()) {
            record(target, AuditAction.UPDATED, before);
        }
        return new CopyResult(target, copied, skipped);
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
        s.put("folder", campaign.getFolder());
        s.put("tests", campaign.getItems().stream().map(i -> i.getTestCase().getKey()
                + (i.getDataSetName() == null ? "" : " [" + i.getDataSetName() + " #" + (i.getDataSetRow() + 1) + "]")).toList());
        return s;
    }
}
