package com.traceagile.domain.testcase;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Project;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** ADR-0013 dossiers de tests explicites : chemins normalisés, déplacement d'une branche. */
class TestFolderTest {

    final Project shop = new Project("SHOP", "Boutique", null);

    @Test
    @DisplayName("ADR-0013 le chemin est normalisé comme le dossier d'un test")
    void normalized() {
        assertThat(new TestFolder(shop, " Panier / Ajout /").getPath()).isEqualTo("Panier/Ajout");
        assertThat(TestFolder.normalize(" / ")).isNull();
        assertThatThrownBy(() -> new TestFolder(shop, " / ")).extracting("code").isEqualTo("TEST_FOLDER_PATH_REQUIRED");
        assertThatThrownBy(() -> new TestFolder(shop, "a".repeat(301))).extracting("code").isEqualTo("TEST_FOLDER_PATH_TOO_LONG");
    }

    @Test
    @DisplayName("ADR-0013 un chemin appartient à une branche : le dossier lui-même ou ses sous-dossiers")
    void within() {
        assertThat(TestFolder.isWithin("Panier/Ajout", "Panier")).isTrue();
        assertThat(TestFolder.isWithin("Panier", "Panier")).isTrue();
        assertThat(TestFolder.isWithin("Paniers", "Panier")).isFalse();
        assertThat(TestFolder.isWithin(null, "Panier")).isFalse();
    }

    @Test
    @DisplayName("ADR-0013 déplacer une branche réécrit le préfixe des chemins")
    void rebase() {
        assertThat(TestFolder.rebase("Panier/Ajout", "Panier", "Commande/Panier")).isEqualTo("Commande/Panier/Ajout");
        assertThat(TestFolder.rebase("Panier", "Panier", "Caddie")).isEqualTo("Caddie");
    }

    @Test
    @DisplayName("ADR-0013 un test OBSOLETE peut être reclassé (le classement n'est pas une modification du test)")
    void relocateObsolete() {
        TestCase test = TestCase.manual(shop, "TC-1", "Ancien");
        test.changeStatus(TestCaseStatus.OBSOLETE);
        test.relocate("Archives / 2025");
        assertThat(test.getFolder()).isEqualTo("Archives/2025");
    }
}
