package com.traceagile.domain.exploratory;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.defect.Defect;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.Objects;

/** F-EXP-06 entrée horodatée d'une session (secondes de temps actif depuis le début). */
@Entity
@Table(name = "session_notes")
public class SessionNote extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "session_id")
    private ExploratorySession session;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private NoteType type;

    @Column(name = "offset_seconds", nullable = false)
    private long offsetSeconds;

    @Column(nullable = false, columnDefinition = "text")
    private String text;

    @Column(name = "noted_at", nullable = false)
    private Instant notedAt;

    /** F-EXP-07 anomalie créée depuis cette note ({@code BUG}). */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "defect_id")
    private Defect defect;

    protected SessionNote() {
    }

    SessionNote(ExploratorySession session, NoteType type, long offsetSeconds, String text, Instant notedAt) {
        this.session = Objects.requireNonNull(session);
        this.type = Objects.requireNonNull(type);
        this.offsetSeconds = offsetSeconds;
        this.text = text;
        this.notedAt = notedAt;
    }

    /** F-EXP-07 une note convertie garde le lien vers son anomalie. */
    public void attachDefect(Defect defect) {
        this.defect = defect;
    }

    public ExploratorySession getSession() {
        return session;
    }

    public NoteType getType() {
        return type;
    }

    public long getOffsetSeconds() {
        return offsetSeconds;
    }

    public String getText() {
        return text;
    }

    public Instant getNotedAt() {
        return notedAt;
    }

    public Defect getDefect() {
        return defect;
    }

    /** « 12:05 » : minutes et secondes depuis le début (heures au-delà). */
    public String offsetLabel() {
        long h = offsetSeconds / 3600;
        long m = offsetSeconds % 3600 / 60;
        long s = offsetSeconds % 60;
        return h > 0 ? String.format("%d:%02d:%02d", h, m, s) : String.format("%02d:%02d", m, s);
    }
}
