package com.traceagile.application.administration;

import com.traceagile.application.common.AuthenticationFailedException;
import com.traceagile.domain.administration.RefreshToken;
import com.traceagile.domain.administration.User;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §11.1 Authentification locale. Le jeton d'accès JWT (15 min) est émis par la couche API ; ce
 * service gère les identifiants et les jetons de rafraîchissement opaques (7 jours, rotation).
 */
@Service
@Transactional
public class AuthenticationService {

    static final Duration REFRESH_TOKEN_VALIDITY = Duration.ofDays(7);

    private final UserRepository users;
    private final RefreshTokenRepository tokens;
    private final PasswordHasher hasher;
    private final Clock clock;
    private final SecureRandom random = new SecureRandom();

    public AuthenticationService(UserRepository users, RefreshTokenRepository tokens, PasswordHasher hasher, Clock clock) {
        this.users = users;
        this.tokens = tokens;
        this.hasher = hasher;
        this.clock = clock;
    }

    public AuthenticationResult login(String login, String password) {
        User user = users.findByLogin(login)
                .filter(User::isActive)
                .filter(u -> hasher.matches(password, u.getPasswordHash()))
                .orElseThrow(() -> new AuthenticationFailedException("AUTH_INVALID_CREDENTIALS",
                        "Login ou mot de passe incorrect."));
        return issue(user);
    }

    public AuthenticationResult refresh(String rawToken) {
        RefreshToken token = tokens.findByTokenHash(sha256(rawToken))
                .filter(t -> t.isUsableAt(clock.instant()))
                .orElseThrow(() -> new AuthenticationFailedException("AUTH_REFRESH_INVALID",
                        "Session expirée, veuillez vous reconnecter."));
        token.revoke();
        return issue(token.getUser());
    }

    public void logout(String rawToken) {
        tokens.findByTokenHash(sha256(rawToken)).ifPresent(RefreshToken::revoke);
    }

    private AuthenticationResult issue(User user) {
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        String raw = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        Instant expiresAt = clock.instant().plus(REFRESH_TOKEN_VALIDITY);
        tokens.save(new RefreshToken(user, sha256(raw), expiresAt));
        return new AuthenticationResult(user, raw, expiresAt);
    }

    private static String sha256(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
