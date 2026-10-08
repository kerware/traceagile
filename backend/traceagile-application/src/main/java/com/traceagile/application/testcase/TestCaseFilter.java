package com.traceagile.application.testcase;

import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestTechnique;
import java.util.Locale;
import java.util.Set;

/**
 * §12 filtres du référentiel : kind, technique, status, tag, requirement, orphan ; plus la recherche
 * {@code q} (clé, titre), le dossier et les candidats à l'automatisation (F-MAN-02).
 */
public record TestCaseFilter(
        Set<TestKind> kinds,
        Set<TestTechnique> techniques,
        Set<TestCaseStatus> statuses,
        String tag,
        String requirementKey,
        Boolean orphan,
        Boolean automationCandidate,
        String folder,
        String q) {

    public static final TestCaseFilter NONE = new TestCaseFilter(null, null, null, null, null, null, null, null, null);

    public TestCaseFilter {
        kinds = kinds == null ? Set.of() : Set.copyOf(kinds);
        techniques = techniques == null ? Set.of() : Set.copyOf(techniques);
        statuses = statuses == null ? Set.of() : Set.copyOf(statuses);
        tag = blank(tag) ? null : tag.strip().toLowerCase(Locale.ROOT);
        requirementKey = blank(requirementKey) ? null : requirementKey.strip();
        folder = blank(folder) ? null : folder.strip();
        q = blank(q) ? null : q.strip();
    }

    private static boolean blank(String value) {
        return value == null || value.isBlank();
    }
}
