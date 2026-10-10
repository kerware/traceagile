package com.traceagile.infrastructure.persistence;

import com.traceagile.application.automation.AutomationRepositories.ProcessedWebhookEventRepository;
import com.traceagile.domain.automation.ProcessedWebhookEvent;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link ProcessedWebhookEventRepository}. */
public interface JpaProcessedWebhookEventRepository extends JpaRepository<ProcessedWebhookEvent, String>, ProcessedWebhookEventRepository {
}
