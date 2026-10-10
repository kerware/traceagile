package com.traceagile.application.attachment;

import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.attachment.Attachment;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.execution.StepResult;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** ADR-0024 pièces jointes : téléversement ou collage, lecture, suppression, reprise des captures (F-EXE-03). */
@Service
@Transactional
public class AttachmentService {

    private final AttachmentRepository attachments;
    private final AttachmentTargets targets;
    private final FileStorage storage;
    private final ProjectRepository projects;

    public AttachmentService(AttachmentRepository attachments, AttachmentTargets targets, FileStorage storage, ProjectRepository projects) {
        this.attachments = attachments;
        this.targets = targets;
        this.storage = storage;
        this.projects = projects;
    }

    /** Métadonnées et contenu. */
    public record Content(Attachment attachment, byte[] bytes) {
    }

    @Transactional(readOnly = true)
    public List<Attachment> list(String projectKey, Attachment.Target target, Collection<UUID> ids) {
        return attachments.findByTargetTypeAndTargetIdInOrderByCreatedAtAsc(target, ids).stream()
                .filter(a -> a.getProject().getKey().equals(projectKey)).toList();
    }

    /** Contrôles (nom, type, taille) avant d'écrire le contenu ; le porteur doit exister dans le projet. */
    public Attachment upload(String projectKey, Attachment.Target target, UUID targetId, String fileName, byte[] content) {
        Project project = projects.findByKey(projectKey)
                .orElseThrow(() -> new NotFoundException("PROJECT_NOT_FOUND", "Projet « " + projectKey + " » introuvable."));
        if (!targets.exists(projectKey, target, targetId)) {
            throw new NotFoundException("ATTACHMENT_TARGET_NOT_FOUND", "Élément porteur introuvable dans le projet.");
        }
        String name = Attachment.fileName(fileName);
        Attachment.contentType(name);
        Attachment.check(content == null ? 0 : content.length);
        return attachments.save(new Attachment(project, target, targetId, name, content.length, storage.store(content)));
    }

    @Transactional(readOnly = true)
    public Attachment get(String projectKey, UUID id) {
        return attachments.findByIdAndProject_Key(id, projectKey)
                .orElseThrow(() -> new NotFoundException("ATTACHMENT_NOT_FOUND", "Pièce jointe introuvable."));
    }

    @Transactional(readOnly = true)
    public Content content(String projectKey, UUID id) {
        Attachment attachment = get(projectKey, id);
        return new Content(attachment, storage.read(attachment.getStorageKey()));
    }

    /** Le contenu n'est effacé que si plus aucune pièce jointe ne le partage. */
    public void delete(String projectKey, UUID id) {
        Attachment attachment = get(projectKey, id);
        attachments.delete(attachment);
        if (!attachments.existsByStorageKey(attachment.getStorageKey())) {
            storage.delete(attachment.getStorageKey());
        }
    }

    /**
     * F-EXE-03 l'anomalie créée depuis une exécution reprend les captures des pas jusqu'au premier pas
     * en échec (tous les pas s'il n'y en a pas).
     */
    public List<Attachment> copyStepCaptures(Execution execution, UUID defectId) {
        int limit = execution.getSteps().stream().filter(s -> s.getStatus() == ExecutionStatus.FAILED).mapToInt(StepResult::getPosition)
                .min().orElse(Integer.MAX_VALUE);
        List<UUID> steps = execution.getSteps().stream().filter(s -> s.getPosition() <= limit).map(StepResult::getId).toList();
        if (steps.isEmpty()) {
            return List.of();
        }
        return attachments.findByTargetTypeAndTargetIdInOrderByCreatedAtAsc(Attachment.Target.EXECUTION_STEP, steps).stream()
                .map(a -> attachments.save(a.copyTo(Attachment.Target.DEFECT, defectId))).toList();
    }
}
