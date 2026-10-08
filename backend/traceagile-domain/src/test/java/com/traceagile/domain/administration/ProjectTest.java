package com.traceagile.domain.administration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.common.BusinessRuleException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

/** §3.1 Project : clé de 3 à 10 lettres majuscules ; rôles par projet (§2.2). */
class ProjectTest {

    @ParameterizedTest
    @ValueSource(strings = {"SHOP", "ABC", "ABCDEFGHIJ"})
    @DisplayName("§3.1 clé projet valide : 3 à 10 lettres majuscules")
    void acceptsValidKey(String key) {
        assertThat(new Project(key, "Nom", null).getKey()).isEqualTo(key);
    }

    @ParameterizedTest
    @ValueSource(strings = {"AB", "ABCDEFGHIJK", "shop", "SH0P", "SH-OP", "ÉTÉS", " SHOP"})
    @DisplayName("§3.1 clé projet invalide → PROJECT_KEY_INVALID")
    void rejectsInvalidKey(String key) {
        assertThatThrownBy(() -> new Project(key, "Nom", null))
                .isInstanceOf(BusinessRuleException.class)
                .extracting("code").isEqualTo("PROJECT_KEY_INVALID");
    }

    @Test
    @DisplayName("§3.1 le nom du projet est obligatoire")
    void requiresName() {
        assertThatThrownBy(() -> new Project("SHOP", "  ", null))
                .isInstanceOf(BusinessRuleException.class)
                .extracting("code").isEqualTo("PROJECT_NAME_REQUIRED");
    }

    @Test
    @DisplayName("§2.2 rôle par projet : un même utilisateur a des rôles différents selon le projet")
    void rolesArePerProject() {
        User alice = new User("alice", "alice@example.com", "Alice", "hash");
        Project shop = new Project("SHOP", "Boutique", null);
        Project bank = new Project("BANK", "Banque", null);

        shop.setMember(alice, ProjectRole.PRODUCT_OWNER);
        bank.setMember(alice, ProjectRole.VIEWER);

        assertThat(shop.roleOf(alice)).contains(ProjectRole.PRODUCT_OWNER);
        assertThat(bank.roleOf(alice)).contains(ProjectRole.VIEWER);
    }

    @Test
    @DisplayName("§2.2 un utilisateur a au plus un rôle par projet : réaffecter remplace le rôle")
    void setMemberReplacesRole() {
        User bob = new User("bob", "bob@example.com", "Bob", "hash");
        Project shop = new Project("SHOP", "Boutique", null);

        shop.setMember(bob, ProjectRole.VIEWER);
        shop.setMember(bob, ProjectRole.TESTER);

        assertThat(shop.getMembers()).hasSize(1);
        assertThat(shop.roleOf(bob)).contains(ProjectRole.TESTER);
    }

    @Test
    @DisplayName("§2.2 un utilisateur sans rôle n'a aucun droit sur le projet")
    void nonMemberHasNoRole() {
        User carol = new User("carol", "carol@example.com", "Carol", "hash");
        Project shop = new Project("SHOP", "Boutique", null);

        assertThat(shop.roleOf(carol)).isEmpty();
        assertThat(shop.allows(carol, Permission.PROJECT_READ)).isFalse();
    }

    @Test
    @DisplayName("§2.2 l'administrateur système a tous les droits sur tous les projets (ADR-0004)")
    void systemAdministratorHasAllRights() {
        User admin = new User("admin", "admin@example.com", "Admin", "hash");
        admin.setSystemAdmin(true);
        Project shop = new Project("SHOP", "Boutique", null);

        assertThat(shop.allows(admin, Permission.PROJECT_ADMIN)).isTrue();
    }

    @Test
    @DisplayName("§2.2 retirer un membre lui retire l'accès")
    void removeMember() {
        User dave = new User("dave", "dave@example.com", "Dave", "hash");
        Project shop = new Project("SHOP", "Boutique", null);
        shop.setMember(dave, ProjectRole.DEVELOPER);

        shop.removeMember(dave);

        assertThat(shop.roleOf(dave)).isEmpty();
    }
}
