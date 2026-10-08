package com.traceagile.api.demo;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.application.testcase.BddService;
import com.traceagile.application.testcase.TestCasePatch;
import com.traceagile.application.testcase.TestCasePatch.StepDraft;
import com.traceagile.application.testcase.TestCaseRepository;
import com.traceagile.application.testcase.TestCaseService;
import com.traceagile.application.testcase.TestCaseService.CreateTestCaseCommand;
import com.traceagile.application.traceability.TraceLinkService.LinkDraft;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestTechnique;
import com.traceagile.domain.traceability.LinkType;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;

/**
 * §15.1 tests de démonstration du projet SHOP (lot 2) : 20 tests manuels, 8 chartes, 30 tests
 * automatisés dont 16 BDD générés depuis les critères Gherkin ; 2 tests orphelins et plusieurs
 * stories volontairement non couvertes. Contenu dans {@code demo/shop-tests.json}.
 */
@Component
public class DemoTestsLoader {

    record ManualDemo(String title, String folder, Priority priority, Integer duration, String requirement,
                      List<List<String>> steps, List<Map<String, String>> dataSet, String candidate) {
    }

    record CharterDemo(String title, String explore, String with, String toDiscover, Integer timebox, List<String> areas,
                       List<String> heuristics, String requirement) {
    }

    record AutomatedDemo(String title, TestTechnique technique, String framework, String path, String identifier,
                         List<String> tags, String requirement, Map<String, Object> parameters,
                         List<Map<String, Object>> dataSet, Map<String, String> env) {
    }

    record TestsDemo(List<ManualDemo> manual, List<CharterDemo> charters, List<AutomatedDemo> automated) {
    }

    static final String REPOSITORY = "https://git.example.com/shop/tests.git";

    private final TestCaseService tests;
    private final TestCaseRepository repository;
    private final BddService bdd;
    private final RequirementService requirements;
    private final ObjectMapper json;

    public DemoTestsLoader(TestCaseService tests, TestCaseRepository repository, BddService bdd,
                           RequirementService requirements, ObjectMapper json) {
        this.tests = tests;
        this.repository = repository;
        this.bdd = bdd;
        this.requirements = requirements;
        this.json = json;
    }

    public void load(String project) throws IOException {
        if (repository.existsByProject_Key(project)) {
            return;
        }
        TestsDemo demo;
        try (InputStream in = getClass().getResourceAsStream("/demo/shop-tests.json")) {
            demo = json.readValue(in, TestsDemo.class);
        }
        List<Requirement> backlog = requirements.backlog(project);
        Map<String, String> keyByTitle = backlog.stream().collect(Collectors.toMap(Requirement::getTitle, Requirement::getKey, (a, b) -> a));
        Function<String, List<LinkDraft>> links = title -> title == null ? List.of()
                : List.of(new LinkDraft(keyByTitle.get(title), LinkType.VERIFIES, List.of()));

        for (ManualDemo m : demo.manual()) {
            TestCasePatch.Builder details = TestCasePatch.builder()
                    .folder(m.folder()).priority(m.priority()).estimatedDurationMin(m.duration())
                    .steps(m.steps().stream().map(s -> new StepDraft(s.get(0), s.size() > 1 ? s.get(1) : null, s.size() > 2 ? s.get(2) : null)).toList())
                    .manualDataSet(m.dataSet());
            if (m.candidate() != null) {
                details.automationCandidate(true, m.candidate());
            }
            ready(tests.create(project, new CreateTestCaseCommand(TestKind.MANUAL, m.title(), null, null, details.build(),
                    links.apply(m.requirement()))).testCase());
        }
        for (CharterDemo c : demo.charters()) {
            TestCasePatch details = TestCasePatch.builder()
                    .mission(c.explore(), c.with(), c.toDiscover()).timeboxMin(c.timebox()).areas(c.areas()).heuristics(c.heuristics())
                    .folder("Exploratoire").build();
            ready(tests.create(project, new CreateTestCaseCommand(TestKind.EXPLORATORY, c.title(), null, null, details,
                    links.apply(c.requirement()))).testCase());
        }
        for (AutomatedDemo a : demo.automated()) {
            TestCasePatch details = TestCasePatch.builder()
                    .location(REPOSITORY, "main", a.path(), a.identifier())
                    .executionTags(a.tags()).parameters(a.parameters()).dataSet(a.dataSet()).environmentRequirements(a.env())
                    .folder("Automatisés/" + a.technique().name()).build();
            ready(tests.create(project, new CreateTestCaseCommand(TestKind.AUTOMATED, a.title(), a.technique(), a.framework(),
                    details, links.apply(a.requirement()))).testCase());
        }
        // F-REQ-11 : un test BDD par critère Gherkin du backlog.
        for (Requirement requirement : backlog) {
            for (AcceptanceCriterion criterion : requirement.getCriteria()) {
                if (criterion.getFormat() == CriterionFormat.GHERKIN) {
                    bdd.generateFromCriterion(project, criterion.getId()).forEach(this::ready);
                }
            }
        }
    }

    private void ready(TestCase test) {
        tests.changeStatus(test.getProject().getKey(), test.getKey(), TestCaseStatus.READY);
    }
}
