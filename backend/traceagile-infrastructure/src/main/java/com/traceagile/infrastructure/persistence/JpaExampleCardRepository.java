package com.traceagile.infrastructure.persistence;

import com.traceagile.application.requirement.ExampleCardRepository;
import com.traceagile.domain.requirement.ExampleCard;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

/** Adaptateur Spring Data du port {@link ExampleCardRepository}. */
public interface JpaExampleCardRepository extends JpaRepository<ExampleCard, UUID>, ExampleCardRepository {
}
