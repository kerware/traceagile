package com.traceagile.application.attachment;

import com.traceagile.domain.attachment.Attachment;
import java.util.UUID;

/** Port : l'élément porteur d'une pièce jointe existe-t-il dans le projet ? (ADR-0024) */
public interface AttachmentTargets {

    boolean exists(String projectKey, Attachment.Target target, UUID id);
}
