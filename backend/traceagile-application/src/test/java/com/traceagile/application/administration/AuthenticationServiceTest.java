package com.traceagile.application.administration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.traceagile.application.common.AuthenticationFailedException;
import com.traceagile.domain.administration.RefreshToken;
import com.traceagile.domain.administration.User;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

/** §11.1 Sécurité : authentification locale, refresh 7 jours, déconnexion (§12 /auth/*). */
@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class AuthenticationServiceTest {

    static final Instant NOW = Instant.parse("2026-10-08T10:00:00Z");

    @Mock
    UserRepository users;
    @Mock
    RefreshTokenRepository tokens;
    @Mock
    PasswordHasher hasher;

    MutableClock clock = new MutableClock(NOW);
    Map<String, RefreshToken> stored = new HashMap<>();
    AuthenticationService service;
    User qa1 = new User("qa1", "qa1@example.com", "Testeur", "hash");

    @BeforeEach
    void setUp() {
        service = new AuthenticationService(users, tokens, hasher, clock);
        when(users.findByLogin("qa1")).thenReturn(Optional.of(qa1));
        when(hasher.matches("demo", "hash")).thenReturn(true);
        when(tokens.save(any())).thenAnswer(inv -> {
            RefreshToken token = inv.getArgument(0);
            stored.put(token.getTokenHash(), token);
            return token;
        });
        when(tokens.findByTokenHash(any())).thenAnswer(inv -> Optional.ofNullable(stored.get(inv.<String>getArgument(0))));
    }

    @Test
    @DisplayName("§12 POST /auth/login : identifiants valides → jeton de rafraîchissement valable 7 jours")
    void loginSucceeds() {
        AuthenticationResult result = service.login("qa1", "demo");

        assertThat(result.user()).isSameAs(qa1);
        assertThat(result.refreshToken()).hasSizeGreaterThan(30);
        assertThat(result.refreshTokenExpiresAt()).isEqualTo(NOW.plus(Duration.ofDays(7)));
    }

    @Test
    @DisplayName("NF-07 seule l'empreinte du jeton de rafraîchissement est stockée")
    void refreshTokenIsStoredHashed() {
        AuthenticationResult result = service.login("qa1", "demo");

        assertThat(stored).doesNotContainKey(result.refreshToken()).hasSize(1);
    }

    @Test
    @DisplayName("§12 POST /auth/login : mauvais mot de passe → AUTH_INVALID_CREDENTIALS")
    void loginWrongPassword() {
        assertThatThrownBy(() -> service.login("qa1", "mauvais"))
                .isInstanceOf(AuthenticationFailedException.class)
                .extracting("code").isEqualTo("AUTH_INVALID_CREDENTIALS");
    }

    @Test
    @DisplayName("§12 POST /auth/login : login inconnu → même message que mauvais mot de passe")
    void loginUnknownUser() {
        assertThatThrownBy(() -> service.login("inconnu", "demo"))
                .isInstanceOf(AuthenticationFailedException.class)
                .extracting("code").isEqualTo("AUTH_INVALID_CREDENTIALS");
    }

    @Test
    @DisplayName("§3.1 User.active : un utilisateur désactivé ne peut pas se connecter")
    void loginInactiveUser() {
        qa1.setActive(false);

        assertThatThrownBy(() -> service.login("qa1", "demo"))
                .isInstanceOf(AuthenticationFailedException.class)
                .extracting("code").isEqualTo("AUTH_INVALID_CREDENTIALS");
    }

    @Test
    @DisplayName("§12 POST /auth/refresh : rotation, l'ancien jeton ne sert plus")
    void refreshRotatesToken() {
        String first = service.login("qa1", "demo").refreshToken();

        AuthenticationResult refreshed = service.refresh(first);

        assertThat(refreshed.refreshToken()).isNotEqualTo(first);
        assertThatThrownBy(() -> service.refresh(first))
                .isInstanceOf(AuthenticationFailedException.class)
                .extracting("code").isEqualTo("AUTH_REFRESH_INVALID");
    }

    @Test
    @DisplayName("§11.1 le jeton de rafraîchissement expire après 7 jours")
    void refreshExpired() {
        String token = service.login("qa1", "demo").refreshToken();
        clock.advance(Duration.ofDays(7).plusSeconds(1));

        assertThatThrownBy(() -> service.refresh(token))
                .isInstanceOf(AuthenticationFailedException.class)
                .extracting("code").isEqualTo("AUTH_REFRESH_INVALID");
    }

    @Test
    @DisplayName("§12 POST /auth/logout : révoque le jeton de rafraîchissement")
    void logoutRevokes() {
        String token = service.login("qa1", "demo").refreshToken();

        service.logout(token);

        assertThatThrownBy(() -> service.refresh(token)).isInstanceOf(AuthenticationFailedException.class);
    }

    @Test
    @DisplayName("§12 POST /auth/logout : un jeton inconnu est ignoré (idempotent)")
    void logoutUnknownTokenIsIgnored() {
        service.logout("inconnu");
    }

    static final class MutableClock extends Clock {
        private Instant now;

        MutableClock(Instant now) {
            this.now = now;
        }

        void advance(Duration duration) {
            now = now.plus(duration);
        }

        @Override
        public ZoneOffset getZone() {
            return ZoneOffset.UTC;
        }

        @Override
        public Clock withZone(java.time.ZoneId zone) {
            return this;
        }

        @Override
        public Instant instant() {
            return now;
        }
    }
}
