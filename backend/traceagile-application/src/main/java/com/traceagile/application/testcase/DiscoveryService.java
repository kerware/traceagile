package com.traceagile.application.testcase;

import com.traceagile.application.requirement.RequirementRepository;
import com.traceagile.application.testcase.TestCaseService.CreateTestCaseCommand;
import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestTechnique;
import com.traceagile.domain.traceability.LinkOrigin;
import com.traceagile.domain.traceability.LinkType;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * F-AUT-08 import d'un rapport de découverte : crée les tests automatisés manquants, met à jour les
 * tags et mots-clés des tests connus et signale les tests disparus du dépôt. F-AUT-09 : les exigences
 * citées par annotation ({@code @Requirement("REQ-12")}…) deviennent des liens (ADR-0012).
 */
@Service
@Transactional
public class DiscoveryService {

    public record DiscoveredTest(TestTechnique technique, String framework, String language, String path,
                                 String testIdentifier, String title, List<String> tags, List<String> requirements,
                                 List<String> keywords) {
    }

    public record DiscoveryReport(String repositoryUrl, String branch, List<DiscoveredTest> tests) {
    }

    public record DiscoveryResult(List<String> created, List<String> updated, List<String> disappeared, List<String> warnings) {
    }

    private final TestCaseService tests;
    private final TestCaseRepository repository;
    private final RequirementRepository requirements;
    private final TraceLinkService links;

    public DiscoveryService(TestCaseService tests, TestCaseRepository repository, RequirementRepository requirements,
                            TraceLinkService links) {
        this.tests = tests;
        this.repository = repository;
        this.requirements = requirements;
        this.links = links;
    }

    public DiscoveryResult importReport(String projectKey, DiscoveryReport report) {
        if (report.tests() == null) {
            throw new BusinessRuleException("DISCOVERY_EMPTY", "Le rapport ne contient pas de liste « tests ».");
        }
        Map<String, TestCase> known = new LinkedHashMap<>();
        repository.findByProject_KeyAndKindOrderByKeyNumberAsc(projectKey, TestKind.AUTOMATED).stream()
                .filter(t -> sameRepository(t, report.repositoryUrl()))
                .forEach(t -> known.put(identity(t.getAutomation().getPath(), t.getAutomation().getTestIdentifier()), t));
        List<String> created = new ArrayList<>();
        List<String> updated = new ArrayList<>();
        List<String> warnings = new ArrayList<>();
        Set<String> seen = new HashSet<>();
        for (DiscoveredTest discovered : report.tests()) {
            if (discovered.testIdentifier() == null || discovered.testIdentifier().isBlank() || discovered.technique() == null) {
                warnings.add("Test ignoré : technique et identifiant sont obligatoires (" + discovered.path() + ").");
                continue;
            }
            String identity = identity(discovered.path(), discovered.testIdentifier());
            seen.add(identity);
            TestCase test = known.get(identity);
            if (test == null) {
                TestCasePatch details = TestCasePatch.builder()
                        .language(discovered.language())
                        .location(report.repositoryUrl(), report.branch(), discovered.path(), discovered.testIdentifier())
                        .executionTags(discovered.tags())
                        .build();
                String title = discovered.title() != null && !discovered.title().isBlank() ? discovered.title() : discovered.testIdentifier();
                test = tests.create(projectKey, new CreateTestCaseCommand(TestKind.AUTOMATED,
                        title.length() > 200 ? title.substring(0, 200) : title, discovered.technique(),
                        discovered.framework(), details, List.of())).testCase();
                test.changeStatus(TestCaseStatus.READY);
                created.add(test.getKey());
            } else {
                tests.update(projectKey, test.getKey(), TestCasePatch.builder().executionTags(discovered.tags()).build(), null);
                updated.add(test.getKey());
            }
            test.getAutomation().setKeywords(discovered.keywords());
            test.getAutomation().setMissingInRepository(false);
            for (String key : discovered.requirements() == null ? List.<String>of() : discovered.requirements()) {
                TestCase linked = test;
                requirements.findByProject_KeyAndKey(projectKey, key).ifPresentOrElse(
                        r -> links.ensureRequirementLink(linked, r, LinkType.VERIFIES, LinkOrigin.DISCOVERY),
                        () -> warnings.add(linked.getKey() + " : exigence " + key + " inconnue."));
            }
        }
        List<String> disappeared = new ArrayList<>();
        known.forEach((identity, test) -> {
            if (!seen.contains(identity) && test.getAutomation().getTechnique() != TestTechnique.BDD) {
                test.getAutomation().setMissingInRepository(true);
                disappeared.add(test.getKey());
            }
        });
        return new DiscoveryResult(created, updated, disappeared, warnings);
    }

    private static boolean sameRepository(TestCase test, String repositoryUrl) {
        return repositoryUrl == null || test.getAutomation().getRepositoryUrl() == null
                || Objects.equals(test.getAutomation().getRepositoryUrl(), repositoryUrl);
    }

    private static String identity(String path, String identifier) {
        return Objects.toString(path, "") + "#" + identifier;
    }
}
