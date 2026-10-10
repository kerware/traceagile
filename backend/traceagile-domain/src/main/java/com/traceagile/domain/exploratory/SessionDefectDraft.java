package com.traceagile.domain.exploratory;

import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.defect.DefectDraft;
import com.traceagile.domain.defect.DefectSeverity;
import com.traceagile.domain.testcase.TestCase;

/**
 * F-EXP-07 anomalie pré-remplie depuis une note {@code BUG} : charte, mission, campagne,
 * environnement, build, moment de la session et constat. Sévérité proposée : MAJOR (ADR-0016).
 */
public final class SessionDefectDraft {

    private static final int TITLE_MAX = 200;

    private SessionDefectDraft() {
    }

    public static DefectDraft from(ExploratorySession session, SessionNote note) {
        TestCase charter = session.getCharter();
        Campaign campaign = session.getExecution().getItem().getCampaign();
        String constat = note.getText().lines().findFirst().orElse(note.getText()).strip();
        String title = charter.getKey() + " " + charter.getTitle() + " : " + constat;
        if (title.length() > TITLE_MAX) {
            title = title.substring(0, TITLE_MAX - 1) + "…";
        }
        StringBuilder d = new StringBuilder();
        d.append("**Charte** : ").append(charter.getKey()).append(" ").append(charter.getTitle()).append("\n");
        d.append("**Mission** : ").append(charter.getCharter().missionSentence()).append("\n");
        d.append("**Session** : tentative ").append(session.getExecution().getAttempt()).append(" de ").append(session.getTester())
                .append(", constat à ").append(note.offsetLabel()).append("\n");
        d.append("**Campagne** : ").append(campaign.getKey()).append(" ").append(campaign.getName()).append("\n");
        d.append("**Environnement** : ").append(orDash(campaign.getEnvironment()))
                .append(" · **Build** : ").append(orDash(campaign.getBuildVersion())).append("\n");
        d.append("\n**Constat**\n\n").append(note.getText()).append("\n");
        return new DefectDraft(title, d.toString(), DefectSeverity.MAJOR);
    }

    private static String orDash(String text) {
        return text == null || text.isBlank() ? "—" : text;
    }
}
