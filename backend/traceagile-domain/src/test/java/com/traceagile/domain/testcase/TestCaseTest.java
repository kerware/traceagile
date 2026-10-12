package com.traceagile.domain.testcase;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.requirement.Priority;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.ValueSource;

/** §3.1 TestCase, ManualStep, ExploratoryCharter, AutomatedTestDefinition ; §6. */
class TestCaseTest {

    final Project shop = new Project("SHOP", "Boutique", null);

    TestCase manual() {
        return TestCase.manual(shop, "TC-1", "Ajouter au panier");
    }

    TestCase automated() {
        return TestCase.automated(shop, "TC-2", "Ajout API", TestTechnique.API, "REST Assured");
    }

    @Test
    @DisplayName("§3.1 un nouveau test est DRAFT, priorité SHOULD, version 1")
    void defaults() {
        TestCase test = manual();

        assertThat(test.getKind()).isEqualTo(TestKind.MANUAL);
        assertThat(test.getStatus()).isEqualTo(TestCaseStatus.DRAFT);
        assertThat(test.getPriority()).isEqualTo(Priority.SHOULD);
        assertThat(test.getCurrentVersion()).isEqualTo(1);
        assertThat(test.getKeyNumber()).isEqualTo(1);
    }

    @Test
    @DisplayName("§3.1 le sous-objet dépend de la nature du test")
    void subObjectByKind() {
        assertThat(manual().getCharter()).isNull();
        assertThat(manual().getAutomation()).isNull();
        assertThat(automated().getAutomation().getTechnique()).isEqualTo(TestTechnique.API);
        TestCase charter = TestCase.exploratory(shop, "TC-3", "Explorer le panier");
        assertThat(charter.getCharter().getTimeboxMin()).isEqualTo(90);
        assertThatThrownBy(() -> automated().addStep("Ouvrir", "Page affichée", null))
                .extracting("code").isEqualTo("TEST_STEPS_MANUAL_ONLY");
    }

    @Test
    @DisplayName("F-MAN-01 pas ordonnés : ajout, réordonnancement, duplication, suppression")
    void steps() {
        TestCase test = manual();
        ManualStep a = test.addStep("Ouvrir la fiche", "La fiche s'affiche", null);
        ManualStep b = test.addStep("Cliquer « Ajouter »", "Le panier contient ${quantite} article", "quantite=1");
        ManualStep c = test.addStep("Ouvrir le panier", "Le total est ${total}", null);

        test.reorderSteps(List.of(c, a, b));
        assertThat(test.getSteps()).containsExactly(c, a, b);

        ManualStep copy = test.duplicateStep(a);
        assertThat(test.getSteps()).containsExactly(c, a, copy, b);
        assertThat(copy.getAction()).isEqualTo("Ouvrir la fiche");
        assertThat(test.getSteps()).extracting(ManualStep::getPosition).containsExactly(1, 2, 3, 4);

        test.removeStep(c);
        assertThat(test.getSteps()).extracting(ManualStep::getPosition).containsExactly(1, 2, 3);
    }

    @Test
    @DisplayName("F-MAN-01 variables ${nom} des pas")
    void variables() {
        TestCase test = manual();
        test.addStep("Saisir ${produit}", "Le prix ${prix} s'affiche", "${produit}");

        assertThat(test.variables()).containsExactly("produit", "prix");
    }

    @Test
    @DisplayName("F-MAN-02 candidat à l'automatisation : justification obligatoire, tests manuels seulement")
    void automationCandidate() {
        TestCase test = manual();
        assertThatThrownBy(() -> test.markAutomationCandidate(true, " "))
                .extracting("code").isEqualTo("TEST_AUTOMATION_JUSTIFICATION_REQUIRED");
        test.markAutomationCandidate(true, "Régression à chaque sprint");
        assertThat(test.isAutomationCandidate()).isTrue();
        assertThatThrownBy(() -> automated().markAutomationCandidate(true, "x"))
                .extracting("code").isEqualTo("TEST_AUTOMATION_CANDIDATE_MANUAL_ONLY");
    }

    @ParameterizedTest
    @ValueSource(ints = {60, 90, 120})
    @DisplayName("F-EXP-02 durée cible de la charte : 60, 90 ou 120 minutes")
    void timebox(int minutes) {
        TestCase charter = TestCase.exploratory(shop, "TC-3", "Explorer");
        charter.getCharter().setTimeboxMin(minutes);
        assertThat(charter.getCharter().getTimeboxMin()).isEqualTo(minutes);
    }

    @Test
    @DisplayName("F-EXP-02 une autre durée est refusée")
    void invalidTimebox() {
        TestCase charter = TestCase.exploratory(shop, "TC-3", "Explorer");
        assertThatThrownBy(() -> charter.getCharter().setTimeboxMin(45))
                .extracting("code").isEqualTo("CHARTER_TIMEBOX_INVALID");
    }

    @Test
    @DisplayName("F-EXP-01 mission « Explorer… avec… pour découvrir… »")
    void mission() {
        TestCase charter = TestCase.exploratory(shop, "TC-3", "Explorer le panier");
        charter.getCharter().setMission("le panier", "des produits en rupture", "les incohérences de total");

        assertThat(charter.getCharter().missionSentence())
                .isEqualTo("Explorer le panier avec des produits en rupture pour découvrir les incohérences de total.");
    }

    @ParameterizedTest(name = "{0} → {1} : {2}")
    @CsvSource({
            "DRAFT,        READY,        true",
            "READY,        DRAFT,        true",
            "READY,        NEEDS_UPDATE, true",
            "NEEDS_UPDATE, READY,        true",
            "DRAFT,        OBSOLETE,     true",
            "OBSOLETE,     DRAFT,        false",
            "DRAFT,        NEEDS_UPDATE, false",
    })
    @DisplayName("§3.2 TestCaseStatus : transitions")
    void transitions(TestCaseStatus from, TestCaseStatus to, boolean allowed) {
        assertThat(from.canMoveTo(to)).isEqualTo(allowed);
    }

    @Test
    @DisplayName("ADR-0012 un test ne passe à READY que s'il est exécutable (pas, mission ou identifiant)")
    void readiness() {
        TestCase test = manual();
        assertThatThrownBy(() -> test.changeStatus(TestCaseStatus.READY))
                .extracting("code").isEqualTo("TEST_NOT_READY");
        test.addStep("Ouvrir", "OK", null);
        test.changeStatus(TestCaseStatus.READY);
        assertThat(test.getStatus()).isEqualTo(TestCaseStatus.READY);

        TestCase api = automated();
        assertThatThrownBy(() -> api.changeStatus(TestCaseStatus.READY)).extracting("code").isEqualTo("TEST_NOT_READY");
        api.getAutomation().setLocation("https://git.example.com/shop/tests.git", "main", "src/test/java/CartApiTest.java", "CartApiTest#addItem");
        api.changeStatus(TestCaseStatus.READY);

        TestCase charter = TestCase.exploratory(shop, "TC-3", "Explorer");
        assertThatThrownBy(() -> charter.changeStatus(TestCaseStatus.READY)).extracting("code").isEqualTo("TEST_NOT_READY");
        charter.getCharter().setMission("le panier", null, "les incohérences");
        charter.changeStatus(TestCaseStatus.READY);
    }

    @Test
    @DisplayName("ADR-0028 un test manuel à paramètres ne passe à READY qu'avec au moins un jeu de données non vide")
    void readinessRequiresDataSetForParameters() {
        TestCase test = manual();
        test.addStep("Se connecter avec ${login}", "Le catalogue s'affiche", null);
        assertThatThrownBy(() -> test.changeStatus(TestCaseStatus.READY))
                .extracting("code").isEqualTo("TEST_DATASET_REQUIRED");
        test.setDataSets(List.of(DataSet.of("Vide", List.of())));
        assertThatThrownBy(() -> test.changeStatus(TestCaseStatus.READY))
                .extracting("code").isEqualTo("TEST_DATASET_REQUIRED");
        test.setDataSets(List.of(DataSet.of("Comptes", List.of(Map.of("login", "alice")))));
        test.changeStatus(TestCaseStatus.READY);
        assertThat(test.getStatus()).isEqualTo(TestCaseStatus.READY);

        TestCase sansParametre = manual();
        sansParametre.addStep("Ouvrir", "OK", null);
        sansParametre.changeStatus(TestCaseStatus.READY);
        assertThat(sansParametre.getStatus()).isEqualTo(TestCaseStatus.READY);
    }

    @Test
    @DisplayName("§3.3-6 un test OBSOLETE ne se modifie plus")
    void obsolete() {
        TestCase test = manual();
        test.changeStatus(TestCaseStatus.OBSOLETE);
        assertThatThrownBy(() -> test.rename("Autre")).extracting("code").isEqualTo("TEST_OBSOLETE");
    }

    @Test
    @DisplayName("F-AUT-10 empreinte significative : pas, Gherkin, jeu de données, identifiant — pas le titre")
    void significantFingerprint() {
        TestCase test = manual();
        test.addStep("Ouvrir", "OK", null);
        Object before = test.significantFingerprint();

        test.rename("Nouveau titre");
        test.setTags(List.of("smoke"));
        assertThat(test.significantFingerprint()).isEqualTo(before);

        test.getSteps().getFirst().rewrite("Ouvrir la page", "OK", null);
        assertThat(test.significantFingerprint()).isNotEqualTo(before);

        TestCase api = automated();
        Object apiBefore = api.significantFingerprint();
        api.getAutomation().setLocation(null, null, "CartApiTest.java", "CartApiTest#add");
        assertThat(api.significantFingerprint()).isNotEqualTo(apiBefore);
    }

    @Test
    @DisplayName("F-AUT-10 nouvelle version : numéro incrémenté")
    void nextVersion() {
        TestCase test = manual();
        assertThat(test.nextVersion()).isEqualTo(2);
        assertThat(test.getCurrentVersion()).isEqualTo(2);
    }

    @Test
    @DisplayName("F-AUT-02 / F-AUT-03 tags d'exécution normalisés et prérequis d'environnement clé / valeur")
    void executionTagsAndEnvironment() {
        AutomatedTestDefinition definition = automated().getAutomation();
        definition.setExecutionTags(List.of(" Smoke", "regression", "smoke"));
        definition.setEnvironmentRequirements(Map.of("navigateur", "chromium", "base", "postgres"));

        assertThat(definition.getExecutionTags()).containsExactly("smoke", "regression");
        assertThat(definition.getEnvironmentRequirements()).containsEntry("navigateur", "chromium");
    }

    @Test
    @DisplayName("§6.1 DATA_DRIVEN : jeux de données portés par le test, valeurs typées")
    void dataDriven() {
        TestCase test = TestCase.automated(shop, "TC-4", "Frais de port", TestTechnique.DATA_DRIVEN, "JUnit 5");
        test.setDataSets(List.of(DataSet.of("Seuils", List.of(Map.of("montant", 49, "frais", 4.9), Map.of("montant", 50, "frais", 0)))));

        assertThat(test.getDataSets().getFirst().rows()).hasSize(2);
        assertThat(test.getParameters()).extracting(TestParameter::name).containsExactlyInAnyOrder("montant", "frais");
    }

    @Test
    @DisplayName("§6.1 BDD : la source Gherkin est réservée à la technique BDD")
    void gherkinOnlyForBdd() {
        assertThatThrownBy(() -> automated().getAutomation().setGherkinSource("Scénario: x"))
                .extracting("code").isEqualTo("TEST_GHERKIN_BDD_ONLY");
    }
}
