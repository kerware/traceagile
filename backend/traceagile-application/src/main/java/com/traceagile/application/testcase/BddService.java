package com.traceagile.application.testcase;

import com.traceagile.application.common.UnprocessableException;
import com.traceagile.application.requirement.AcceptanceCriterionService;
import com.traceagile.application.requirement.GherkinValidator;
import com.traceagile.application.testcase.FeatureFileParser.ParsedFeature;
import com.traceagile.application.testcase.FeatureFileParser.ParsedScenario;
import com.traceagile.application.testcase.TestCaseService.CreateTestCaseCommand;
import com.traceagile.application.testcase.TestCaseService.TestCaseResult;
import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestTechnique;
import com.traceagile.domain.traceability.LinkOrigin;
import com.traceagile.domain.traceability.LinkType;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §6.2 BDD intégré : génération depuis un critère (F-REQ-11), import / export de fichiers .feature
 * (F-AUT-05, F-AUT-07), étapes connues pour l'autocomplétion (F-AUT-04).
 */
@Service
@Transactional
public class BddService {

    static final String FEATURES_DIR = "src/test/resources/features/";

    public record FeatureFile(String path, String content) {
    }

    public record ImportResult(List<String> created, List<String> updated, List<String> warnings) {
    }

    public record StepUsage(String text, long count) {
    }

    private final TestCaseService tests;
    private final TestCaseRepository repository;
    private final AcceptanceCriterionService criteria;
    private final GherkinValidator validator;
    private final FeatureFileParser parser;
    private final TraceLinkService links;

    public BddService(TestCaseService tests, TestCaseRepository repository, AcceptanceCriterionService criteria,
                      GherkinValidator validator, FeatureFileParser parser, TraceLinkService links) {
        this.tests = tests;
        this.repository = repository;
        this.criteria = criteria;
        this.validator = validator;
        this.parser = parser;
        this.links = links;
    }

    /**
     * F-REQ-11 « Générer un test BDD » : un test automatisé BDD par scénario du critère, pré-rempli,
     * tagué {@code @REQ-n @AC-n-m} et lié à l'exigence et au critère.
     */
    public List<TestCase> generateFromCriterion(String projectKey, UUID criterionId) {
        AcceptanceCriterion criterion = criteria.get(projectKey, criterionId);
        if (criterion.getFormat() != CriterionFormat.GHERKIN) {
            throw new BusinessRuleException("CRITERION_NOT_GHERKIN", "Seul un critère Gherkin génère un test BDD.");
        }
        Requirement requirement = criterion.getRequirement();
        ParsedFeature feature = parser.parse(asFeature(criterion.getContent(), requirement));
        if (!feature.valid() || feature.scenarios().isEmpty()) {
            throw new UnprocessableException("GHERKIN_INVALID", "Le critère ne contient pas de scénario valide.",
                    Map.of("gherkinErrors", feature.errors()));
        }
        String tagLine = "@" + requirement.getKey() + " @AC-" + requirement.getKeyNumber() + "-" + criterion.getPosition();
        List<TestCase> generated = new ArrayList<>();
        for (ParsedScenario scenario : feature.scenarios()) {
            String block = withTags(scenario.block(), tagLine);
            TestCasePatch details = TestCasePatch.builder()
                    .objective("Vérifier le critère n° " + criterion.getPosition() + " de " + requirement.getKey() + " : "
                            + requirement.getTitle())
                    .location(null, null, FEATURES_DIR + slug(requirement.getKey() + " " + requirement.getTitle()) + ".feature",
                            scenario.name())
                    .gherkinSource(ParsedFeature.compose(feature.header(), List.of(block)))
                    .executionTags(List.of("bdd"))
                    .build();
            TestCase test = tests.create(projectKey, new CreateTestCaseCommand(TestKind.AUTOMATED, title(scenario, requirement),
                    TestTechnique.BDD, null, details, List.of())).testCase();
            links.ensureCriterionLink(test, criterion, LinkType.VERIFIES, LinkOrigin.GENERATED);
            generated.add(test);
        }
        return generated;
    }

    /** F-AUT-05 / F-AUT-07 import : un test par scénario ; un scénario déjà connu (même chemin et nom) est mis à jour. */
    public ImportResult importFeatures(String projectKey, List<FeatureFile> files, String framework) {
        List<String> created = new ArrayList<>();
        List<String> updated = new ArrayList<>();
        List<String> warnings = new ArrayList<>();
        List<Map<String, Object>> fileErrors = new ArrayList<>();
        Map<String, TestCase> existing = new LinkedHashMap<>();
        repository.findByProject_KeyAndKindOrderByKeyNumberAsc(projectKey, TestKind.AUTOMATED).stream()
                .filter(t -> t.getAutomation().getTechnique() == TestTechnique.BDD)
                .forEach(t -> existing.put(t.getAutomation().getPath() + "#" + t.getAutomation().getTestIdentifier(), t));
        for (FeatureFile file : files) {
            ParsedFeature feature = parser.parse(file.content());
            if (!feature.valid()) {
                fileErrors.add(Map.of("file", file.path(), "errors", feature.errors()));
                continue;
            }
            for (ParsedScenario scenario : feature.scenarios()) {
                String source = feature.documentFor(scenario);
                TestCase known = existing.get(file.path() + "#" + scenario.name());
                if (known != null) {
                    TestCaseResult result = tests.update(projectKey, known.getKey(),
                            TestCasePatch.builder().gherkinSource(source).build(), null);
                    warnings.addAll(prefixed(known.getKey(), result.warnings()));
                    updated.add(known.getKey());
                } else {
                    TestCasePatch details = TestCasePatch.builder()
                            .location(null, null, file.path(), scenario.name())
                            .gherkinSource(source)
                            .build();
                    TestCaseResult result = tests.create(projectKey, new CreateTestCaseCommand(TestKind.AUTOMATED,
                            truncate(scenario.name()), TestTechnique.BDD, framework, details, List.of()));
                    warnings.addAll(prefixed(result.testCase().getKey(), result.warnings()));
                    created.add(result.testCase().getKey());
                }
            }
        }
        if (!fileErrors.isEmpty()) {
            throw new UnprocessableException("FEATURE_INVALID", fileErrors.size() + " fichier(s) .feature invalide(s), rien n'a été importé.",
                    Map.of("fileErrors", fileErrors));
        }
        return new ImportResult(created, updated, warnings);
    }

    /**
     * F-AUT-07 export : les scénarios sont regroupés par fichier ({@code path}) ; l'en-tête est celui
     * du premier test du fichier. Sans clé précisée, tous les tests BDD du projet.
     */
    @Transactional(readOnly = true)
    public Map<String, String> exportFeatures(String projectKey, List<String> keys) {
        List<TestCase> selected = keys == null || keys.isEmpty()
                ? repository.findByProject_KeyAndKindOrderByKeyNumberAsc(projectKey, TestKind.AUTOMATED)
                : keys.stream().map(k -> tests.get(projectKey, k)).toList();
        Map<String, List<TestCase>> byFile = selected.stream()
                .filter(t -> t.getKind() == TestKind.AUTOMATED && t.getAutomation().getGherkinSource() != null)
                .sorted(Comparator.comparingInt(TestCase::getKeyNumber))
                .collect(Collectors.groupingBy(this::exportPath, LinkedHashMap::new, Collectors.toList()));
        Map<String, String> files = new LinkedHashMap<>();
        byFile.forEach((path, group) -> {
            ParsedFeature first = parser.parse(group.getFirst().getAutomation().getGherkinSource());
            List<String> blocks = group.stream()
                    .flatMap(t -> parser.parse(t.getAutomation().getGherkinSource()).scenarios().stream())
                    .map(ParsedScenario::block)
                    .toList();
            files.put(path, ParsedFeature.compose(first.header(), blocks));
        });
        return files;
    }

    /** F-AUT-04 étapes déjà utilisées dans le projet (tests BDD et critères Gherkin), les plus fréquentes d'abord. */
    @Transactional(readOnly = true)
    public List<StepUsage> steps(String projectKey, List<String> criterionSources, String query) {
        List<String> sources = new ArrayList<>(criterionSources);
        repository.findByProject_KeyAndKindOrderByKeyNumberAsc(projectKey, TestKind.AUTOMATED).stream()
                .map(t -> t.getAutomation().getGherkinSource())
                .filter(s -> s != null)
                .forEach(sources::add);
        Map<String, Long> counts = sources.stream()
                .flatMap(s -> parser.stepTexts(s).stream())
                .filter(text -> query == null || text.toLowerCase(Locale.ROOT).contains(query.toLowerCase(Locale.ROOT)))
                .collect(Collectors.groupingBy(text -> text, Collectors.counting()));
        return counts.entrySet().stream()
                .map(e -> new StepUsage(e.getKey(), e.getValue()))
                .sorted(Comparator.comparingLong(StepUsage::count).reversed().thenComparing(StepUsage::text))
                .limit(200)
                .toList();
    }

    // ---------------------------------------------------------------- outils

    /** Un critère est souvent un scénario seul : on l'insère dans une fonctionnalité nommée d'après l'exigence. */
    private String asFeature(String content, Requirement requirement) {
        ParsedFeature asIs = parser.parse(content);
        if (asIs.valid() && asIs.featureName() != null) {
            return content;
        }
        String language = validator.validate(content).language();
        String indented = content.lines().map(line -> line.isBlank() ? "" : "  " + line).collect(Collectors.joining("\n"));
        return "# language: " + language + "\n" + featureKeyword(language) + ": " + requirement.getTitle() + "\n\n" + indented + "\n";
    }

    private static String featureKeyword(String language) {
        return "fr".equals(language) ? "Fonctionnalité" : "Feature";
    }

    private static String withTags(String block, String tagLine) {
        String indent = block.substring(0, block.length() - block.stripLeading().length());
        return indent + tagLine + "\n" + block;
    }

    private String exportPath(TestCase test) {
        return Optional.ofNullable(test.getAutomation().getPath())
                .orElse(FEATURES_DIR + slug(Optional.ofNullable(test.getAutomation().getFeatureName()).orElse(test.getKey())) + ".feature");
    }

    private static String title(ParsedScenario scenario, Requirement requirement) {
        String name = scenario.name() == null || scenario.name().isBlank() ? requirement.getTitle() : scenario.name();
        return truncate(Character.toUpperCase(name.charAt(0)) + name.substring(1));
    }

    private static String truncate(String title) {
        return title.length() <= 200 ? title : title.substring(0, 200);
    }

    static String slug(String value) {
        String ascii = Normalizer.normalize(value, Normalizer.Form.NFD).replaceAll("\\p{M}", "");
        String slug = ascii.toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9]+", "-").replaceAll("(^-|-$)", "");
        return slug.length() > 80 ? slug.substring(0, 80) : slug;
    }

    private static List<String> prefixed(String key, List<String> warnings) {
        return warnings.stream().map(w -> key + " : " + w).toList();
    }
}
