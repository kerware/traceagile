package com.traceagile.domain.attachment;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Permission;
import com.traceagile.domain.administration.Project;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/** ADR-0024 pièces jointes (F-EXE-01, F-EXE-03, F-EXP-08) : nom, type, taille, droits par porteur. */
class AttachmentTest {

    final Project shop = new Project("SHOP", "Boutique", null);

    @ParameterizedTest(name = "« {0} » → « {1} »")
    @CsvSource({"capture.PNG, capture.PNG", "C:\\Users\\qa\\écran 1.png, écran 1.png", "../../etc/passwd.txt, passwd.txt", "' ', capture.png"})
    @DisplayName("ADR-0024 nom de fichier sans chemin ni caractère de contrôle ; un collage sans nom devient capture.png")
    void fileName(String raw, String expected) {
        assertThat(Attachment.fileName(raw)).isEqualTo(expected);
    }

    @Test
    @DisplayName("ADR-0024 type déduit de l'extension, liste fermée ; 10 Mo au plus, jamais vide")
    void typeAndSize() {
        assertThat(Attachment.contentType("trace.LOG")).isEqualTo("text/plain");
        assertThat(Attachment.contentType("ecran.jpeg")).isEqualTo("image/jpeg");
        assertThatThrownBy(() -> Attachment.contentType("virus.exe")).extracting("code").isEqualTo("ATTACHMENT_TYPE_REFUSED");
        assertThatThrownBy(() -> Attachment.contentType("page.html")).extracting("code").isEqualTo("ATTACHMENT_TYPE_REFUSED");
        assertThatThrownBy(() -> Attachment.check(Attachment.MAX_SIZE + 1)).extracting("code").isEqualTo("ATTACHMENT_TOO_LARGE");
        assertThatThrownBy(() -> Attachment.check(0)).extracting("code").isEqualTo("ATTACHMENT_EMPTY");
    }

    @Test
    @DisplayName("F-EXE-03 une capture de pas reprise par l'anomalie garde le même contenu ; droits d'écriture par porteur")
    void copyAndWriters() {
        Attachment step = new Attachment(shop, Attachment.Target.EXECUTION_STEP, UUID.randomUUID(), "pas-2.png", 1200, "k1");
        assertThat(step.isImage()).isTrue();
        UUID defect = UUID.randomUUID();
        Attachment copy = step.copyTo(Attachment.Target.DEFECT, defect);
        assertThat(copy.getStorageKey()).isEqualTo("k1");
        assertThat(copy.getTargetId()).isEqualTo(defect);
        assertThat(Attachment.Target.DEFECT.writers()).contains(Permission.REQUIREMENT_WRITE, Permission.EXECUTION_WRITE);
        assertThat(Attachment.Target.REQUIREMENT.writers()).containsExactly(Permission.REQUIREMENT_COMMENT);
    }
}
