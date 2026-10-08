package com.traceagile.application.administration;

import com.traceagile.domain.administration.ProjectRole;

public record MemberAssignment(String login, ProjectRole role) {
}
