package com.traceagile.domain.administration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.common.BusinessRuleException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

/** §3.1 User : login, email, displayName, passwordHash, active. */
class UserTest {

    @Test
    @DisplayName("§3.1 un nouvel utilisateur est actif et n'est pas administrateur système")
    void newUserIsActive() {
        User user = new User("qa1", "qa1@example.com", "Testeur 1", "hash");

        assertThat(user.isActive()).isTrue();
        assertThat(user.isSystemAdmin()).isFalse();
    }

    @ParameterizedTest
    @ValueSource(strings = {"", "a", "with space", "UPPER", "trop-long-login-de-plus-de-trente-deux-caracteres"})
    @DisplayName("§3.1 login invalide → USER_LOGIN_INVALID")
    void rejectsInvalidLogin(String login) {
        assertThatThrownBy(() -> new User(login, "x@example.com", "X", "hash"))
                .isInstanceOf(BusinessRuleException.class)
                .extracting("code").isEqualTo("USER_LOGIN_INVALID");
    }

    @Test
    @DisplayName("§3.1 email invalide → USER_EMAIL_INVALID")
    void rejectsInvalidEmail() {
        assertThatThrownBy(() -> new User("qa1", "pas-un-email", "X", "hash"))
                .isInstanceOf(BusinessRuleException.class)
                .extracting("code").isEqualTo("USER_EMAIL_INVALID");
    }

    @Test
    @DisplayName("§3.1 le nom affiché par défaut est le login")
    void displayNameDefaultsToLogin() {
        assertThat(new User("qa1", "qa1@example.com", null, "hash").getDisplayName()).isEqualTo("qa1");
    }
}
