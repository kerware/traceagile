package com.traceagile.api.demo;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.application.administration.CreateProjectCommand;
import com.traceagile.application.administration.CreateUserCommand;
import com.traceagile.application.administration.MemberAssignment;
import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.administration.ProjectService;
import com.traceagile.application.administration.UserAdministrationService;
import com.traceagile.application.administration.UserRepository;
import com.traceagile.application.requirement.RequirementPatch;
import com.traceagile.application.requirement.RequirementRepository;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.application.requirement.RequirementService.CreateRequirementCommand;
import com.traceagile.application.requirement.RequirementService.CriterionDraft;
import com.traceagile.domain.administration.ProjectRole;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.requirement.NfrCategory;
import com.traceagile.domain.requirement.Planguage;
import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.domain.requirement.RiskLevel;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * §15.1 Jeu de démonstration, chargé avec le profil {@code demo} ; idempotent.
 * Lot 0 : utilisateurs (mot de passe {@code demo}) et projet {@code SHOP} avec ses membres.
 * Lot 1 : backlog de SHOP décrit dans {@code demo/shop-requirements.json}.
 * Lot 2 : référentiel de tests ({@link DemoTestsLoader}, {@code demo/shop-tests.json}).
 * Lot 4 : release et sprints ({@link DemoPlanningLoader}). Lot 5 : campagnes, exécutions, anomalies
 * ({@link DemoCampaignLoader}).
 */
@Component
@Profile("demo")
public class DemoDataLoader implements ApplicationRunner {

    static final String PASSWORD = "demo";
    static final String SHOP = "SHOP";
    private static final Logger LOG = LoggerFactory.getLogger(DemoDataLoader.class);

    private record DemoUser(String login, String displayName, boolean systemAdmin, ProjectRole shopRole) {
    }

    /** Une exigence du fichier JSON et ses enfants. */
    record DemoRequirement(RequirementType type, String title, String description, Priority priority, RiskLevel risk,
                           Integer points, Integer value, String asA, String iWant, String soThat, List<String> tags,
                           RequirementStatus status, NfrCategory category, Boolean transverse, String scale, String method,
                           String threshold, String target, String unit, List<DemoCriterion> criteria,
                           List<DemoRequirement> children) {
    }

    record DemoCriterion(String text, String gherkin) {
    }

    static final List<DemoUser> USERS = List.of(
            new DemoUser("admin", "Administrateur", true, ProjectRole.ADMINISTRATOR),
            new DemoUser("po", "Paula Owner", false, ProjectRole.PRODUCT_OWNER),
            new DemoUser("qa1", "Quentin Testeur", false, ProjectRole.TESTER),
            new DemoUser("qa2", "Quitterie Testeuse", false, ProjectRole.TESTER),
            new DemoUser("dev", "Dev Eloppeur", false, ProjectRole.DEVELOPER),
            new DemoUser("viewer", "Victor Lecteur", false, ProjectRole.VIEWER));

    private final UserAdministrationService userService;
    private final ProjectService projectService;
    private final UserRepository users;
    private final ProjectRepository projects;
    private final RequirementService requirements;
    private final RequirementRepository requirementRepository;
    private final ObjectMapper json;
    private final DemoTestsLoader testsLoader;
    private final DemoPlanningLoader planningLoader;
    private final DemoCampaignLoader campaignLoader;

    public DemoDataLoader(UserAdministrationService userService, ProjectService projectService, UserRepository users,
                          ProjectRepository projects, RequirementService requirements,
                          RequirementRepository requirementRepository, ObjectMapper json, DemoTestsLoader testsLoader,
                          DemoPlanningLoader planningLoader, DemoCampaignLoader campaignLoader) {
        this.planningLoader = planningLoader;
        this.campaignLoader = campaignLoader;
        this.testsLoader = testsLoader;
        this.userService = userService;
        this.projectService = projectService;
        this.users = users;
        this.projects = projects;
        this.requirements = requirements;
        this.requirementRepository = requirementRepository;
        this.json = json;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) throws IOException {
        for (DemoUser user : USERS) {
            if (!users.existsByLogin(user.login())) {
                userService.create(new CreateUserCommand(user.login(), user.login() + "@traceagile.demo",
                        user.displayName(), PASSWORD, user.systemAdmin()));
            }
        }
        if (!projects.existsByKey(SHOP)) {
            projectService.create(new CreateProjectCommand(SHOP, "Boutique en ligne",
                    "Projet de démonstration : catalogue, panier et commande, compte client."));
            projectService.replaceMembers(SHOP, USERS.stream()
                    .map(u -> new MemberAssignment(u.login(), u.shopRole())).toList());
        }
        if (!requirementRepository.existsByProject_Key(SHOP)) {
            try (InputStream in = getClass().getResourceAsStream("/demo/shop-requirements.json")) {
                DemoRequirement[] backlog = json.readValue(in, DemoRequirement[].class);
                for (DemoRequirement requirement : backlog) {
                    load(requirement, null);
                }
            }
        }
        testsLoader.load(SHOP);
        planningLoader.load(SHOP);
        campaignLoader.load(SHOP);
        LOG.info("Jeu de démonstration prêt (utilisateurs {}, mot de passe « {} »)",
                USERS.stream().map(DemoUser::login).toList(), PASSWORD);
    }

    private void load(DemoRequirement demo, String parentKey) {
        RequirementPatch.Builder details = RequirementPatch.builder()
                .description(demo.description())
                .userStory(demo.asA(), demo.iWant(), demo.soThat())
                .priority(demo.priority())
                .riskLevel(demo.risk())
                .storyPoints(demo.points())
                .businessValue(demo.value())
                .tags(demo.tags())
                .category(demo.category())
                .planguage(new Planguage(demo.scale(), demo.method(), demo.threshold(), demo.target(), demo.unit()));
        if (Boolean.TRUE.equals(demo.transverse())) {
            details.transverse(true);
        }
        List<CriterionDraft> criteria = demo.criteria() == null ? List.of() : demo.criteria().stream()
                .map(c -> c.gherkin() != null
                        ? new CriterionDraft(CriterionFormat.GHERKIN, c.gherkin())
                        : new CriterionDraft(CriterionFormat.TEXT, c.text()))
                .toList();
        Requirement requirement = requirements.create(SHOP,
                new CreateRequirementCommand(demo.type(), demo.title(), parentKey, details.build(), criteria));
        if (demo.status() == RequirementStatus.TO_REFINE || demo.status() == RequirementStatus.READY) {
            requirements.changeStatus(SHOP, requirement.getKey(), demo.status(), true);
        }
        if (demo.children() != null) {
            demo.children().forEach(child -> load(child, requirement.getKey()));
        }
    }
}
