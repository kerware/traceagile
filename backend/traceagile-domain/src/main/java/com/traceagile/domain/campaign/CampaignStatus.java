package com.traceagile.domain.campaign;

/** §3.2 CampaignStatus : PLANNED → IN_PROGRESS → COMPLETED, ou ABORTED. */
public enum CampaignStatus {
    PLANNED,
    IN_PROGRESS,
    COMPLETED,
    ABORTED;

    public boolean isClosed() {
        return this == COMPLETED || this == ABORTED;
    }
}
