package com.traceagile.domain.requirement;

import java.util.Optional;

/**
 * Faits sur les tests et anomalies liés à une exigence, utilisés par les items automatiques de la
 * DoR / DoD (F-REQ-19). {@link Optional#empty()} : donnée pas encore disponible (avant les lots 3 et 5).
 */
public interface VerificationFacts {

    Optional<Boolean> hasLinkedTest(Requirement requirement);

    Optional<Boolean> allLinkedTestsPassed(Requirement requirement);

    Optional<Boolean> hasOpenBlockingDefect(Requirement requirement);
}
