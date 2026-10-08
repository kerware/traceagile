package com.traceagile.infrastructure.gherkin;

import static org.assertj.core.api.Assertions.assertThat;

import com.traceagile.application.testcase.FeatureFileParser.ParsedFeature;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** F-AUT-05 un .feature à plusieurs scénarios donne un test par scénario ; F-AUT-07 recomposition. */
class CucumberFeatureFileParserTest {

    static final String PANIER = """
            # language: fr
            @panier
            Fonctionnalité: Livraison
              Les frais dépendent du montant.

              Contexte:
                Étant donné un client connecté

              @REQ-12 @smoke
              Scénario: livraison gratuite au seuil
                Étant donné un panier de 50 €
                Alors la livraison est offerte

              Scénario: livraison payante
                Étant donné un panier de 49 €
                Alors la livraison coûte 4,90 €
            """;

    CucumberFeatureFileParser parser = new CucumberFeatureFileParser(new CucumberGherkinValidator());

    @Test
    @DisplayName("F-AUT-05 découpe : en-tête (langue, tags, description, contexte) et un bloc par scénario")
    void split() {
        ParsedFeature feature = parser.parse(PANIER);

        assertThat(feature.valid()).isTrue();
        assertThat(feature.language()).isEqualTo("fr");
        assertThat(feature.featureName()).isEqualTo("Livraison");
        assertThat(feature.header()).contains("# language: fr", "@panier", "Contexte:", "un client connecté")
                .doesNotContain("Scénario");
        assertThat(feature.scenarios()).extracting("name").containsExactly("livraison gratuite au seuil", "livraison payante");
        assertThat(feature.scenarios().getFirst().tags()).containsExactly("@REQ-12", "@smoke");
        assertThat(feature.scenarios().getFirst().block()).startsWith("  @REQ-12 @smoke\n  Scénario: livraison gratuite")
                .doesNotContain("livraison payante");
    }

    @Test
    @DisplayName("F-AUT-05 le document d'un scénario seul reste un .feature valide")
    void documentForScenario() {
        ParsedFeature feature = parser.parse(PANIER);
        String single = feature.documentFor(feature.scenarios().get(1));

        ParsedFeature reparsed = parser.parse(single);
        assertThat(reparsed.valid()).isTrue();
        assertThat(reparsed.scenarios()).extracting("name").containsExactly("livraison payante");
        assertThat(single).contains("Contexte:");
    }

    @Test
    @DisplayName("F-AUT-07 recomposer plusieurs scénarios redonne la fonctionnalité d'origine")
    void compose() {
        ParsedFeature feature = parser.parse(PANIER);
        String merged = ParsedFeature.compose(feature.header(), feature.scenarios().stream().map(s -> s.block()).toList());

        assertThat(parser.parse(merged).scenarios()).hasSize(2);
    }

    @Test
    @DisplayName("F-AUT-05 sans directive de langue, les mots-clés français sont reconnus")
    void frenchWithoutDirective() {
        ParsedFeature feature = parser.parse("Fonctionnalité: Compte\n  Scénario: connexion\n    Soit un client\n");

        assertThat(feature.valid()).isTrue();
        assertThat(feature.header()).startsWith("# language: fr");
        assertThat(feature.scenarios()).hasSize(1);
    }

    @Test
    @DisplayName("F-AUT-05 fichier invalide : erreurs positionnées")
    void invalid() {
        assertThat(parser.parse("Pas du Gherkin\n").valid()).isFalse();
    }

    @Test
    @DisplayName("F-AUT-04 textes des étapes, contexte compris, sans mot-clé")
    void stepTexts() {
        assertThat(parser.stepTexts(PANIER)).containsExactly(
                "un client connecté", "un panier de 50 €", "la livraison est offerte", "un panier de 49 €",
                "la livraison coûte 4,90 €");
        assertThat(parser.stepTexts("Scénario: seul\n  Soit un panier vide\n")).isEqualTo(List.of("un panier vide"));
    }
}
