package com.traceagile.application.campaign;

import com.traceagile.domain.campaign.CampaignFolder;
import java.util.List;

/** Port de persistance des dossiers de campagnes explicites (ADR-0018). */
public interface CampaignFolderRepository {

    List<CampaignFolder> findByProject_KeyOrderByPathAsc(String projectKey);

    CampaignFolder save(CampaignFolder folder);

    void delete(CampaignFolder folder);
}
