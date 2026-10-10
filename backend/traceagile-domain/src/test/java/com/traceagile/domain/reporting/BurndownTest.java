package com.traceagile.domain.reporting;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** F-RPT-02 burndown du sprint (ADR-0023). */
class BurndownTest {

    final LocalDate start = LocalDate.of(2026, 10, 12);

    @Test
    @DisplayName("F-RPT-02 points restants par jour jusqu'à aujourd'hui, ligne idéale linéaire des points engagés à 0")
    void remainingAndIdeal() {
        List<Burndown.Day> days = Burndown.of(start, start.plusDays(4), start.plusDays(2), 20,
                Map.of(start.plusDays(1), 5, start.plusDays(2), 8, start.minusDays(3), 1));
        assertThat(days).extracting(Burndown.Day::date)
                .containsExactly(start, start.plusDays(1), start.plusDays(2), start.plusDays(3), start.plusDays(4));
        assertThat(days).extracting(Burndown.Day::remaining).containsExactly(19, 14, 6, null, null);
        assertThat(days).extracting(Burndown.Day::ideal).containsExactly(20.0, 15.0, 10.0, 5.0, 0.0);
    }

    @Test
    @DisplayName("F-RPT-02 sprint d'un jour, plus de points terminés qu'engagés : jamais sous 0")
    void edges() {
        assertThat(Burndown.of(start, start, start, 3, Map.of(start, 5))).singleElement()
                .satisfies(d -> {
                    assertThat(d.remaining()).isZero();
                    assertThat(d.ideal()).isZero();
                });
    }
}
