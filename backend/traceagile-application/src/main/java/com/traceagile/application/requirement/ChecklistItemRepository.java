package com.traceagile.application.requirement;

import com.traceagile.domain.requirement.ChecklistItem;
import com.traceagile.domain.requirement.ChecklistKind;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** Port de persistance de la DoR / DoD des projets (F-REQ-19). */
public interface ChecklistItemRepository {

    List<ChecklistItem> findByProject_KeyAndKindOrderByPositionAsc(String projectKey, ChecklistKind kind);

    Optional<ChecklistItem> findById(UUID id);

    ChecklistItem save(ChecklistItem item);

    void delete(ChecklistItem item);
}
