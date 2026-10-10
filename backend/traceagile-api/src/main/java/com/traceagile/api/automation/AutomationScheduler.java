package com.traceagile.api.automation;

import com.traceagile.application.automation.AutomatedRunService;
import com.traceagile.application.automation.ExecutionServerService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

/** §10.2 heartbeat des serveurs (60 s) ; §10.4 contrôle des runs sans nouvelles (chaque minute). */
@Configuration
@EnableScheduling
@ConditionalOnProperty(name = "traceagile.automation.scheduler-enabled", havingValue = "true", matchIfMissing = true)
public class AutomationScheduler {

    private static final Logger LOG = LoggerFactory.getLogger(AutomationScheduler.class);

    private final ExecutionServerService servers;
    private final AutomatedRunService runs;

    public AutomationScheduler(ExecutionServerService servers, AutomatedRunService runs) {
        this.servers = servers;
        this.runs = runs;
    }

    @Scheduled(initialDelayString = "PT20S", fixedDelayString = "PT60S")
    public void heartbeat() {
        try {
            servers.heartbeat();
        } catch (RuntimeException e) {
            LOG.warn("Heartbeat des serveurs d'exécution en échec : {}", e.getMessage());
        }
    }

    @Scheduled(initialDelayString = "PT30S", fixedDelayString = "PT60S")
    public void timeouts() {
        try {
            runs.checkTimeouts();
        } catch (RuntimeException e) {
            LOG.warn("Contrôle des timeouts en échec : {}", e.getMessage());
        }
    }
}
