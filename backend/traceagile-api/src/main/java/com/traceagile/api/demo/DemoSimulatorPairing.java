package com.traceagile.api.demo;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Profile;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/** §15.1 profil demo : appaire le simulateur, et le serveur d'exécution réel s'il est configuré, dès qu'ils répondent. */
@Component
@Profile("demo")
@ConditionalOnProperty(name = "traceagile.automation.scheduler-enabled", havingValue = "true", matchIfMissing = true)
public class DemoSimulatorPairing {

    private final DemoAutomationLoader automation;

    public DemoSimulatorPairing(DemoAutomationLoader automation) {
        this.automation = automation;
    }

    @Scheduled(initialDelayString = "PT5S", fixedDelayString = "PT30S")
    public void pair() {
        automation.pair();
        automation.pairExecutionServer();
    }
}
