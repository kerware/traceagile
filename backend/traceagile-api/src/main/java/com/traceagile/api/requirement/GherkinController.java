package com.traceagile.api.requirement;

import com.traceagile.api.requirement.RequirementDtos.GherkinErrorResponse;
import com.traceagile.api.requirement.RequirementDtos.GherkinValidateRequest;
import com.traceagile.api.requirement.RequirementDtos.GherkinValidationResponse;
import com.traceagile.application.requirement.GherkinValidator;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** §12 POST /gherkin/validate : validation à la frappe des éditeurs Gherkin (F-REQ-10). */
@RestController
@RequestMapping("/api/v1/gherkin")
@Tag(name = "Gherkin")
public class GherkinController {

    private final GherkinValidator validator;

    public GherkinController(GherkinValidator validator) {
        this.validator = validator;
    }

    @PostMapping("/validate")
    @PreAuthorize("isAuthenticated()")
    public GherkinValidationResponse validate(@Valid @RequestBody GherkinValidateRequest request) {
        var result = validator.validate(request.source());
        return new GherkinValidationResponse(result.valid(), result.language(),
                result.errors().stream().map(e -> new GherkinErrorResponse(e.line(), e.column(), e.message())).toList());
    }
}
