package com.traceagile.application.execution;

import com.traceagile.domain.execution.Execution;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** Port de persistance des exécutions (§8.4). */
public interface ExecutionRepository {

    Optional<Execution> findById(UUID id);

    /** Toutes les exécutions d'un projet, de la plus ancienne à la plus récente (dernier résultat par test). */
    List<Execution> findByTestCase_Project_KeyOrderByStartedAtAsc(String projectKey);

    List<Execution> findByTestCase_IdInOrderByStartedAtDesc(Collection<UUID> testIds);

    /** §3.3-6 un test exécuté ne se supprime plus. */
    boolean existsByTestCase_IdIn(Collection<UUID> testIds);

    Execution save(Execution execution);
}
