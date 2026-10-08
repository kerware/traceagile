package com.traceagile.application.traceability;

import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.VerificationFacts;
import java.util.Optional;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;

/**
 * F-REQ-19 faits de DoR / DoD. Lot 2 : « au moins un test lié » est évalué ; les résultats
 * d'exécution (lot 5) et les anomalies (lot 5) restent « non évalués ».
 */
@Component
public class TraceVerificationFacts implements VerificationFacts {

    private final TraceLinkService links;

    public TraceVerificationFacts(@Lazy TraceLinkService links) {
        this.links = links;
    }

    @Override
    public Optional<Boolean> hasLinkedTest(Requirement requirement) {
        return Optional.of(links.hasCoveringTest(requirement));
    }

    @Override
    public Optional<Boolean> allLinkedTestsPassed(Requirement requirement) {
        return Optional.empty();
    }

    @Override
    public Optional<Boolean> hasOpenBlockingDefect(Requirement requirement) {
        return Optional.empty();
    }
}
