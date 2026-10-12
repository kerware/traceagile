package com.traceagile.api.administration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.traceagile.application.administration.CreateUserCommand;
import com.traceagile.application.administration.UserAdministrationService;
import com.traceagile.application.administration.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

/** Installation hors Docker : données de démarrage, premier administrateur système. */
class InitialAdministratorTest {

    private final UserRepository users = mock(UserRepository.class);
    private final UserAdministrationService service = mock(UserAdministrationService.class);

    @Test
    @DisplayName("Base vide : l'administrateur système est créé avec le mot de passe configuré")
    void createsConfiguredAdministrator() {
        when(users.count()).thenReturn(0L);
        String password = new InitialAdministrator(users, service, "admin", "Mot-de-passe-1", "admin@exemple.fr").ensure();
        ArgumentCaptor<CreateUserCommand> command = ArgumentCaptor.forClass(CreateUserCommand.class);
        verify(service).create(command.capture());
        assertThat(command.getValue()).isEqualTo(new CreateUserCommand("admin", "admin@exemple.fr", "Administrateur", "Mot-de-passe-1", true));
        assertThat(password).isEqualTo("Mot-de-passe-1");
    }

    @Test
    @DisplayName("Sans mot de passe configuré, un mot de passe aléatoire de 20 caractères est tiré")
    void generatesPassword() {
        when(users.count()).thenReturn(0L);
        String password = new InitialAdministrator(users, service, "admin", "", "admin@exemple.fr").ensure();
        assertThat(password).hasSize(20);
        ArgumentCaptor<CreateUserCommand> command = ArgumentCaptor.forClass(CreateUserCommand.class);
        verify(service).create(command.capture());
        assertThat(command.getValue().password()).isEqualTo(password);
    }

    @Test
    @DisplayName("Des utilisateurs existent (base déjà installée ou démo SwagLabs injectée) : rien n'est créé")
    void keepsExistingUsers() {
        when(users.count()).thenReturn(6L);
        assertThat(new InitialAdministrator(users, service, "admin", "x", "admin@exemple.fr").ensure()).isNull();
        verify(service, never()).create(any());
    }
}
