package com.traceagile.domain.administration;

import static com.traceagile.domain.administration.Permission.*;
import static org.assertj.core.api.Assertions.assertThat;

import java.util.EnumSet;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** §2.2 Rôles : matrice des droits par rôle de projet. */
class ProjectRolePermissionsTest {

    @Test
    @DisplayName("§2.2 Administrateur : tout")
    void administratorHasEveryPermission() {
        assertThat(ProjectRole.ADMINISTRATOR.permissions()).containsExactlyInAnyOrder(Permission.values());
    }

    @Test
    @DisplayName("§2.2 Product Owner : exigences en écriture, tests en lecture, planification en écriture ; ADR-0023 rapports")
    void productOwner() {
        assertThat(ProjectRole.PRODUCT_OWNER.permissions()).containsExactlyInAnyOrderElementsOf(EnumSet.of(
                PROJECT_READ,
                REQUIREMENT_READ, REQUIREMENT_WRITE, REQUIREMENT_COMMENT,
                TEST_READ,
                PLANNING_READ, PLANNING_WRITE, CAMPAIGN_READ,
                EXECUTION_READ, REPORT_WRITE));
    }

    @Test
    @DisplayName("§2.2 Testeur : propose des critères, gère tests et campagnes, exécute ; ADR-0023 rapports")
    void tester() {
        assertThat(ProjectRole.TESTER.permissions()).containsExactlyInAnyOrderElementsOf(EnumSet.of(
                PROJECT_READ,
                REQUIREMENT_READ, REQUIREMENT_COMMENT, ACCEPTANCE_CRITERION_PROPOSE,
                TEST_READ, TEST_WRITE, AUTOMATED_TEST_WRITE,
                PLANNING_READ, CAMPAIGN_READ, CAMPAIGN_WRITE,
                EXECUTION_READ, EXECUTION_WRITE, REPORT_WRITE));
    }

    @Test
    @DisplayName("§2.2 Développeur : tests automatisés et lancement de runs")
    void developer() {
        assertThat(ProjectRole.DEVELOPER.permissions()).containsExactlyInAnyOrderElementsOf(EnumSet.of(
                PROJECT_READ,
                REQUIREMENT_READ, REQUIREMENT_COMMENT,
                TEST_READ, AUTOMATED_TEST_WRITE,
                PLANNING_READ, CAMPAIGN_READ,
                EXECUTION_READ, AUTOMATED_RUN_LAUNCH));
    }

    @Test
    @DisplayName("§2.2 Lecteur : lecture seule")
    void viewer() {
        assertThat(ProjectRole.VIEWER.permissions()).containsExactlyInAnyOrderElementsOf(EnumSet.of(
                PROJECT_READ, REQUIREMENT_READ, TEST_READ, PLANNING_READ, CAMPAIGN_READ, EXECUTION_READ));
    }

    @Test
    @DisplayName("§2.2 Seul l'administrateur du projet gère ses membres")
    void onlyAdministratorManagesMembers() {
        for (ProjectRole role : ProjectRole.values()) {
            assertThat(role.allows(PROJECT_ADMIN)).isEqualTo(role == ProjectRole.ADMINISTRATOR);
        }
    }
}
