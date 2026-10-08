package com.traceagile.application.administration;

import com.traceagile.domain.administration.User;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

/** Port de persistance des utilisateurs. */
public interface UserRepository {

    Optional<User> findById(UUID id);

    Optional<User> findByLogin(String login);

    boolean existsByLogin(String login);

    Page<User> findAll(Pageable pageable);

    User save(User user);
}
