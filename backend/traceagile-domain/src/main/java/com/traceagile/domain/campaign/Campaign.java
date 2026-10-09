package com.traceagile.domain.campaign;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.planning.Release;
import com.traceagile.domain.planning.Sprint;
import com.traceagile.domain.testcase.TestCase;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;

/**
 * §3.1 Campaign (F-CMP-01) : périmètre (sprint, release ou régression), environnement, build,
 * tests sélectionnés ordonnés (F-CMP-02, F-CMP-03). Une campagne terminée ou abandonnée est en lecture seule.
 */
@Entity
@Table(name = "campaigns")
public class Campaign extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @Column(name = "campaign_key", nullable = false, length = 20, updatable = false)
    private String key;

    @Column(name = "key_number", nullable = false, updatable = false)
    private int keyNumber;

    @Column(nullable = false, length = 120)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "scope_type", nullable = false, length = 12)
    private CampaignScope scopeType;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sprint_id")
    private Sprint sprint;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "release_id")
    private Release release;

    @Column(length = 60)
    private String environment;

    @Column(name = "build_version", length = 60)
    private String buildVersion;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 12)
    private CampaignStatus status = CampaignStatus.PLANNED;

    @Column(name = "planned_start")
    private LocalDate plannedStart;

    @Column(name = "planned_end")
    private LocalDate plannedEnd;

    @OneToMany(mappedBy = "campaign", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("position ASC")
    private List<CampaignItem> items = new ArrayList<>();

    protected Campaign() {
    }

    public Campaign(Project project, String key, String name, CampaignScope scopeType, Sprint sprint, Release release,
                    String environment, String buildVersion, LocalDate plannedStart, LocalDate plannedEnd) {
        this.project = Objects.requireNonNull(project);
        this.key = Objects.requireNonNull(key);
        this.keyNumber = Integer.parseInt(key.substring(key.lastIndexOf('-') + 1));
        rename(name);
        setScope(scopeType, sprint, release);
        describeTarget(environment, buildVersion);
        schedule(plannedStart, plannedEnd);
    }

    void ensureOpen() {
        if (status.isClosed()) {
            throw new BusinessRuleException("CAMPAIGN_CLOSED", "La campagne " + key + " est " + status + " : elle est en lecture seule.");
        }
    }

    public void rename(String name) {
        ensureOpen();
        if (name == null || name.isBlank()) {
            throw new BusinessRuleException("CAMPAIGN_NAME_REQUIRED", "Le nom de la campagne est obligatoire.");
        }
        this.name = name.strip();
    }

    public void setScope(CampaignScope scopeType, Sprint sprint, Release release) {
        ensureOpen();
        boolean valid = switch (Objects.requireNonNull(scopeType)) {
            case SPRINT -> sprint != null && release == null;
            case RELEASE -> release != null && sprint == null;
            case REGRESSION -> sprint == null && release == null;
        };
        if (!valid) {
            throw new BusinessRuleException("CAMPAIGN_SCOPE_INVALID",
                    "Une campagne de sprint vise un sprint, de release une release, de régression ni l'un ni l'autre.");
        }
        this.scopeType = scopeType;
        this.sprint = sprint;
        this.release = release;
    }

    public void describeTarget(String environment, String buildVersion) {
        ensureOpen();
        this.environment = environment == null || environment.isBlank() ? null : environment.strip();
        this.buildVersion = buildVersion == null || buildVersion.isBlank() ? null : buildVersion.strip();
    }

    public void schedule(LocalDate start, LocalDate end) {
        ensureOpen();
        if (start != null && end != null && end.isBefore(start)) {
            throw new BusinessRuleException("PLANNING_DATES_INVALID", "La date de fin précède la date de début.");
        }
        this.plannedStart = start;
        this.plannedEnd = end;
    }

    // ---------------------------------------------------------------- sélection (F-CMP-02, F-CMP-03)

    public boolean contains(TestCase test) {
        return items.stream().anyMatch(i -> same(i.getTestCase(), test));
    }

    /** Ajoute le test en fin de campagne ; {@code null} s'il y est déjà. */
    public CampaignItem add(TestCase test, int riskScore) {
        ensureOpen();
        if (contains(test)) {
            return null;
        }
        CampaignItem item = new CampaignItem(this, test, items.size() + 1, riskScore);
        items.add(item);
        return item;
    }

    public void remove(CampaignItem item) {
        ensureOpen();
        if (!item.getExecutions().isEmpty()) {
            throw new BusinessRuleException("CAMPAIGN_ITEM_EXECUTED",
                    item.getTestCase().getKey() + " a déjà été exécuté dans cette campagne : il ne peut plus en être retiré.");
        }
        items.remove(item);
        renumber();
    }

    /** F-CMP-03 ordre proposé : score de risque décroissant (stable). */
    public void sortByRisk() {
        ensureOpen();
        items.sort(Comparator.comparingInt(CampaignItem::getRiskScore).reversed().thenComparingInt(CampaignItem::getPosition));
        renumber();
    }

    /** F-CMP-03 ordre modifié à la main : liste complète des éléments. */
    public void reorder(List<CampaignItem> ordered) {
        ensureOpen();
        if (ordered.size() != items.size() || !items.containsAll(ordered)) {
            throw new BusinessRuleException("CAMPAIGN_ORDER_INVALID", "L'ordre doit reprendre tous les tests de la campagne, une fois chacun.");
        }
        items.clear();
        items.addAll(ordered);
        renumber();
    }

    private void renumber() {
        for (int i = 0; i < items.size(); i++) {
            items.get(i).moveTo(i + 1);
        }
    }

    private static boolean same(TestCase a, TestCase b) {
        return a == b || (a.getId() != null && a.getId().equals(b.getId()));
    }

    // ---------------------------------------------------------------- cycle de vie

    /** Démarrage explicite ou à la première exécution. */
    public void start() {
        ensureOpen();
        status = CampaignStatus.IN_PROGRESS;
    }

    public void complete() {
        ensureOpen();
        status = CampaignStatus.COMPLETED;
    }

    public void abort() {
        ensureOpen();
        status = CampaignStatus.ABORTED;
    }

    public Project getProject() {
        return project;
    }

    public String getKey() {
        return key;
    }

    public int getKeyNumber() {
        return keyNumber;
    }

    public String getName() {
        return name;
    }

    public CampaignScope getScopeType() {
        return scopeType;
    }

    public Sprint getSprint() {
        return sprint;
    }

    public Release getRelease() {
        return release;
    }

    public String getEnvironment() {
        return environment;
    }

    public String getBuildVersion() {
        return buildVersion;
    }

    public CampaignStatus getStatus() {
        return status;
    }

    public LocalDate getPlannedStart() {
        return plannedStart;
    }

    public LocalDate getPlannedEnd() {
        return plannedEnd;
    }

    public List<CampaignItem> getItems() {
        return List.copyOf(items);
    }
}
