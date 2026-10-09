package com.traceagile.domain.testcase;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Project;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

/** F-MAN-01 / §6.1 paramètres d'un test et jeux de données nommés, pour les tests manuels et automatisés (ADR-0013). */
class TestParametersTest {

    final Project shop = new Project("SHOP", "Boutique", null);

    TestCase manual() {
        return TestCase.manual(shop, "TC-1", "Ajouter au panier");
    }

    @Test
    @DisplayName("F-MAN-01 les ${nom-parametre} des pas deviennent automatiquement des paramètres, dans l'ordre")
    void detectedFromSteps() {
        TestCase test = manual();
        test.addStep("Ouvrir la fiche de ${nom-produit}", "Le prix ${prix_ttc} s'affiche", "${nom-produit}");

        assertThat(test.getParameters()).extracting(TestParameter::name).containsExactly("nom-produit", "prix_ttc");
        assertThat(test.detectedParameters()).containsExactly("nom-produit", "prix_ttc");
    }

    @Test
    @DisplayName("F-MAN-01 un paramètre détecté garde la valeur par défaut et la description saisies")
    void detectedKeepsDeclaredDetails() {
        TestCase test = manual();
        test.setParameters(List.of(new TestParameter("prix", "2,50 €", "Prix TTC affiché")));
        test.addStep("Vérifier ${prix}", null, null);

        assertThat(test.getParameters()).containsExactly(new TestParameter("prix", "2,50 €", "Prix TTC affiché"));
    }

    @Test
    @DisplayName("ADR-0013 un paramètre déclaré mais absent des pas est conservé (marqué non utilisé côté interface)")
    void declaredButUnusedIsKept() {
        TestCase test = manual();
        test.setParameters(List.of(new TestParameter("devise", "EUR", null)));

        assertThat(test.getParameters()).extracting(TestParameter::name).containsExactly("devise");
        assertThat(test.detectedParameters()).isEmpty();
    }

    @Test
    @DisplayName("§6.1 un test automatisé déclare aussi des paramètres")
    void automatedParameters() {
        TestCase test = TestCase.automated(shop, "TC-2", "API", TestTechnique.API, "REST Assured");
        test.setParameters(List.of(new TestParameter("baseUrl", "https://recette", "URL de l'API")));

        assertThat(test.getParameters()).hasSize(1);
    }

    @ParameterizedTest
    @ValueSource(strings = {"", "avec espace", "a/b", "é"})
    @DisplayName("ADR-0013 nom de paramètre invalide → TEST_PARAMETER_NAME_INVALID")
    void invalidName(String name) {
        assertThatThrownBy(() -> manual().setParameters(List.of(new TestParameter(name, null, null))))
                .extracting("code").isEqualTo("TEST_PARAMETER_NAME_INVALID");
    }

    @Test
    @DisplayName("ADR-0013 nom de paramètre en double → TEST_PARAMETER_DUPLICATED")
    void duplicatedName() {
        assertThatThrownBy(() -> manual().setParameters(List.of(new TestParameter("a", null, null), new TestParameter("a", null, null))))
                .extracting("code").isEqualTo("TEST_PARAMETER_DUPLICATED");
    }

    @Test
    @DisplayName("§6.1 plusieurs jeux de données nommés ; une colonne inconnue devient un paramètre")
    void dataSets() {
        TestCase test = manual();
        test.addStep("Ouvrir ${produit}", null, null);
        test.setDataSets(List.of(
                DataSet.of("Recette", List.of(Map.of("produit", "Stylo"), Map.of("produit", "Cahier"))),
                DataSet.of("Limites", List.of(Map.of("produit", "", "quantite", 999)))));

        assertThat(test.getDataSets()).extracting(DataSet::name).containsExactly("Recette", "Limites");
        assertThat(test.getParameters()).extracting(TestParameter::name).containsExactly("produit", "quantite");
    }

    @Test
    @DisplayName("ADR-0013 jeux de données : nom obligatoire et unique, lignes non vides, valeurs scalaires")
    void dataSetRules() {
        TestCase test = manual();
        assertThatThrownBy(() -> test.setDataSets(List.of(DataSet.of(" ", List.of()))))
                .extracting("code").isEqualTo("TEST_DATASET_NAME_REQUIRED");
        assertThatThrownBy(() -> test.setDataSets(List.of(DataSet.of("A", List.of()), DataSet.of("a", List.of()))))
                .extracting("code").isEqualTo("TEST_DATASET_DUPLICATED");
        assertThatThrownBy(() -> test.setDataSets(List.of(DataSet.of("A", List.of(Map.of())))))
                .extracting("code").isEqualTo("TEST_DATASET_ROW_EMPTY");
        assertThatThrownBy(() -> test.setDataSets(List.of(DataSet.of("A", List.of(Map.of("a", List.of(1)))))))
                .extracting("code").isEqualTo("TEST_DATASET_VALUE_INVALID");
    }

    @Test
    @DisplayName("ADR-0013 supprimer un paramètre retire sa colonne des jeux de données")
    void removingParameterDropsColumn() {
        TestCase test = manual();
        test.setDataSets(List.of(DataSet.of("Recette", List.of(Map.of("a", "1", "b", "2")))));

        test.setParameters(List.of(new TestParameter("a", null, null)));

        assertThat(test.getDataSets().getFirst().rows()).containsExactly(Map.of("a", "1"));
    }

    @Test
    @DisplayName("F-AUT-10 paramètres et jeux de données sont des modifications significatives")
    void fingerprint() {
        TestCase test = manual();
        Object before = test.significantFingerprint();
        test.setDataSets(List.of(DataSet.of("Recette", List.of(Map.of("a", "1")))));
        assertThat(test.significantFingerprint()).isNotEqualTo(before);
    }
}
