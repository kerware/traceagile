package com.traceagile.application.campaign;

import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignStatus;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

/** Port de persistance des campagnes (§8.3). */
public interface CampaignRepository {

    List<Campaign> findByProject_KeyOrderByKeyNumberDesc(String projectKey);

    List<Campaign> findByProject_KeyAndStatusIn(String projectKey, Collection<CampaignStatus> statuses);

    Optional<Campaign> findByProject_KeyAndKey(String projectKey, String key);

    boolean existsByProject_Key(String projectKey);

    Campaign save(Campaign campaign);

    /** Persiste les tests ajoutés (identifiants attribués) avant de les renvoyer. */
    void flush();
}
