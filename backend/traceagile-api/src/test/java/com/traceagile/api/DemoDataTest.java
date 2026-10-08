package com.traceagile.api;

import static org.assertj.core.api.Assertions.assertThat;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.api.demo.DemoDataLoader;
import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.administration.UserRepository;
import com.traceagile.application.requirement.RequirementRepository;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import java.util.List;
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

    DemoDataLoader loader() {
        return new DemoDataLoader(userService, projectService, users, projects, requirements, requirementRepository, objectMapper);
    }

    @Test
    @Transactional
    @DisplayName("§15.1 SHOP : 3 épics, 8 features, 25 stories, 4 règles métier, 4 ENF ; chargement idempotent")
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
        assertThat(stories.stream().filter(s -> s.getStatus() == RequirementStatus.READY)).hasSizeGreaterThanOrEqualTo(10);
        Map<String, Requirement> byTitle = backlog.stream().collect(Collectors.toMap(Requirement::getTitle, Function.identity()));
        assertThat(byTitle.get("Livraison gratuite dès 50 € d'achat").getType()).isEqualTo(RequirementType.BUSINESS_RULE);
        assertThat(byTitle.get("Temps de réponse des pages").isTransverse()).isTrue();
        assertThat(users.findByLogin("qa2")).isPresent();
    }
}
