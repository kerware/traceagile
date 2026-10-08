package com.traceagile.application.traceability;

import com.traceagile.domain.traceability.TraceEntityType;
import com.traceagile.domain.traceability.TraceLink;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** Port de persistance des liens de traçabilité (§3.1 TraceLink). */
public interface TraceLinkRepository {

    List<TraceLink> findBySourceTypeAndSourceId(TraceEntityType sourceType, UUID sourceId);

    List<TraceLink> findByTargetTypeAndTargetId(TraceEntityType targetType, UUID targetId);

    List<TraceLink> findByTargetTypeAndTargetIdIn(TraceEntityType targetType, Collection<UUID> targetIds);

    Optional<TraceLink> findBySourceIdAndTargetId(UUID sourceId, UUID targetId);

    TraceLink save(TraceLink link);

    void delete(TraceLink link);
}
