package com.traceagile.infrastructure.persistence;

import com.traceagile.application.administration.RefreshTokenRepository;
import com.traceagile.domain.administration.RefreshToken;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link RefreshTokenRepository}. */
public interface JpaRefreshTokenRepository extends JpaRepository<RefreshToken, UUID>, RefreshTokenRepository {
}
