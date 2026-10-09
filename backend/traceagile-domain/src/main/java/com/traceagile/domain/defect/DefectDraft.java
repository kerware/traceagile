package com.traceagile.domain.defect;

import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.StepResult;
import com.traceagile.domain.testcase.TestCase;
import java.util.List;

/**
 * F-EXE-03 anomalie pré-remplie depuis une exécution : étapes jusqu'au pas en échec, attendu,
 * obtenu, environnement, build. Sévérité proposée : MAJOR (ADR-0016). Les captures arrivent avec
 * les pièces jointes (lot 9).
 */
public record DefectDraft(String title, String description, DefectSeverity severity) {

    public static DefectDraft from(Execution execution) {
        TestCase test = execution.getTestCase();
        Campaign campaign = execution.getItem().getCampaign();
        StepResult failed = execution.firstFailedStep().orElse(null);
        String title = test.getKey() + " " + test.getTitle()
                + (failed == null ? " : échec" : " : échec au pas " + failed.getPosition() + " (" + firstLine(failed.getAction()) + ")");
        StringBuilder d = new StringBuilder();
        d.append("**Test** : ").append(test.getKey()).append(" ").append(test.getTitle())
                .append(" (version ").append(execution.getTestCaseVersion()).append(", tentative ").append(execution.getAttempt()).append(")\n");
        d.append("**Campagne** : ").append(campaign.getKey()).append(" ").append(campaign.getName()).append("\n");
        d.append("**Environnement** : ").append(orDash(campaign.getEnvironment()))
                .append(" · **Build** : ").append(orDash(campaign.getBuildVersion())).append("\n");
        if (execution.getDataSetName() != null) {
            d.append("**Jeu de données** : ").append(execution.getDataSetName()).append(", ligne ").append(execution.getDataSetRow() + 1).append("\n");
        }
        List<StepResult> steps = execution.getSteps();
        if (!steps.isEmpty()) {
            d.append("\n**Étapes pour reproduire**\n\n");
            for (StepResult step : steps) {
                d.append(step.getPosition()).append(". ").append(step.getAction());
                if (step.getTestData() != null) {
                    d.append(" (données : ").append(step.getTestData()).append(")");
                }
                d.append("\n");
                if (step == failed) {
                    break;
                }
            }
        }
        if (failed != null) {
            d.append("\n**Attendu** : ").append(orDash(failed.getExpectedResult())).append("\n");
            d.append("**Obtenu** : ").append(orDash(failed.getActualResult())).append("\n");
        } else if (execution.getComment() != null) {
            d.append("\n**Commentaire** : ").append(execution.getComment()).append("\n");
        }
        return new DefectDraft(title, d.toString(), DefectSeverity.MAJOR);
    }

    private static String firstLine(String text) {
        String line = text == null ? "" : text.lines().findFirst().orElse("");
        return line.length() > 60 ? line.substring(0, 57) + "…" : line;
    }

    private static String orDash(String text) {
        return text == null || text.isBlank() ? "—" : text;
    }
}
