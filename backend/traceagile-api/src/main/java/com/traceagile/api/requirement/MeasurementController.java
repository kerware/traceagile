package com.traceagile.api.requirement;

import com.traceagile.application.requirement.NfrMeasurementService;
import com.traceagile.domain.requirement.NfrMeasurement;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** F-REQ-18 valeurs mesurées d'une ENF : historique (20 dernières) et saisie (ADR-0024). */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}")
@Tag(name = "Exigences")
public class MeasurementController {

    /** Saisir une mesure : qui crée ou modifie des tests. */
    static final String MEASURE = "hasPermission(#projectKey, 'Project', 'TEST_WRITE') or hasPermission(#projectKey, 'Project', 'AUTOMATED_TEST_WRITE')";

    private final NfrMeasurementService measurements;

    public MeasurementController(NfrMeasurementService measurements) {
        this.measurements = measurements;
    }

    public record NfrMeasurementResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) double value,
            String unit,
            String metric,
            @Schema(description = "Test de performance d'origine (absent : saisie)") String testKey,
            String runKey,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant measuredAt,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) NfrMeasurement.Outcome outcome,
            String createdBy) {
    }

    public record NfrMeasurementRequest(@NotNull Double value) {
    }

    @GetMapping("/requirements/{key}/measurements")
    @PreAuthorize(RequirementController.READ)
    public List<NfrMeasurementResponse> history(@PathVariable String projectKey, @PathVariable String key) {
        return measurements.history(projectKey, key).stream().map(MeasurementController::response).toList();
    }

    @PostMapping("/requirements/{key}/measurements")
    @PreAuthorize(MEASURE)
    @ResponseStatus(HttpStatus.CREATED)
    public NfrMeasurementResponse record(@PathVariable String projectKey, @PathVariable String key, @Valid @RequestBody NfrMeasurementRequest r) {
        return response(measurements.record(projectKey, key, r.value()));
    }

    static NfrMeasurementResponse response(NfrMeasurement m) {
        return new NfrMeasurementResponse(m.getValue(), m.getUnit(), m.getMetric(), m.getTestKey(), m.getRunKey(), m.getMeasuredAt(), m.getOutcome(),
                m.getCreatedBy());
    }
}
