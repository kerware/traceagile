package com.traceagile.infrastructure.persistence;

import com.traceagile.application.defect.DefectRepository;
import com.traceagile.domain.defect.Defect;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link DefectRepository}. */
public interface JpaDefectRepository extends JpaRepository<Defect, UUID>, DefectRepository {
}
