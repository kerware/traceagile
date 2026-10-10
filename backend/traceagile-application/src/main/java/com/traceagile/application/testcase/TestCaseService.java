package com.traceagile.application.testcase;

import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.audit.AuditService;
import com.traceagile.application.campaign.CampaignItemRepository;
import com.traceagile.application.execution.ExecutionRepository;
import com.traceagile.application.common.KeyGenerator;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.common.UnprocessableException;
import com.traceagile.application.common.VersionConflictException;
import com.traceagile.application.requirement.GherkinValidator;
import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.application.traceability.TraceLinkService.LinkDraft;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.audit.AuditAction;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.common.FieldChange;
import com.traceagile.domain.common.SnapshotDiff;
import com.traceagile.domain.testcase.AutomationFramework;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.testcase.TestCaseVersion;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestTechnique;
import java.util.ArrayList;
import java.util.List;
import java.util.Collection;
import java.util.Comparator;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Sort;
import java.util.Map;
import java.util.Objects;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** §6 référentiel de tests : création des trois natures, modification, versions (F-AUT-10), statut. */
@Service
@Transactional
public class TestCaseService {

    static final String KEY_PREFIX = "TC";
    public static final String AUDIT_TYPE = "TEST_CASE";
    /** F-MAN-02 tri par fréquence d'exécution ({@code sort=executionCount,desc}). */
    public static final String EXECUTION_COUNT = "executionCount";

    public record CreateTestCaseCommand(TestKind kind, String title, TestTechnique technique, String framework,
                                        TestCasePatch details, List<LinkDraft> links) {
    }

    /** Test enregistré et avertissements (tags Gherkin inconnus, F-AUT-06). */
    public record TestCaseResult(TestCase testCase, List<String> warnings) {
    }

    private final TestCaseRepository tests;
    private final TestCaseVersionRepository versions;
    private final ProjectRepository projects;
    private final AutomationFrameworkRepository frameworks;
    private final KeyGenerator keys;
    private final GherkinValidator gherkin;
    private final FeatureFileParser features;
    private final TraceLinkService links;
    private final AuditService audit;
    private final ExecutionRepository executions;
    private final CampaignItemRepository campaignItems;

    public TestCaseService(TestCaseRepository tests, TestCaseVersionRepository versions, ProjectRepository projects,
                           AutomationFrameworkRepository frameworks, KeyGenerator keys, GherkinValidator gherkin,
                           FeatureFileParser features, TraceLinkService links, AuditService audit, ExecutionRepository executions,
                           CampaignItemRepository campaignItems) {
        this.executions = executions;
        this.campaignItems = campaignItems;
        this.tests = tests;
        this.versions = versions;
        this.projects = projects;
        this.frameworks = frameworks;
        this.keys = keys;
        this.gherkin = gherkin;
        this.features = features;
        this.links = links;
        this.audit = audit;
    }

    // ---------------------------------------------------------------- lecture

    @Transactional(readOnly = true)
    public TestCase get(String projectKey, String key) {
        return tests.findByProject_KeyAndKey(projectKey, key)
                .orElseThrow(() -> new NotFoundException("TEST_NOT_FOUND", "Test « " + key + " » introuvable."));
    }

    @Transactional(readOnly = true)
    public Page<TestCase> search(String projectKey, TestCaseFilter filter, Pageable pageable) {
        Sort.Order byExecutions = pageable.getSort().getOrderFor(EXECUTION_COUNT);
        if (byExecutions == null) {
            return tests.search(projectKey, filter, pageable);
        }
        // F-MAN-02 candidats triés par fréquence d'exécution : tri en mémoire (propriété calculée).
        List<TestCase> all = tests.search(projectKey, filter, Pageable.unpaged(Sort.by("keyNumber"))).getContent();
        Map<UUID, Long> counts = executionCounts(all);
        Comparator<TestCase> comparator = Comparator.comparingLong((TestCase t) -> counts.getOrDefault(t.getId(), 0L));
        List<TestCase> sorted = all.stream().sorted(byExecutions.isDescending() ? comparator.reversed() : comparator).toList();
        int from = (int) Math.min(pageable.getOffset(), sorted.size());
        int to = Math.min(from + pageable.getPageSize(), sorted.size());
        return new PageImpl<>(sorted.subList(from, to), pageable, sorted.size());
    }

    /** F-MAN-02 nombre d'exécutions de chaque test (toutes campagnes, toutes tentatives). */
    @Transactional(readOnly = true)
    public Map<UUID, Long> executionCounts(Collection<TestCase> list) {
        if (list.isEmpty()) {
            return Map.of();
        }
        return executions.findByTestCase_IdInOrderByStartedAtDesc(list.stream().map(TestCase::getId).toList()).stream()
                .collect(Collectors.groupingBy(e -> e.getTestCase().getId(), Collectors.counting()));
    }

    /** §13.2 arbre par dossier ou par feature : tous les tests du projet. */
    @Transactional(readOnly = true)
    public List<TestCase> all(String projectKey) {
        return tests.findByProject_KeyOrderByKeyNumberAsc(projectKey);
    }

    @Transactional(readOnly = true)
    public List<TestCaseVersion> versions(String projectKey, String key) {
        return versions.findByTestCaseOrderByVersionNumberDesc(get(projectKey, key));
    }

    @Transactional(readOnly = true)
    public List<FieldChange> diff(String projectKey, String key, int from, int to) {
        TestCase test = get(projectKey, key);
        return SnapshotDiff.between(version(test, from).getSnapshot(), version(test, to).getSnapshot());
    }

    private TestCaseVersion version(TestCase test, int number) {
        return versions.findByTestCaseAndVersionNumber(test, number)
                .orElseThrow(() -> new NotFoundException("VERSION_NOT_FOUND", "Version " + number + " introuvable."));
    }

    // ---------------------------------------------------------------- écriture

    public TestCaseResult create(String projectKey, CreateTestCaseCommand command) {
        Project project = projects.findByKey(projectKey)
                .orElseThrow(() -> new NotFoundException("PROJECT_NOT_FOUND", "Projet « " + projectKey + " » introuvable."));
        if (command.kind() == null) {
            throw new BusinessRuleException("TEST_KIND_REQUIRED", "La nature du test est obligatoire.");
        }
        String key = keys.next(project, KEY_PREFIX);
        TestCase test = switch (command.kind()) {
            case MANUAL -> TestCase.manual(project, key, command.title());
            case EXPLORATORY -> TestCase.exploratory(project, key, command.title());
            case AUTOMATED -> {
                if (command.technique() == null) {
                    throw new BusinessRuleException("TEST_TECHNIQUE_REQUIRED", "La technique d'un test automatisé est obligatoire.");
                }
                yield TestCase.automated(project, key, command.title(), command.technique(),
                        command.framework() != null ? command.framework() : defaultFramework(command.technique()));
            }
        };
        if (command.details() != null) {
            command.details().applyTo(test, callable(projectKey));
        }
        prepareGherkin(test);
        TestCase saved = tests.save(test);
        versions.save(TestCaseVersion.of(saved));
        if (command.links() != null && !command.links().isEmpty()) {
            links.replace(saved, command.links());
        }
        List<String> warnings = applyTags(saved);
        audit.record(project.getId(), AUDIT_TYPE, saved.getId(), saved.getKey(), AuditAction.CREATED, Map.of(), saved.snapshot());
        return new TestCaseResult(saved, warnings);
    }

    /** §12 PATCH avec If-Match ; F-AUT-10 une modification significative crée une version. */
    public TestCaseResult update(String projectKey, String key, TestCasePatch patch, Long expectedVersion) {
        TestCase test = get(projectKey, key);
        VersionConflictException.check(expectedVersion, test.getVersion());
        Map<String, Object> before = test.snapshot();
        Object fingerprint = test.significantFingerprint();
        patch.applyTo(test, callable(projectKey));
        prepareGherkin(test);
        if (!Objects.equals(fingerprint, test.significantFingerprint())) {
            test.nextVersion();
            versions.save(TestCaseVersion.of(test));
        }
        List<String> warnings = applyTags(test);
        audit.record(test.getProject().getId(), AUDIT_TYPE, test.getId(), key, AuditAction.UPDATED, before, test.snapshot());
        return new TestCaseResult(test, warnings);
    }

    public TestCase changeStatus(String projectKey, String key, TestCaseStatus target) {
        TestCase test = get(projectKey, key);
        Map<String, Object> before = test.snapshot();
        test.changeStatus(target);
        if (target == TestCaseStatus.READY) {
            // §3.3-7 le test a été revu : ses liens ne sont plus suspects.
            links.clearSuspicionOf(test);
        }
        audit.record(test.getProject().getId(), AUDIT_TYPE, test.getId(), key, AuditAction.STATUS_CHANGED, before, test.snapshot());
        return test;
    }

    /** F-TRA-01 exigences liées saisies depuis la fiche test. */
    public TestCase replaceLinks(String projectKey, String key, List<LinkDraft> drafts) {
        TestCase test = get(projectKey, key);
        links.replace(test, drafts);
        return test;
    }

    /** §3.3-6 un test déjà exécuté ne se supprime pas (on le passe OBSOLETE) ; ni un test sélectionné dans une campagne. */
    public void delete(String projectKey, String key) {
        TestCase test = get(projectKey, key);
        if (executions.existsByTestCase_IdIn(List.of(test.getId()))) {
            throw new BusinessRuleException("TEST_ALREADY_EXECUTED", key + " a déjà été exécuté : passez-le à « Obsolète » plutôt que de le supprimer.");
        }
        List<String> callers = calledBy(test);
        if (!callers.isEmpty()) {
            throw new BusinessRuleException("TEST_CALLED", key + " est appelé par " + String.join(", ", callers) + " : retirez d'abord ces appels.");
        }
        if (campaignItems.existsByTestCase_Id(test.getId())) {
            throw new BusinessRuleException("TEST_IN_CAMPAIGN", key + " est sélectionné dans une campagne : retirez-le d'abord de la campagne.");
        }
        audit.record(test.getProject().getId(), AUDIT_TYPE, test.getId(), key, AuditAction.DELETED, test.snapshot(), Map.of());
        links.deleteLinksOf(test);
        tests.delete(test);
    }

    /** ADR-0018 clés des tests qui appellent ce test, dans l'ordre des clés. */
    @Transactional(readOnly = true)
    public List<String> calledBy(TestCase test) {
        if (test.getId() == null) {
            return List.of();
        }
        return tests.findDistinctBySteps_CalledTest_Id(test.getId()).stream()
                .sorted(java.util.Comparator.comparingInt(TestCase::getKeyNumber)).map(TestCase::getKey).toList();
    }

    // ---------------------------------------------------------------- outils

    /** ADR-0018 résolution des tests appelés par les pas. */
    private java.util.function.Function<String, TestCase> callable(String projectKey) {
        return k -> tests.findByProject_KeyAndKey(projectKey, k).orElseThrow(() ->
                new BusinessRuleException("TEST_CALL_INVALID", "Cas de test appelé « " + k + " » introuvable."));
    }

    /**
     * F-AUT-04 / F-AUT-05 la source Gherkin d'un test BDD est validée ; le nom de la fonctionnalité et,
     * à défaut, l'identifiant (nom du scénario) en sont déduits.
     */
    void prepareGherkin(TestCase test) {
        if (test.getKind() != TestKind.AUTOMATED || test.getAutomation().getGherkinSource() == null) {
            return;
        }
        String source = test.getAutomation().getGherkinSource();
        GherkinValidator.GherkinValidation validation = gherkin.validate(source);
        if (!validation.valid()) {
            throw new UnprocessableException("GHERKIN_INVALID", "Le scénario Gherkin contient des erreurs de syntaxe.",
                    Map.of("gherkinErrors", validation.errors()));
        }
        FeatureFileParser.ParsedFeature parsed = features.parse(source);
        test.getAutomation().setFeatureName(parsed.featureName());
        if (test.getAutomation().getTestIdentifier() == null && !parsed.scenarios().isEmpty()) {
            var automation = test.getAutomation();
            automation.setLocation(automation.getRepositoryUrl(), automation.getBranch(), automation.getPath(),
                    parsed.scenarios().getFirst().name());
        }
    }

    List<String> applyTags(TestCase test) {
        if (test.getKind() != TestKind.AUTOMATED || test.getAutomation().getGherkinSource() == null) {
            return List.of();
        }
        return new ArrayList<>(links.applyGherkinTags(test, test.getAutomation().getGherkinSource()));
    }

    /** F-AUT-01 premier framework de la donnée de référence pour cette technique. */
    String defaultFramework(TestTechnique technique) {
        return frameworks.findByTechniqueOrderByPositionAsc(technique).stream().findFirst().map(AutomationFramework::getName)
                .orElseThrow(() -> new BusinessRuleException("TEST_FRAMEWORK_REQUIRED",
                        "Aucun framework de référence pour " + technique + " : précisez-le."));
    }
}
