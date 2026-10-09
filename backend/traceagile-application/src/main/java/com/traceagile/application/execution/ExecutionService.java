package com.traceagile.application.execution;

import com.traceagile.application.campaign.CampaignItemRepository;
import com.traceagile.application.campaign.CampaignService;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.campaign.CampaignStatus;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.defect.DefectDraft;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.ExecutionOrigin;
import com.traceagile.domain.execution.ExecutionStatus;
import java.time.Clock;
import java.time.Instant;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §8.4 exécution manuelle : « Mes tests à exécuter » (F-EXE-01), saisie pas à pas et statut
 * (F-EXE-01, F-EXE-02), anomalie pré-remplie (F-EXE-03), tentatives (F-EXE-04). Résultats
 * enregistrés sans pas pour les tests automatisés (démonstration, lot 7).
 */
@Service
@Transactional
public class ExecutionService {

    static final Set<CampaignStatus> OPEN = EnumSet.of(CampaignStatus.PLANNED, CampaignStatus.IN_PROGRESS);

    private final ExecutionRepository executions;
    private final CampaignItemRepository items;
    private final CampaignService campaigns;
    private final Clock clock;

    public ExecutionService(ExecutionRepository executions, CampaignItemRepository items, CampaignService campaigns, Clock clock) {
        this.executions = executions;
        this.items = items;
        this.campaigns = campaigns;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public Execution get(String projectKey, UUID id) {
        return executions.findById(id).filter(e -> e.getTestCase().getProject().getKey().equals(projectKey))
                .orElseThrow(() -> new NotFoundException("EXECUTION_NOT_FOUND", "Exécution introuvable."));
    }

    /** F-EXE-01 tests affectés au testeur dans les campagnes ouvertes, filtrés par statut de la dernière tentative. */
    @Transactional(readOnly = true)
    public List<CampaignItem> myItems(String projectKey, String login, Set<ExecutionStatus> statuses) {
        return items.findByCampaign_Project_KeyAndAssignee_LoginAndCampaign_StatusInOrderByCampaign_KeyNumberAscPositionAsc(projectKey, login, OPEN)
                .stream().filter(i -> statuses == null || statuses.isEmpty() || statuses.contains(i.lastStatus())).toList();
    }

    /** F-EXE-01 / F-EXE-04 nouvelle tentative d'un test manuel (jeu de données facultatif, ADR-0013). */
    public Execution start(String projectKey, UUID itemId, String login, String dataSetName, Integer row) {
        CampaignItem item = campaigns.item(projectKey, itemId);
        Execution latest = item.latest();
        if (latest != null && latest.getStatus() == ExecutionStatus.RUNNING) {
            throw new BusinessRuleException("EXECUTION_IN_PROGRESS",
                    "La tentative " + latest.getAttempt() + " est en cours : terminez-la avant d'en commencer une autre.");
        }
        return executions.save(Execution.manual(item, login, clock.instant(), dataSetName, row));
    }

    /** F-EXE-01 saisie d'un pas de la dernière tentative. */
    public Execution recordStep(String projectKey, UUID id, int position, ExecutionStatus status, String actualResult) {
        Execution execution = editable(projectKey, id);
        execution.recordStep(position, status, actualResult, clock.instant());
        return execution;
    }

    /** F-EXE-02 statut forcé avec commentaire. */
    public Execution override(String projectKey, UUID id, ExecutionStatus status, String comment) {
        Execution execution = editable(projectKey, id);
        execution.override(status, comment, clock.instant());
        return execution;
    }

    /** Résultat sans pas : test automatisé (lot 7, import, démonstration) ou charte (lot 6). */
    public Execution record(CampaignItem item, ExecutionOrigin origin, ExecutionStatus status, String executedBy, Instant startedAt,
                            Instant endedAt, String comment) {
        return executions.save(Execution.recorded(item, origin, status, executedBy, startedAt, endedAt, comment));
    }

    @Transactional(readOnly = true)
    public DefectDraft defectDraft(String projectKey, UUID id) {
        return DefectDraft.from(get(projectKey, id));
    }

    /** Seule la dernière tentative d'une campagne ouverte se modifie ; les précédentes sont l'historique. */
    private Execution editable(String projectKey, UUID id) {
        Execution execution = get(projectKey, id);
        CampaignItem item = execution.getItem();
        if (item.getCampaign().getStatus().isClosed()) {
            throw new BusinessRuleException("CAMPAIGN_CLOSED", "La campagne " + item.getCampaign().getKey() + " est terminée : l'exécution est en lecture seule.");
        }
        if (item.latest() != null && !item.latest().getId().equals(execution.getId())) {
            throw new BusinessRuleException("EXECUTION_NOT_LATEST", "Seule la dernière tentative se modifie ; les précédentes sont conservées telles quelles.");
        }
        return execution;
    }
}
