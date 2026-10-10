package com.traceagile.api.demo;

import com.traceagile.application.automation.AutomationRepositories.AutomatedRunRepository;
import com.traceagile.application.automation.ExecutionServerService;
import com.traceagile.application.automation.FlakyService;
import com.traceagile.application.common.KeyGenerator;
import com.traceagile.application.execution.ExecutionRepository;
import com.traceagile.domain.automation.AutomatedRun;
import com.traceagile.domain.automation.ExecutionServer;
import com.traceagile.domain.automation.RunStatus;
import com.traceagile.domain.automation.RunSummary;
import com.traceagile.domain.automation.ServerStatus;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.ExecutionStatus;
import java.time.Instant;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * §15.1 « le simulateur déclaré et connecté » (lot 7, ADR-0020) : serveur « Simulateur » appairé avec
 * un jeton que le simulateur émet à la demande (identifiants de son administrateur, configurés) ; tant
 * qu'il ne répond pas, l'appairage est retenté. Historique : 3 runs sur CMP-2, dont 2 tests instables.
 */
@Component
public class DemoAutomationLoader {

    static final String SERVER_NAME = "Simulateur";
    private static final Logger LOG = LoggerFactory.getLogger(DemoAutomationLoader.class);

    private final ExecutionServerService servers;
    private final AutomatedRunRepository runs;
    private final ExecutionRepository executions;
    private final FlakyService flaky;
    private final KeyGenerator keys;
    private final String simulatorUrl;
    private final String adminUser;
    private final String adminPassword;

    public DemoAutomationLoader(ExecutionServerService servers, AutomatedRunRepository runs, ExecutionRepository executions, FlakyService flaky,
                                KeyGenerator keys, @Value("${traceagile.demo.simulator-url}") String simulatorUrl,
                                @Value("${traceagile.demo.simulator-admin-user}") String adminUser,
                                @Value("${traceagile.demo.simulator-admin-password}") String adminPassword) {
        this.servers = servers;
        this.runs = runs;
        this.executions = executions;
        this.flaky = flaky;
        this.keys = keys;
        this.simulatorUrl = simulatorUrl;
        this.adminUser = adminUser;
        this.adminPassword = adminPassword;
    }

    @Transactional
    public ExecutionServer ensureServer() {
        return servers.list().stream().filter(s -> s.getName().equals(SERVER_NAME)).findFirst()
                .orElseGet(() -> servers.create(SERVER_NAME, simulatorUrl));
    }

    /** ADR-0020 demande un jeton au simulateur s'il n'y en a pas (ou s'il a été refusé). */
    @Transactional
    public void pair() {
        ExecutionServer server = ensureServer();
        if (server.isPaired() && server.getStatus() != ServerStatus.UNAUTHORIZED) {
            return;
        }
        try {
            servers.pairWithCredentials(server.getId(), adminUser, adminPassword);
            LOG.info("Simulateur appairé : jeton émis par {}", simulatorUrl);
        } catch (BusinessRuleException e) {
            LOG.info("Simulateur pas encore appairé ({}) : nouvel essai dans 30 s", e.getMessage());
        }
    }

    /**
     * F-EXE-11 trois runs passés sur les mêmes tests et le même build : les deux premiers échouent au
     * deuxième run seulement, ils sont donc instables ; tous finissent réussis.
     */
    @Transactional
    public void history(Campaign campaign, List<CampaignItem> items, Instant start) {
        ExecutionServer server = ensureServer();
        Instant at = start;
        for (int round = 0; round < 3; round++) {
            AutomatedRun run = runs.save(AutomatedRun.queue(campaign.getProject(), keys.next(campaign.getProject(), "RUN"), campaign, server,
                    "dev", at, 30));
            run.dispatched("demo-job-" + (round + 1), at);
            run.started("sim-agent-1", at.plusSeconds(1));
            int passed = 0;
            for (int i = 0; i < items.size(); i++) {
                boolean fails = round == 1 && i < 2;
                Execution execution = executions.save(Execution.automated(items.get(i), run, at));
                execution.automatedStarted(at.plusSeconds(2 + i * 30L));
                execution.automatedFinished(fails ? ExecutionStatus.FAILED : ExecutionStatus.PASSED, 25_000L,
                        fails ? "AssertionError : délai de réponse dépassé (intermittent)" : null, at.plusSeconds(27 + i * 30L));
                passed += fails ? 0 : 1;
            }
            run.finished(RunStatus.COMPLETED, new RunSummary(items.size(), passed, items.size() - passed, 0, 0), null, null,
                    at.plusSeconds(30L * items.size() + 5));
            at = at.plusSeconds(3_600L * 6);
        }
        items.forEach(item -> flaky.recompute(item.getTestCase()));
    }
}
