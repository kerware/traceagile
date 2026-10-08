package com.traceagile.api.security;

import com.traceagile.application.administration.ProjectService;
import com.traceagile.domain.administration.Permission;
import java.io.Serializable;
import org.springframework.security.access.PermissionEvaluator;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

/**
 * §11.1 / §2.2 Évalue {@code hasPermission(#key, 'Project', 'REQUIREMENT_WRITE')} à partir du rôle
 * de l'utilisateur sur le projet. L'administrateur système passe toujours (ADR-0004).
 */
@Component
public class ProjectPermissionEvaluator implements PermissionEvaluator {

    static final String PROJECT = "Project";

    private final ProjectService projects;

    public ProjectPermissionEvaluator(ProjectService projects) {
        this.projects = projects;
    }

    @Override
    public boolean hasPermission(Authentication authentication, Serializable targetId, String targetType, Object permission) {
        if (authentication == null || !PROJECT.equals(targetType) || targetId == null) {
            return false;
        }
        if (SecurityConfig.isSystemAdmin(authentication)) {
            return true;
        }
        return projects.isAllowed(authentication.getName(), targetId.toString(), Permission.valueOf(permission.toString()));
    }

    @Override
    public boolean hasPermission(Authentication authentication, Object targetDomainObject, Object permission) {
        return false;
    }
}
