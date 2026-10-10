package com.traceagile.application.automation;

import com.traceagile.domain.execution.ExecutionStatus;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** F-EXE-10 port de lecture des rapports de tests (JUnit XML, Cucumber JSON, Robot output.xml, Playwright JSON). */
public interface ReportParser {

    enum ReportFormat { JUNIT, CUCUMBER, ROBOT, PLAYWRIGHT }

    /**
     * Résultat d'un test du rapport. {@code identifiers} : identifiants candidats, du plus précis au plus
     * large (« Classe#méthode », titre…), comparés au {@code testIdentifier} des tests automatisés.
     */
    record ReportResult(String name, List<String> identifiers, ExecutionStatus status, Long durationMs, String message, List<String> tags) {

        private static final Pattern REQUIREMENT = Pattern.compile("^@?(REQ-\\d+)$", Pattern.CASE_INSENSITIVE);

        public String identifier() {
            return identifiers.getFirst();
        }

        /** Tags d'exigence (« @REQ-12 », « REQ-12 ») normalisés en clés. */
        public List<String> requirementKeys() {
            return tags.stream().map(t -> REQUIREMENT.matcher(t.strip())).filter(Matcher::matches)
                    .map(m -> m.group(1).toUpperCase(Locale.ROOT)).distinct().toList();
        }
    }

    /** @throws com.traceagile.application.common.UnprocessableException REPORT_INVALID si le fichier n'est pas au format annoncé */
    List<ReportResult> parse(ReportFormat format, byte[] content);
}
