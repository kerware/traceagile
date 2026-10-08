package com.traceagile.domain.requirement;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.CascadeType;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Embedded;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.TreeSet;
import java.util.stream.Collectors;

/**
 * §3.1 Requirement : élément du backlog (épic, feature, user story, règle métier, ENF, enabler).
 * Porte les règles du §3.3 (parenté, cycle, DoR minimale) et du §4.
 */
@Entity
@Table(name = "requirements")
public class Requirement extends AuditableEntity {

    static final int TITLE_MAX = 200;
    /** F-REQ-06 suite de Fibonacci. */
    static final Set<Integer> FIBONACCI = Set.of(1, 2, 3, 5, 8, 13, 21);
    /** F-REQ-21 ordre canonique des champs d'un instantané (jsonb ne conserve pas l'ordre des clés). */
    public static final List<String> SNAPSHOT_FIELDS = List.of("key", "type", "title", "parentKey", "status", "description",
            "userStory.asA", "userStory.iWant", "userStory.soThat", "priority", "businessValue", "storyPoints", "riskLevel",
            "category", "planguage.scale", "planguage.measurementMethod", "planguage.minimumThreshold", "planguage.target",
            "planguage.unit", "transverse", "tags", "externalRef", "criteria");
    /** F-REQ-07 seuil de l'alerte « Story à découper ». */
    static final int SPLIT_THRESHOLD = 13;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @Column(name = "requirement_key", nullable = false, length = 20, updatable = false)
    private String key;

    /** Partie numérique de la clé, pour trier REQ-2 avant REQ-10. */
    @Column(name = "key_number", nullable = false, updatable = false)
    private int keyNumber;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private RequirementType type;

    @Column(nullable = false, length = TITLE_MAX)
    private String title;

    @Column(columnDefinition = "text")
    private String description;

    @Embedded
    private UserStory userStory;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Priority priority = Priority.SHOULD;

    @Column(name = "business_value")
    private Integer businessValue;

    @Column(name = "story_points")
    private Integer storyPoints;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private RequirementStatus status = RequirementStatus.DRAFT;

    @Enumerated(EnumType.STRING)
    @Column(name = "risk_level", nullable = false, length = 10)
    private RiskLevel riskLevel = RiskLevel.MEDIUM;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private NfrCategory category;

    @Embedded
    private Planguage planguage;

    @Column(nullable = false)
    private boolean transverse;

    @ElementCollection
    @CollectionTable(name = "requirement_tags", joinColumns = @JoinColumn(name = "requirement_id"))
    @Column(name = "tag", length = 50)
    private Set<String> tags = new TreeSet<>();

    @Column(name = "external_ref", length = 100)
    private String externalRef;

    @Column(name = "current_version", nullable = false)
    private int currentVersion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id")
    private Requirement parent;

    @OneToMany(mappedBy = "parent")
    @OrderBy("rank")
    private List<Requirement> children = new ArrayList<>();

    /** F-REQ-03 rang LexoRank (collation C). */
    @Column(name = "rank", nullable = false, length = 255)
    private String rank;

    @Embedded
    private Invest invest = Invest.NONE;

    @OneToMany(mappedBy = "requirement", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("position")
    private List<AcceptanceCriterion> criteria = new ArrayList<>();

    /** F-REQ-19 items manuels de DoR / DoD cochés. */
    @ManyToMany
    @JoinTable(name = "requirement_checklist_checks",
            joinColumns = @JoinColumn(name = "requirement_id"),
            inverseJoinColumns = @JoinColumn(name = "checklist_item_id"))
    private Set<ChecklistItem> checkedItems = new HashSet<>();

    /** F-REQ-04 texte indexé (clé, titre, description, story, critères) ; tsvector généré en base. */
    @Column(name = "search_text", nullable = false, columnDefinition = "text")
    private String searchText = "";

    protected Requirement() {
    }

    public Requirement(Project project, String key, RequirementType type, String title, String rank) {
        this.project = Objects.requireNonNull(project, "project");
        this.key = Objects.requireNonNull(key, "key");
        this.keyNumber = parseKeyNumber(key);
        this.type = Objects.requireNonNull(type, "type");
        this.rank = Objects.requireNonNull(rank, "rank");
        rename(title);
    }

    // ---------------------------------------------------------------- champs simples

    public void rename(String title) {
        ensureEditable();
        if (title == null || title.isBlank()) {
            throw new BusinessRuleException("REQ_TITLE_REQUIRED", "Le titre est obligatoire.");
        }
        if (title.strip().length() > TITLE_MAX) {
            throw new BusinessRuleException("REQ_TITLE_TOO_LONG", "Le titre dépasse " + TITLE_MAX + " caractères.");
        }
        this.title = title.strip();
        refreshSearchText();
    }

    public void describe(String description) {
        ensureEditable();
        this.description = description == null || description.isBlank() ? null : description;
        refreshSearchText();
    }

    public void setUserStory(UserStory userStory) {
        ensureEditable();
        this.userStory = userStory == null || userStory.isEmpty() ? null : userStory;
        refreshSearchText();
    }

    public void setPriority(Priority priority) {
        ensureEditable();
        this.priority = Objects.requireNonNull(priority);
    }

    public void setBusinessValue(Integer businessValue) {
        ensureEditable();
        if (businessValue != null && (businessValue < 1 || businessValue > 100)) {
            throw new BusinessRuleException("REQ_BUSINESS_VALUE_INVALID", "La valeur métier est comprise entre 1 et 100.");
        }
        this.businessValue = businessValue;
    }

    /** F-REQ-06 points de la suite de Fibonacci (1, 2, 3, 5, 8, 13, 21) ou {@code null}. */
    public void estimate(Integer storyPoints) {
        ensureEditable();
        if (storyPoints != null && !FIBONACCI.contains(storyPoints)) {
            throw new BusinessRuleException("REQ_POINTS_INVALID", "Les points suivent la suite 1, 2, 3, 5, 8, 13, 21.");
        }
        this.storyPoints = storyPoints;
    }

    public void setRiskLevel(RiskLevel riskLevel) {
        ensureEditable();
        this.riskLevel = Objects.requireNonNull(riskLevel);
    }

    /** F-REQ-16 catégorie ISO 25010, réservée aux ENF. */
    public void setCategory(NfrCategory category) {
        ensureEditable();
        if (category != null && type != RequirementType.NON_FUNCTIONAL) {
            throw new BusinessRuleException("REQ_CATEGORY_NFR_ONLY", "Seule une exigence non fonctionnelle a une catégorie.");
        }
        this.category = category;
    }

    public void setPlanguage(Planguage planguage) {
        ensureEditable();
        if (planguage != null && !planguage.isEmpty() && type != RequirementType.NON_FUNCTIONAL) {
            throw new BusinessRuleException("REQ_PLANGUAGE_NFR_ONLY", "Seule une exigence non fonctionnelle a des champs mesurables.");
        }
        this.planguage = planguage == null || planguage.isEmpty() ? null : planguage;
    }

    /** F-REQ-17 ENF transverse. */
    public void setTransverse(boolean transverse) {
        ensureEditable();
        if (transverse && type != RequirementType.NON_FUNCTIONAL) {
            throw new BusinessRuleException("REQ_TRANSVERSE_NFR_ONLY", "Seule une exigence non fonctionnelle peut être transverse.");
        }
        this.transverse = transverse;
    }

    public void setTags(Collection<String> tags) {
        ensureEditable();
        this.tags.clear();
        if (tags != null) {
            tags.stream()
                    .filter(Objects::nonNull)
                    .map(t -> t.strip().toLowerCase(Locale.ROOT))
                    .filter(t -> !t.isEmpty())
                    .forEach(t -> {
                        if (t.length() > 50) {
                            throw new BusinessRuleException("REQ_TAG_TOO_LONG", "Un tag dépasse 50 caractères : " + t);
                        }
                        this.tags.add(t);
                    });
        }
    }

    public void setExternalRef(String externalRef) {
        ensureEditable();
        this.externalRef = externalRef == null || externalRef.isBlank() ? null : externalRef.strip();
    }

    /** F-REQ-07 INVEST. */
    public void setInvest(Invest invest) {
        ensureEditable();
        this.invest = invest == null ? Invest.NONE : invest;
    }

    public void setRank(String rank) {
        this.rank = Objects.requireNonNull(rank);
    }

    // ---------------------------------------------------------------- hiérarchie (§3.3-1)

    /** F-REQ-02 Place l'exigence sous {@code newParent} (ou à la racine) après vérification du §3.3-1. */
    public void moveUnder(Requirement newParent) {
        ensureEditable();
        checkParent(type, newParent);
        if (parent != null) {
            parent.mutableChildren().remove(this);
        }
        parent = newParent;
        if (newParent != null) {
            newParent.mutableChildren().add(this);
        }
    }

    /** Vérifie que la position actuelle respecte le §3.3-1 (utile à la création). */
    public void checkHierarchy() {
        checkParent(type, parent);
    }

    /** §3.3-1 un changement de type revérifie le parent et les enfants. */
    public void changeType(RequirementType newType) {
        ensureEditable();
        if (newType == type) {
            return;
        }
        checkParent(newType, parent);
        for (Requirement child : children) {
            if (!child.getType().allowedParents().contains(newType)) {
                throw new BusinessRuleException("REQ_PARENT_INVALID", "L'enfant " + child.getKey() + " (" + child.getType()
                        + ") ne peut pas être placé sous un " + newType + ".");
            }
        }
        if (newType != RequirementType.NON_FUNCTIONAL) {
            category = null;
            planguage = null;
            transverse = false;
        }
        type = newType;
    }

    private void checkParent(RequirementType childType, Requirement candidate) {
        if (candidate == null) {
            if (!childType.allowsNoParent()) {
                throw new BusinessRuleException("REQ_PARENT_REQUIRED", "Une " + childType + " doit avoir un parent FEATURE ou EPIC.");
            }
            return;
        }
        for (Requirement ancestor = candidate; ancestor != null; ancestor = ancestor.getParent()) {
            if (ancestor == this) {
                throw new BusinessRuleException("REQ_CYCLE", "Une exigence ne peut pas être placée sous elle-même ou sa descendance.");
            }
        }
        Project candidateProject = candidate.getProject();
        boolean sameProject = candidateProject == project
                || (project.getId() != null && project.getId().equals(candidateProject.getId()));
        if (!sameProject) {
            throw new BusinessRuleException("REQ_PARENT_INVALID", "Le parent doit appartenir au même projet.");
        }
        if (!childType.allowedParents().contains(candidate.getType())) {
            throw new BusinessRuleException("REQ_PARENT_INVALID",
                    "Une " + childType + " ne peut pas être placée sous une " + candidate.getType() + ".");
        }
    }

    public boolean isDescendantOf(Requirement ancestor) {
        for (Requirement current = parent; current != null; current = current.getParent()) {
            if (current == ancestor) {
                return true;
            }
        }
        return false;
    }

    /** F-REQ-17 Cette ENF transverse s'applique-t-elle à {@code story} ? */
    public boolean appliesTransverselyTo(Requirement story) {
        if (type != RequirementType.NON_FUNCTIONAL || !transverse || story.getType() != RequirementType.USER_STORY) {
            return false;
        }
        return parent == null || story.isDescendantOf(parent);
    }

    /** §3.3-6 suppression : seulement sans enfant (et, à partir du lot 5, jamais exécutée). */
    public void ensureDeletable() {
        if (!children.isEmpty()) {
            throw new BusinessRuleException("REQ_HAS_CHILDREN", "Supprimez ou déplacez d'abord les exigences enfants.");
        }
    }

    // ---------------------------------------------------------------- statut (§3.2, §3.3-2)

    public void changeStatus(RequirementStatus target) {
        if (!status.canMoveTo(target)) {
            throw new BusinessRuleException("REQ_STATUS_TRANSITION_INVALID",
                    "Passage de " + status + " à " + target + " impossible.");
        }
        if (target == RequirementStatus.READY && criteria.isEmpty()) {
            throw new BusinessRuleException("REQ_READY_WITHOUT_CRITERIA",
                    "Une exigence ne passe à READY qu'avec au moins un critère d'acceptation.");
        }
        status = target;
    }

    private void ensureEditable() {
        if (status == RequirementStatus.OBSOLETE) {
            throw new BusinessRuleException("REQ_OBSOLETE", "Une exigence obsolète ne peut plus être modifiée.");
        }
    }

    // ---------------------------------------------------------------- critères (F-REQ-09)

    public AcceptanceCriterion addCriterion(CriterionFormat format, String content) {
        ensureEditable();
        AcceptanceCriterion criterion = new AcceptanceCriterion(this, criteria.size() + 1, format, content);
        criteria.add(criterion);
        refreshSearchText();
        return criterion;
    }

    public void rewriteCriterion(AcceptanceCriterion criterion, CriterionFormat format, String content) {
        ensureEditable();
        ensureOwn(criterion);
        criterion.rewrite(format, content);
        refreshSearchText();
    }

    public void removeCriterion(AcceptanceCriterion criterion) {
        ensureEditable();
        ensureOwn(criterion);
        criteria.remove(criterion);
        renumber();
        refreshSearchText();
    }

    public void reorderCriteria(List<AcceptanceCriterion> ordered) {
        ensureEditable();
        if (ordered.size() != criteria.size() || !new HashSet<>(ordered).equals(new HashSet<>(criteria))) {
            throw new BusinessRuleException("CRITERIA_ORDER_INVALID", "L'ordre doit contenir exactement les critères existants.");
        }
        criteria.clear();
        criteria.addAll(ordered);
        renumber();
    }

    private void ensureOwn(AcceptanceCriterion criterion) {
        if (!criteria.contains(criterion)) {
            throw new BusinessRuleException("CRITERION_NOT_IN_REQUIREMENT", "Ce critère n'appartient pas à l'exigence " + key + ".");
        }
    }

    private void renumber() {
        for (int i = 0; i < criteria.size(); i++) {
            criteria.get(i).setPosition(i + 1);
        }
    }

    // ---------------------------------------------------------------- DoR / DoD (F-REQ-19)

    public void check(ChecklistItem item, boolean checked) {
        if (item.isAutomatic()) {
            throw new BusinessRuleException("CHECKLIST_ITEM_AUTOMATIC", "Cet item est vérifié automatiquement.");
        }
        if (checked) {
            checkedItems.add(item);
        } else {
            checkedItems.remove(item);
        }
    }

    public boolean isChecked(ChecklistItem item) {
        return checkedItems.contains(item);
    }

    // ---------------------------------------------------------------- versions, duplication

    /** F-REQ-21 numéro de la prochaine version figée. */
    public int nextVersion() {
        return ++currentVersion;
    }

    /** F-REQ-21 / NF-16 instantané des champs métier, critères compris. */
    public Map<String, Object> snapshot() {
        Map<String, Object> snapshot = new LinkedHashMap<>();
        UserStory story = getUserStory();
        Planguage measure = getPlanguage();
        snapshot.put("key", key);
        snapshot.put("type", type.name());
        snapshot.put("title", title);
        snapshot.put("parentKey", parent == null ? null : parent.getKey());
        snapshot.put("status", status.name());
        snapshot.put("description", description);
        snapshot.put("userStory.asA", story.asA());
        snapshot.put("userStory.iWant", story.iWant());
        snapshot.put("userStory.soThat", story.soThat());
        snapshot.put("priority", priority.name());
        snapshot.put("businessValue", businessValue);
        snapshot.put("storyPoints", storyPoints);
        snapshot.put("riskLevel", riskLevel.name());
        snapshot.put("category", category == null ? null : category.name());
        snapshot.put("planguage.scale", measure.scale());
        snapshot.put("planguage.measurementMethod", measure.measurementMethod());
        snapshot.put("planguage.minimumThreshold", measure.minimumThreshold());
        snapshot.put("planguage.target", measure.target());
        snapshot.put("planguage.unit", measure.unit());
        snapshot.put("transverse", transverse);
        snapshot.put("tags", tags.isEmpty() ? null : String.join(", ", tags));
        snapshot.put("externalRef", externalRef);
        snapshot.put("criteria", criteria.stream().map(AcceptanceCriterion::describe).toList());
        return snapshot;
    }

    /** Remet un instantané relu (jsonb) dans l'ordre canonique ; les champs inconnus suivent. */
    public static Map<String, Object> inSnapshotOrder(Map<String, ?> snapshot) {
        Map<String, Object> ordered = new LinkedHashMap<>();
        SNAPSHOT_FIELDS.stream().filter(snapshot::containsKey).forEach(field -> ordered.put(field, snapshot.get(field)));
        snapshot.forEach(ordered::putIfAbsent);
        return ordered;
    }

    /** F-REQ-02 copie : nouvelle clé, statut DRAFT, mêmes champs et critères, même parent, sans enfants. */
    public Requirement duplicate(String newKey, String newRank) {
        Requirement copy = new Requirement(project, newKey, type, truncate("Copie de " + title), newRank);
        copy.description = description;
        copy.userStory = userStory;
        copy.priority = priority;
        copy.businessValue = businessValue;
        copy.storyPoints = storyPoints;
        copy.riskLevel = riskLevel;
        copy.category = category;
        copy.planguage = planguage;
        copy.transverse = transverse;
        copy.tags.addAll(tags);
        copy.externalRef = externalRef;
        copy.invest = invest;
        if (parent != null) {
            copy.moveUnder(parent);
        }
        criteria.forEach(c -> copy.addCriterion(c.getFormat(), c.getContent()));
        copy.refreshSearchText();
        return copy;
    }

    private static int parseKeyNumber(String key) {
        try {
            return Integer.parseInt(key.substring(key.lastIndexOf('-') + 1));
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Clé d'exigence invalide : " + key, e);
        }
    }

    private static String truncate(String value) {
        return value.length() <= TITLE_MAX ? value : value.substring(0, TITLE_MAX);
    }

    private void refreshSearchText() {
        UserStory story = getUserStory();
        searchText = java.util.stream.Stream.concat(
                        java.util.stream.Stream.of(key, title, description, story.asA(), story.iWant(), story.soThat()),
                        criteria.stream().map(AcceptanceCriterion::getContent))
                .filter(Objects::nonNull)
                .collect(Collectors.joining("\n"));
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

    public RequirementType getType() {
        return type;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public UserStory getUserStory() {
        return userStory == null ? UserStory.EMPTY : userStory;
    }

    public Priority getPriority() {
        return priority;
    }

    public Integer getBusinessValue() {
        return businessValue;
    }

    public Integer getStoryPoints() {
        return storyPoints;
    }

    /** F-REQ-07 alerte « Story à découper » à partir de 13 points. */
    public boolean needsSplitting() {
        return storyPoints != null && storyPoints >= SPLIT_THRESHOLD;
    }

    public RequirementStatus getStatus() {
        return status;
    }

    public RiskLevel getRiskLevel() {
        return riskLevel;
    }

    public NfrCategory getCategory() {
        return category;
    }

    public Planguage getPlanguage() {
        return planguage == null ? Planguage.EMPTY : planguage;
    }

    public boolean isTransverse() {
        return transverse;
    }

    public Set<String> getTags() {
        return Collections.unmodifiableSet(tags);
    }

    public String getExternalRef() {
        return externalRef;
    }

    public int getCurrentVersion() {
        return currentVersion;
    }

    public Requirement getParent() {
        return parent;
    }

    public List<Requirement> getChildren() {
        return Collections.unmodifiableList(children);
    }

    /** Liste modifiable, appelée par méthode pour fonctionner aussi à travers un proxy Hibernate. */
    List<Requirement> mutableChildren() {
        return children;
    }

    public String getRank() {
        return rank;
    }

    public Invest getInvest() {
        return invest == null ? Invest.NONE : invest;
    }

    public List<AcceptanceCriterion> getCriteria() {
        return Collections.unmodifiableList(criteria);
    }

    public String getSearchText() {
        return searchText;
    }
}
