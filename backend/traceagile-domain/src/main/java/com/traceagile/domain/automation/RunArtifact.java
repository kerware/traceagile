package com.traceagile.domain.automation;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.execution.Execution;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.Objects;

/**
 * ADR-0021 artefact d'un run, annoncé par le serveur d'exécution (webhook ou liste) : traces système,
 * résultats JUnit XML ou Jest JSON, rapport, copie d'écran d'un échec. Seule la référence est conservée ;
 * le contenu est relu sur le serveur, avec le jeton qu'il a émis, à chaque téléchargement.
 */
@Entity
@Table(name = "run_artifacts")
public class RunArtifact extends AuditableEntity {

    public enum Kind {
        SYSTEM_TRACE, JUNIT, JEST, REPORT, SCREENSHOT, OTHER;

        public static Kind of(String value, String name) {
            if (value != null) {
                try {
                    return valueOf(value);
                } catch (IllegalArgumentException ignored) {
                    // type inconnu : déduit du nom
                }
            }
            String n = name.toLowerCase();
            if (n.endsWith(".png") || n.endsWith(".jpg") || n.endsWith(".jpeg")) {
                return SCREENSHOT;
            }
            if (n.equals("junit.xml") || n.startsWith("test-") && n.endsWith(".xml")) {
                return JUNIT;
            }
            if (n.equals("jest.json")) {
                return JEST;
            }
            return n.endsWith(".log") ? SYSTEM_TRACE : OTHER;
        }
    }

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "run_id")
    private AutomatedRun run;

    /** Test concerné (copie d'écran d'un échec) ; {@code null} pour un artefact du job. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "execution_id")
    private Execution execution;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(name = "content_type", nullable = false, length = 100)
    private String contentType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 15)
    private Kind kind;

    private Long size;

    protected RunArtifact() {
    }

    public RunArtifact(AutomatedRun run, Execution execution, String name, String contentType, Kind kind, Long size) {
        this.run = Objects.requireNonNull(run);
        this.execution = execution;
        this.name = Objects.requireNonNull(name);
        this.contentType = contentType == null || contentType.isBlank() ? "application/octet-stream" : contentType;
        this.kind = kind;
        this.size = size;
    }

    public AutomatedRun getRun() {
        return run;
    }

    public Execution getExecution() {
        return execution;
    }

    public String getName() {
        return name;
    }

    public String getContentType() {
        return contentType;
    }

    public Kind getKind() {
        return kind;
    }

    public Long getSize() {
        return size;
    }
}
