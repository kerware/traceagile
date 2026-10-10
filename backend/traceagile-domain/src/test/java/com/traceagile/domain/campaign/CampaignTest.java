package com.traceagile.domain.campaign;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.administration.User;
import com.traceagile.domain.planning.Sprint;
import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.requirement.RiskLevel;
import com.traceagile.domain.testcase.DataSet;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.testcase.TestTechnique;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/** §8.3 campagnes : périmètre, sélection, priorisation par le risque, affectation, cycle de vie. */
class CampaignTest {

    final Project shop = new Project("SHOP", "Boutique", null);
    final Sprint sprint = new Sprint(shop, "SPR-2", "Sprint 2", null, LocalDate.of(2026, 10, 12), LocalDate.of(2026, 10, 25), 20);

    Campaign campaign() {
        return new Campaign(shop, "CMP-1", "Recette SPR-2", CampaignScope.SPRINT, sprint, null, "recette", "2.0.0-rc1", null, null);
    }

    TestCase ready(String key, Priority priority) {
        TestCase test = TestCase.manual(shop, key, "Test " + key);
        test.addStep("Ouvrir", "OK", null);
        test.setPriority(priority);
        test.changeStatus(TestCaseStatus.READY);
        return test;
    }

    @Test
    @DisplayName("F-CMP-01 une campagne de sprint exige un sprint, de release une release ; une régression aucun")
    void scope() {
        assertThat(campaign().getStatus()).isEqualTo(CampaignStatus.PLANNED);
        assertThatThrownBy(() -> new Campaign(shop, "CMP-2", "X", CampaignScope.SPRINT, null, null, null, null, null, null))
                .extracting("code").isEqualTo("CAMPAIGN_SCOPE_INVALID");
        assertThatThrownBy(() -> new Campaign(shop, "CMP-2", " ", CampaignScope.REGRESSION, null, null, null, null, null, null))
                .extracting("code").isEqualTo("CAMPAIGN_NAME_REQUIRED");
        assertThatThrownBy(() -> new Campaign(shop, "CMP-2", "X", CampaignScope.REGRESSION, null, null, null, null,
                LocalDate.of(2026, 10, 20), LocalDate.of(2026, 10, 1))).extracting("code").isEqualTo("PLANNING_DATES_INVALID");
    }

    @ParameterizedTest(name = "risque {0} × priorité {1} = {2}")
    @CsvSource({"CRITICAL, MUST, 32", "HIGH, SHOULD, 12", "MEDIUM, COULD, 4", "LOW, WONT, 1", ", MUST, 4"})
    @DisplayName("F-CMP-03 score de priorisation = poids du risque de l'exigence × poids de la priorité du test")
    void riskScore(RiskLevel risk, Priority priority, int score) {
        assertThat(RiskPriority.score(risk, priority)).isEqualTo(score);
    }

    @Test
    @DisplayName("F-CMP-02 / F-CMP-03 ajout sans doublon, version du test figée ; tri par risque, puis ordre manuel")
    void selectionAndOrder() {
        Campaign campaign = campaign();
        TestCase a = ready("TC-1", Priority.COULD);
        TestCase b = ready("TC-2", Priority.MUST);
        assertThat(campaign.add(a, 2)).isNotNull();
        assertThat(campaign.add(b, 32)).isNotNull();
        assertThat(campaign.add(a, 2)).as("déjà présent").isNull();
        assertThat(campaign.getItems().getFirst().getTestCaseVersion()).isEqualTo(1);

        campaign.sortByRisk();
        assertThat(campaign.getItems()).extracting(i -> i.getTestCase().getKey()).containsExactly("TC-2", "TC-1");
        campaign.reorder(List.of(campaign.getItems().get(1), campaign.getItems().get(0)));
        assertThat(campaign.getItems()).extracting(i -> i.getTestCase().getKey()).containsExactly("TC-1", "TC-2");
        assertThat(campaign.getItems()).extracting(CampaignItem::getPosition).containsExactly(1, 2);
    }

    @Test
    @DisplayName("F-CMP-04 un test manuel est affecté à un testeur ; un test automatisé au serveur d'exécution")
    void assignment() {
        Campaign campaign = campaign();
        CampaignItem manual = campaign.add(ready("TC-1", Priority.MUST), 4);
        User qa = new User("qa1", "qa1@traceagile.demo", "QA", "h");
        manual.assign(qa);
        assertThat(manual.getAssignee()).isSameAs(qa);
        manual.assign(null);
        assertThat(manual.getAssignee()).isNull();

        TestCase api = TestCase.automated(shop, "TC-9", "API", TestTechnique.API, "REST Assured");
        CampaignItem automated = campaign.add(api, 1);
        assertThatThrownBy(() -> automated.assign(qa)).extracting("code").isEqualTo("CAMPAIGN_ITEM_AUTOMATED");
        assertThat(automated.isExecutedByServer()).isTrue();
    }

    @Test
    @DisplayName("§3.2 CampaignStatus : PLANNED → IN_PROGRESS → COMPLETED ; abandon ; une campagne terminée est en lecture seule")
    void lifecycle() {
        Campaign campaign = campaign();
        campaign.start();
        assertThat(campaign.getStatus()).isEqualTo(CampaignStatus.IN_PROGRESS);
        campaign.start();
        campaign.complete();
        assertThat(campaign.getStatus()).isEqualTo(CampaignStatus.COMPLETED);
        assertThatThrownBy(() -> campaign.add(ready("TC-1", Priority.MUST), 1)).extracting("code").isEqualTo("CAMPAIGN_CLOSED");
        assertThatThrownBy(campaign::abort).extracting("code").isEqualTo("CAMPAIGN_CLOSED");
    }

    @Test
    @DisplayName("ADR-0022 F-CMP-02 un test manuel à jeu de données est sélectionné une fois par ligne de son premier jeu ; sans jeu, une seule fois")
    void selectWithDataSet() {
        Campaign campaign = campaign();
        TestCase cart = ready("TC-7", Priority.MUST);
        cart.setDataSets(List.of(DataSet.of("Vide", List.of()),
                DataSet.of("Recette", List.of(Map.of("produit", "Stylo bleu"), Map.of("produit", "Cahier A4"))),
                DataSet.of("Limites", List.of(Map.of("produit", "")))));
        TestCase plain = ready("TC-8", Priority.MUST);

        List<CampaignItem> added = campaign.select(cart, 8);
        assertThat(added).extracting(CampaignItem::getDataSetName).containsExactly("Recette", "Recette");
        assertThat(added).extracting(CampaignItem::getDataSetRow).containsExactly(0, 1);
        assertThat(campaign.select(plain, 8)).singleElement().extracting(CampaignItem::getDataSetName).isNull();
        assertThat(campaign.select(cart, 8)).isEmpty();
        assertThat(campaign.getItems()).extracting(CampaignItem::getPosition).containsExactly(1, 2, 3);
    }
}
