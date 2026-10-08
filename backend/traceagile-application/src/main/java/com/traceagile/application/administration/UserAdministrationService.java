package com.traceagile.application.administration;

import com.traceagile.application.common.ConflictException;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.common.VersionConflictException;
import com.traceagile.domain.administration.User;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Administration des utilisateurs (§12 : GET/POST /users, PATCH /users/{id}). */
@Service
@Transactional
public class UserAdministrationService {

    private final UserRepository users;
    private final PasswordHasher hasher;

    public UserAdministrationService(UserRepository users, PasswordHasher hasher) {
        this.users = users;
        this.hasher = hasher;
    }

    public User create(CreateUserCommand command) {
        if (users.existsByLogin(command.login())) {
            throw new ConflictException("USER_LOGIN_TAKEN", "Le login « " + command.login() + " » est déjà utilisé.");
        }
        User user = new User(command.login(), command.email(), command.displayName(), hasher.hash(command.password()));
        user.setSystemAdmin(command.systemAdmin());
        return users.save(user);
    }

    public User update(UUID id, UpdateUserCommand command, Long expectedVersion) {
        User user = get(id);
        VersionConflictException.check(expectedVersion, user.getVersion());
        if (command.email() != null) {
            user.setEmail(command.email());
        }
        if (command.displayName() != null) {
            user.setDisplayName(command.displayName());
        }
        if (command.password() != null) {
            user.setPasswordHash(hasher.hash(command.password()));
        }
        if (command.active() != null) {
            user.setActive(command.active());
        }
        if (command.systemAdmin() != null) {
            user.setSystemAdmin(command.systemAdmin());
        }
        return user;
    }

    @Transactional(readOnly = true)
    public User get(UUID id) {
        return users.findById(id)
                .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Utilisateur introuvable."));
    }

    @Transactional(readOnly = true)
    public User getByLogin(String login) {
        return users.findByLogin(login)
                .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Utilisateur « " + login + " » introuvable."));
    }

    @Transactional(readOnly = true)
    public Page<User> list(Pageable pageable) {
        return users.findAll(pageable);
    }
}
