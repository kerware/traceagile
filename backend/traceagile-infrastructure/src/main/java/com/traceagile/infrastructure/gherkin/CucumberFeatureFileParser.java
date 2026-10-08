package com.traceagile.infrastructure.gherkin;

import com.traceagile.application.requirement.GherkinValidator;
import com.traceagile.application.requirement.GherkinValidator.GherkinError;
import com.traceagile.application.testcase.FeatureFileParser;
import io.cucumber.gherkin.GherkinParser;
import io.cucumber.messages.types.Envelope;
import io.cucumber.messages.types.Feature;
import io.cucumber.messages.types.FeatureChild;
import io.cucumber.messages.types.GherkinDocument;
import io.cucumber.messages.types.RuleChild;
import io.cucumber.messages.types.Scenario;
import io.cucumber.messages.types.Step;
import io.cucumber.messages.types.Tag;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.TreeSet;
import java.util.regex.Pattern;
import org.springframework.stereotype.Component;

/**
 * F-AUT-05 / F-AUT-07 découpage d'un .feature avec io.cucumber:gherkin. L'en-tête est tout ce qui
 * précède le premier scénario ou la première règle ; un scénario va de ses tags à l'élément suivant.
 * Les scénarios placés dans une règle (« Règle: ») sont repris sans la règle (ADR-0012). Sans
 * directive {@code # language}, le français puis l'anglais sont essayés, comme pour la validation.
 */
@Component
public class CucumberFeatureFileParser implements FeatureFileParser {

    private static final Pattern LANGUAGE = Pattern.compile("^\\s*#\\s*language\\s*:", Pattern.MULTILINE);

    private final GherkinValidator validator;
    private final GherkinParser parser = GherkinParser.builder()
            .includeSource(false)
            .includeGherkinDocument(true)
            .includePickles(false)
            .build();

    public CucumberFeatureFileParser(GherkinValidator validator) {
        this.validator = validator;
    }

    @Override
    public ParsedFeature parse(String source) {
        List<String> candidates = LANGUAGE.matcher(source).find()
                ? List.of(source)
                : List.of("# language: fr\n" + source, source);
        ParsedFeature best = null;
        for (String candidate : candidates) {
            ParsedFeature parsed = parseExactly(candidate);
            if (parsed.valid() && parsed.featureName() != null) {
                return parsed;
            }
            if (best == null) {
                best = parsed;
            }
        }
        // Erreurs positionnées sur le texte d'origine : celles du validateur (lignes recalées).
        List<GherkinError> errors = validator.validate(source).errors();
        return new ParsedFeature(best.language(), null, "", List.of(),
                errors.isEmpty() ? List.of(new GherkinError(1, 1, "Fonctionnalité absente (« Fonctionnalité: » ou « Feature: »).")) : errors);
    }

    @Override
    public List<String> stepTexts(String source) {
        ParsedFeature parsed = parse(source);
        String document = source;
        if (!parsed.valid()) {
            String language = validator.validate(source).language();
            document = "# language: " + language + "\n" + ("fr".equals(language) ? "Fonctionnalité" : "Feature") + ": x\n" + source;
        }
        Optional<Feature> feature = document(document).flatMap(GherkinDocument::getFeature);
        List<String> texts = new ArrayList<>();
        feature.ifPresent(f -> f.getChildren().forEach(child -> collectSteps(child, texts)));
        return texts;
    }

    private ParsedFeature parseExactly(String source) {
        List<Envelope> envelopes = parser.parse("file.feature", source.getBytes(StandardCharsets.UTF_8)).toList();
        List<GherkinError> errors = envelopes.stream().flatMap(e -> e.getParseError().stream())
                .map(e -> new GherkinError(e.getSource().getLocation().map(l -> l.getLine().intValue()).orElse(1),
                        e.getSource().getLocation().flatMap(l -> l.getColumn()).map(Number::intValue).orElse(1),
                        e.getMessage().replaceFirst("^\\(\\d+:\\d+\\):\\s*", "")))
                .toList();
        Optional<Feature> feature = envelopes.stream().flatMap(e -> e.getGherkinDocument().stream())
                .findFirst().flatMap(GherkinDocument::getFeature);
        if (!errors.isEmpty() || feature.isEmpty()) {
            return new ParsedFeature(feature.map(Feature::getLanguage).orElse("en"), null, "", List.of(), errors);
        }
        String[] lines = source.split("\n", -1);
        TreeSet<Integer> boundaries = new TreeSet<>();
        List<Scenario> scenarios = new ArrayList<>();
        for (FeatureChild child : feature.get().getChildren()) {
            child.getScenario().ifPresent(s -> {
                boundaries.add(start(s.getLocation().getLine(), s.getTags()));
                scenarios.add(s);
            });
            child.getRule().ifPresent(rule -> {
                boundaries.add(start(rule.getLocation().getLine(), rule.getTags()));
                for (RuleChild ruleChild : rule.getChildren()) {
                    ruleChild.getScenario().ifPresent(s -> {
                        boundaries.add(start(s.getLocation().getLine(), s.getTags()));
                        scenarios.add(s);
                    });
                }
            });
        }
        int firstBoundary = boundaries.isEmpty() ? lines.length + 1 : boundaries.first();
        String header = join(lines, 1, firstBoundary - 1);
        List<ParsedScenario> parsedScenarios = new ArrayList<>();
        for (Scenario scenario : scenarios) {
            int start = start(scenario.getLocation().getLine(), scenario.getTags());
            Integer next = boundaries.higher(start);
            int end = next == null ? lines.length : next - 1;
            parsedScenarios.add(new ParsedScenario(scenario.getName(),
                    scenario.getTags().stream().map(Tag::getName).toList(), join(lines, start, end).stripTrailing() + "\n"));
        }
        return new ParsedFeature(feature.get().getLanguage(), feature.get().getName(), header.stripTrailing() + "\n",
                parsedScenarios, List.of());
    }

    private Optional<GherkinDocument> document(String source) {
        return parser.parse("file.feature", source.getBytes(StandardCharsets.UTF_8))
                .flatMap(e -> e.getGherkinDocument().stream()).findFirst();
    }

    private static void collectSteps(FeatureChild child, List<String> texts) {
        child.getBackground().ifPresent(b -> b.getSteps().forEach(s -> texts.add(s.getText())));
        child.getScenario().ifPresent(s -> s.getSteps().stream().map(Step::getText).forEach(texts::add));
        child.getRule().ifPresent(rule -> rule.getChildren().forEach(rc -> {
            rc.getBackground().ifPresent(b -> b.getSteps().forEach(s -> texts.add(s.getText())));
            rc.getScenario().ifPresent(s -> s.getSteps().stream().map(Step::getText).forEach(texts::add));
        }));
    }

    private static int start(int keywordLine, List<Tag> tags) {
        return tags.stream().mapToInt(t -> t.getLocation().getLine()).min().orElse(keywordLine);
    }

    /** Lignes {@code from} à {@code to} incluses, numérotées à partir de 1. */
    private static String join(String[] lines, int from, int to) {
        StringBuilder text = new StringBuilder();
        for (int i = from; i <= to && i <= lines.length; i++) {
            text.append(lines[i - 1]).append('\n');
        }
        return text.toString();
    }
}
