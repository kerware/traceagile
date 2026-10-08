package com.traceagile.application.requirement;

/**
 * §11.3 Événement de domaine : une exigence a été modifiée. Écouté au lot 3 pour passer les tests
 * liés à NEEDS_UPDATE (§3.3-7) et invalider le cache de couverture.
 */
public record RequirementChanged(String projectKey, String requirementKey) {
}
