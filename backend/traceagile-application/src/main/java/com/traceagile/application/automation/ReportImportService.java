package com.traceagile.application.automation;

import com.traceagile.application.automation.ReportParser.ReportFormat;
import com.traceagile.application.automation.ReportParser.ReportResult;
import com.traceagile.application.campaign.CampaignRepository;
import com.traceagile.application.campaign.CampaignService;
import com.traceagile.application.execution.ExecutionRepository;
import com.traceagile.application.requirement.RequirementRepository;
import com.traceagile.application.testcase.TestCasePatch;
import com.traceagile.application.testcase.TestCaseRepository;
import com.traceagile.application.testcase.TestCaseService;
import com.traceagile.application.testcase.TestCaseService.CreateTestCaseCommand;
import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.application.traceability.TraceLinkService.LinkDraft;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.ExecutionOrigin;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestTechnique;
import com.traceagile.domain.traceability.LinkType;
import java.time.Clock;
import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * F-EXE-10 import manuel de résultats dans une campagne (ADR-0020) : chaque résultat du rapport est
 * rapproché d'un test automatisé par son {@code testIdentifier}, sinon par un tag d'exigence quand
 * l'exigence n'a qu'un test automatisé. En aperçu rien n'est écrit ; à l'application, les inconnus
 * peuvent être créés (technique déduite du format, liés aux exigences des tags), les tests sont
 * ajoutés à la campagne au besoin et chaque résultat devient une tentative « automatisée ».
 */
@Service
@Transactional
public class ReportImportService {

    public enum MatchedBy { IDENTIFIER, REQUIREMENT_TAG, CREATED }

    public record ImportLine(String name, String identifier, ExecutionStatus status, Long durationMs, String message,
                             List<String> requirementKeys, String testKey, MatchedBy matchedBy) {
    }

    public record ImportResult(List<ImportLine> lines, List<String> created, int recorded, boolean applied) {
    }

    private static final Map<ReportFormat, TestTechnique> TECHNIQUE = Map.of(ReportFormat.JUNIT, TestTechnique.UNIT, ReportFormat.JEST, TestTechnique.UNIT,
            ReportFormat.CUCUMBER, TestTechnique.BDD, ReportFormat.ROBOT, TestTechnique.KEYWORD, ReportFormat.PLAYWRIGHT, TestTechnique.UI);
    private static final Map<ReportFormat, String> FRAMEWORK = Map.of(ReportFormat.JUNIT, "JUnit 5", ReportFormat.JEST, "Jest", ReportFormat.CUCUMBER, "Cucumber-JVM",
            ReportFormat.ROBOT, "Robot Framework", ReportFormat.PLAYWRIGHT, "Playwright");

    private final ReportParser parser;
    private final CampaignService campaigns;
    private final CampaignRepository campaignRepository;
    private final TestCaseRepository tests;
    private final TestCaseService testService;
    private final RequirementRepository requirements;
    private final TraceLinkService links;
    private final ExecutionRepository executions;
    private final FlakyService flaky;
    private final Clock clock;

    public ReportImportService(ReportParser parser, CampaignService campaigns, CampaignRepository campaignRepository, TestCaseRepository tests,
                               TestCaseService testService, RequirementRepository requirements, TraceLinkService links,
                               ExecutionRepository executions, FlakyService flaky, Clock clock) {
        this.parser = parser;
        this.campaigns = campaigns;
        this.campaignRepository = campaignRepository;
        this.tests = tests;
        this.testService = testService;
        this.requirements = requirements;
        this.links = links;
        this.executions = executions;
        this.flaky = flaky;
        this.clock = clock;
    }

    /**
     * @param apply         {@code false} : aperçu seulement
     * @param createUnknown créer les tests inconnus (sinon leurs résultats sont ignorés)
     */
    public ImportResult importReport(String projectKey, String campaignKey, ReportFormat format, byte[] content, String fileName,
                                     boolean apply, boolean createUnknown) {
        Campaign campaign = campaigns.get(projectKey, campaignKey);
        List<ReportResult> results = parser.parse(format, content);
        Map<String, TestCase> byIdentifier = new HashMap<>();
        tests.findByProject_KeyAndKindOrderByKeyNumberAsc(projectKey, TestKind.AUTOMATED).forEach(t -> {
            String identifier = t.getAutomation().getTestIdentifier();
            if (identifier != null) {
                byIdentifier.putIfAbsent(identifier.strip().toLowerCase(Locale.ROOT), t);
            }
        });
        List<ImportLine> lines = new ArrayList<>();
        Map<ImportLine, TestCase> matches = new LinkedHashMap<>();
        for (ReportResult result : results) {
            List<String> known = result.requirementKeys().stream().filter(k -> requirements.findByProject_KeyAndKey(projectKey, k).isPresent()).toList();
            MatchedBy by = null;
            TestCase test = result.identifiers().stream().map(id -> byIdentifier.get(id.strip().toLowerCase(Locale.ROOT)))
                    .filter(t -> t != null).findFirst().orElse(null);
            if (test != null) {
                by = MatchedBy.IDENTIFIER;
            } else {
                test = byRequirementTag(projectKey, known).orElse(null);
                by = test == null ? null : MatchedBy.REQUIREMENT_TAG;
            }
            ImportLine line = new ImportLine(result.name(), result.identifier(), result.status(), result.durationMs(), result.message(), known,
                    test == null ? null : test.getKey(), by);
            lines.add(line);
            if (test != null) {
                matches.put(line, test);
            }
        }
        if (!apply) {
            return new ImportResult(lines, List.of(), 0, false);
        }

        List<String> created = new ArrayList<>();
        List<ImportLine> applied = new ArrayList<>();
        for (ImportLine line : lines) {
            TestCase test = matches.get(line);
            if (test == null && createUnknown) {
                test = create(projectKey, format, line);
                created.add(test.getKey());
                byIdentifier.put(line.identifier().toLowerCase(Locale.ROOT), test);
                line = new ImportLine(line.name(), line.identifier(), line.status(), line.durationMs(), line.message(), line.requirementKeys(),
                        test.getKey(), MatchedBy.CREATED);
                matches.put(line, test);
            }
            applied.add(line);
        }
        Instant now = clock.instant();
        int recorded = 0;
        for (ImportLine line : applied) {
            TestCase test = matches.get(line);
            if (test == null) {
                continue;
            }
            CampaignItem item = campaign.getItems().stream().filter(i -> i.getTestCase().getId().equals(test.getId())).findFirst()
                    .orElseGet(() -> campaign.add(test, 0));
            campaignRepository.flush();
            long duration = line.durationMs() == null ? 0 : line.durationMs();
            String comment = "Import « " + (fileName == null ? format.name() : fileName) + " »" + (line.message() == null ? "" : " : " + line.message());
            executions.save(Execution.recorded(item, ExecutionOrigin.AUTOMATED, line.status(), "import", now.minusMillis(duration), now,
                    comment.length() <= 2000 ? comment : comment.substring(0, 1999) + "…"));
            flaky.recompute(test);
            recorded++;
        }
        return new ImportResult(applied, created, recorded, true);
    }

    /** Une exigence d'un tag n'a qu'un test automatisé lié : c'est lui. */
    private Optional<TestCase> byRequirementTag(String projectKey, List<String> requirementKeys) {
        List<TestCase> candidates = requirementKeys.stream()
                .map(k -> requirements.findByProject_KeyAndKey(projectKey, k)).flatMap(Optional::stream)
                .flatMap((Requirement r) -> links.testsOf(r).stream()).map(TraceLinkService.TestLink::testCase)
                .filter(t -> t.getKind() == TestKind.AUTOMATED).distinct().toList();
        return candidates.size() == 1 ? Optional.of(candidates.getFirst()) : Optional.empty();
    }

    private TestCase create(String projectKey, ReportFormat format, ImportLine line) {
        String title = line.name().length() <= 200 ? line.name() : line.name().substring(0, 199) + "…";
        TestCasePatch details = TestCasePatch.builder().location(null, null, null, line.identifier())
                .description("Créé à l'import d'un rapport " + format + ".").build();
        List<LinkDraft> drafts = line.requirementKeys().stream().map(k -> new LinkDraft(k, LinkType.VERIFIES, List.of())).toList();
        return testService.create(projectKey, new CreateTestCaseCommand(TestKind.AUTOMATED, title, TECHNIQUE.get(format), FRAMEWORK.get(format),
                details, drafts)).testCase();
    }
}
