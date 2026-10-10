package com.traceagile.api;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.api.demo.DemoDataLoader;
import com.traceagile.api.demo.DemoTestsLoader;
import com.traceagile.application.testcase.TestCaseService;
import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestTechnique;
import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.administration.UserRepository;
import com.traceagile.application.requirement.RequirementRepository;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.application.traceability.TraceabilityService;
import com.traceagile.application.traceability.TraceabilityService.Matrix;
import com.traceagile.domain.traceability.VerificationStatus;
import com.traceagile.application.planning.PlanningService;
import com.traceagile.domain.planning.PlanningStatus;
import com.traceagile.domain.planning.Release;
import com.traceagile.domain.planning.ScopeOutcome;
import com.traceagile.domain.planning.Sprint;
import com.traceagile.domain.planning.SprintScopeItem;
import com.traceagile.api.demo.DemoPlanningLoader;
import com.traceagile.application.campaign.CampaignService;
import com.traceagile.application.defect.DefectService;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignStatus;
import com.traceagile.domain.defect.Defect;
import com.traceagile.domain.defect.DefectSeverity;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.api.demo.DemoCampaignLoader;
import com.traceagile.application.exploratory.ExploratoryService;
import com.traceagile.domain.exploratory.ExploratoryMetrics;
import com.traceagile.domain.exploratory.SessionState;
import java.util.List;
import java.util.Set;
import java.util.Set;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

/** §15.1 Jeu de démonstration : contenu du lot 1 et idempotence. */
class DemoDataTest extends AbstractApiTest {

    @Autowired
    UserRepository users;
    @Autowired
    ProjectRepository projects;
    @Autowired
    RequirementRepository requirementRepository;
    @Autowired
    RequirementService requirements;
    @Autowired
    ObjectMapper objectMapper;
    @Autowired
    DemoTestsLoader testsLoader;
    @Autowired
    DemoPlanningLoader planningLoader;
    @Autowired
    PlanningService planning;
    @Autowired
    DemoCampaignLoader campaignLoader;
    @Autowired
    CampaignService campaigns;
    @Autowired
    DefectService defectService;
    @Autowired
    TestCaseService testCases;
    @Autowired
    TraceLinkService links;
    @Autowired
    TraceabilityService traceability;
    @Autowired
    ExploratoryService exploratory;

    DemoDataLoader loader() {
        return new DemoDataLoader(userService, projectService, users, projects, requirements, requirementRepository, objectMapper,
                testsLoader, planningLoader, campaignLoader);
    }

    @Test
    @Transactional
    @DisplayName("§15.1 SHOP : backlog (3 épics, 8 features, 25 stories, 4 règles, 4 ENF) et tests (20 manuels, 8 chartes, 30 automatisés) ; idempotent")
    void shopRequirements() throws Exception {
        loader().run(null);
        loader().run(null);

        List<Requirement> backlog = requirements.backlog("SHOP");
        Map<RequirementType, Long> byType = backlog.stream().collect(Collectors.groupingBy(Requirement::getType, Collectors.counting()));
        assertThat(byType).containsExactlyInAnyOrderEntriesOf(Map.of(
                RequirementType.EPIC, 3L, RequirementType.FEATURE, 8L, RequirementType.USER_STORY, 25L,
                RequirementType.BUSINESS_RULE, 4L, RequirementType.NON_FUNCTIONAL, 4L));
        List<Requirement> stories = backlog.stream().filter(r -> r.getType() == RequirementType.USER_STORY).toList();
        assertThat(stories).allSatisfy(story -> assertThat(story.getCriteria()).isNotEmpty());
        long gherkinCriteria = backlog.stream().flatMap(r -> r.getCriteria().stream())
                .filter(c -> c.getFormat().name().equals("GHERKIN")).count();
        assertThat(gherkinCriteria).isGreaterThanOrEqualTo(15);
        // 12 stories prêtes au lot 1, dont une partie planifiée au lot 4 (IN_SPRINT, DONE).
        assertThat(stories.stream().filter(s -> Set.of(RequirementStatus.READY, RequirementStatus.IN_SPRINT, RequirementStatus.DONE)
                .contains(s.getStatus()))).hasSizeGreaterThanOrEqualTo(12);
        Map<String, Requirement> byTitle = backlog.stream().collect(Collectors.toMap(Requirement::getTitle, Function.identity()));
        assertThat(byTitle.get("Livraison gratuite dès 50 € d'achat").getType()).isEqualTo(RequirementType.BUSINESS_RULE);
        assertThat(byTitle.get("Temps de réponse des pages").isTransverse()).isTrue();
        assertThat(users.findByLogin("qa2")).isPresent();

        // Lot 2 : 20 manuels, 8 chartes, 30 automatisés (16 BDD), 2 orphelins, au moins 3 stories non couvertes.
        List<TestCase> all = testCases.all("SHOP");
        Map<TestKind, Long> byKind = all.stream().collect(Collectors.groupingBy(TestCase::getKind, Collectors.counting()));
        assertThat(byKind).containsExactlyInAnyOrderEntriesOf(Map.of(TestKind.MANUAL, 20L, TestKind.EXPLORATORY, 8L, TestKind.AUTOMATED, 30L));
        Map<TestTechnique, Long> byTechnique = all.stream().filter(t -> t.getAutomation() != null)
                .collect(Collectors.groupingBy(t -> t.getAutomation().getTechnique(), Collectors.counting()));
        assertThat(byTechnique).containsKeys(TestTechnique.BDD, TestTechnique.UI, TestTechnique.API, TestTechnique.UNIT,
                TestTechnique.DATA_DRIVEN, TestTechnique.PERFORMANCE);
        assertThat(byTechnique.get(TestTechnique.BDD)).isEqualTo(16L);
        // Lot 3 (§3.3-7) : les tests de la story modifiée après coup sont à revoir, tous les autres READY.
        Requirement promo = byTitle.get("Appliquer un code promo");
        List<TestCase> promoTests = links.testsOf(promo).stream().map(l -> l.testCase()).toList();
        assertThat(promoTests).isNotEmpty().allSatisfy(t -> assertThat(t.getStatus()).isEqualTo(TestCaseStatus.NEEDS_UPDATE));
        assertThat(all.stream().filter(t -> !promoTests.contains(t)))
                .allSatisfy(t -> assertThat(t.getStatus()).isEqualTo(TestCaseStatus.READY));
        assertThat(links.testsOf(promo)).allSatisfy(l -> assertThat(l.suspect()).isTrue());
        assertThat(all.stream().filter(t -> links.requirementsOf(t).isEmpty())).hasSize(2);
        assertThat(stories.stream().filter(s -> links.testsOf(s).isEmpty())).hasSizeGreaterThanOrEqualTo(3);

        // Lot 3 — critère de fin : matrice correcte sur le jeu de démonstration.
        Matrix matrix = traceability.matrix("SHOP", null, false, null);
        assertThat(matrix.rows()).hasSize(backlog.size());
        long requirementLinks = backlog.stream().mapToLong(r -> links.testsOf(r).size()).sum();
        assertThat(matrix.cells()).hasSize((int) requirementLinks);
        assertThat(matrix.columns()).hasSize((int) all.stream().filter(t -> !links.requirementsOf(t).isEmpty()).count());
        assertThat(matrix.cells().stream().filter(c -> c.link().isSuspect()).map(c -> c.requirement().getTitle()))
                .isNotEmpty().allMatch("Appliquer un code promo"::equals);
        assertThat(matrix.rows().stream().filter(r -> r.requirement().equals(promo)).findFirst().orElseThrow().status())
                .isEqualTo(VerificationStatus.SUSPECT);
        assertThat(traceability.orphans("SHOP").testsWithoutRequirement()).hasSize(2);

        // Lot 4 : REL-1 « Version 2.0 », 3 sprints de 2 semaines — SPR-1 clos, SPR-2 actif, SPR-3 planifié.
        Release release = planning.release("SHOP", "REL-1");
        assertThat(release.getName()).isEqualTo("Version 2.0");
        assertThat(release.getSprints()).extracting(Sprint::getKey, Sprint::getStatus).containsExactly(
                tuple("SPR-1", PlanningStatus.CLOSED), tuple("SPR-2", PlanningStatus.ACTIVE), tuple("SPR-3", PlanningStatus.PLANNED));
        assertThat(release.getSprints()).allSatisfy(s ->
                assertThat(s.getEndDate()).isEqualTo(s.getStartDate().plusWeeks(2).minusDays(1)));
        Sprint spr2 = planning.sprint("SHOP", "SPR-2");
        assertThat(spr2.getStartDate()).isBeforeOrEqualTo(java.time.LocalDate.now()).isAfter(java.time.LocalDate.now().minusWeeks(2));
        assertThat(spr2.requirements()).isNotEmpty().allSatisfy(r -> assertThat(r.getStatus()).isEqualTo(RequirementStatus.IN_SPRINT));
        Sprint spr1 = planning.sprint("SHOP", "SPR-1");
        assertThat(spr1.getScope()).extracting(SprintScopeItem::getOutcome).contains(ScopeOutcome.DONE, ScopeOutcome.CARRIED_OVER);
        assertThat(spr2.requirements().getFirst().getKey())
                .isEqualTo(spr1.getScope().stream().filter(i -> i.getOutcome() == ScopeOutcome.CARRIED_OVER).findFirst().orElseThrow()
                        .getRequirement().getKey());
        assertThat(planning.sprint("SHOP", "SPR-3").requirements()).isNotEmpty()
                .allSatisfy(r -> assertThat(r.getStatus()).isEqualTo(RequirementStatus.READY));

        // Lot 5 : CMP-1 terminée (tout exécuté, une 2ᵉ tentative), CMP-2 en cours, CMP-3 planifiée ; 6 anomalies.
        Campaign cmp1 = campaigns.get("SHOP", "CMP-1");
        assertThat(cmp1.getStatus()).isEqualTo(CampaignStatus.COMPLETED);
        // ADR-0018 campagnes rangées
        assertThat(cmp1.getFolder()).isEqualTo("Version 2.0/Recettes de sprint");
        assertThat(campaigns.get("SHOP", "CMP-3").getFolder()).isEqualTo("Version 2.0/Régression");
        assertThat(cmp1.getItems()).isNotEmpty().allSatisfy(i -> assertThat(i.lastStatus()).isIn(ExecutionStatus.PASSED, ExecutionStatus.FAILED));
        assertThat(cmp1.getItems()).anySatisfy(i -> assertThat(i.getExecutions()).hasSize(2));
        assertThat(campaigns.get("SHOP", "CMP-2").getStatus()).isEqualTo(CampaignStatus.IN_PROGRESS);
        assertThat(campaigns.get("SHOP", "CMP-2").getItems()).anySatisfy(i -> assertThat(i.lastStatus()).isEqualTo(ExecutionStatus.NOT_RUN));
        // « Mes exécutions » : qa1 et qa2 ont chacun au moins un test manuel à jouer dans CMP-2
        for (String tester : List.of("qa1", "qa2")) {
            assertThat(campaigns.get("SHOP", "CMP-2").getItems()).as(tester).anySatisfy(i -> {
                assertThat(i.getAssignee()).isNotNull();
                assertThat(i.getAssignee().getLogin()).isEqualTo(tester);
                assertThat(i.getTestCase().getKind()).isEqualTo(com.traceagile.domain.testcase.TestKind.MANUAL);
                assertThat(i.lastStatus()).isEqualTo(ExecutionStatus.NOT_RUN);
            });
        }
        assertThat(campaigns.get("SHOP", "CMP-3").getStatus()).isEqualTo(CampaignStatus.PLANNED);
        List<Defect> allDefects = defectService.list("SHOP", new DefectService.DefectFilter(null, null, null, null));
        assertThat(allDefects).hasSize(6);
        assertThat(allDefects).extracting(Defect::getSeverity).contains(DefectSeverity.BLOCKER, DefectSeverity.CRITICAL,
                DefectSeverity.MAJOR, DefectSeverity.MINOR, DefectSeverity.TRIVIAL);
        assertThat(traceability.orphans("SHOP").defectsWithoutRequirement()).hasSize(1);
        Double validation = traceability.coverage("SHOP", "sprint:SPR-1").coverage().validation().percent();
        assertThat(validation).as("SPR-1 : une story en échec sur quatre").isEqualTo(75.0);

        // Lot 6 (§15.1) : 5 sessions exploratoires débriefées, une autre en attente d'approbation ; métriques de SPR-1
        assertThat(exploratory.list("SHOP", Set.of(SessionState.DEBRIEFED))).hasSize(5)
                .allSatisfy(session -> assertThat(session.getApprovedBy()).isEqualTo("po"));
        assertThat(exploratory.list("SHOP", Set.of(SessionState.FINISHED))).singleElement()
                .satisfies(session -> assertThat(session.getTester()).isEqualTo("qa2"));
        ExploratoryMetrics sprint1 = exploratory.metrics("SHOP", "sprint:SPR-1");
        assertThat(sprint1.sessions()).isEqualTo(4);
        assertThat(sprint1.chartersExecuted()).isEqualTo(sprint1.chartersPlanned());
        assertThat(sprint1.averageConfidence()).isNotNull();
    }
}
