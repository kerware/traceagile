package com.traceagile.domain.exploratory;

import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.testcase.TestCase;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.TreeMap;
import java.util.function.ToDoubleFunction;

/**
 * §5.4 métriques exploratoires d'un périmètre (campagne, sprint, release, projet). Seules les sessions
 * terminées comptent ; une moyenne sans donnée est absente ({@code null}) plutôt que nulle.
 *
 * @param durationVsTargetPct durée totale / durées cibles cumulées des mêmes sessions
 * @param defectsPerHour      anomalies liées aux sessions par heure de session (temps actif)
 * @param neverExploredAreas  zones des chartes planifiées jamais couvertes par une session
 */
public record ExploratoryMetrics(int sessions, int inProgress, int awaitingApproval, int debriefed, long totalMinutes,
                                 Double averageMinutes, Double averageTimeboxMin, Double durationVsTargetPct, TbsAverage averageTbs,
                                 Double defectsPerHour, int chartersPlanned, int chartersExecuted, Double averageConfidence,
                                 List<String> neverExploredAreas) {

    public record TbsAverage(double testPct, double bugPct, double setupPct) {
    }

    /**
     * @param sessions     sessions du périmètre
     * @param plannedItems éléments de campagne du périmètre (seules les chartes comptent)
     * @param defects      anomalies liées aux tentatives de ces sessions
     */
    public static ExploratoryMetrics of(Collection<ExploratorySession> sessions, Collection<CampaignItem> plannedItems, int defects) {
        List<ExploratorySession> closed = sessions.stream().filter(s -> !s.getState().isOpen()).toList();
        long totalSeconds = closed.stream().mapToLong(ExploratorySession::getActiveSeconds).sum();
        long totalMinutes = closed.stream().mapToLong(ExploratorySession::getDurationMin).sum();
        long totalTimebox = closed.stream().mapToLong(ExploratorySession::getTimeboxMin).sum();
        List<Tbs> tbs = closed.stream().map(ExploratorySession::getTbs).filter(Objects::nonNull).toList();
        List<Proof> proofs = closed.stream().map(ExploratorySession::getProof).filter(Objects::nonNull).toList();

        List<TestCase> planned = plannedItems.stream().map(CampaignItem::getTestCase).filter(t -> t.getCharter() != null).distinct().toList();
        long executed = closed.stream().map(ExploratorySession::getCharter).distinct().count();
        Map<String, String> uncovered = new TreeMap<>(String.CASE_INSENSITIVE_ORDER);
        planned.forEach(t -> t.getCharter().getAreas().forEach(a -> uncovered.putIfAbsent(a, a)));
        closed.forEach(s -> s.getAreasCovered().forEach(uncovered::remove));

        return new ExploratoryMetrics(closed.size(), (int) sessions.stream().filter(s -> s.getState().isOpen()).count(),
                (int) closed.stream().filter(s -> s.getState() == SessionState.FINISHED).count(),
                (int) closed.stream().filter(s -> s.getState() == SessionState.DEBRIEFED).count(),
                totalMinutes,
                average(closed, s -> s.getDurationMin()),
                average(closed, ExploratorySession::getTimeboxMin),
                totalTimebox == 0 ? null : round(totalMinutes * 100.0 / totalTimebox),
                tbs.isEmpty() ? null : new TbsAverage(average(tbs, Tbs::testPct), average(tbs, Tbs::bugPct), average(tbs, Tbs::setupPct)),
                totalSeconds == 0 ? null : round(defects * 3600.0 / totalSeconds),
                planned.size(), (int) executed,
                average(proofs, Proof::feelings),
                List.copyOf(uncovered.values()));
    }

    private static <T> Double average(List<T> values, ToDoubleFunction<T> value) {
        return values.isEmpty() ? null : round(values.stream().mapToDouble(value).average().orElse(0));
    }

    private static double round(double value) {
        return Math.round(value * 10) / 10.0;
    }
}
