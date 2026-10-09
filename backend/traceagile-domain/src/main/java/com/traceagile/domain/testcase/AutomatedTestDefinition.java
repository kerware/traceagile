package com.traceagile.domain.testcase;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * §3.1 AutomatedTestDefinition : TraceAgile référence le test (dépôt, chemin, identifiant) sans en
 * stocker le code, sauf le Gherkin (§6) ; jeux de données et paramètres déclarés sont portés par le
 * {@link TestCase} (ADR-0013). Les champs propres à une technique
 * (navigateurs, URL de base, métriques attendues…) vont dans {@code parameters} (ADR-0012).
 */
@Entity
@Table(name = "automated_test_definitions")
public class AutomatedTestDefinition extends AuditableEntity {

    @OneToOne(optional = false)
    @JoinColumn(name = "test_case_id", unique = true)
    private TestCase testCase;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TestTechnique technique;

    @Column(nullable = false, length = 60)
    private String framework;

    @Column(length = 40)
    private String language;

    @Column(name = "repository_url", length = 500)
    private String repositoryUrl;

    @Column(length = 200)
    private String branch;

    @Column(length = 500)
    private String path;

    @Column(name = "test_identifier", length = 500)
    private String testIdentifier;

    /** F-AUT-05 nom de la fonctionnalité Gherkin : regroupe les scénarios d'un même fichier. */
    @Column(name = "feature_name", length = 200)
    private String featureName;

    @Column(name = "gherkin_source", columnDefinition = "text")
    private String gherkinSource;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private Map<String, Object> parameters = new LinkedHashMap<>();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "execution_tags", nullable = false, columnDefinition = "jsonb")
    private List<String> executionTags = new ArrayList<>();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "environment_requirements", nullable = false, columnDefinition = "jsonb")
    private Map<String, String> environmentRequirements = new LinkedHashMap<>();

    /** §6.1 KEYWORD : mots-clés utilisés, renseignés par la découverte (lecture seule). */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private List<String> keywords = new ArrayList<>();

    /** F-AUT-08 absent du dernier rapport de découverte du dépôt. */
    @Column(name = "missing_in_repository", nullable = false)
    private boolean missingInRepository;

    protected AutomatedTestDefinition() {
    }

    AutomatedTestDefinition(TestCase testCase, TestTechnique technique, String framework) {
        this.testCase = testCase;
        this.technique = Objects.requireNonNull(technique, "technique");
        setFrameworkValue(framework);
    }

    public void setTechnique(TestTechnique technique, String framework) {
        testCase.ensureEditable();
        if (technique != TestTechnique.BDD && gherkinSource != null) {
            throw new BusinessRuleException("TEST_GHERKIN_BDD_ONLY", "Seul un test BDD porte une source Gherkin.");
        }
        this.technique = Objects.requireNonNull(technique);
        setFrameworkValue(framework);
    }

    private void setFrameworkValue(String framework) {
        if (framework == null || framework.isBlank()) {
            throw new BusinessRuleException("TEST_FRAMEWORK_REQUIRED", "Le framework est obligatoire.");
        }
        this.framework = framework.strip();
    }

    /** Dépôt, branche, chemin et identifiant résolus par le serveur d'exécution (§6). */
    public void setLocation(String repositoryUrl, String branch, String path, String testIdentifier) {
        testCase.ensureEditable();
        this.repositoryUrl = blankToNull(repositoryUrl);
        this.branch = blankToNull(branch);
        this.path = blankToNull(path);
        this.testIdentifier = blankToNull(testIdentifier);
    }

    public void setLanguage(String language) {
        testCase.ensureEditable();
        this.language = blankToNull(language);
    }

    /** F-AUT-04 / F-AUT-05 source Gherkin d'un scénario (validée par l'application). */
    public void setGherkinSource(String gherkinSource) {
        testCase.ensureEditable();
        if (technique != TestTechnique.BDD) {
            throw new BusinessRuleException("TEST_GHERKIN_BDD_ONLY", "Seul un test BDD porte une source Gherkin.");
        }
        this.gherkinSource = blankToNull(gherkinSource);
    }

    public void setFeatureName(String featureName) {
        this.featureName = blankToNull(featureName);
    }

    public void setParameters(Map<String, Object> parameters) {
        testCase.ensureEditable();
        this.parameters = parameters == null ? new LinkedHashMap<>() : new LinkedHashMap<>(parameters);
    }

    /** F-AUT-02 tags d'exécution (smoke, regression, nightly…) en minuscules, sans doublon. */
    public void setExecutionTags(List<String> executionTags) {
        testCase.ensureEditable();
        this.executionTags = new ArrayList<>(ExploratoryCharter.clean(executionTags).stream()
                .map(t -> t.toLowerCase(Locale.ROOT)).distinct().toList());
    }

    /** F-AUT-03 prérequis d'environnement en paires clé / valeur. */
    public void setEnvironmentRequirements(Map<String, String> environmentRequirements) {
        testCase.ensureEditable();
        Map<String, String> cleaned = new LinkedHashMap<>();
        if (environmentRequirements != null) {
            environmentRequirements.forEach((key, value) -> {
                if (key != null && !key.isBlank()) {
                    cleaned.put(key.strip(), value == null ? "" : value.strip());
                }
            });
        }
        this.environmentRequirements = cleaned;
    }

    public void setKeywords(List<String> keywords) {
        this.keywords = ExploratoryCharter.clean(keywords);
    }

    public void setMissingInRepository(boolean missingInRepository) {
        this.missingInRepository = missingInRepository;
    }

    boolean isComplete() {
        boolean identified = testIdentifier != null;
        return technique == TestTechnique.BDD ? identified && gherkinSource != null : identified;
    }

    /** F-AUT-10 contenu significatif : technique, framework, chemin, identifiant, Gherkin (jeux de données : TestCase). */
    List<Object> content() {
        return Arrays.asList(technique.name(), framework, path, testIdentifier, gherkinSource);
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.strip();
    }

    public TestCase getTestCase() {
        return testCase;
    }

    public TestTechnique getTechnique() {
        return technique;
    }

    public String getFramework() {
        return framework;
    }

    public String getLanguage() {
        return language;
    }

    public String getRepositoryUrl() {
        return repositoryUrl;
    }

    public String getBranch() {
        return branch;
    }

    public String getPath() {
        return path;
    }

    public String getTestIdentifier() {
        return testIdentifier;
    }

    public String getFeatureName() {
        return featureName;
    }

    public String getGherkinSource() {
        return gherkinSource;
    }

    public Map<String, Object> getParameters() {
        return java.util.Collections.unmodifiableMap(parameters);
    }

    public List<String> getExecutionTags() {
        return List.copyOf(executionTags);
    }

    public Map<String, String> getEnvironmentRequirements() {
        return new LinkedHashMap<>(environmentRequirements);
    }

    public List<String> getKeywords() {
        return List.copyOf(keywords);
    }

    public boolean isMissingInRepository() {
        return missingInRepository;
    }
}
