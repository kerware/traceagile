package com.traceagile.infrastructure.security;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** NF-07 Mots de passe BCrypt (coût 12). */
class BCryptPasswordHasherTest {

    BCryptPasswordHasher hasher = new BCryptPasswordHasher();

    @Test
    @DisplayName("NF-07 le hachage utilise BCrypt avec un coût de 12")
    void usesBcryptCost12() {
        assertThat(hasher.hash("demo")).startsWith("$2a$12$");
    }

    @Test
    @DisplayName("NF-07 le mot de passe d'origine est vérifiable, un autre est refusé")
    void matches() {
        String hash = hasher.hash("demo");

        assertThat(hasher.matches("demo", hash)).isTrue();
        assertThat(hasher.matches("autre", hash)).isFalse();
    }
}
