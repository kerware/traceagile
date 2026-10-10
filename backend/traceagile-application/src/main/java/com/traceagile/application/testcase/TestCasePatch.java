package com.traceagile.application.testcase;

import java.util.function.Function;
import com.traceagile.domain.testcase.StepContent;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.testcase.AutomatedTestDefinition;
import com.traceagile.domain.testcase.DataSet;
import com.traceagile.domain.testcase.ExploratoryCharter;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestParameter;
import com.traceagile.domain.testcase.TestTechnique;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Consumer;

/**
 * §12 merge-patch d'un cas de test : {@code null} = inchangé, {@link Optional#empty()} = effacé
 * (ADR-0009). Les champs propres à une nature sont refusés sur une autre nature.
 */
public record TestCasePatch(
        Optional<String> title,
        Optional<String> description,
        Optional<String> objective,
        Optional<Priority> priority,
        Optional<List<String>> tags,
        Optional<Integer> estimatedDurationMin,
        Optional<String> folder,
        Optional<Boolean> automationCandidate,
        Optional<String> automationJustification,
        // MANUAL (F-MAN-01)
        Optional<List<StepDraft>> steps,
        // toutes natures (ADR-0013)
        Optional<List<TestParameter>> parameters,
        // EXPLORATORY (F-EXP-01 / F-EXP-02)
        Optional<String> explore,
        Optional<String> with,
        Optional<String> toDiscover,
        Optional<List<String>> areas,
        Optional<List<String>> heuristics,
        Optional<Integer> timeboxMin,
        Optional<String> setupNotes,
        Optional<String> targetedRisk,
        // AUTOMATED (§6.1)
        Optional<TestTechnique> technique,
        Optional<String> framework,
        Optional<String> language,
        Optional<String> repositoryUrl,
        Optional<String> branch,
        Optional<String> path,
        Optional<String> testIdentifier,
        Optional<String> gherkinSource,
        Optional<List<DataSet>> dataSets,
        Optional<Map<String, Object>> configuration,
        Optional<List<String>> executionTags,
        Optional<Map<String, String>> environmentRequirements) {

    /** ADR-0018 {@code calledTestKey} : pas d'appel d'un autre cas de test, avec ses valeurs de paramètres. */
    public record StepDraft(String action, String expectedResult, String testData, String calledTestKey, Map<String, String> callParameters) {

        public StepDraft(String action, String expectedResult, String testData) {
            this(action, expectedResult, testData, null, null);
        }
    }

    public static final TestCasePatch EMPTY = new TestCasePatch(null, null, null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
            null, null, null);

    public boolean touchesGherkin() {
        return gherkinSource != null;
    }

    public void applyTo(TestCase test) {
        applyTo(test, key -> {
            throw new BusinessRuleException("TEST_CALL_INVALID", "Cas de test appelé « " + key + " » introuvable.");
        });
    }

    /** {@code callable} : cas de test appelé d'après sa clé (ADR-0018). */
    public void applyTo(TestCase test, Function<String, TestCase> callable) {
        if (title != null) {
            test.rename(title.orElse(null));
        }
        apply(description, test::describe);
        apply(objective, test::setObjective);
        if (priority != null) {
            priority.ifPresent(test::setPriority);
        }
        apply(tags, test::setTags);
        apply(estimatedDurationMin, test::setEstimatedDurationMin);
        apply(folder, test::setFolder);
        if (automationCandidate != null || automationJustification != null) {
            boolean candidate = automationCandidate == null ? test.isAutomationCandidate() : automationCandidate.orElse(false);
            String justification = automationJustification == null ? test.getAutomationJustification() : automationJustification.orElse(null);
            test.markAutomationCandidate(candidate, justification);
        }
        if (steps != null) {
            require(test, TestKind.MANUAL, "pas");
            test.replaceSteps(steps.orElse(List.of()).stream()
                    .map(s -> new StepContent(s.action(), s.expectedResult(), s.testData(),
                            s.calledTestKey() == null || s.calledTestKey().isBlank() ? null : callable.apply(s.calledTestKey().strip()),
                            s.callParameters()))
                    .toList());
        }
        // Après les pas (paramètres détectés), avant les jeux (dont les colonnes inconnues sont déclarées).
        apply(parameters, test::setParameters);
        apply(dataSets, test::setDataSets);
        if (any(explore, with, toDiscover, areas, heuristics, timeboxMin, setupNotes, targetedRisk)) {
            require(test, TestKind.EXPLORATORY, "champs de charte");
            ExploratoryCharter charter = test.getCharter();
            if (any(explore, with, toDiscover)) {
                charter.setMission(merge(explore, charter.getExplore()), merge(with, charter.getWith()),
                        merge(toDiscover, charter.getToDiscover()));
            }
            apply(areas, charter::setAreas);
            apply(heuristics, charter::setHeuristics);
            if (timeboxMin != null) {
                charter.setTimeboxMin(timeboxMin.orElse(90));
            }
            apply(setupNotes, charter::setSetupNotes);
            apply(targetedRisk, charter::setTargetedRisk);
        }
        if (any(technique, framework, language, repositoryUrl, branch, path, testIdentifier, gherkinSource,
                configuration, executionTags, environmentRequirements)) {
            require(test, TestKind.AUTOMATED, "champs de test automatisé");
            AutomatedTestDefinition automation = test.getAutomation();
            if (technique != null || framework != null) {
                TestTechnique newTechnique = technique == null ? automation.getTechnique() : technique.orElse(automation.getTechnique());
                if (newTechnique != TestTechnique.BDD && automation.getGherkinSource() != null) {
                    automation.setGherkinSource(null);
                }
                automation.setTechnique(newTechnique, framework == null ? automation.getFramework() : framework.orElse(null));
            }
            apply(language, automation::setLanguage);
            if (any(repositoryUrl, branch, path, testIdentifier)) {
                automation.setLocation(merge(repositoryUrl, automation.getRepositoryUrl()), merge(branch, automation.getBranch()),
                        merge(path, automation.getPath()), merge(testIdentifier, automation.getTestIdentifier()));
            }
            if (gherkinSource != null && (gherkinSource.isPresent() || automation.getTechnique() == TestTechnique.BDD)) {
                automation.setGherkinSource(gherkinSource.orElse(null));
            }
            apply(configuration, automation::setParameters);
            apply(executionTags, automation::setExecutionTags);
            apply(environmentRequirements, automation::setEnvironmentRequirements);
        }
    }

    private static boolean any(Optional<?>... fields) {
        return Arrays.stream(fields).anyMatch(f -> f != null);
    }

    private static void require(TestCase test, TestKind kind, String what) {
        if (test.getKind() != kind) {
            throw new BusinessRuleException("TEST_FIELD_KIND_MISMATCH",
                    "Les " + what + " ne s'appliquent qu'à un test " + kind + " (ce test est " + test.getKind() + ").");
        }
    }

    private static <T> void apply(Optional<T> field, Consumer<T> setter) {
        if (field != null) {
            setter.accept(field.orElse(null));
        }
    }

    private static <T> T merge(Optional<T> field, T current) {
        return field == null ? current : field.orElse(null);
    }

    /** Patch construit champ par champ (création, import, génération). */
    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private final Object[] values = new Object[31];

        private Builder set(int index, Object value) {
            values[index] = Optional.ofNullable(value);
            return this;
        }

        public Builder title(String v) { return set(0, v); }
        public Builder description(String v) { return set(1, v); }
        public Builder objective(String v) { return set(2, v); }
        public Builder priority(Priority v) { return set(3, v); }
        public Builder tags(List<String> v) { return set(4, v); }
        public Builder estimatedDurationMin(Integer v) { return set(5, v); }
        public Builder folder(String v) { return set(6, v); }
        public Builder automationCandidate(boolean candidate, String justification) { set(7, candidate); return set(8, justification); }
        public Builder steps(List<StepDraft> v) { return set(9, v); }
        public Builder parameters(List<TestParameter> v) { return set(10, v); }
        public Builder mission(String explore, String with, String toDiscover) { set(11, explore); set(12, with); return set(13, toDiscover); }
        public Builder areas(List<String> v) { return set(14, v); }
        public Builder heuristics(List<String> v) { return set(15, v); }
        public Builder timeboxMin(Integer v) { return set(16, v); }
        public Builder setupNotes(String v) { return set(17, v); }
        public Builder targetedRisk(String v) { return set(18, v); }
        public Builder language(String v) { return set(21, v); }
        public Builder location(String repositoryUrl, String branch, String path, String testIdentifier) {
            set(22, repositoryUrl); set(23, branch); set(24, path); return set(25, testIdentifier);
        }
        public Builder gherkinSource(String v) { return set(26, v); }
        public Builder dataSets(List<DataSet> v) { return set(27, v); }
        public Builder configuration(Map<String, Object> v) { return set(28, v); }
        public Builder executionTags(List<String> v) { return set(29, v); }
        public Builder environmentRequirements(Map<String, String> v) { return set(30, v); }

        @SuppressWarnings("unchecked")
        public TestCasePatch build() {
            List<Object> v = new ArrayList<>(Arrays.asList(values));
            return new TestCasePatch((Optional<String>) v.get(0), (Optional<String>) v.get(1), (Optional<String>) v.get(2),
                    (Optional<Priority>) v.get(3), (Optional<List<String>>) v.get(4), (Optional<Integer>) v.get(5),
                    (Optional<String>) v.get(6), (Optional<Boolean>) v.get(7), (Optional<String>) v.get(8),
                    (Optional<List<StepDraft>>) v.get(9), (Optional<List<TestParameter>>) v.get(10),
                    (Optional<String>) v.get(11), (Optional<String>) v.get(12), (Optional<String>) v.get(13),
                    (Optional<List<String>>) v.get(14), (Optional<List<String>>) v.get(15), (Optional<Integer>) v.get(16),
                    (Optional<String>) v.get(17), (Optional<String>) v.get(18), (Optional<TestTechnique>) v.get(19),
                    (Optional<String>) v.get(20), (Optional<String>) v.get(21), (Optional<String>) v.get(22),
                    (Optional<String>) v.get(23), (Optional<String>) v.get(24), (Optional<String>) v.get(25),
                    (Optional<String>) v.get(26), (Optional<List<DataSet>>) v.get(27),
                    (Optional<Map<String, Object>>) v.get(28), (Optional<List<String>>) v.get(29),
                    (Optional<Map<String, String>>) v.get(30));
        }
    }
}
