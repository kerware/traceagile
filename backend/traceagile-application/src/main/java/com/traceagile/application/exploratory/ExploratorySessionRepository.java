package com.traceagile.application.exploratory;

import com.traceagile.domain.exploratory.ExploratorySession;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** Port de persistance des sessions exploratoires (§5.2). */
public interface ExploratorySessionRepository {

    /** ADR-0019 l'identifiant d'une session dans l'API est celui de sa tentative. */
    Optional<ExploratorySession> findByExecution_Id(UUID executionId);

    List<ExploratorySession> findByExecution_Item_Campaign_Project_Key(String projectKey);

    ExploratorySession save(ExploratorySession session);

    /** Attribue les identifiants des notes ajoutées (collection en cascade). */
    void flush();
}
