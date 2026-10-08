package com.traceagile.api.demo;

import com.traceagile.application.administration.CreateProjectCommand;
import com.traceagile.application.administration.CreateUserCommand;
import com.traceagile.application.administration.MemberAssignment;
import com.traceagile.application.administration.ProjectService;
import com.traceagile.application.administration.UserAdministrationService;
import com.traceagile.application.administration.UserRepository;
import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.domain.administration.ProjectRole;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * §15.1 Jeu de démonstration, chargé avec le profil {@code demo} ; idempotent. Lot 0 : utilisateurs
 * (mot de passe {@code demo}) et projet {@code SHOP} avec ses membres. Complété à chaque lot.
 */
@Component
@Profile("demo")
public class DemoDataLoader implements ApplicationRunner {

    static final String PASSWORD = "demo";
    private static final Logger LOG = LoggerFactory.getLogger(DemoDataLoader.class);

    private record DemoUser(String login, String displayName, boolean systemAdmin, ProjectRole shopRole) {
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

    public DemoDataLoader(UserAdministrationService userService, ProjectService projectService,
                          UserRepository users, ProjectRepository projects) {
        this.userService = userService;
        this.projectService = projectService;
        this.users = users;
        this.projects = projects;
    }

    @Override
    public void run(ApplicationArguments args) {
        for (DemoUser user : USERS) {
            if (!users.existsByLogin(user.login())) {
                userService.create(new CreateUserCommand(user.login(), user.login() + "@traceagile.demo",
                        user.displayName(), PASSWORD, user.systemAdmin()));
            }
        }
        if (!projects.existsByKey("SHOP")) {
            projectService.create(new CreateProjectCommand("SHOP", "Boutique en ligne",
                    "Projet de démonstration : catalogue, panier et commande, compte client."));
            projectService.replaceMembers("SHOP", USERS.stream()
                    .map(u -> new MemberAssignment(u.login(), u.shopRole())).toList());
        }
        LOG.info("Jeu de démonstration prêt (utilisateurs {}, mot de passe « {} »)",
                USERS.stream().map(DemoUser::login).toList(), PASSWORD);
    }
}
