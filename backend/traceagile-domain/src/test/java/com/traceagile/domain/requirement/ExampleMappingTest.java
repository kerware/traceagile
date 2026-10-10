package com.traceagile.domain.requirement;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Project;
import java.time.Instant;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** §4.4 atelier Example Mapping (F-REQ-13 à F-REQ-15) et commentaires (§13.2, ADR-0024). */
class ExampleMappingTest {

    final Project shop = new Project("SHOP", "Boutique", null);
    final Requirement story = new Requirement(shop, "REQ-2", RequirementType.USER_STORY, "Payer", "b");
    final Instant now = Instant.parse("2026-10-20T10:00:00Z");

    @Test
    @DisplayName("F-REQ-13 règles et exemples d'une story ; un exemple se rattache à une règle de la même story")
    void cards() {
        ExampleCard rule = ExampleCard.rule(story, " Livraison gratuite dès 50 € ", 1);
        ExampleCard example = ExampleCard.example(story, rule, "Panier de 49,99 € : frais de 4,90 €", 1);
        assertThat(rule.getText()).isEqualTo("Livraison gratuite dès 50 €");
        assertThat(example.getRule()).isSameAs(rule);

        Requirement feature = new Requirement(shop, "REQ-1", RequirementType.FEATURE, "Panier", "a");
        assertThatThrownBy(() -> ExampleCard.rule(feature, "x", 1)).extracting("code").isEqualTo("EXAMPLE_MAPPING_STORY_ONLY");
        assertThatThrownBy(() -> ExampleCard.example(story, example, "x", 2)).extracting("code").isEqualTo("EXAMPLE_RULE_REQUIRED");
        Requirement other = new Requirement(shop, "REQ-3", RequirementType.USER_STORY, "Autre", "c");
        assertThatThrownBy(() -> ExampleCard.example(other, rule, "x", 1)).extracting("code").isEqualTo("EXAMPLE_RULE_REQUIRED");
        assertThatThrownBy(() -> ExampleCard.rule(story, " ", 2)).extracting("code").isEqualTo("EXAMPLE_CARD_TEXT_REQUIRED");
        assertThatThrownBy(() -> rule.edit("x".repeat(501))).extracting("code").isEqualTo("EXAMPLE_CARD_TOO_LONG");
    }

    @Test
    @DisplayName("F-REQ-14 un exemple devient un scénario Gherkin à compléter ; une carte ne se convertit qu'une fois")
    void conversion() {
        ExampleCard rule = ExampleCard.rule(story, "Livraison gratuite dès 50 €", 1);
        ExampleCard example = ExampleCard.example(story, rule, "Panier de 50 € : livraison offerte", 1);
        assertThat(example.gherkin()).isEqualTo("""
                Scénario: Panier de 50 € : livraison offerte
                  Étant donné Livraison gratuite dès 50 €
                  Quand l'action est réalisée
                  Alors le résultat attendu est obtenu""");
        example.markConverted("Critère 3");
        assertThatThrownBy(() -> example.markConverted("Critère 4")).extracting("code").isEqualTo("EXAMPLE_CARD_ALREADY_CONVERTED");
        assertThat(example.getConvertedTo()).isEqualTo("Critère 3");
    }

    @Test
    @DisplayName("§13.2 commentaire : texte obligatoire, modification datée ; F-REQ-15 une question reste ouverte tant qu'elle n'est pas résolue")
    void comments() {
        Comment comment = new Comment(story, "qa1", " Bien vu ", false);
        assertThat(comment.getText()).isEqualTo("Bien vu");
        assertThat(comment.isAuthor("qa1")).isTrue();
        assertThat(comment.isOpenQuestion()).isFalse();
        comment.edit("Bien vu, merci", now);
        assertThat(comment.getEditedAt()).isEqualTo(now);
        assertThatThrownBy(() -> comment.resolve(true, "po", now)).extracting("code").isEqualTo("COMMENT_NOT_A_QUESTION");
        assertThatThrownBy(() -> new Comment(story, "qa1", "  ", false)).extracting("code").isEqualTo("COMMENT_TEXT_REQUIRED");

        Comment question = new Comment(story, "qa1", "Et pour un panier de 50 € pile ?", true);
        assertThat(question.isOpenQuestion()).isTrue();
        question.resolve(true, "po", now);
        assertThat(question.isOpenQuestion()).isFalse();
        assertThat(question.getResolvedBy()).isEqualTo("po");
        question.resolve(false, "po", now);
        assertThat(question.isOpenQuestion()).isTrue();
        assertThat(question.getResolvedBy()).isNull();
    }
}
