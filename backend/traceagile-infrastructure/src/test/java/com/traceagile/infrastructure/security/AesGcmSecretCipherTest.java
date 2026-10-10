package com.traceagile.infrastructure.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** ADR-0020 le jeton du serveur d'exécution est chiffré au repos (§3.1 « apiToken (chiffré) »). */
class AesGcmSecretCipherTest {

    @Test
    @DisplayName("§3.1 chiffrement AES-GCM : aller-retour, IV aléatoire, altération ou autre clé détectées")
    void roundTrip() {
        AesGcmSecretCipher cipher = new AesGcmSecretCipher("clé de test");
        String first = cipher.encrypt("ets_jeton");
        assertThat(first).doesNotContain("ets_jeton");
        assertThat(cipher.encrypt("ets_jeton")).isNotEqualTo(first);
        assertThat(cipher.decrypt(first)).isEqualTo("ets_jeton");
        String tampered = first.substring(0, first.length() - 4) + (first.endsWith("AAAA") ? "BBBB" : "AAAA");
        assertThatThrownBy(() -> cipher.decrypt(tampered)).isInstanceOf(IllegalStateException.class);
        assertThatThrownBy(() -> new AesGcmSecretCipher("autre clé").decrypt(first)).isInstanceOf(IllegalStateException.class);
    }
}
