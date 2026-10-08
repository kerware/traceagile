package com.traceagile.infrastructure.persistence;

import com.traceagile.application.administration.UserRepository;
import com.traceagile.domain.administration.User;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link UserRepository}. */
public interface JpaUserRepository extends JpaRepository<User, UUID>, UserRepository {
}
