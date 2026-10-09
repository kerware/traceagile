package com.traceagile.application.traceability;

import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.VerificationFacts;
import java.util.Optional;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;

/**
 * F-REQ-19 faits de DoR / DoD. « Au moins un test lié » (lot 2) et « tous les tests liés passés »
 * (lot 3, d'après {@link ExecutionResults}) sont évalués ; les anomalies bloquantes restent « non
 * évaluées » jusqu'au lot 5.
 */
@Component
public class TraceVerificationFacts implements VerificationFacts {

    private final TraceLinkService links;
    private final TraceabilityService traceability;

    public TraceVerificationFacts(@Lazy TraceLinkService links, @Lazy TraceabilityService traceability) {
        this.links = links;
        this.traceability = traceability;
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
        return Optional.empty();
    }
}
