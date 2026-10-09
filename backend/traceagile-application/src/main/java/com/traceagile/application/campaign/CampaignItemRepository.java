package com.traceagile.application.campaign;

import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.campaign.CampaignStatus;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** Port de lecture des tests de campagne (affectations, « Mes exécutions »). */
public interface CampaignItemRepository {

    Optional<CampaignItem> findById(UUID id);

    /** F-EXE-01 tests affectés à un testeur dans les campagnes ouvertes du projet. */
    List<CampaignItem> findByCampaign_Project_KeyAndAssignee_LoginAndCampaign_StatusInOrderByCampaign_KeyNumberAscPositionAsc(
            String projectKey, String login, Collection<CampaignStatus> statuses);

    boolean existsByTestCase_Id(UUID testCaseId);
}
