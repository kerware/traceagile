package com.traceagile.domain.testcase;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.requirement.Priority;
import jakarta.persistence.CascadeType;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * §3.1 TestCase : test réutilisable, manuel scripté, charte exploratoire ou test automatisé. La
 * nature est fixée à la création et détermine le sous-objet (ADR-0012).
 */
@Entity
@Table(name = "test_cases")
public class TestCase extends AuditableEntity {

    static final int TITLE_MAX = 200;
    private static final Pattern VARIABLE = Pattern.compile("\\$\\{([\\w.-]+)}");
    private static final Pattern PARAMETER_NAME = Pattern.compile("[\\w.-]{1,60}");

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @Column(name = "test_key", nullable = false, length = 20, updatable = false)
    private String key;

    @Column(name = "key_number", nullable = false, updatable = false)
    private int keyNumber;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 12, updatable = false)
    private TestKind kind;

    @Column(nullable = false, length = TITLE_MAX)
    private String title;

    @Column(columnDefinition = "text")
    private String description;

    @Column(columnDefinition = "text")
    private String objective;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Priority priority = Priority.SHOULD;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 15)
    private TestCaseStatus status = TestCaseStatus.DRAFT;

    @ElementCollection
    @CollectionTable(name = "test_case_tags", joinColumns = @JoinColumn(name = "test_case_id"))
    @Column(name = "tag", length = 50)
    private Set<String> tags = new TreeSet<>();

    @Column(name = "estimated_duration_min")
    private Integer estimatedDurationMin;

    /** §13.2 rangement du référentiel « par dossier » (chemin séparé par « / »). */
    @Column(length = 300)
    private String folder;

    /** F-AUT-10 version courante ; une exécution référence la version utilisée (lot 5). */
    @Column(name = "current_version", nullable = false)
    private int currentVersion = 1;

    @Column(name = "automation_candidate", nullable = false)
    private boolean automationCandidate;

    /** F-EXE-11 instable : recalculé après chaque résultat automatisé (ADR-0020). */
    @Column(nullable = false)
    private boolean flaky;

    @Column(name = "automation_justification", length = 1000)
    private String automationJustification;

    @OneToMany(mappedBy = "testCase", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("position")
    private List<ManualStep> steps = new ArrayList<>();

    /** ADR-0013 paramètres déclarés (les ${nom} des pas manuels s'y ajoutent à la lecture). */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private List<TestParameter> parameters = new ArrayList<>();

    /** ADR-0013 jeux de données nommés : une ligne par exécution. */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "data_sets", nullable = false, columnDefinition = "jsonb")
    private List<DataSet> dataSets = new ArrayList<>();

    @OneToOne(mappedBy = "testCase", cascade = CascadeType.ALL, orphanRemoval = true)
    private ExploratoryCharter charter;

    @OneToOne(mappedBy = "testCase", cascade = CascadeType.ALL, orphanRemoval = true)
    private AutomatedTestDefinition automation;

    protected TestCase() {
    }

    private TestCase(Project project, String key, TestKind kind, String title) {
        this.project = Objects.requireNonNull(project, "project");
        this.key = Objects.requireNonNull(key, "key");
        this.keyNumber = Integer.parseInt(key.substring(key.lastIndexOf('-') + 1));
        this.kind = Objects.requireNonNull(kind, "kind");
        rename(title);
    }

    public static TestCase manual(Project project, String key, String title) {
        return new TestCase(project, key, TestKind.MANUAL, title);
    }

    public static TestCase exploratory(Project project, String key, String title) {
        TestCase test = new TestCase(project, key, TestKind.EXPLORATORY, title);
        test.charter = new ExploratoryCharter(test);
        return test;
    }

    public static TestCase automated(Project project, String key, String title, TestTechnique technique, String framework) {
        TestCase test = new TestCase(project, key, TestKind.AUTOMATED, title);
        test.automation = new AutomatedTestDefinition(test, technique, framework);
        return test;
    }

    // ---------------------------------------------------------------- champs communs

    public void rename(String title) {
        ensureEditable();
        if (title == null || title.isBlank()) {
            throw new BusinessRuleException("TEST_TITLE_REQUIRED", "Le titre du test est obligatoire.");
        }
        if (title.strip().length() > TITLE_MAX) {
            throw new BusinessRuleException("TEST_TITLE_TOO_LONG", "Le titre dépasse " + TITLE_MAX + " caractères.");
        }
        this.title = title.strip();
    }

    public void describe(String description) {
        ensureEditable();
        this.description = blankToNull(description);
    }

    public void setObjective(String objective) {
        ensureEditable();
        this.objective = blankToNull(objective);
    }

    public void setPriority(Priority priority) {
        ensureEditable();
        this.priority = Objects.requireNonNull(priority);
    }

    public void setTags(Collection<String> tags) {
        ensureEditable();
        this.tags.clear();
        if (tags != null) {
            tags.stream().filter(Objects::nonNull).map(t -> t.strip().toLowerCase(Locale.ROOT)).filter(t -> !t.isEmpty())
                    .forEach(t -> {
                        if (t.length() > 50) {
                            throw new BusinessRuleException("TEST_TAG_TOO_LONG", "Un tag dépasse 50 caractères : " + t);
                        }
                        this.tags.add(t);
                    });
        }
    }

    public void setEstimatedDurationMin(Integer minutes) {
        ensureEditable();
        if (minutes != null && (minutes < 1 || minutes > 10_000)) {
            throw new BusinessRuleException("TEST_DURATION_INVALID", "La durée estimée est comprise entre 1 et 10 000 minutes.");
        }
        this.estimatedDurationMin = minutes;
    }

    public void setFolder(String folder) {
        ensureEditable();
        relocate(folder);
    }

    /** ADR-0013 reclassement (renommage ou déplacement d'un dossier) : permis même sur un test OBSOLETE. */
    public void relocate(String folder) {
        String normalized = TestFolder.normalize(folder);
        if (normalized != null && normalized.length() > TestFolder.MAX_LENGTH) {
            throw new BusinessRuleException("TEST_FOLDER_PATH_TOO_LONG", "Le chemin du dossier dépasse " + TestFolder.MAX_LENGTH + " caractères.");
        }
        this.folder = normalized;
    }

    /** F-MAN-02 candidat à l'automatisation, avec justification. */
    public void markAutomationCandidate(boolean candidate, String justification) {
        ensureEditable();
        if (candidate && kind != TestKind.MANUAL) {
            throw new BusinessRuleException("TEST_AUTOMATION_CANDIDATE_MANUAL_ONLY", "Seul un test manuel est candidat à l'automatisation.");
        }
        if (candidate && (justification == null || justification.isBlank())) {
            throw new BusinessRuleException("TEST_AUTOMATION_JUSTIFICATION_REQUIRED", "Justifiez la candidature à l'automatisation.");
        }
        this.automationCandidate = candidate;
        this.automationJustification = candidate ? justification.strip() : null;
    }

    // ---------------------------------------------------------------- pas manuels (F-MAN-01)

    public ManualStep addStep(String action, String expectedResult, String testData) {
        ensureManual();
        return addStep(StepContent.of(action, expectedResult, testData));
    }

    /** ADR-0018 pas ordinaire ou appel d'un autre cas de test manuel (sans cycle). */
    public ManualStep addStep(StepContent content) {
        ensureManual();
        if (content.calledTest() != null) {
            checkCall(content.calledTest());
        }
        ManualStep step = new ManualStep(this, steps.size() + 1, content);
        steps.add(step);
        return step;
    }

    /**
     * ADR-0018 un test appelé est un test manuel non obsolète du même projet ; l'appel ne doit pas
     * revenir, directement ou non, vers ce test.
     */
    private void checkCall(TestCase called) {
        // accesseurs, jamais les champs : l'appelé peut être un proxy Hibernate
        Project calledProject = called.getProject();
        boolean sameProject = calledProject == project || (calledProject.getId() != null && calledProject.getId().equals(project.getId()));
        if (called.getKind() != TestKind.MANUAL || called.getStatus() == TestCaseStatus.OBSOLETE || !sameProject) {
            throw new BusinessRuleException("TEST_CALL_INVALID",
                    called.getKey() + " ne peut pas être appelé : seul un test manuel non obsolète du projet peut l'être.");
        }
        if (same(called, this) || called.calls(this, new HashSet<>())) {
            throw new BusinessRuleException("TEST_CALL_CYCLE", "Appeler " + called.getKey() + " depuis " + key + " créerait une boucle d'appels.");
        }
    }

    /** Ce test appelle-t-il {@code target}, directement ou par ses appelés ? */
    private boolean calls(TestCase target, Set<TestCase> visited) {
        if (!visited.add(this)) {
            return false;
        }
        // getSteps() : sur un proxy Hibernate, une méthode privée verrait des champs vides
        for (ManualStep step : getSteps()) {
            TestCase called = step.getCalledTest();
            if (called != null && (same(called, target) || called.calls(target, visited))) {
                return true;
            }
        }
        return false;
    }

    private static boolean same(TestCase a, TestCase b) {
        return a == b || (a.getId() != null && a.getId().equals(b.getId()));
    }

    public ManualStep duplicateStep(ManualStep step) {
        ensureManual();
        int index = indexOf(step);
        ManualStep copy = new ManualStep(this, 0, step.toContent());
        steps.add(index + 1, copy);
        renumber();
        return copy;
    }

    public void removeStep(ManualStep step) {
        ensureManual();
        steps.remove(steps.get(indexOf(step)));
        renumber();
    }

    public void reorderSteps(List<ManualStep> ordered) {
        ensureManual();
        if (ordered.size() != steps.size() || !new HashSet<>(ordered).equals(new HashSet<>(steps))) {
            throw new BusinessRuleException("TEST_STEPS_ORDER_INVALID", "L'ordre doit contenir exactement les pas existants.");
        }
        steps.clear();
        steps.addAll(ordered);
        renumber();
    }

    /** Remplace tous les pas (édition en bloc depuis l'interface). */
    public void replaceSteps(List<StepContent> contents) {
        ensureManual();
        steps.clear();
        contents.forEach(this::addStep);
    }

    /** F-MAN-01 variables ${nom} utilisées dans les pas, dans l'ordre d'apparition. */
    public List<String> variables() {
        Set<String> names = new LinkedHashSet<>();
        for (ManualStep step : steps) {
            for (String text : step.content()) {
                if (text != null) {
                    Matcher matcher = VARIABLE.matcher(text);
                    while (matcher.find()) {
                        names.add(matcher.group(1));
                    }
                }
            }
        }
        return List.copyOf(names);
    }

    // ---------------------------------------------------------------- paramètres et jeux de données (ADR-0013)

    /** F-MAN-01 paramètres détectés dans les pas d'un test manuel ({@code ${nom}}). */
    public List<String> detectedParameters() {
        return kind == TestKind.MANUAL ? variables() : List.of();
    }

    /**
     * Paramètres du test : d'abord ceux détectés dans les pas (avec la valeur par défaut et la
     * description déclarées s'il y en a), puis les autres paramètres déclarés.
     */
    public List<TestParameter> getParameters() {
        Map<String, TestParameter> declared = new LinkedHashMap<>();
        parameters.forEach(p -> declared.put(p.name(), p));
        List<TestParameter> result = new ArrayList<>();
        for (String name : detectedParameters()) {
            result.add(declared.containsKey(name) ? declared.remove(name) : TestParameter.named(name));
        }
        result.addAll(declared.values());
        return List.copyOf(result);
    }

    /** Remplace les paramètres déclarés ; les colonnes des jeux de données sans paramètre disparaissent. */
    public void setParameters(List<TestParameter> declared) {
        ensureEditable();
        Set<String> names = new HashSet<>();
        List<TestParameter> cleaned = new ArrayList<>();
        for (TestParameter parameter : declared == null ? List.<TestParameter>of() : declared) {
            if (parameter.name() == null || !PARAMETER_NAME.matcher(parameter.name()).matches()) {
                throw new BusinessRuleException("TEST_PARAMETER_NAME_INVALID",
                        "Nom de paramètre invalide : « " + parameter.name() + " » (lettres sans accent, chiffres, « _ », « - », « . »).");
            }
            if (!names.add(parameter.name())) {
                throw new BusinessRuleException("TEST_PARAMETER_DUPLICATED", "Le paramètre « " + parameter.name() + " » apparaît deux fois.");
            }
            cleaned.add(parameter);
        }
        this.parameters = cleaned;
        Set<String> known = getParameters().stream().map(TestParameter::name).collect(Collectors.toSet());
        this.dataSets = new ArrayList<>(dataSets.stream()
                .map(d -> new DataSet(d.name(), d.rows().stream()
                        .map(row -> row.entrySet().stream().filter(e -> known.contains(e.getKey()))
                                .collect(LinkedHashMap<String, Object>::new, (m, e) -> m.put(e.getKey(), e.getValue()), Map::putAll))
                        .map(row -> (Map<String, Object>) row)
                        .toList(), d.rowNames()))
                .toList());
    }

    public List<DataSet> getDataSets() {
        return List.copyOf(dataSets);
    }

    /** Jeux de données nommés ; une colonne qui n'est pas encore un paramètre en devient un. */
    public void setDataSets(List<DataSet> sets) {
        ensureEditable();
        Set<String> names = new HashSet<>();
        for (DataSet set : sets == null ? List.<DataSet>of() : sets) {
            if (set.name() == null || set.name().isBlank()) {
                throw new BusinessRuleException("TEST_DATASET_NAME_REQUIRED", "Chaque jeu de données a un nom.");
            }
            if (!names.add(set.name().toLowerCase(Locale.ROOT))) {
                throw new BusinessRuleException("TEST_DATASET_DUPLICATED", "Le jeu de données « " + set.name() + " » existe déjà.");
            }
            for (Map<String, Object> row : set.rows()) {
                if (row.isEmpty()) {
                    throw new BusinessRuleException("TEST_DATASET_ROW_EMPTY", "Une ligne du jeu « " + set.name() + " » est vide.");
                }
                if (row.values().stream().anyMatch(v -> v != null && !(v instanceof String || v instanceof Number || v instanceof Boolean))) {
                    throw new BusinessRuleException("TEST_DATASET_VALUE_INVALID",
                            "Les valeurs du jeu « " + set.name() + " » sont du texte, des nombres ou des booléens.");
                }
            }
            // ADR-0029 une ligne se désigne par son nom : il est unique dans son jeu
            if (!set.duplicatedRowNames().isEmpty()) {
                throw new BusinessRuleException("TEST_DATASET_ROW_NAME_DUPLICATED",
                        "Le jeu « " + set.name() + " » a deux lignes nommées « " + set.duplicatedRowNames().get(0) + " ».");
            }
        }
        // Une colonne devient un paramètre déclaré, même détecté : il survit au retrait du ${nom} des pas.
        Set<String> known = parameters.stream().map(TestParameter::name).collect(Collectors.toCollection(HashSet::new));
        List<TestParameter> declared = new ArrayList<>(parameters);
        for (DataSet set : sets == null ? List.<DataSet>of() : sets) {
            for (Map<String, Object> row : set.rows()) {
                for (String column : row.keySet()) {
                    if (known.add(column)) {
                        declared.add(TestParameter.named(column));
                    }
                }
            }
        }
        setParameters(declared);
        this.dataSets = new ArrayList<>(sets == null ? List.of() : sets);
    }

    private void ensureManual() {
        ensureEditable();
        if (kind != TestKind.MANUAL) {
            throw new BusinessRuleException("TEST_STEPS_MANUAL_ONLY", "Seul un test manuel comporte des pas.");
        }
    }

    private int indexOf(ManualStep step) {
        int index = steps.indexOf(step);
        if (index < 0) {
            throw new BusinessRuleException("TEST_STEP_NOT_IN_TEST", "Ce pas n'appartient pas au test " + key + ".");
        }
        return index;
    }

    private void renumber() {
        for (int i = 0; i < steps.size(); i++) {
            steps.get(i).setPosition(i + 1);
        }
    }

    // ---------------------------------------------------------------- statut, version

    public void changeStatus(TestCaseStatus target) {
        if (!status.canMoveTo(target)) {
            throw new BusinessRuleException("TEST_STATUS_TRANSITION_INVALID", "Passage de " + status + " à " + target + " impossible.");
        }
        if (target == TestCaseStatus.READY && !isExecutable()) {
            throw new BusinessRuleException("TEST_NOT_READY", switch (kind) {
                case MANUAL -> "Un test manuel prêt comporte au moins un pas.";
                case EXPLORATORY -> "Une charte prête précise au moins « Explorer » et « pour découvrir ».";
                case AUTOMATED -> "Un test automatisé prêt a un identifiant (et une source Gherkin en BDD).";
            });
        }
        // ADR-0028 un test manuel paramétré se joue avec les valeurs d'au moins un jeu de données
        if (target == TestCaseStatus.READY && kind == TestKind.MANUAL && !getParameters().isEmpty()
                && dataSets.stream().allMatch(d -> d.rows().isEmpty())) {
            throw new BusinessRuleException("TEST_DATASET_REQUIRED",
                    "Un test manuel à paramètres prêt a au moins un jeu de données avec une ligne.");
        }
        status = target;
    }

    /** §3.3-7 posé par l'outil quand une exigence liée change (lot 3). */
    public void markNeedsUpdate() {
        if (status == TestCaseStatus.READY) {
            status = TestCaseStatus.NEEDS_UPDATE;
        }
    }

    public boolean isFlaky() {
        return flaky;
    }

    public void markFlaky(boolean flaky) {
        this.flaky = flaky;
    }

    public boolean isExecutable() {
        return switch (kind) {
            case MANUAL -> !steps.isEmpty();
            case EXPLORATORY -> charter.isComplete();
            case AUTOMATED -> automation.isComplete();
        };
    }

    void ensureEditable() {
        if (status == TestCaseStatus.OBSOLETE) {
            throw new BusinessRuleException("TEST_OBSOLETE", "Un test obsolète ne peut plus être modifié.");
        }
    }

    /** F-AUT-10 empreinte des modifications significatives (pas, Gherkin, jeu de données, identifiant). */
    public Object significantFingerprint() {
        return switch (kind) {
            case MANUAL -> List.of(steps.stream().map(ManualStep::content).toList(), getParameters(), dataSets);
            case EXPLORATORY -> List.of(charter.content(), getParameters(), dataSets);
            case AUTOMATED -> List.of(automation.content(), getParameters(), dataSets);
        };
    }

    /** F-AUT-10 nouvelle version après une modification significative. */
    public int nextVersion() {
        return ++currentVersion;
    }

    /** Instantané des champs métier (audit NF-16, versions F-AUT-10). */
    public Map<String, Object> snapshot() {
        Map<String, Object> snapshot = new LinkedHashMap<>();
        snapshot.put("key", key);
        snapshot.put("kind", kind.name());
        snapshot.put("title", title);
        snapshot.put("status", status.name());
        snapshot.put("priority", priority.name());
        snapshot.put("description", description);
        snapshot.put("objective", objective);
        snapshot.put("tags", tags.isEmpty() ? null : String.join(", ", tags));
        snapshot.put("estimatedDurationMin", estimatedDurationMin);
        snapshot.put("folder", folder);
        snapshot.put("automationCandidate", automationCandidate);
        snapshot.put("automationJustification", automationJustification);
        snapshot.put("parameters", getParameters().isEmpty() ? null : getParameters().stream()
                .map(p -> p.name() + (p.defaultValue() == null ? "" : " = " + p.defaultValue())).toList());
        snapshot.put("dataSets", dataSets.isEmpty() ? null : dataSets.stream()
                .map(d -> d.name() + " : " + d.rows()).toList());
        switch (kind) {
            case MANUAL -> {
                snapshot.put("steps", steps.stream().map(ManualStep::describe).toList());
            }
            case EXPLORATORY -> {
                snapshot.put("mission", charter.missionSentence());
                snapshot.put("areas", String.join(", ", charter.getAreas()));
                snapshot.put("heuristics", String.join(", ", charter.getHeuristics()));
                snapshot.put("timeboxMin", charter.getTimeboxMin());
                snapshot.put("setupNotes", charter.getSetupNotes());
                snapshot.put("targetedRisk", charter.getTargetedRisk());
            }
            case AUTOMATED -> {
                snapshot.put("technique", automation.getTechnique().name());
                snapshot.put("framework", automation.getFramework());
                snapshot.put("language", automation.getLanguage());
                snapshot.put("repositoryUrl", automation.getRepositoryUrl());
                snapshot.put("branch", automation.getBranch());
                snapshot.put("path", automation.getPath());
                snapshot.put("testIdentifier", automation.getTestIdentifier());
                snapshot.put("gherkinSource", automation.getGherkinSource());
                snapshot.put("parameters", automation.getParameters().isEmpty() ? null : automation.getParameters().toString());
                snapshot.put("executionTags", String.join(", ", automation.getExecutionTags()));
                snapshot.put("environmentRequirements", automation.getEnvironmentRequirements().isEmpty() ? null
                        : automation.getEnvironmentRequirements().toString());
            }
        }
        return snapshot;
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.strip();
    }

    // ---------------------------------------------------------------- accesseurs

    public Project getProject() {
        return project;
    }

    public String getKey() {
        return key;
    }

    public int getKeyNumber() {
        return keyNumber;
    }

    public TestKind getKind() {
        return kind;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public String getObjective() {
        return objective;
    }

    public Priority getPriority() {
        return priority;
    }

    public TestCaseStatus getStatus() {
        return status;
    }

    public Set<String> getTags() {
        return Collections.unmodifiableSet(tags);
    }

    public Integer getEstimatedDurationMin() {
        return estimatedDurationMin;
    }

    public String getFolder() {
        return folder;
    }

    public int getCurrentVersion() {
        return currentVersion;
    }

    public boolean isAutomationCandidate() {
        return automationCandidate;
    }

    public String getAutomationJustification() {
        return automationJustification;
    }

    public List<ManualStep> getSteps() {
        return Collections.unmodifiableList(steps);
    }


    public ExploratoryCharter getCharter() {
        return charter;
    }

    public AutomatedTestDefinition getAutomation() {
        return automation;
    }
}
