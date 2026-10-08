package com.traceagile.application.administration;

import com.traceagile.domain.administration.User;
import java.time.Instant;

/** Utilisateur authentifié et nouveau jeton de rafraîchissement (en clair, transmis une seule fois). */
public record AuthenticationResult(User user, String refreshToken, Instant refreshTokenExpiresAt) {
}
