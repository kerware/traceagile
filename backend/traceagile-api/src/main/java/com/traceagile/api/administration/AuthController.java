package com.traceagile.api.administration;

import com.traceagile.api.administration.AdministrationDtos.LoginRequest;
import com.traceagile.api.administration.AdministrationDtos.TokenResponse;
import com.traceagile.api.security.AccessTokenService;
import com.traceagile.api.security.SecurityProperties;
import com.traceagile.application.administration.AuthenticationResult;
import com.traceagile.application.administration.AuthenticationService;
import com.traceagile.application.common.AuthenticationFailedException;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.time.Clock;
import java.time.Duration;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * §12 Authentification. Le jeton de rafraîchissement circule uniquement dans un cookie HttpOnly,
 * SameSite=Strict, limité à {@code /api/v1/auth} (ADR-0003).
 */
@RestController
@RequestMapping("/api/v1/auth")
@Tag(name = "Authentification")
@SecurityRequirements
public class AuthController {

    static final String REFRESH_COOKIE = "traceagile_refresh";
    static final String REFRESH_COOKIE_PATH = "/api/v1/auth";

    private final AuthenticationService authentication;
    private final AccessTokenService accessTokens;
    private final MeController me;
    private final SecurityProperties properties;
    private final Clock clock;

    public AuthController(AuthenticationService authentication, AccessTokenService accessTokens, MeController me,
                          SecurityProperties properties, Clock clock) {
        this.authentication = authentication;
        this.accessTokens = accessTokens;
        this.me = me;
        this.properties = properties;
        this.clock = clock;
    }

    @PostMapping("/login")
    public ResponseEntity<TokenResponse> login(@Valid @RequestBody LoginRequest request) {
        return respond(authentication.login(request.login(), request.password()));
    }

    @PostMapping("/refresh")
    public ResponseEntity<TokenResponse> refresh(@CookieValue(name = REFRESH_COOKIE, required = false) String refreshToken) {
        if (refreshToken == null) {
            throw new AuthenticationFailedException("AUTH_REFRESH_INVALID", "Session expirée, veuillez vous reconnecter.");
        }
        return respond(authentication.refresh(refreshToken));
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@CookieValue(name = REFRESH_COOKIE, required = false) String refreshToken) {
        if (refreshToken != null) {
            authentication.logout(refreshToken);
        }
        return ResponseEntity.noContent().header(HttpHeaders.SET_COOKIE, cookie("", Duration.ZERO).toString()).build();
    }

    private ResponseEntity<TokenResponse> respond(AuthenticationResult result) {
        Duration maxAge = Duration.between(clock.instant(), result.refreshTokenExpiresAt());
        TokenResponse body = new TokenResponse(accessTokens.issue(result.user()), "Bearer",
                accessTokens.expiresInSeconds(), me.describe(result.user()));
        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, cookie(result.refreshToken(), maxAge).toString())
                .body(body);
    }

    private ResponseCookie cookie(String value, Duration maxAge) {
        return ResponseCookie.from(REFRESH_COOKIE, value)
                .httpOnly(true)
                .secure(properties.refreshCookieSecure())
                .sameSite("Strict")
                .path(REFRESH_COOKIE_PATH)
                .maxAge(maxAge)
                .build();
    }
}
