package com.traceagile.domain.attachment;

import com.traceagile.domain.administration.Permission;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.EnumSet;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * ADR-0024 pièce jointe (F-EXE-01 captures des pas, F-EXE-03 captures d'une anomalie, F-EXP-08 captures
 * d'une note de session) : métadonnées en base, contenu dans le {@code FileStorage} (clé partagée
 * quand une capture est reprise par une anomalie).
 */
@Entity
@Table(name = "attachments")
public class Attachment extends AuditableEntity {

    public static final long MAX_SIZE = 10L * 1024 * 1024;

    /** Types acceptés : images, PDF, texte, journaux, JSON, XML, CSV. */
    static final Map<String, String> TYPES = Map.ofEntries(
            Map.entry("png", "image/png"), Map.entry("jpg", "image/jpeg"), Map.entry("jpeg", "image/jpeg"), Map.entry("gif", "image/gif"),
            Map.entry("webp", "image/webp"), Map.entry("pdf", "application/pdf"), Map.entry("txt", "text/plain"), Map.entry("log", "text/plain"),
            Map.entry("md", "text/markdown"), Map.entry("json", "application/json"), Map.entry("xml", "application/xml"), Map.entry("csv", "text/csv"));

    /** Élément porteur et droit nécessaire pour y joindre un fichier. */
    public enum Target {
        REQUIREMENT(EnumSet.of(Permission.REQUIREMENT_COMMENT)),
        EXECUTION_STEP(EnumSet.of(Permission.EXECUTION_WRITE)),
        DEFECT(EnumSet.of(Permission.EXECUTION_WRITE, Permission.AUTOMATED_RUN_LAUNCH, Permission.REQUIREMENT_WRITE)),
        SESSION_NOTE(EnumSet.of(Permission.EXECUTION_WRITE));

        private final Set<Permission> writers;

        Target(Set<Permission> writers) {
            this.writers = writers;
        }

        /** Il suffit de l'un de ces droits. */
        public Set<Permission> writers() {
            return writers;
        }
    }

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @Enumerated(EnumType.STRING)
    @Column(name = "target_type", nullable = false, length = 20)
    private Target targetType;

    @Column(name = "target_id", nullable = false)
    private UUID targetId;

    @Column(name = "file_name", nullable = false, length = 200)
    private String fileName;

    @Column(name = "content_type", nullable = false, length = 100)
    private String contentType;

    @Column(nullable = false)
    private long size;

    @Column(name = "storage_key", nullable = false, length = 100)
    private String storageKey;

    protected Attachment() {
    }

    public Attachment(Project project, Target targetType, UUID targetId, String fileName, long size, String storageKey) {
        this.project = project;
        this.targetType = targetType;
        this.targetId = targetId;
        this.fileName = fileName(fileName);
        this.contentType = contentType(this.fileName);
        this.size = check(size);
        this.storageKey = storageKey;
    }

    /** F-EXE-03 la capture d'un pas reprise par l'anomalie : même contenu, autre porteur. */
    public Attachment copyTo(Target target, UUID id) {
        return new Attachment(project, target, id, fileName, size, storageKey);
    }

    /** Nom sans chemin, 200 caractères au plus ; un collage sans nom devient « capture.png ». */
    public static String fileName(String name) {
        String base = name == null ? "" : name.replace('\\', '/');
        base = base.substring(base.lastIndexOf('/') + 1).replaceAll("[\\p{Cntrl}\"]", "").strip();
        if (base.isEmpty() || base.equals(".") || base.equals("..")) {
            base = "capture.png";
        }
        return base.length() > 200 ? base.substring(base.length() - 200) : base;
    }

    /** Type MIME déduit de l'extension (jamais de celui annoncé par le navigateur) ; refusé hors liste. */
    public static String contentType(String fileName) {
        int dot = fileName.lastIndexOf('.');
        String extension = dot < 0 ? "" : fileName.substring(dot + 1).toLowerCase(Locale.ROOT);
        String type = TYPES.get(extension);
        if (type == null) {
            throw new BusinessRuleException("ATTACHMENT_TYPE_REFUSED",
                    "Type de fichier refusé (« " + fileName + " ») : images, PDF, texte, journaux, JSON, XML ou CSV.");
        }
        return type;
    }

    public static long check(long size) {
        if (size <= 0) {
            throw new BusinessRuleException("ATTACHMENT_EMPTY", "Le fichier est vide.");
        }
        if (size > MAX_SIZE) {
            throw new BusinessRuleException("ATTACHMENT_TOO_LARGE", "Le fichier dépasse 10 Mo.");
        }
        return size;
    }

    public boolean isImage() {
        return contentType.startsWith("image/");
    }

    public Project getProject() {
        return project;
    }

    public Target getTargetType() {
        return targetType;
    }

    public UUID getTargetId() {
        return targetId;
    }

    public String getFileName() {
        return fileName;
    }

    public String getContentType() {
        return contentType;
    }

    public long getSize() {
        return size;
    }

    public String getStorageKey() {
        return storageKey;
    }
}
