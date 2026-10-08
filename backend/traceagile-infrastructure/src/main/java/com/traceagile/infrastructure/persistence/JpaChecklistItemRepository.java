package com.traceagile.infrastructure.persistence;

import com.traceagile.application.requirement.ChecklistItemRepository;
import com.traceagile.domain.requirement.ChecklistItem;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link ChecklistItemRepository}. */
public interface JpaChecklistItemRepository extends JpaRepository<ChecklistItem, UUID>, ChecklistItemRepository {
}
