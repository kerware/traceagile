package com.traceagile.application.requirement;

import com.traceagile.domain.requirement.ExampleCard;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** Port des cartes de l'atelier Example Mapping (F-REQ-13). */
public interface ExampleCardRepository {

    List<ExampleCard> findByRequirement_IdOrderByPositionAsc(UUID requirementId);

    Optional<ExampleCard> findByIdAndRequirement_Project_Key(UUID id, String projectKey);

    ExampleCard save(ExampleCard card);

    void delete(ExampleCard card);
}
