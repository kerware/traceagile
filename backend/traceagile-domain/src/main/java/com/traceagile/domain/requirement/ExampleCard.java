package com.traceagile.domain.requirement;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/**
 * F-REQ-13 carte de l'atelier Example Mapping d'une story (ADR-0024) : une règle (bleue) ou un
 * exemple (vert) rattaché à une règle. La story est la carte jaune ; les questions (rouges) sont des
 * commentaires {@link Comment#isQuestion()}.
 */
@Entity
@Table(name = "example_cards")
public class ExampleCard extends AuditableEntity {

    public static final int MAX_LENGTH = 500;

    /** Colonne de la carte. */
    public enum Kind {
        RULE,
        EXAMPLE
    }

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requirement_id")
    private Requirement requirement;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Kind kind;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "rule_id")
    private ExampleCard rule;

    @Column(nullable = false, length = MAX_LENGTH)
    private String text;

    @Column(nullable = false)
    private int position;

    /** F-REQ-14 élément créé par la conversion : clé de l'exigence (règle) ou « Critère n » (exemple). */
    @Column(name = "converted_to", length = 40)
    private String convertedTo;

    protected ExampleCard() {
    }

    private ExampleCard(Requirement requirement, Kind kind, ExampleCard rule, String text, int position) {
        if (requirement.getType() != RequirementType.USER_STORY) {
            throw new BusinessRuleException("EXAMPLE_MAPPING_STORY_ONLY", "L'atelier Example Mapping porte sur une user story.");
        }
        this.requirement = requirement;
        this.kind = kind;
        this.rule = rule;
        this.position = position;
        edit(text);
    }

    public static ExampleCard rule(Requirement story, String text, int position) {
        return new ExampleCard(story, Kind.RULE, null, text, position);
    }

    /** Un exemple est rattaché à une règle de la même story. */
    public static ExampleCard example(Requirement story, ExampleCard rule, String text, int position) {
        if (rule == null || rule.getKind() != Kind.RULE || !sameRequirement(rule.getRequirement(), story)) {
            throw new BusinessRuleException("EXAMPLE_RULE_REQUIRED", "Un exemple se rattache à une règle de la même story.");
        }
        return new ExampleCard(story, Kind.EXAMPLE, rule, text, position);
    }

    private static boolean sameRequirement(Requirement a, Requirement b) {
        return a == b || (a.getId() != null && a.getId().equals(b.getId()));
    }

    public void edit(String text) {
        String value = text == null ? "" : text.strip();
        if (value.isEmpty()) {
            throw new BusinessRuleException("EXAMPLE_CARD_TEXT_REQUIRED", "La carte est vide.");
        }
        if (value.length() > MAX_LENGTH) {
            throw new BusinessRuleException("EXAMPLE_CARD_TOO_LONG", "La carte dépasse " + MAX_LENGTH + " caractères.");
        }
        this.text = value;
    }

    public void moveTo(int position) {
        this.position = position;
    }

    /** F-REQ-14 une carte ne se convertit qu'une fois. */
    public void ensureConvertible() {
        if (convertedTo != null) {
            throw new BusinessRuleException("EXAMPLE_CARD_ALREADY_CONVERTED", "Cette carte a déjà été convertie (" + convertedTo + ").");
        }
    }

    public void markConverted(String target) {
        ensureConvertible();
        this.convertedTo = target;
    }

    /**
     * F-REQ-14 critère Gherkin tiré d'un exemple : le scénario porte le texte de l'exemple, les étapes
     * sont à compléter.
     */
    public String gherkin() {
        return "Scénario: " + text.replace('\n', ' ') + "\n"
                + "  Étant donné " + (rule == null ? "le contexte" : rule.getText().replace('\n', ' ')) + "\n"
                + "  Quand l'action est réalisée\n"
                + "  Alors le résultat attendu est obtenu";
    }

    public Requirement getRequirement() {
        return requirement;
    }

    public Kind getKind() {
        return kind;
    }

    public ExampleCard getRule() {
        return rule;
    }

    public String getText() {
        return text;
    }

    public int getPosition() {
        return position;
    }

    public String getConvertedTo() {
        return convertedTo;
    }
}
