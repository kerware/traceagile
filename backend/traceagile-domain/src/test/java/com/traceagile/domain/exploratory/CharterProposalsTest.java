package com.traceagile.domain.exploratory;

import static org.assertj.core.api.Assertions.assertThat;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.requirement.NfrCategory;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementType;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** F-EXP-04 générer des chartes depuis une exigence : une par critère d'acceptation, une par ENF transverse applicable. */
class CharterProposalsTest {

    final Project shop = new Project("SHOP", "Boutique", null);

    @Test
    @DisplayName("F-EXP-04 une proposition par critère (titre du scénario Gherkin ou texte) et par ENF transverse")
    void proposals() {
        Requirement story = new Requirement(shop, "REQ-7", RequirementType.USER_STORY, "Appliquer un code promo", "a");
        story.addCriterion(CriterionFormat.GHERKIN, """
                # language: fr
                Fonctionnalité: Code promo
                  Scénario: Code expiré refusé
                    Soit un code expiré
                    Alors il est refusé""");
        story.addCriterion(CriterionFormat.TEXT, "Le total est recalculé après application du code.");
        Requirement nfr = new Requirement(shop, "REQ-30", RequirementType.NON_FUNCTIONAL, "Temps de réponse < 800 ms", "a");
        nfr.setCategory(NfrCategory.PERFORMANCE);

        List<CharterProposal> proposals = CharterProposals.from(story, List.of(nfr));

        assertThat(proposals).hasSize(3);
        CharterProposal first = proposals.getFirst();
        assertThat(first.source()).isEqualTo("CRITERION");
        assertThat(first.criterionPosition()).isEqualTo(1);
        assertThat(first.title()).isEqualTo("Explorer « Appliquer un code promo » : Code expiré refusé");
        assertThat(first.explore()).isEqualTo("Appliquer un code promo");
        assertThat(first.toDiscover()).contains("Code expiré refusé");
        assertThat(first.requirementKeys()).containsExactly("REQ-7");
        assertThat(proposals.get(1).title()).endsWith("Le total est recalculé après application du code.");
        CharterProposal performance = proposals.get(2);
        assertThat(performance.source()).isEqualTo("NFR");
        assertThat(performance.requirementKeys()).containsExactly("REQ-7", "REQ-30");
        assertThat(performance.toDiscover()).contains("Temps de réponse < 800 ms");
        assertThat(performance.heuristics()).contains("Goldilocks");
    }
}
