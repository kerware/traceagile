package com.traceagile.application.administration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.traceagile.application.common.ConflictException;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.common.VersionConflictException;
import com.traceagile.domain.administration.User;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

/** Lot 0 — administration des utilisateurs (§12 Administration : GET/POST /users, PATCH /users/{id}). */
@ExtendWith(MockitoExtension.class)
class UserAdministrationServiceTest {

    @Mock
    UserRepository users;
    @Mock
    PasswordHasher hasher;

    UserAdministrationService service;

    @BeforeEach
    void setUp() {
        service = new UserAdministrationService(users, hasher);
    }

    @Test
    @DisplayName("NF-07 le mot de passe est stocké haché, jamais en clair")
    void createHashesPassword() {
        when(users.existsByLogin("qa1")).thenReturn(false);
        when(hasher.hash("secret-123")).thenReturn("$2a$12$hash");
        when(users.save(any())).thenAnswer(inv -> inv.getArgument(0));

        User created = service.create(new CreateUserCommand("qa1", "qa1@example.com", "Testeur", "secret-123", false));

        assertThat(created.getPasswordHash()).isEqualTo("$2a$12$hash");
        assertThat(created.isActive()).isTrue();
    }

    @Test
    @DisplayName("§3.1 le login est unique → USER_LOGIN_TAKEN")
    void createRejectsDuplicateLogin() {
        when(users.existsByLogin("qa1")).thenReturn(true);

        assertThatThrownBy(() -> service.create(new CreateUserCommand("qa1", "qa1@example.com", null, "secret-123", false)))
                .isInstanceOf(ConflictException.class)
                .extracting("code").isEqualTo("USER_LOGIN_TAKEN");
        verify(users, never()).save(any());
    }

    @Test
    @DisplayName("§12 PATCH /users/{id} : mise à jour partielle, seuls les champs fournis changent")
    void updateIsPartial() {
        User user = new User("qa1", "qa1@example.com", "Testeur", "old");
        UUID id = UUID.randomUUID();
        when(users.findById(id)).thenReturn(Optional.of(user));

        service.update(id, new UpdateUserCommand(null, "Testeur principal", null, false, null), 0L);

        assertThat(user.getEmail()).isEqualTo("qa1@example.com");
        assertThat(user.getDisplayName()).isEqualTo("Testeur principal");
        assertThat(user.isActive()).isFalse();
        assertThat(user.getPasswordHash()).isEqualTo("old");
    }

    @Test
    @DisplayName("§12 If-Match : une version périmée provoque un conflit (412)")
    void updateChecksVersion() {
        User user = new User("qa1", "qa1@example.com", "Testeur", "old");
        UUID id = UUID.randomUUID();
        when(users.findById(id)).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> service.update(id, new UpdateUserCommand(null, "X", null, null, null), 3L))
                .isInstanceOf(VersionConflictException.class);
    }

    @Test
    @DisplayName("§12 PATCH /users/{id} : changement de mot de passe haché")
    void updatePassword() {
        User user = new User("qa1", "qa1@example.com", "Testeur", "old");
        UUID id = UUID.randomUUID();
        when(users.findById(id)).thenReturn(Optional.of(user));
        when(hasher.hash("nouveau-mdp")).thenReturn("new-hash");

        service.update(id, new UpdateUserCommand(null, null, "nouveau-mdp", null, null), null);

        assertThat(user.getPasswordHash()).isEqualTo("new-hash");
    }

    @Test
    @DisplayName("utilisateur inconnu → USER_NOT_FOUND")
    void updateUnknownUser() {
        UUID id = UUID.randomUUID();
        when(users.findById(id)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.update(id, new UpdateUserCommand(null, null, null, null, null), null))
                .isInstanceOf(NotFoundException.class)
                .extracting("code").isEqualTo("USER_NOT_FOUND");
    }
}
