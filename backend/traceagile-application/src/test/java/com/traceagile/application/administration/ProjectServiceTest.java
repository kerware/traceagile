package com.traceagile.application.administration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.traceagile.application.common.ConflictException;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.domain.administration.Permission;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.administration.ProjectRole;
import com.traceagile.domain.administration.User;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;

/** Lot 0 — projets et membres (§2.2, §3.1, §12 Administration). */
@ExtendWith(MockitoExtension.class)
class ProjectServiceTest {

    @Mock
    ProjectRepository projects;
    @Mock
    UserRepository users;
    @Mock
    ApplicationEventPublisher events;

    ProjectService service;

    User admin = systemAdmin();
    User po = new User("po", "po@example.com", "PO", "h");

    @BeforeEach
    void setUp() {
        service = new ProjectService(projects, users, events);
    }

    @Test
    @DisplayName("§12 POST /projects : création d'un projet, qui reçoit sa DoR / DoD par défaut (F-REQ-19)")
    void create() {
        when(projects.existsByKey("SHOP")).thenReturn(false);
        when(projects.save(any())).thenAnswer(inv -> inv.getArgument(0));

        Project project = service.create(new CreateProjectCommand("SHOP", "Boutique", "Démo"));

        assertThat(project.getKey()).isEqualTo("SHOP");
        assertThat(project.isArchived()).isFalse();
        verify(events).publishEvent(new ProjectCreated("SHOP"));
    }

    @Test
    @DisplayName("§3.1 la clé projet est unique → PROJECT_KEY_TAKEN")
    void createRejectsDuplicateKey() {
        when(projects.existsByKey("SHOP")).thenReturn(true);

        assertThatThrownBy(() -> service.create(new CreateProjectCommand("SHOP", "Boutique", null)))
                .isInstanceOf(ConflictException.class)
                .extracting("code").isEqualTo("PROJECT_KEY_TAKEN");
        verify(projects, never()).save(any());
    }

    @Test
    @DisplayName("§2.2 l'administrateur système voit tous les projets")
    void adminSeesAllProjects() {
        Pageable page = Pageable.ofSize(50);
        when(projects.findAll(page)).thenReturn(new PageImpl<>(List.of(new Project("SHOP", "Boutique", null))));

        assertThat(service.listVisible(admin, page).getContent()).hasSize(1);
    }

    @Test
    @DisplayName("§2.2 un utilisateur ne voit que les projets où il a un rôle")
    void memberSeesOnlyHisProjects() {
        Pageable page = Pageable.ofSize(50);
        when(projects.findDistinctByMembers_User_Login("po", page)).thenReturn(new PageImpl<>(List.of()));

        assertThat(service.listVisible(po, page).getContent()).isEmpty();
        verify(projects, never()).findAll(page);
    }

    @Test
    @DisplayName("§12 GET /me : projets dont l'utilisateur est membre, même pour l'administrateur système")
    void memberships() {
        Project shop = new Project("SHOP", "Boutique", null);
        when(projects.findDistinctByMembers_User_Login("admin", Pageable.unpaged()))
                .thenReturn(new PageImpl<>(List.of(shop)));

        assertThat(service.memberships(admin)).containsExactly(shop);
    }

    @Test
    @DisplayName("§12 PUT /projects/{key}/members : remplace la liste des membres")
    void replaceMembers() {
        Project shop = new Project("SHOP", "Boutique", null);
        User viewer = new User("viewer", "viewer@example.com", null, "h");
        shop.setMember(viewer, ProjectRole.VIEWER);
        when(projects.findByKey("SHOP")).thenReturn(Optional.of(shop));
        when(users.findByLogin("po")).thenReturn(Optional.of(po));

        service.replaceMembers("SHOP", List.of(new MemberAssignment("po", ProjectRole.PRODUCT_OWNER)));

        assertThat(shop.getMembers()).hasSize(1);
        assertThat(shop.roleOf(po)).contains(ProjectRole.PRODUCT_OWNER);
        assertThat(shop.roleOf(viewer)).isEmpty();
    }

    @Test
    @DisplayName("§12 PUT /projects/{key}/members : utilisateur inconnu → USER_NOT_FOUND")
    void replaceMembersWithUnknownUser() {
        when(projects.findByKey("SHOP")).thenReturn(Optional.of(new Project("SHOP", "Boutique", null)));
        when(users.findByLogin("ghost")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.replaceMembers("SHOP", List.of(new MemberAssignment("ghost", ProjectRole.VIEWER))))
                .isInstanceOf(NotFoundException.class)
                .extracting("code").isEqualTo("USER_NOT_FOUND");
    }

    @Test
    @DisplayName("§12 PUT /projects/{key}/members : un login en double → MEMBER_DUPLICATED")
    void replaceMembersRejectsDuplicates() {
        when(projects.findByKey("SHOP")).thenReturn(Optional.of(new Project("SHOP", "Boutique", null)));

        assertThatThrownBy(() -> service.replaceMembers("SHOP", List.of(
                new MemberAssignment("po", ProjectRole.VIEWER),
                new MemberAssignment("po", ProjectRole.TESTER))))
                .isInstanceOf(com.traceagile.domain.common.BusinessRuleException.class)
                .extracting("code").isEqualTo("MEMBER_DUPLICATED");
    }

    @Test
    @DisplayName("projet inconnu → PROJECT_NOT_FOUND")
    void unknownProject() {
        when(projects.findByKey("NOPE")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.get("NOPE"))
                .isInstanceOf(NotFoundException.class)
                .extracting("code").isEqualTo("PROJECT_NOT_FOUND");
    }

    @Test
    @DisplayName("§2.2 contrôle d'accès : droit accordé selon le rôle du projet")
    void isAllowed() {
        Project shop = new Project("SHOP", "Boutique", null);
        shop.setMember(po, ProjectRole.PRODUCT_OWNER);
        when(projects.findByKey("SHOP")).thenReturn(Optional.of(shop));
        when(users.findByLogin("po")).thenReturn(Optional.of(po));

        assertThat(service.isAllowed("po", "SHOP", Permission.REQUIREMENT_WRITE)).isTrue();
        assertThat(service.isAllowed("po", "SHOP", Permission.PROJECT_ADMIN)).isFalse();
    }

    @Test
    @DisplayName("§2.2 contrôle d'accès : projet inconnu → refusé (pas de fuite d'existence)")
    void isAllowedOnUnknownProject() {
        when(projects.findByKey("NOPE")).thenReturn(Optional.empty());

        assertThat(service.isAllowed("po", "NOPE", Permission.PROJECT_READ)).isFalse();
    }

    private static User systemAdmin() {
        User user = new User("admin", "admin@example.com", "Admin", "h");
        user.setSystemAdmin(true);
        return user;
    }
}
