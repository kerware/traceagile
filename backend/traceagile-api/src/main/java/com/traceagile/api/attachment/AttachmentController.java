package com.traceagile.api.attachment;

import com.traceagile.application.administration.ProjectService;
import com.traceagile.application.attachment.AttachmentService;
import com.traceagile.domain.attachment.Attachment;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.io.IOException;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

/**
 * ADR-0024 pièces jointes des exigences, pas d'exécution (F-EXE-01), anomalies (F-EXE-03) et notes de
 * session (F-EXP-08). Lecture : membres du projet ; écriture : droit propre au porteur (vérifié ici → 403).
 */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}")
@Tag(name = "Pièces jointes")
public class AttachmentController {

    static final String READ = "hasPermission(#projectKey, 'Project', 'PROJECT_READ')";

    private final AttachmentService attachments;
    private final ProjectService projects;

    public AttachmentController(AttachmentService attachments, ProjectService projects) {
        this.attachments = attachments;
        this.projects = projects;
    }

    public record AttachmentResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Attachment.Target targetType,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID targetId,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String fileName,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String contentType,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long size,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean image,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant createdAt,
            String createdBy) {
    }

    /** Pièces jointes d'un ou plusieurs porteurs du même type (tous les pas d'une exécution, par exemple). */
    @GetMapping("/attachments")
    @PreAuthorize(READ)
    public List<AttachmentResponse> list(@PathVariable String projectKey, @RequestParam Attachment.Target targetType,
                                         @RequestParam List<UUID> targetIds) {
        return attachments.list(projectKey, targetType, targetIds).stream().map(AttachmentController::response).toList();
    }

    @PostMapping(path = "/attachments", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize(READ)
    @ResponseStatus(HttpStatus.CREATED)
    public AttachmentResponse upload(@PathVariable String projectKey, @RequestParam Attachment.Target targetType, @RequestParam UUID targetId,
                                     @RequestPart("file") MultipartFile file, Authentication authentication) throws IOException {
        checkWrite(authentication, projectKey, targetType);
        return response(attachments.upload(projectKey, targetType, targetId, file.getOriginalFilename(), file.getBytes()));
    }

    /** Contenu : les images s'affichent, le reste se télécharge ; jamais interprété par le navigateur. */
    @GetMapping("/attachments/{id}/content")
    @PreAuthorize(READ)
    public ResponseEntity<byte[]> content(@PathVariable String projectKey, @PathVariable UUID id) {
        AttachmentService.Content content = attachments.content(projectKey, id);
        Attachment a = content.attachment();
        ContentDisposition disposition = (a.isImage() ? ContentDisposition.inline() : ContentDisposition.attachment())
                .filename(a.getFileName(), java.nio.charset.StandardCharsets.UTF_8).build();
        return ResponseEntity.ok().contentType(MediaType.parseMediaType(a.getContentType()))
                .header(HttpHeaders.CONTENT_DISPOSITION, disposition.toString())
                .header("X-Content-Type-Options", "nosniff")
                .header("Content-Security-Policy", "sandbox")
                .body(content.bytes());
    }

    @DeleteMapping("/attachments/{id}")
    @PreAuthorize(READ)
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable String projectKey, @PathVariable UUID id, Authentication authentication) {
        checkWrite(authentication, projectKey, attachments.get(projectKey, id).getTargetType());
        attachments.delete(projectKey, id);
    }

    private void checkWrite(Authentication authentication, String projectKey, Attachment.Target target) {
        boolean allowed = target.writers().stream().anyMatch(p -> projects.isAllowed(authentication.getName(), projectKey, p));
        if (!allowed) {
            throw new AccessDeniedException("Pièce jointe refusée sur " + target);
        }
    }

    static AttachmentResponse response(Attachment a) {
        return new AttachmentResponse(a.getId(), a.getTargetType(), a.getTargetId(), a.getFileName(), a.getContentType(), a.getSize(), a.isImage(),
                a.getCreatedAt(), a.getCreatedBy());
    }
}
