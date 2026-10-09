package com.traceagile.domain.planning;

import com.traceagile.domain.common.BusinessRuleException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/** F-PLN-01 génération de sprints : N sprints consécutifs de 1 à 4 semaines, sans chevauchement. */
public final class SprintSchedule {

    public static final int MAX_COUNT = 26;

    private SprintSchedule() {
    }

    /** @return pour chaque sprint, {@code [début, fin]} (fin incluse) */
    public static List<LocalDate[]> generate(LocalDate start, int count, int weeks) {
        if (start == null) {
            throw new BusinessRuleException("PLANNING_DATES_REQUIRED", "La date de début est obligatoire.");
        }
        if (weeks < 1 || weeks > 4) {
            throw new BusinessRuleException("SPRINT_DURATION_INVALID", "Un sprint dure de 1 à 4 semaines.");
        }
        if (count < 1 || count > MAX_COUNT) {
            throw new BusinessRuleException("SPRINT_COUNT_INVALID", "On génère de 1 à " + MAX_COUNT + " sprints.");
        }
        List<LocalDate[]> slots = new ArrayList<>();
        LocalDate from = start;
        for (int i = 0; i < count; i++) {
            LocalDate to = from.plusWeeks(weeks).minusDays(1);
            slots.add(new LocalDate[] {from, to});
            from = to.plusDays(1);
        }
        return slots;
    }

    static void checkDates(LocalDate start, LocalDate end) {
        if (start == null || end == null) {
            throw new BusinessRuleException("PLANNING_DATES_REQUIRED", "Les dates de début et de fin sont obligatoires.");
        }
        if (end.isBefore(start)) {
            throw new BusinessRuleException("PLANNING_DATES_INVALID", "La date de fin précède la date de début.");
        }
    }

    static boolean overlap(LocalDate aStart, LocalDate aEnd, LocalDate bStart, LocalDate bEnd) {
        return !aEnd.isBefore(bStart) && !bEnd.isBefore(aStart);
    }
}
