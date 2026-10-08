package com.traceagile.domain.requirement;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.BusinessRuleException;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

/** §3.1 Requirement ; F-REQ-05 à F-REQ-09, F-REQ-16, F-REQ-17, F-REQ-21. */
class RequirementTest {

    final Project shop = new Project("SHOP", "Boutique", null);

    Requirement story() {
        Requirement feature = new Requirement(shop, "REQ-1", RequirementType.FEATURE, "Panier", "a");
        Requirement story = new Requirement(shop, "REQ-2", RequirementType.USER_STORY, "Livraison gratuite", "b");
        story.moveUnder(feature);
        return story;
    }

    @Test
    @DisplayName("§3.1 une nouvelle exigence est DRAFT, priorité SHOULD, risque MEDIUM, version 0")
    void defaults() {
        Requirement story = story();

        assertThat(story.getStatus()).isEqualTo(RequirementStatus.DRAFT);
        assertThat(story.getPriority()).isEqualTo(Priority.SHOULD);
        assertThat(story.getRiskLevel()).isEqualTo(RiskLevel.MEDIUM);
        assertThat(story.getCurrentVersion()).isZero();
    }

    @Test
    @DisplayName("§3.1 le titre est obligatoire (200 caractères au plus)")
    void titleRequired() {
        assertThatThrownBy(() -> new Requirement(shop, "REQ-1", RequirementType.EPIC, " ", "i"))
                .extracting("code").isEqualTo("REQ_TITLE_REQUIRED");
        assertThatThrownBy(() -> story().rename("x".repeat(201)))
                .extracting("code").isEqualTo("REQ_TITLE_TOO_LONG");
    }

    @Test
    @DisplayName("F-REQ-05 phrase « En tant que… je veux… afin de… »")
    void userStorySentence() {
        UserStory userStory = new UserStory("client", "la livraison gratuite dès 50 €", "commander plus");

        assertThat(userStory.sentence())
                .isEqualTo("En tant que client, je veux la livraison gratuite dès 50 € afin de commander plus.");
        assertThat(new UserStory("client", "payer", null).sentence()).isEqualTo("En tant que client, je veux payer.");
        assertThat(new UserStory(null, null, null).isEmpty()).isTrue();
    }

    @ParameterizedTest
    @ValueSource(ints = {1, 2, 3, 5, 8, 13, 21})
    @DisplayName("F-REQ-06 points d'estimation : suite de Fibonacci")
    void fibonacciPoints(int points) {
        Requirement story = story();
        story.estimate(points);
        assertThat(story.getStoryPoints()).isEqualTo(points);
    }

    @ParameterizedTest
    @ValueSource(ints = {0, 4, 6, 20, 34, -1})
    @DisplayName("F-REQ-06 points hors suite → REQ_POINTS_INVALID")
    void invalidPoints(int points) {
        assertThatThrownBy(() -> story().estimate(points))
                .isInstanceOf(BusinessRuleException.class)
                .extracting("code").isEqualTo("REQ_POINTS_INVALID");
    }

    @Test
    @DisplayName("F-REQ-06 estimation effaçable")
    void clearEstimate() {
        Requirement story = story();
        story.estimate(5);
        story.estimate(null);
        assertThat(story.getStoryPoints()).isNull();
    }

    @Test
    @DisplayName("F-REQ-06 valeur métier entre 1 et 100")
    void businessValue() {
        Requirement story = story();
        story.setBusinessValue(100);
        assertThat(story.getBusinessValue()).isEqualTo(100);
        assertThatThrownBy(() -> story.setBusinessValue(0)).extracting("code").isEqualTo("REQ_BUSINESS_VALUE_INVALID");
        assertThatThrownBy(() -> story.setBusinessValue(101)).extracting("code").isEqualTo("REQ_BUSINESS_VALUE_INVALID");
    }

    @Test
    @DisplayName("F-REQ-07 une story de 13 points ou plus est à découper")
    void splitAlert() {
        Requirement story = story();
        story.estimate(8);
        assertThat(story.needsSplitting()).isFalse();
        story.estimate(13);
        assertThat(story.needsSplitting()).isTrue();
    }

    @Test
    @DisplayName("F-REQ-07 indicateur INVEST : six cases")
    void invest() {
        Requirement story = story();
        story.setInvest(new Invest(true, true, true, false, true, true));

        assertThat(story.getInvest().checkedCount()).isEqualTo(5);
        assertThat(story.getInvest().isComplete()).isFalse();
    }

    @Test
    @DisplayName("§3.1 tags normalisés : minuscules, sans doublon ni blanc")
    void tags() {
        Requirement story = story();
        story.setTags(List.of(" Panier ", "panier", "", "Promo"));
        assertThat(story.getTags()).containsExactly("panier", "promo");
    }

    @Test
    @DisplayName("F-REQ-16 une ENF porte une catégorie ISO 25010 et des champs Planguage")
    void nonFunctional() {
        Requirement nfr = new Requirement(shop, "REQ-9", RequirementType.NON_FUNCTIONAL, "Temps de réponse", "z");
        nfr.setCategory(NfrCategory.PERFORMANCE);
        nfr.setPlanguage(new Planguage("Temps de réponse p95 de la recherche", "Gatling, 100 utilisateurs", "800", "300", "ms"));

        assertThat(nfr.getCategory()).isEqualTo(NfrCategory.PERFORMANCE);
        assertThat(nfr.getPlanguage().target()).isEqualTo("300");
    }

    @Test
    @DisplayName("F-REQ-16 catégorie et transversalité réservées aux ENF")
    void categoryOnlyForNfr() {
        assertThatThrownBy(() -> story().setCategory(NfrCategory.SECURITY))
                .extracting("code").isEqualTo("REQ_CATEGORY_NFR_ONLY");
        assertThatThrownBy(() -> story().setTransverse(true))
                .extracting("code").isEqualTo("REQ_TRANSVERSE_NFR_ONLY");
    }

    @Test
    @DisplayName("F-REQ-17 une ENF transverse s'applique aux stories de son parent (ou de tout le projet sans parent)")
    void transverseScope() {
        Requirement epic = new Requirement(shop, "REQ-1", RequirementType.EPIC, "Catalogue", "a");
        Requirement feature = new Requirement(shop, "REQ-2", RequirementType.FEATURE, "Recherche", "b");
        Requirement story = new Requirement(shop, "REQ-3", RequirementType.USER_STORY, "Chercher", "c");
        Requirement otherFeature = new Requirement(shop, "REQ-4", RequirementType.FEATURE, "Fiche", "d");
        feature.moveUnder(epic);
        story.moveUnder(feature);
        Requirement featureNfr = nfr("REQ-5", feature);
        Requirement otherNfr = nfr("REQ-6", otherFeature);
        Requirement projectNfr = nfr("REQ-7", null);
        Requirement notTransverse = new Requirement(shop, "REQ-8", RequirementType.NON_FUNCTIONAL, "Local", "h");
        notTransverse.moveUnder(feature);

        assertThat(featureNfr.appliesTransverselyTo(story)).isTrue();
        assertThat(projectNfr.appliesTransverselyTo(story)).isTrue();
        assertThat(otherNfr.appliesTransverselyTo(story)).isFalse();
        assertThat(notTransverse.appliesTransverselyTo(story)).isFalse();
        assertThat(featureNfr.appliesTransverselyTo(epic)).as("seulement les stories").isFalse();
    }

    private Requirement nfr(String key, Requirement parent) {
        Requirement nfr = new Requirement(shop, key, RequirementType.NON_FUNCTIONAL, "ENF " + key, "z");
        if (parent != null) {
            nfr.moveUnder(parent);
        }
        nfr.setTransverse(true);
        return nfr;
    }

    @Test
    @DisplayName("F-REQ-09 critères ordonnés ; ajout, retrait, réordonnancement")
    void criteria() {
        Requirement story = story();
        AcceptanceCriterion a = story.addCriterion(CriterionFormat.TEXT, "Le total est affiché");
        AcceptanceCriterion b = story.addCriterion(CriterionFormat.GHERKIN, "Scénario: x");
        AcceptanceCriterion c = story.addCriterion(CriterionFormat.TEXT, "Le seuil est paramétrable");

        story.reorderCriteria(List.of(c, a, b));
        assertThat(story.getCriteria()).containsExactly(c, a, b);
        assertThat(story.getCriteria()).extracting(AcceptanceCriterion::getPosition).containsExactly(1, 2, 3);

        story.removeCriterion(a);
        assertThat(story.getCriteria()).containsExactly(c, b);
        assertThat(story.getCriteria()).extracting(AcceptanceCriterion::getPosition).containsExactly(1, 2);
        assertThat(b.getStatus()).isEqualTo(CriterionStatus.TO_VERIFY);
    }

    @Test
    @DisplayName("F-REQ-09 le réordonnancement doit contenir exactement les critères existants")
    void reorderMustBeComplete() {
        Requirement story = story();
        AcceptanceCriterion a = story.addCriterion(CriterionFormat.TEXT, "A");
        story.addCriterion(CriterionFormat.TEXT, "B");

        assertThatThrownBy(() -> story.reorderCriteria(List.of(a)))
                .extracting("code").isEqualTo("CRITERIA_ORDER_INVALID");
    }

    @Test
    @DisplayName("F-REQ-09 un critère vide est refusé")
    void emptyCriterion() {
        assertThatThrownBy(() -> story().addCriterion(CriterionFormat.TEXT, "  "))
                .extracting("code").isEqualTo("CRITERION_CONTENT_REQUIRED");
    }

    @Test
    @DisplayName("F-REQ-21 instantané : champs métier et critères, sans champs techniques")
    void snapshot() {
        Requirement story = story();
        story.setUserStory(new UserStory("client", "payer", "recevoir"));
        story.estimate(5);
        story.setTags(List.of("panier"));
        story.addCriterion(CriterionFormat.TEXT, "Le total est affiché");

        Map<String, Object> snapshot = story.snapshot();

        assertThat(snapshot).containsEntry("key", "REQ-2")
                .containsEntry("title", "Livraison gratuite")
                .containsEntry("parentKey", "REQ-1")
                .containsEntry("storyPoints", 5)
                .containsEntry("userStory.asA", "client")
                .containsEntry("tags", "panier")
                .containsEntry("criteria", List.of("[TEXT] Le total est affiché"))
                .doesNotContainKeys("id", "version", "rank");
        assertThat(snapshot.keySet()).containsExactlyElementsOf(Requirement.SNAPSHOT_FIELDS);
    }

    @Test
    @DisplayName("F-REQ-21 jsonb ne garde pas l'ordre des clés : un instantané relu est remis dans l'ordre canonique")
    void snapshotOrder() {
        Map<String, Object> shuffled = new java.util.HashMap<>(story().snapshot());

        assertThat(Requirement.inSnapshotOrder(shuffled).keySet()).containsExactlyElementsOf(Requirement.SNAPSHOT_FIELDS);
    }

    @Test
    @DisplayName("F-REQ-02 dupliquer : nouvelle clé, DRAFT, critères copiés, même parent, sans enfants")
    void duplicate() {
        Requirement story = story();
        story.estimate(3);
        story.setTags(List.of("panier"));
        story.addCriterion(CriterionFormat.GHERKIN, "Scénario: x");

        Requirement copy = story.duplicate("REQ-10", "c");

        assertThat(copy.getKey()).isEqualTo("REQ-10");
        assertThat(copy.getTitle()).isEqualTo("Copie de Livraison gratuite");
        assertThat(copy.getStatus()).isEqualTo(RequirementStatus.DRAFT);
        assertThat(copy.getParent()).isSameAs(story.getParent());
        assertThat(copy.getStoryPoints()).isEqualTo(3);
        assertThat(copy.getTags()).isEqualTo(Set.of("panier"));
        assertThat(copy.getCriteria()).singleElement().satisfies(c -> {
            assertThat(c.getContent()).isEqualTo("Scénario: x");
            assertThat(c).isNotSameAs(story.getCriteria().getFirst());
        });
    }
}
