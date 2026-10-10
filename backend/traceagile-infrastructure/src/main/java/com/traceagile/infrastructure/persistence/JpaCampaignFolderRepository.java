package com.traceagile.infrastructure.persistence;

import com.traceagile.application.campaign.CampaignFolderRepository;
import com.traceagile.domain.campaign.CampaignFolder;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link CampaignFolderRepository}. */
public interface JpaCampaignFolderRepository extends JpaRepository<CampaignFolder, UUID>, CampaignFolderRepository {
}
