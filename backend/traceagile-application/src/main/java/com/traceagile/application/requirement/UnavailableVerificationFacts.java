package com.traceagile.application.requirement;

import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.VerificationFacts;
import java.util.Optional;
import org.springframework.stereotype.Component;

/**
 * Lot 1 : les tests (lot 2-3) et les anomalies (lot 5) n'existent pas encore ; les items de DoR /
 * DoD qui en dépendent sont « non évalués ». Remplacé par une implémentation réelle au lot 3.
 */
@Component
public class UnavailableVerificationFacts implements VerificationFacts {

    @Override
    public Optional<Boolean> hasLinkedTest(Requirement requirement) {
        return Optional.empty();
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
