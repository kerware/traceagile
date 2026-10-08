package com.traceagile.application.administration;

public record CreateUserCommand(String login, String email, String displayName, String password, boolean systemAdmin) {
}
