package com.traceagile.api.testcase;

import com.traceagile.api.security.SecurityConfig;
import com.traceagile.application.administration.ProjectService;
import com.traceagile.domain.administration.Permission;
import com.traceagile.domain.testcase.TestKind;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

/**
 * §2.2 droits d'écriture sur les tests selon leur nature : le testeur modifie tous les tests
 * (TEST_WRITE), le développeur seulement les tests automatisés (AUTOMATED_TEST_WRITE). Complète la
 * règle {@code @PreAuthorize} de l'endpoint, qui ne connaît pas encore la nature du test.
 */
@Component
public class TestPermissions {

    /** Règle d'endpoint : l'un ou l'autre droit d'écriture sur les tests. */
    public static final String WRITE_ANY = "hasPermission(#projectKey, 'Project', 'TEST_WRITE') "
            + "or hasPermission(#projectKey, 'Project', 'AUTOMATED_TEST_WRITE')";
    public static final String READ = "hasPermission(#projectKey, 'Project', 'TEST_READ')";

    private final ProjectService projects;

    public TestPermissions(ProjectService projects) {
        this.projects = projects;
    }

    public void checkWrite(Authentication authentication, String projectKey, TestKind kind) {
        if (SecurityConfig.isSystemAdmin(authentication)) {
            return;
        }
        boolean allowed = projects.isAllowed(authentication.getName(), projectKey, Permission.TEST_WRITE)
                || kind == TestKind.AUTOMATED && projects.isAllowed(authentication.getName(), projectKey, Permission.AUTOMATED_TEST_WRITE);
        if (!allowed) {
            throw new AccessDeniedException("Écriture refusée sur un test " + kind);
        }
    }
}
