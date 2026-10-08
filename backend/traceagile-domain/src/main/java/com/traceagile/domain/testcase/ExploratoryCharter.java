package com.traceagile.domain.testcase;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * §3.1 ExploratoryCharter : mission « Explorer… avec… pour découvrir… » (F-EXP-01), zones,
 * heuristiques, durée cible de 60, 90 ou 120 minutes, notes de préparation (F-EXP-02).
 */
@Entity
@Table(name = "exploratory_charters")
public class ExploratoryCharter extends AuditableEntity {

    static final Set<Integer> TIMEBOXES = Set.of(60, 90, 120);
    /** F-EXP-02 heuristiques suggérées (extensibles par projet au lot 6). */
    public static final List<String> SUGGESTED_HEURISTICS = List.of("SFDIPOT", "FEW HICCUPPS", "CRUD", "Goldilocks",
            "Tours de Whittaker");

    @OneToOne(optional = false)
    @JoinColumn(name = "test_case_id", unique = true)
    private TestCase testCase;

    @Column(name = "mission_explore", length = 500)
    private String explore;

    @Column(name = "mission_with", length = 500)
    private String with;

    @Column(name = "mission_to_discover", length = 500)
    private String toDiscover;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private List<String> areas = new ArrayList<>();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private List<String> heuristics = new ArrayList<>();

    @Column(name = "timebox_min", nullable = false)
    private int timeboxMin = 90;

    @Column(name = "setup_notes", columnDefinition = "text")
    private String setupNotes;

    /** F-EXP-02 risque visé, en texte libre. */
    @Column(name = "targeted_risk", length = 500)
    private String targetedRisk;

    protected ExploratoryCharter() {
    }

    ExploratoryCharter(TestCase testCase) {
        this.testCase = testCase;
    }

    public void setMission(String explore, String with, String toDiscover) {
        testCase.ensureEditable();
        this.explore = blankToNull(explore);
        this.with = blankToNull(with);
        this.toDiscover = blankToNull(toDiscover);
    }

    public void setTimeboxMin(int timeboxMin) {
        testCase.ensureEditable();
        if (!TIMEBOXES.contains(timeboxMin)) {
            throw new BusinessRuleException("CHARTER_TIMEBOX_INVALID", "La durée cible est de 60, 90 ou 120 minutes.");
        }
        this.timeboxMin = timeboxMin;
    }

    public void setAreas(List<String> areas) {
        testCase.ensureEditable();
        this.areas = clean(areas);
    }

    public void setHeuristics(List<String> heuristics) {
        testCase.ensureEditable();
        this.heuristics = clean(heuristics);
    }

    public void setSetupNotes(String setupNotes) {
        testCase.ensureEditable();
        this.setupNotes = blankToNull(setupNotes);
    }

    public void setTargetedRisk(String targetedRisk) {
        testCase.ensureEditable();
        this.targetedRisk = blankToNull(targetedRisk);
    }

    /** F-EXP-01 « Explorer le panier avec des produits en rupture pour découvrir les incohérences. » */
    public String missionSentence() {
        if (explore == null && with == null && toDiscover == null) {
            return "";
        }
        StringBuilder sentence = new StringBuilder("Explorer ").append(explore == null ? "…" : explore);
        if (with != null) {
            sentence.append(" avec ").append(with);
        }
        return sentence.append(" pour découvrir ").append(toDiscover == null ? "…" : toDiscover).append('.').toString();
    }

    boolean isComplete() {
        return explore != null && toDiscover != null;
    }

    List<Object> content() {
        return List.of(Objects.toString(explore, ""), Objects.toString(with, ""), Objects.toString(toDiscover, ""),
                List.copyOf(areas), timeboxMin);
    }

    static List<String> clean(List<String> values) {
        if (values == null) {
            return new ArrayList<>();
        }
        return new ArrayList<>(values.stream().filter(Objects::nonNull).map(String::strip).filter(v -> !v.isEmpty())
                .distinct().toList());
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.strip();
    }

    public TestCase getTestCase() {
        return testCase;
    }

    public String getExplore() {
        return explore;
    }

    public String getWith() {
        return with;
    }

    public String getToDiscover() {
        return toDiscover;
    }

    public List<String> getAreas() {
        return List.copyOf(areas);
    }

    public List<String> getHeuristics() {
        return List.copyOf(heuristics);
    }

    public int getTimeboxMin() {
        return timeboxMin;
    }

    public String getSetupNotes() {
        return setupNotes;
    }

    public String getTargetedRisk() {
        return targetedRisk;
    }
}
