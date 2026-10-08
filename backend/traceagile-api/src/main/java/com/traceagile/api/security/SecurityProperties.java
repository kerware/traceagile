package com.traceagile.api.security;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * §11.1 Paramètres de sécurité.
 *
 * @param jwtSecret secret HMAC-SHA256 des jetons d'accès (au moins 32 octets)
 * @param accessTokenTtl durée de vie du jeton d'accès (15 min)
 * @param refreshCookieSecure ajoute l'attribut {@code Secure} au cookie de rafraîchissement (HTTPS)
 */
@ConfigurationProperties("traceagile.security")
public record SecurityProperties(String jwtSecret, Duration accessTokenTtl, boolean refreshCookieSecure) {

    public SecurityProperties {
        if (jwtSecret == null || jwtSecret.getBytes(java.nio.charset.StandardCharsets.UTF_8).length < 32) {
            throw new IllegalStateException("traceagile.security.jwt-secret doit comporter au moins 32 octets");
        }
        if (accessTokenTtl == null) {
            accessTokenTtl = Duration.ofMinutes(15);
        }
    }
}
