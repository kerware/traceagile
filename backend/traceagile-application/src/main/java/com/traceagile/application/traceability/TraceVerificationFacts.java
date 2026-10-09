package com.traceagile.application.traceability;

import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.VerificationFacts;
import java.util.Optional;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;

/**
 * F-REQ-19 faits de DoR / DoD : « au moins un test lié » (lot 2), « tous les tests liés passés »
 * (lot 3) et « aucune anomalie bloquante ouverte » (lot 5), d'après {@link ExecutionResults}.
 */
@Component
public class TraceVerificationFacts implements VerificationFacts {

    private final TraceLinkService links;
    private final TraceabilityService traceability;
    private final ExecutionResults executions;

    public TraceVerificationFacts(@Lazy TraceLinkService links, @Lazy TraceabilityService traceability, @Lazy ExecutionResults executions) {
        this.links = links;
        this.traceability = traceability;
        this.executions = executions;
    }

    @Override
    public Optional<Boolean> hasLinkedTest(Requirement requirement) {
        return Optional.of(links.hasCoveringTest(requirement));
    }

    @Override
    public Optional<Boolean> allLinkedTestsPassed(Requirement requirement) {
        return Optional.of(traceability.allCoveringTestsPassed(requirement));
    }

    @Override
    public Optional<Boolean> hasOpenBlockingDefect(Requirement requirement) {
        return Optional.of(executions.requirementsWithOpenBlockingDefect(requirement.getProject().getKey()).contains(requirement.getId()));
    }
}
