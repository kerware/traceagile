package com.traceagile.api.automation;

import com.traceagile.api.automation.AutomationDtos.RunArtifactResponse;
import com.traceagile.api.automation.AutomationDtos.RunCounts;
import com.traceagile.api.automation.AutomationDtos.RunDetail;
import com.traceagile.api.automation.AutomationDtos.RunExecutionResponse;
import com.traceagile.api.automation.AutomationDtos.RunSummaryResponse;
import com.traceagile.api.automation.AutomationDtos.ServerChoice;
import com.traceagile.api.automation.AutomationDtos.ServerResponse;
import com.traceagile.api.campaign.CampaignMapper;
import com.traceagile.domain.automation.AutomatedRun;
import com.traceagile.domain.automation.ExecutionServer;
import com.traceagile.domain.automation.RunArtifact;
import com.traceagile.domain.automation.ServerStatus;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.ExecutionStatus;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.stereotype.Component;

/** Correspondance domaine → DTO de l'exécution automatisée. */
@Component
public class AutomationMapper {

    private final CampaignMapper campaigns;

    public AutomationMapper(CampaignMapper campaigns) {
        this.campaigns = campaigns;
    }

    ServerResponse server(ExecutionServer s) {
        return new ServerResponse(s.getId(), s.getName(), s.getBaseUrl(), s.getAuthType(), s.isPaired(), s.getTokenHint(), s.getTokenId(),
                s.getPairedAt(), s.getStatus(), s.getLastHeartbeat(), s.getLastError(), s.getServerVersion(), s.getTechniques(), s.getFrameworks(),
                s.getEnvironments(), s.getAgents(), s.isEnabled());
    }

    ServerChoice choice(ExecutionServer s) {
        boolean usable = s.isEnabled() && s.isPaired() && s.getStatus() != ServerStatus.UNAUTHORIZED;
        return new ServerChoice(s.getId(), s.getName(), s.getStatus(), s.getTechniques(), usable);
    }

    RunSummaryResponse summary(AutomatedRun run, List<Execution> executions) {
        return new RunSummaryResponse(run.getKey(), run.getStatus(), campaigns.ref(run.getCampaign()), run.getServer().getName(), run.getRequestedBy(),
                run.getRequestedAt(), run.getStartedAt(), run.getEndedAt(), run.getEnvironment(), run.getBuildVersion(), run.getAgent(),
                run.getExternalJobId(), run.getRerunOf(), run.getErrorCode(), run.getErrorMessage(), run.getReportUrl(), run.getTimeoutMinutes(),
                counts(executions));
    }

    RunDetail detail(AutomatedRun run, List<Execution> executions, Map<UUID, String> screenshots) {
        return new RunDetail(summary(run, executions), executions.stream().map(e -> execution(e, screenshots.get(e.getId()))).toList(), !run.isFinal());
    }

    RunArtifactResponse artifact(RunArtifact a) {
        return new RunArtifactResponse(a.getName(), a.getContentType(), a.getKind(), a.getSize(),
                a.getExecution() == null ? null : a.getExecution().getTestCase().getKey());
    }

    RunExecutionResponse execution(Execution e, String screenshot) {
        return new RunExecutionResponse(e.getId(), e.getItem().getId(), campaigns.test(e.getTestCase()), e.getTestCase().getAutomation().getTechnique(),
                e.getTestCase().getAutomation().getTestIdentifier(), e.getStatus(), e.getStartedAt(), e.getEndedAt(), e.getDurationMs(), e.getComment(),
                e.getTestCase().isFlaky(), screenshot);
    }

    static RunCounts counts(List<Execution> executions) {
        return new RunCounts(executions.size(), count(executions, ExecutionStatus.NOT_RUN), count(executions, ExecutionStatus.RUNNING),
                count(executions, ExecutionStatus.PASSED), count(executions, ExecutionStatus.FAILED), count(executions, ExecutionStatus.ERROR),
                count(executions, ExecutionStatus.SKIPPED) + count(executions, ExecutionStatus.BLOCKED));
    }

    private static int count(List<Execution> executions, ExecutionStatus status) {
        return (int) executions.stream().filter(e -> e.getStatus() == status).count();
    }
}
