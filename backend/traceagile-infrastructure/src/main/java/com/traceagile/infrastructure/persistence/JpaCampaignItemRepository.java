package com.traceagile.infrastructure.persistence;

import com.traceagile.application.campaign.CampaignItemRepository;
import com.traceagile.domain.campaign.CampaignItem;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link CampaignItemRepository}. */
public interface JpaCampaignItemRepository extends JpaRepository<CampaignItem, UUID>, CampaignItemRepository {
}
