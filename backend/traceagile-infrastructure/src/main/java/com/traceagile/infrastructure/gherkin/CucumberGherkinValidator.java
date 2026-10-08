package com.traceagile.infrastructure.gherkin;

import com.traceagile.application.requirement.GherkinValidator;
import io.cucumber.gherkin.GherkinDialect;
import io.cucumber.gherkin.GherkinDialectProvider;
import io.cucumber.gherkin.GherkinParser;
import io.cucumber.messages.types.Envelope;
import io.cucumber.messages.types.ParseError;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.stereotype.Component;

/**
 * F-REQ-10 Validation avec io.cucumber:gherkin. Un critère est souvent un scénario seul : l'en-tête
 * « Fonctionnalité » est ajouté si besoin, puis les numéros de ligne sont recalés sur le texte saisi.
 * Sans directive {@code # language}, le français puis l'anglais sont essayés (ADR-0011).
 */
@Component
public class CucumberGherkinValidator implements GherkinValidator {

    private static final Pattern LANGUAGE = Pattern.compile("^\\s*#\\s*language\\s*:\\s*([\\w-]+)", Pattern.MULTILINE);
    private static final List<String> DEFAULT_LANGUAGES = List.of("fr", "en");

    private final GherkinDialectProvider dialects = new GherkinDialectProvider();
    private final GherkinParser parser = GherkinParser.builder()
            .includeSource(false)
            .includeGherkinDocument(false)
            .includePickles(true)
            .build();

    @Override
    public GherkinValidation validate(String source) {
        Matcher declared = LANGUAGE.matcher(source);
        List<String> languages = declared.find() ? List.of(declared.group(1)) : DEFAULT_LANGUAGES;
        boolean languageDeclared = languages != DEFAULT_LANGUAGES;
        List<GherkinValidation> attempts = new ArrayList<>();
        for (String language : languages) {
            Optional<GherkinDialect> dialect = dialects.getDialect(language);
            if (dialect.isEmpty()) {
                return new GherkinValidation(language, List.of(new GherkinError(1, 1, "Langue Gherkin inconnue : " + language)));
            }
            GherkinValidation attempt = parse(source, dialect.get(), languageDeclared);
            if (attempt.valid()) {
                return attempt;
            }
            attempts.add(attempt);
        }
        return attempts.stream().min(Comparator.comparingInt(a -> a.errors().size())).orElseThrow();
    }

    private GherkinValidation parse(String source, GherkinDialect dialect, boolean languageDeclared) {
        StringBuilder wrapped = new StringBuilder();
        int offset = 0;
        if (!languageDeclared) {
            wrapped.append("# language: ").append(dialect.getLanguage()).append('\n');
            offset++;
        }
        if (!hasFeatureHeader(source, dialect)) {
            wrapped.append(dialect.getFeatureKeywords().getFirst()).append(": Critère d'acceptation\n");
            offset++;
        }
        wrapped.append(source);

        List<GherkinError> errors = new ArrayList<>();
        int scenarios = 0;
        List<Envelope> envelopes = parser.parse("criterion.feature", wrapped.toString().getBytes(StandardCharsets.UTF_8)).toList();
        for (Envelope envelope : envelopes) {
            if (envelope.getParseError().isPresent()) {
                errors.add(toError(envelope.getParseError().get(), offset));
            }
            if (envelope.getPickle().isPresent()) {
                scenarios++;
            }
        }
        if (errors.isEmpty() && scenarios == 0) {
            errors.add(new GherkinError(1, 1, "Aucun scénario : commencez par « Scénario: » (ou « Scenario: »)."));
        }
        return new GherkinValidation(dialect.getLanguage(), errors);
    }

    private static boolean hasFeatureHeader(String source, GherkinDialect dialect) {
        for (String line : source.lines().toList()) {
            String trimmed = line.strip().toLowerCase(Locale.ROOT);
            for (String keyword : dialect.getFeatureKeywords()) {
                if (trimmed.startsWith(keyword.toLowerCase(Locale.ROOT) + ":")) {
                    return true;
                }
            }
        }
        return false;
    }

    private static GherkinError toError(ParseError error, int offset) {
        int line = 1;
        int column = 1;
        var location = error.getSource().getLocation();
        if (location.isPresent()) {
            line = Math.max(1, location.get().getLine().intValue() - offset);
            column = location.get().getColumn().map(Number::intValue).orElse(1);
        }
        // Le message du parseur commence par « (ligne:colonne): » dans le texte enveloppé : on le retire.
        String message = error.getMessage().replaceFirst("^\\(\\d+:\\d+\\):\\s*", "");
        return new GherkinError(line, column, message);
    }
}
