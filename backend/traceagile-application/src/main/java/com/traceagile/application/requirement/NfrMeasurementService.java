package com.traceagile.application.requirement;

import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.requirement.NfrMeasurement;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementType;
import java.time.Clock;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** F-REQ-18 valeurs mesurées des ENF : remontées par les tests de performance ou saisies (ADR-0024). */
@Service
@Transactional
public class NfrMeasurementService {

    private final NfrMeasurementRepository measurements;
    private final RequirementService requirements;
    private final TraceLinkService links;
    private final Clock clock;

    public NfrMeasurementService(NfrMeasurementRepository measurements, RequirementService requirements, TraceLinkService links, Clock clock) {
        this.measurements = measurements;
        this.requirements = requirements;
        this.links = links;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public List<NfrMeasurement> history(String projectKey, String requirementKey) {
        return measurements.findTop20ByRequirement_IdOrderByMeasuredAtDesc(requirements.get(projectKey, requirementKey).getId());
    }

    @Transactional(readOnly = true)
    public Optional<NfrMeasurement> latest(Requirement requirement) {
        return measurements.findFirstByRequirement_IdOrderByMeasuredAtDesc(requirement.getId());
    }

    /** Saisie manuelle (mesure faite hors TraceAgile). */
    public NfrMeasurement record(String projectKey, String requirementKey, double value) {
        return measurements.save(new NfrMeasurement(requirements.get(projectKey, requirementKey), value, null, null, null, Instant.now(clock)));
    }

    /**
     * F-REQ-18 métriques d'une tentative automatisée ({@code metrics} de TEST_FINISHED) : une mesure par
     * ENF vérifiée par le test, avec la métrique qui correspond à son unité.
     */
    public List<NfrMeasurement> fromRun(Execution execution, String runKey, Map<String, Double> metrics, Instant at) {
        if (metrics == null || metrics.isEmpty()) {
            return List.of();
        }
        return links.requirementsOf(execution.getTestCase()).stream()
                .filter(l -> l.linkType().countsForCoverage())
                .map(TraceLinkService.RequirementLink::requirement)
                .filter(r -> r.getType() == RequirementType.NON_FUNCTIONAL)
                .flatMap(nfr -> NfrMeasurement.pick(metrics, nfr.getPlanguage() == null ? null : nfr.getPlanguage().unit()).stream()
                        .map(metric -> measurements.save(new NfrMeasurement(nfr, metric.getValue(), metric.getKey(),
                                execution.getTestCase().getKey(), runKey, at))))
                .toList();
    }
}
