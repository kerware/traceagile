package com.traceagile.domain.administration;

import static com.traceagile.domain.administration.Permission.*;

import java.util.Collections;
import java.util.EnumSet;
import java.util.Set;

/** §2.2 Rôles attribués par projet et droits associés. */
public enum ProjectRole {
    ADMINISTRATOR(EnumSet.allOf(Permission.class)),
    PRODUCT_OWNER(EnumSet.of(
            PROJECT_READ,
            REQUIREMENT_READ, REQUIREMENT_WRITE, REQUIREMENT_COMMENT,
            TEST_READ,
            PLANNING_READ, PLANNING_WRITE, CAMPAIGN_READ,
            EXECUTION_READ)),
    TESTER(EnumSet.of(
            PROJECT_READ,
            REQUIREMENT_READ, REQUIREMENT_COMMENT, ACCEPTANCE_CRITERION_PROPOSE,
            TEST_READ, TEST_WRITE, AUTOMATED_TEST_WRITE,
            PLANNING_READ, CAMPAIGN_READ, CAMPAIGN_WRITE,
            EXECUTION_READ, EXECUTION_WRITE)),
    DEVELOPER(EnumSet.of(
            PROJECT_READ,
            REQUIREMENT_READ, REQUIREMENT_COMMENT,
            TEST_READ, AUTOMATED_TEST_WRITE,
            PLANNING_READ, CAMPAIGN_READ,
            EXECUTION_READ, AUTOMATED_RUN_LAUNCH)),
    VIEWER(EnumSet.of(
            PROJECT_READ, REQUIREMENT_READ, TEST_READ, PLANNING_READ, CAMPAIGN_READ, EXECUTION_READ));

    private final Set<Permission> permissions;

    ProjectRole(EnumSet<Permission> permissions) {
        this.permissions = Collections.unmodifiableSet(permissions);
    }

    public Set<Permission> permissions() {
        return permissions;
    }

    public boolean allows(Permission permission) {
        return permissions.contains(permission);
    }
}
