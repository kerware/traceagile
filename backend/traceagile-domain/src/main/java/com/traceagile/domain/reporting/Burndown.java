package com.traceagile.domain.reporting;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * F-RPT-02 burndown d'un sprint (ADR-0023) : points restants chaque jour = points engagés moins les
 * points des stories terminées ce jour-là ou avant ; rien après aujourd'hui. La ligne idéale va
 * linéairement des points engagés (premier jour) à 0 (dernier jour).
 */
public final class Burndown {

    /** Un jour du sprint : {@code remaining} {@code null} pour un jour futur. */
    public record Day(LocalDate date, Integer remaining, double ideal) {
    }

    private Burndown() {
    }

    public static List<Day> of(LocalDate start, LocalDate end, LocalDate today, int committed, Map<LocalDate, Integer> donePointsByDate) {
        long days = ChronoUnit.DAYS.between(start, end);
        List<Day> result = new ArrayList<>();
        for (long i = 0; i <= days; i++) {
            LocalDate date = start.plusDays(i);
            double ideal = days == 0 ? 0 : Math.round(committed * (1 - (double) i / days) * 10) / 10.0;
            Integer remaining = null;
            if (!date.isAfter(today)) {
                int done = donePointsByDate.entrySet().stream().filter(e -> !e.getKey().isAfter(date)).mapToInt(Map.Entry::getValue).sum();
                remaining = Math.max(0, committed - done);
            }
            result.add(new Day(date, remaining, ideal));
        }
        return result;
    }
}
