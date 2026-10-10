package com.traceagile.domain.automation;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

/** §10.4 événement de webhook déjà traité (clé eventId) : un doublon est ignoré. */
@Entity
@Table(name = "processed_webhook_events")
public class ProcessedWebhookEvent {

    @Id
    @Column(name = "event_id", length = 100)
    private String eventId;

    @Column(name = "run_id", nullable = false)
    private UUID runId;

    @Column(name = "received_at", nullable = false)
    private Instant receivedAt;

    protected ProcessedWebhookEvent() {
    }

    public ProcessedWebhookEvent(String eventId, UUID runId, Instant receivedAt) {
        this.eventId = eventId;
        this.runId = runId;
        this.receivedAt = receivedAt;
    }

    public String getEventId() {
        return eventId;
    }
}
