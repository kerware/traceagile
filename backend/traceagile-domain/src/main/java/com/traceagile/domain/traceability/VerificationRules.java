package com.traceagile.domain.traceability;

import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.requirement.CriterionStatus;
import java.util.Collection;
import java.util.List;
import java.util.Objects;

/**
 * §7.3 règles du statut de vérification et F-REQ-12 état d'un critère. Entrée : dernier résultat de
 * chaque test couvrant ({@code null} = jamais exécuté). Priorité retenue quand plusieurs conditions
 * s'appliquent (ADR-0014) : non couverte, en échec, suspecte, bloquée, puis validée / en cours / non exécutée.
 */
public final class VerificationRules {

    private VerificationRules() {
    }

    public static VerificationStatus leaf(List<ExecutionStatus> coveringResults, boolean openBlockingDefect, boolean suspect) {
        if (coveringResults.isEmpty()) {
            return VerificationStatus.NOT_COVERED;
        }
        if (openBlockingDefect || coveringResults.contains(ExecutionStatus.FAILED)) {
            return VerificationStatus.FAILED;
        }
        if (suspect) {
            return VerificationStatus.SUSPECT;
        }
        if (coveringResults.contains(ExecutionStatus.BLOCKED) || coveringResults.contains(ExecutionStatus.ERROR)) {
            return VerificationStatus.BLOCKED;
        }
        if (coveringResults.stream().allMatch(r -> r == ExecutionStatus.PASSED)) {
            return VerificationStatus.VALIDATED;
        }
        return coveringResults.stream().anyMatch(VerificationRules::executed) ? VerificationStatus.IN_PROGRESS : VerificationStatus.NOT_RUN;
    }

    /** §7.2 une exigence parente agrège ses enfants (et son propre statut si elle est couverte directement). */
    public static VerificationStatus aggregate(Collection<VerificationStatus> statuses) {
        if (statuses.isEmpty()) {
            return VerificationStatus.NOT_COVERED;
        }
        for (VerificationStatus priority : List.of(VerificationStatus.FAILED, VerificationStatus.SUSPECT, VerificationStatus.BLOCKED)) {
            if (statuses.contains(priority)) {
                return priority;
            }
        }
        if (statuses.stream().allMatch(s -> s == VerificationStatus.VALIDATED)) {
            return VerificationStatus.VALIDATED;
        }
        if (statuses.stream().allMatch(s -> s == VerificationStatus.NOT_COVERED)) {
            return VerificationStatus.NOT_COVERED;
        }
        if (statuses.stream().allMatch(s -> s == VerificationStatus.NOT_COVERED || s == VerificationStatus.NOT_RUN)) {
            return VerificationStatus.NOT_RUN;
        }
        return VerificationStatus.IN_PROGRESS;
    }

    /** F-REQ-12 état d'un critère d'après les tests qui lui sont liés. */
    public static CriterionStatus criterion(List<ExecutionStatus> linkedResults) {
        if (linkedResults.contains(ExecutionStatus.FAILED)) {
            return CriterionStatus.FAILED;
        }
        if (!linkedResults.isEmpty() && linkedResults.stream().allMatch(r -> r == ExecutionStatus.PASSED)) {
            return CriterionStatus.VERIFIED;
        }
        return CriterionStatus.TO_VERIFY;
    }

    static boolean executed(ExecutionStatus result) {
        return Objects.nonNull(result) && result.isExecuted();
    }
}
