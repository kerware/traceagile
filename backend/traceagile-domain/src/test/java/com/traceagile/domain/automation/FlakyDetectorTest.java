package com.traceagile.domain.automation;

import static org.assertj.core.api.Assertions.assertThat;

import com.traceagile.domain.automation.FlakyDetector.Outcome;
import com.traceagile.domain.execution.ExecutionStatus;
import java.util.Arrays;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/** F-EXE-11 un test qui alterne PASSED / FAILED sur le même build au moins 2 fois dans les 10 dernières exécutions est instable. */
class FlakyDetectorTest {

    /** « 2.0:P,2.0:F » : build et statut, de la plus ancienne à la plus récente. */
    static List<Outcome> outcomes(String spec) {
        return Arrays.stream(spec.split(",")).map(String::strip).map(s -> {
            String[] parts = s.split(":");
            ExecutionStatus status = switch (parts[1]) {
                case "P" -> ExecutionStatus.PASSED;
                case "F" -> ExecutionStatus.FAILED;
                case "E" -> ExecutionStatus.ERROR;
                default -> ExecutionStatus.SKIPPED;
            };
            return new Outcome(parts[0].isEmpty() ? null : parts[0], status);
        }).toList();
    }

    @ParameterizedTest(name = "{0} → {1}")
    @CsvSource(delimiter = '|', value = {
            "2.0:P, 2.0:F, 2.0:P             | true",
            "2.0:P, 2.0:F                    | false",
            "2.0:P, 2.1:F, 2.2:P, 2.3:F      | false",
            "2.0:F, 2.0:F, 2.0:P, 2.0:P      | false",
            "2.0:P, 2.0:E, 2.0:F, 2.0:P      | true",
            "2.0:P, 2.0:S, 2.0:P             | false",
            "2.0:P, 2.0:F, 2.1:P, 2.1:F, 2.1:P | true",
            ":P, :F, :P                      | true",
    })
    @DisplayName("F-EXE-11 alternances par build")
    void flaky(String history, boolean expected) {
        assertThat(FlakyDetector.isFlaky(outcomes(history))).isEqualTo(expected);
    }

    @ParameterizedTest(name = "seules les 10 dernières comptent")
    @CsvSource(delimiter = '|', value = {"2.0:P, 2.0:F, 2.0:P, 3.0:P, 3.0:P, 3.0:P, 3.0:P, 3.0:P, 3.0:P, 3.0:P, 3.0:P, 3.0:P | false"})
    @DisplayName("F-EXE-11 fenêtre de 10 exécutions")
    void window(String history, boolean expected) {
        assertThat(FlakyDetector.isFlaky(outcomes(history))).isEqualTo(expected);
    }
}
