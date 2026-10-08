package com.traceagile.application.administration;

import com.traceagile.domain.administration.RefreshToken;
import java.util.Optional;

/** Port de persistance des jetons de rafraîchissement. */
public interface RefreshTokenRepository {

    Optional<RefreshToken> findByTokenHash(String tokenHash);

    RefreshToken save(RefreshToken token);
}
