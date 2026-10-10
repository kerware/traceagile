package com.traceagile.infrastructure.persistence;

import com.traceagile.application.requirement.NfrMeasurementRepository;
import com.traceagile.domain.requirement.NfrMeasurement;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link NfrMeasurementRepository}. */
public interface JpaNfrMeasurementRepository extends JpaRepository<NfrMeasurement, UUID>, NfrMeasurementRepository {
}
