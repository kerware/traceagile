package com.traceagile.api.security;

import com.traceagile.domain.administration.User;
import java.time.Clock;
import java.time.Instant;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Component;

/** §11.1 Émission des jetons d'accès JWT (HS256, 15 min). */
@Component
public class AccessTokenService {

    static final String ISSUER = "traceagile";
    static final String CLAIM_SYSTEM_ADMIN = "adm";

    private final JwtEncoder encoder;
    private final SecurityProperties properties;
    private final Clock clock;

    public AccessTokenService(JwtEncoder encoder, SecurityProperties properties, Clock clock) {
        this.encoder = encoder;
        this.properties = properties;
        this.clock = clock;
    }

    public String issue(User user) {
        Instant now = clock.instant();
        JwtClaimsSet claims = JwtClaimsSet.builder()
                .issuer(ISSUER)
                .subject(user.getLogin())
                .issuedAt(now)
                .expiresAt(now.plus(properties.accessTokenTtl()))
                .claim("uid", user.getId().toString())
                .claim(CLAIM_SYSTEM_ADMIN, user.isSystemAdmin())
                .build();
        return encoder.encode(JwtEncoderParameters.from(JwsHeader.with(MacAlgorithm.HS256).build(), claims)).getTokenValue();
    }

    public long expiresInSeconds() {
        return properties.accessTokenTtl().toSeconds();
    }
}
