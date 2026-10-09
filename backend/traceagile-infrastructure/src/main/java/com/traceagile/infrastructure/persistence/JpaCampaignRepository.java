package com.traceagile.infrastructure.persistence;

import com.traceagile.application.campaign.CampaignRepository;
import com.traceagile.domain.campaign.Campaign;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link CampaignRepository}. */
public interface JpaCampaignRepository extends JpaRepository<Campaign, UUID>, CampaignRepository {
}
