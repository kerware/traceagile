package com.traceagile.application.automation;

import com.traceagile.domain.automation.AutomatedRun;
import com.traceagile.domain.automation.ExecutionServer;
import com.traceagile.domain.automation.ProcessedWebhookEvent;
import com.traceagile.domain.automation.RunArtifact;
import com.traceagile.domain.automation.RunStatus;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** Ports de persistance de l'exécution automatisée (§8.5, §10). */
public final class AutomationRepositories {

    private AutomationRepositories() {
    }

    public interface ExecutionServerRepository {

        List<ExecutionServer> findAllByOrderByNameAsc();

        Optional<ExecutionServer> findById(UUID id);

        boolean existsByNameIgnoreCase(String name);

        ExecutionServer save(ExecutionServer server);

        void delete(ExecutionServer server);
    }

    public interface AutomatedRunRepository {

        Optional<AutomatedRun> findByProject_KeyAndKey(String projectKey, String key);

        List<AutomatedRun> findByKey(String key);

        List<AutomatedRun> findByCampaign_IdOrderByKeyNumberDesc(UUID campaignId);

        List<AutomatedRun> findByProject_KeyOrderByKeyNumberDesc(String projectKey);

        List<AutomatedRun> findByStatusIn(Collection<RunStatus> statuses);

        boolean existsByServer_Id(UUID serverId);

        AutomatedRun save(AutomatedRun run);
    }

    public interface RunArtifactRepository {

        List<RunArtifact> findByRun_Id(UUID runId);

        Optional<RunArtifact> findByRun_IdAndName(UUID runId, String name);

        RunArtifact save(RunArtifact artifact);
    }

    public interface ProcessedWebhookEventRepository {

        boolean existsById(String eventId);

        ProcessedWebhookEvent save(ProcessedWebhookEvent event);
    }
}
