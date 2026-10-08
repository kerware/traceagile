package com.traceagile.infrastructure.gherkin;

import static org.assertj.core.api.Assertions.assertThat;

import com.traceagile.application.requirement.GherkinValidator.GherkinValidation;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** F-REQ-10 validation Gherkin côté serveur (io.cucumber:gherkin), mots-clés français et anglais. */
class CucumberGherkinValidatorTest {

    CucumberGherkinValidator validator = new CucumberGherkinValidator();

    @Test
    @DisplayName("F-REQ-10 un scénario français seul est valide (en-tête Fonctionnalité implicite)")
    void frenchScenario() {
        GherkinValidation result = validator.validate("""
                Scénario: livraison gratuite au seuil
                  Étant donné un panier de 50 €
                  Quand je valide ma commande
                  Alors la livraison est offerte""");

        assertThat(result.valid()).isTrue();
        assertThat(result.language()).isEqualTo("fr");
    }

    @Test
    @DisplayName("F-REQ-10 un scénario anglais seul est valide")
    void englishScenario() {
        GherkinValidation result = validator.validate("""
                Scenario: free shipping
                  Given a cart of 50 EUR
                  Then shipping is free""");

        assertThat(result.valid()).isTrue();
        assertThat(result.language()).isEqualTo("en");
    }

    @Test
    @DisplayName("F-REQ-10 la directive # language est respectée, fichier .feature complet accepté")
    void languageDirectiveAndFullFeature() {
        GherkinValidation result = validator.validate("""
                # language: fr
                Fonctionnalité: Panier
                  Plan du scénario: seuils
                    Soit un panier de <montant> €
                    Alors la livraison coûte <frais> €
                    Exemples:
                      | montant | frais |
                      | 49      | 5     |
                      | 50      | 0     |""");

        assertThat(result.valid()).isTrue();
        assertThat(result.language()).isEqualTo("fr");
    }

    @Test
    @DisplayName("F-REQ-10 une erreur est positionnée sur la ligne saisie par l'utilisateur")
    void errorLine() {
        GherkinValidation result = validator.validate("""
                Scénario: tableau mal formé
                  Étant donné les produits
                    | nom | prix |
                    | stylo |
                  Alors rien""");

        assertThat(result.valid()).isFalse();
        assertThat(result.errors()).first().satisfies(error -> {
            assertThat(error.line()).isEqualTo(4);
            assertThat(error.message()).isNotBlank();
        });
    }

    @Test
    @DisplayName("F-REQ-10 du texte libre n'est pas du Gherkin")
    void plainText() {
        assertThat(validator.validate("Le total du panier est affiché").valid()).isFalse();
    }
}
