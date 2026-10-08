package com.traceagile.api.administration;

import com.traceagile.api.administration.AdministrationDtos.MeResponse;
import com.traceagile.application.administration.ProjectService;
import com.traceagile.application.administration.UserAdministrationService;
import com.traceagile.domain.administration.User;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** §12 GET /me : profil de l'utilisateur connecté et ses rôles par projet (§2.2). */
@RestController
@RequestMapping("/api/v1/me")
@Tag(name = "Authentification")
public class MeController {

    private final UserAdministrationService users;
    private final ProjectService projects;
    private final AdministrationMapper mapper;

    public MeController(UserAdministrationService users, ProjectService projects, AdministrationMapper mapper) {
        this.users = users;
        this.projects = projects;
        this.mapper = mapper;
    }

    @GetMapping
    public MeResponse me(Authentication authentication) {
        return describe(users.getByLogin(authentication.getName()));
    }

    MeResponse describe(User user) {
        var memberships = projects.memberships(user).stream()
                .map(project -> mapper.toMembership(project, project.roleOf(user).orElseThrow()))
                .toList();
        return new MeResponse(user.getId(), user.getLogin(), user.getEmail(), user.getDisplayName(),
                user.isSystemAdmin(), memberships);
    }
}
