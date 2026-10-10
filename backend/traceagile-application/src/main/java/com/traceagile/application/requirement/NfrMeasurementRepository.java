package com.traceagile.application.requirement;

import com.traceagile.domain.requirement.NfrMeasurement;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/** Port des valeurs mesurées des ENF (F-REQ-18). */
public interface NfrMeasurementRepository {

    List<NfrMeasurement> findTop20ByRequirement_IdOrderByMeasuredAtDesc(UUID requirementId);

    Optional<NfrMeasurement> findFirstByRequirement_IdOrderByMeasuredAtDesc(UUID requirementId);

    NfrMeasurement save(NfrMeasurement measurement);
}
