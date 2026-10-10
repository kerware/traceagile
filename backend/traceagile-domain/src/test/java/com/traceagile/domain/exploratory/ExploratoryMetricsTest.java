package com.traceagile.domain.exploratory;

import static org.assertj.core.api.Assertions.assertThat;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.campaign.CampaignScope;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** §5.4 métriques exploratoires. */
class ExploratoryMetricsTest {

    final Project shop = new Project("SHOP", "Boutique", null);
    final Instant t0 = Instant.parse("2026-10-12T09:00:00Z");
    final Campaign campaign = new Campaign(shop, "CMP-1", "Recette", CampaignScope.REGRESSION, null, null, null, null, null, null);

    CampaignItem charter(String key, int timebox, List<String> areas) {
        TestCase test = TestCase.exploratory(shop, key, "Charte " + key);
        test.getCharter().setMission("x", "y", "z");
        test.getCharter().setTimeboxMin(timebox);
        test.getCharter().setAreas(areas);
        test.changeStatus(TestCaseStatus.READY);
        return campaign.add(test, 1);
    }

    ExploratorySession session(CampaignItem item, int minutes, Tbs tbs, List<String> covered, Integer feelings) {
        ExploratorySession session = ExploratorySession.start(item, "qa1", t0);
        session.finish(tbs, covered, ExecutionStatus.PASSED, t0.plusSeconds(minutes * 60L));
        if (feelings != null) {
            session.debrief(new Proof("p", "r", null, null, feelings), "qa1", t0);
        }
        return session;
    }

    @Test
    @DisplayName("§5.4 sessions, durées par rapport à la cible, TBS moyen, anomalies par heure, chartes planifiées / exécutées, confiance, zones jamais explorées")
    void metrics() {
        CampaignItem search = charter("TC-21", 60, List.of("Recherche", "Filtres", "Tri"));
        CampaignItem cart = charter("TC-22", 120, List.of("Panier"));
        charter("TC-23", 90, List.of("Paiement"));
        ExploratorySession first = session(search, 45, new Tbs(60, 30, 10), List.of("recherche", "Filtres"), 4);
        ExploratorySession second = session(cart, 135, new Tbs(80, 10, 10), List.of("Panier"), 2);
        ExploratorySession running = ExploratorySession.start(charter("TC-24", 60, List.of("Compte")), "qa2", t0);

        ExploratoryMetrics metrics = ExploratoryMetrics.of(List.of(first, second, running),
                List.of(search, cart, campaign.getItems().get(2), running.getExecution().getItem()), 3);

        assertThat(metrics.sessions()).isEqualTo(2);
        assertThat(metrics.inProgress()).isEqualTo(1);
        assertThat(metrics.totalMinutes()).isEqualTo(180);
        assertThat(metrics.averageMinutes()).isEqualTo(90.0);
        assertThat(metrics.averageTimeboxMin()).isEqualTo(90.0);
        assertThat(metrics.durationVsTargetPct()).isEqualTo(100.0);
        assertThat(metrics.averageTbs()).isEqualTo(new ExploratoryMetrics.TbsAverage(70.0, 20.0, 10.0));
        assertThat(metrics.defectsPerHour()).isEqualTo(1.0);
        assertThat(metrics.chartersPlanned()).isEqualTo(4);
        assertThat(metrics.chartersExecuted()).isEqualTo(2);
        assertThat(metrics.averageConfidence()).isEqualTo(3.0);
        assertThat(metrics.neverExploredAreas()).containsExactly("Compte", "Paiement", "Tri");
        assertThat(metrics.awaitingApproval()).isEqualTo(2);
        assertThat(metrics.debriefed()).isZero();
    }

    @Test
    @DisplayName("§5.4 sans session : valeurs absentes plutôt que zéro trompeur")
    void empty() {
        ExploratoryMetrics metrics = ExploratoryMetrics.of(List.of(), List.of(), 0);
        assertThat(metrics.sessions()).isZero();
        assertThat(metrics.averageMinutes()).isNull();
        assertThat(metrics.averageTbs()).isNull();
        assertThat(metrics.defectsPerHour()).isNull();
        assertThat(metrics.averageConfidence()).isNull();
    }
}
