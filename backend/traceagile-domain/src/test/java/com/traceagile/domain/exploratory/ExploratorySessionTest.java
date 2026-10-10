package com.traceagile.domain.exploratory;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

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
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/** §5.2 sessions exploratoires (F-EXP-05 à F-EXP-10), §5.3 débriefing PROOF (F-EXP-11 à F-EXP-13). */
class ExploratorySessionTest {

    final Project shop = new Project("SHOP", "Boutique", null);
    final Instant t0 = Instant.parse("2026-10-12T09:00:00Z");

    CampaignItem item() {
        TestCase charter = TestCase.exploratory(shop, "TC-21", "Explorer la recherche");
        charter.getCharter().setMission("la recherche", "des saisies inhabituelles", "les erreurs mal gérées");
        charter.getCharter().setAreas(List.of("Recherche", "Filtres"));
        charter.getCharter().setTimeboxMin(60);
        charter.changeStatus(TestCaseStatus.READY);
        Campaign campaign = new Campaign(shop, "CMP-1", "Recette", CampaignScope.REGRESSION, null, null, "recette", "2.0", null, null);
        return campaign.add(charter, 1);
    }

    ExploratorySession started() {
        return ExploratorySession.start(item(), "qa1", t0);
    }

    @Test
    @DisplayName("F-EXP-05 démarrer une session : tentative en cours, chronomètre lancé, durée cible de la charte")
    void start() {
        ExploratorySession session = started();
        assertThat(session.getState()).isEqualTo(SessionState.RUNNING);
        assertThat(session.getExecution().getStatus()).isEqualTo(ExecutionStatus.RUNNING);
        assertThat(session.getExecution().getAttempt()).isEqualTo(1);
        assertThat(session.getTester()).isEqualTo("qa1");
        assertThat(session.getTimeboxMin()).isEqualTo(60);
        assertThat(session.getExecution().getItem().getCampaign().getStatus()).hasToString("IN_PROGRESS");
    }

    @Test
    @DisplayName("F-EXP-05 seule une charte se joue en session ; pas deux sessions en cours sur le même élément")
    void startRules() {
        TestCase manual = TestCase.manual(shop, "TC-1", "Manuel");
        manual.addStep("Ouvrir", "OK", null);
        Campaign campaign = new Campaign(shop, "CMP-1", "Recette", CampaignScope.REGRESSION, null, null, null, null, null, null);
        CampaignItem manualItem = campaign.add(manual, 1);
        assertThatThrownBy(() -> ExploratorySession.start(manualItem, "qa1", t0)).hasFieldOrPropertyWithValue("code", "SESSION_NOT_A_CHARTER");

        ExploratorySession session = started();
        assertThatThrownBy(() -> ExploratorySession.start(session.getExecution().getItem(), "qa1", t0))
                .hasFieldOrPropertyWithValue("code", "EXECUTION_IN_PROGRESS");
    }

    @Test
    @DisplayName("F-EXP-05 chronomètre : la pause ne compte pas ; F-EXP-06 notes horodatées relativement au début (temps actif)")
    void timerAndNotes() {
        ExploratorySession session = started();
        SessionNote first = session.addNote(NoteType.NOTE, "Recherche vide : message clair", t0.plusSeconds(90));
        session.pause(t0.plusSeconds(600));
        session.pause(t0.plusSeconds(700)); // idempotent
        assertThat(session.elapsedSeconds(t0.plusSeconds(1_800))).isEqualTo(600);
        SessionNote paused = session.addNote(NoteType.IDEA, "Tester les emojis", t0.plusSeconds(1_200));
        session.resume(t0.plusSeconds(1_800));
        SessionNote bug = session.addNote(NoteType.BUG, "Les guillemets cassent la page de résultats", t0.plusSeconds(2_100));

        assertThat(first.getOffsetSeconds()).isEqualTo(90);
        assertThat(paused.getOffsetSeconds()).isEqualTo(600);
        assertThat(bug.getOffsetSeconds()).isEqualTo(900);
        assertThat(session.getNotes()).extracting(SessionNote::getType).containsExactly(NoteType.NOTE, NoteType.IDEA, NoteType.BUG);
        assertThatThrownBy(() -> session.addNote(NoteType.NOTE, "  ", t0)).hasFieldOrPropertyWithValue("code", "SESSION_NOTE_REQUIRED");
    }

    @ParameterizedTest(name = "TBS {0}/{1}/{2} → {3}")
    @CsvSource({
            "60, 30, 10, ",
            "50, 30, 10, SESSION_TBS_INVALID",
            "110, -10, 0, SESSION_TBS_INVALID",
    })
    @DisplayName("F-EXP-09 la répartition TBS totalise 100")
    void tbs(int test, int bug, int setup, String error) {
        ExploratorySession session = started();
        Runnable finish = () -> session.finish(new Tbs(test, bug, setup), List.of("Recherche"), ExecutionStatus.PASSED, t0.plusSeconds(3_600));
        if (error == null) {
            finish.run();
            assertThat(session.getTbs()).isEqualTo(new Tbs(test, bug, setup));
        } else {
            assertThatThrownBy(finish::run).hasFieldOrPropertyWithValue("code", error);
        }
    }

    @Test
    @DisplayName("F-EXP-09 fin de session : statut PASSED / FAILED / BLOCKED de la tentative, durée active, zones couvertes")
    void finish() {
        ExploratorySession session = started();
        session.pause(t0.plusSeconds(1_800));
        session.resume(t0.plusSeconds(2_400));
        assertThatThrownBy(() -> session.finish(new Tbs(70, 20, 10), List.of(), ExecutionStatus.SKIPPED, t0.plusSeconds(4_200)))
                .hasFieldOrPropertyWithValue("code", "SESSION_STATUS_INVALID");
        session.finish(new Tbs(70, 20, 10), List.of(" Recherche ", "recherche", "Tri"), ExecutionStatus.FAILED, t0.plusSeconds(4_200));

        assertThat(session.getState()).isEqualTo(SessionState.FINISHED);
        assertThat(session.getDurationMin()).isEqualTo(60);
        assertThat(session.getAreasCovered()).containsExactly("Recherche", "Tri");
        assertThat(session.getExecution().getStatus()).isEqualTo(ExecutionStatus.FAILED);
        assertThat(session.getExecution().getDurationMs()).isEqualTo(3_600_000L);
        assertThat(session.getExecution().getEndedAt()).isEqualTo(t0.plusSeconds(4_200));
        assertThatThrownBy(() -> session.addNote(NoteType.NOTE, "après coup", t0.plusSeconds(5_000)))
                .hasFieldOrPropertyWithValue("code", "SESSION_CLOSED");
        assertThatThrownBy(() -> session.pause(t0.plusSeconds(5_000))).hasFieldOrPropertyWithValue("code", "SESSION_CLOSED");
    }

    @Test
    @DisplayName("F-EXP-11 / F-EXP-13 débriefing PROOF après la fin, approuvé par un autre utilisateur ; la session passe « débriefée »")
    void debrief() {
        ExploratorySession session = started();
        Proof proof = new Proof("Recherche et filtres parcourus", "1 bogue sur les guillemets", "Jeu de données pauvre",
                "Explorer le tri\nExplorer la pagination", 4);
        assertThatThrownBy(() -> session.debrief(proof, "qa1", t0)).hasFieldOrPropertyWithValue("code", "SESSION_NOT_FINISHED");
        session.finish(new Tbs(60, 30, 10), List.of("Recherche"), ExecutionStatus.PASSED, t0.plusSeconds(3_000));
        assertThatThrownBy(() -> session.approve("po", t0)).hasFieldOrPropertyWithValue("code", "SESSION_DEBRIEF_MISSING");
        assertThatThrownBy(() -> session.debrief(new Proof("x", "y", null, null, 6), "qa1", t0))
                .hasFieldOrPropertyWithValue("code", "SESSION_FEELINGS_INVALID");
        assertThatThrownBy(() -> session.debrief(new Proof(" ", "y", null, null, 3), "qa1", t0))
                .hasFieldOrPropertyWithValue("code", "SESSION_DEBRIEF_INCOMPLETE");

        session.debrief(proof, "qa1", t0.plusSeconds(3_100));
        assertThat(session.getProof()).isEqualTo(proof);
        assertThat(session.getProof().outlookItems()).containsExactly("Explorer le tri", "Explorer la pagination");
        assertThatThrownBy(() -> session.approve("qa1", t0.plusSeconds(3_200))).hasFieldOrPropertyWithValue("code", "SESSION_SELF_APPROVAL");
        session.approve("po", t0.plusSeconds(3_300));

        assertThat(session.getState()).isEqualTo(SessionState.DEBRIEFED);
        assertThat(session.getApprovedBy()).isEqualTo("po");
        assertThatThrownBy(() -> session.debrief(proof, "qa1", t0)).hasFieldOrPropertyWithValue("code", "SESSION_CLOSED");
    }

    @Test
    @DisplayName("F-EXP-10 brouillon de note sauvegardé, puis effacé quand la note est ajoutée")
    void draft() {
        ExploratorySession session = started();
        session.saveDraft("Le filtre prix ");
        assertThat(session.getDraft()).isEqualTo("Le filtre prix ");
        session.addNote(NoteType.ISSUE, "Le filtre prix ignore les centimes", t0.plusSeconds(60));
        assertThat(session.getDraft()).isNull();
    }
}
