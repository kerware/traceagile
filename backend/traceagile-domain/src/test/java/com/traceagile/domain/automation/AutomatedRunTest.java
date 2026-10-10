package com.traceagile.domain.automation;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.campaign.CampaignScope;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.ExecutionOrigin;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestTechnique;
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** §8.5 runs automatisés (F-EXE-06 à F-EXE-09), §10.4 règles des webhooks (timeout). */
class AutomatedRunTest {

    final Project shop = new Project("SHOP", "Boutique", null);
    final Instant t0 = Instant.parse("2026-10-12T09:00:00Z");
    final Campaign campaign = new Campaign(shop, "CMP-1", "Régression", CampaignScope.REGRESSION, null, null, "recette", "2.0.0", null, null);
    final ExecutionServer server = new ExecutionServer("Simulateur", "http://simulateur:8090");

    CampaignItem automated(String key) {
        TestCase test = TestCase.automated(shop, key, "API " + key, TestTechnique.API, "REST Assured");
        test.getAutomation().setLocation("https://git/shop.git", "main", "src/test/java", "CartApiTest#" + key);
        return campaign.add(test, 1);
    }

    AutomatedRun run() {
        server.pair("chiffré", "secret chiffré", "tok-1", "abcd", t0);
        server.reportCapabilities("0.2.0", List.of(TestTechnique.API, TestTechnique.BDD), List.of("rest-assured"), List.of("recette"), 2, t0);
        return AutomatedRun.queue(shop, "RUN-1", campaign, server, "dev", t0, 30);
    }

    @Test
    @DisplayName("F-EXE-06 un run est créé QUEUED avec l'environnement et le build de la campagne ; ses tentatives sont en attente")
    void queue() {
        AutomatedRun run = run();
        Execution execution = Execution.automated(automated("TC-30"), run, t0);
        assertThat(run.getStatus()).isEqualTo(RunStatus.QUEUED);
        assertThat(run.getEnvironment()).isEqualTo("recette");
        assertThat(run.getBuildVersion()).isEqualTo("2.0.0");
        assertThat(execution.getStatus()).isEqualTo(ExecutionStatus.NOT_RUN);
        assertThat(execution.getOrigin()).isEqualTo(ExecutionOrigin.AUTOMATED);
        assertThat(execution.getRun()).isSameAs(run);
        assertThat(execution.getExecutedBy()).isEqualTo("Simulateur");
        assertThat(campaign.getStatus()).hasToString("IN_PROGRESS");
    }

    @Test
    @DisplayName("F-EXE-06 seuls les tests automatisés partent sur un serveur ; un serveur doit savoir exécuter leurs techniques")
    void rules() {
        TestCase manual = TestCase.manual(shop, "TC-1", "Manuel");
        manual.addStep("Ouvrir", "OK", null);
        CampaignItem manualItem = campaign.add(manual, 1);
        assertThatThrownBy(() -> Execution.automated(manualItem, run(), t0)).hasFieldOrPropertyWithValue("code", "RUN_TEST_NOT_AUTOMATED");
        assertThat(server.supports(TestTechnique.API)).isTrue();
        assertThat(server.supports(TestTechnique.PERFORMANCE)).isFalse();
    }

    @Test
    @DisplayName("§10.4 cycle de vie : DISPATCHED (jobId), RUNNING, résultats par test, COMPLETED avec synthèse")
    void lifecycle() {
        AutomatedRun run = run();
        Execution a = Execution.automated(automated("TC-30"), run, t0);
        Execution b = Execution.automated(automated("TC-31"), run, t0);
        run.dispatched("job-42", t0.plusSeconds(1));
        assertThat(run.getStatus()).isEqualTo(RunStatus.DISPATCHED);
        assertThat(run.getExternalJobId()).isEqualTo("job-42");
        run.started("agent-1", t0.plusSeconds(2));
        a.automatedStarted(t0.plusSeconds(3));
        assertThat(a.getStatus()).isEqualTo(ExecutionStatus.RUNNING);
        a.automatedFinished(ExecutionStatus.PASSED, 1_200L, null, t0.plusSeconds(5));
        b.automatedFinished(ExecutionStatus.FAILED, 800L, "AssertionError : 404", t0.plusSeconds(6));
        assertThat(b.getDurationMs()).isEqualTo(800L);
        assertThat(b.getComment()).isEqualTo("AssertionError : 404");
        assertThatThrownBy(() -> b.automatedFinished(ExecutionStatus.RUNNING, 1L, null, t0)).hasFieldOrPropertyWithValue("code", "EXECUTION_STATUS_INVALID");
        run.finished(RunStatus.COMPLETED, new RunSummary(2, 1, 1, 0, 0), "http://sim/report", "http://sim/logs", t0.plusSeconds(7));

        assertThat(run.getStatus()).isEqualTo(RunStatus.COMPLETED);
        assertThat(run.getSummary()).isEqualTo(new RunSummary(2, 1, 1, 0, 0));
        assertThat(run.getEndedAt()).isEqualTo(t0.plusSeconds(7));
        assertThat(run.isFinal()).isTrue();
        assertThatThrownBy(() -> run.cancel(t0.plusSeconds(8))).hasFieldOrPropertyWithValue("code", "RUN_FINISHED");
    }

    @Test
    @DisplayName("F-EXE-08 annulation ; §10.4 TIMEOUT si aucun événement au-delà de timeoutMinutes + 5 min ; les tentatives non terminées sont closes")
    void cancelAndTimeout() {
        AutomatedRun cancelled = run();
        Execution pending = Execution.automated(automated("TC-30"), cancelled, t0);
        cancelled.cancel(t0.plusSeconds(10));
        pending.abandon(ExecutionStatus.SKIPPED, "Run annulé", t0.plusSeconds(10));
        assertThat(cancelled.getStatus()).isEqualTo(RunStatus.CANCELLED);
        assertThat(pending.getStatus()).isEqualTo(ExecutionStatus.SKIPPED);

        AutomatedRun slow = AutomatedRun.queue(shop, "RUN-2", campaign, server, "dev", t0, 30);
        slow.dispatched("job-43", t0);
        slow.touch(t0.plusSeconds(600));
        assertThat(slow.isOverdue(t0.plusSeconds(600 + 35 * 60 - 1))).isFalse();
        assertThat(slow.isOverdue(t0.plusSeconds(600 + 35 * 60 + 1))).isTrue();
        slow.timeout(t0.plusSeconds(3_000));
        assertThat(slow.getStatus()).isEqualTo(RunStatus.TIMEOUT);
        assertThat(slow.isOverdue(t0.plusSeconds(99_999))).isFalse();
    }

    @Test
    @DisplayName("§10.4 JOB_ERROR : run en échec avec code et message")
    void error() {
        AutomatedRun run = run();
        run.failed("REPOSITORY_UNREACHABLE", "Dépôt inaccessible", t0.plusSeconds(5));
        assertThat(run.getStatus()).isEqualTo(RunStatus.FAILED);
        assertThat(run.getErrorCode()).isEqualTo("REPOSITORY_UNREACHABLE");
        assertThat(run.getErrorMessage()).isEqualTo("Dépôt inaccessible");
    }
}
