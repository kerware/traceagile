package com.traceagile.api.testcase;

import com.traceagile.api.testcase.TestCaseDtos.FrameworkResponse;
import com.traceagile.application.testcase.AutomationFrameworkService;
import com.traceagile.domain.testcase.TestTechnique;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** F-AUT-01 données de référence : frameworks par technique (§13.2 /admin référentiels). */
@RestController
@RequestMapping("/api/v1/reference/frameworks")
@Tag(name = "Administration")
public class ReferenceController {

    private final AutomationFrameworkService frameworks;
    private final TestCaseMapper mapper;

    public ReferenceController(AutomationFrameworkService frameworks, TestCaseMapper mapper) {
        this.frameworks = frameworks;
        this.mapper = mapper;
    }

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public List<FrameworkResponse> list() {
        return mapper.toFrameworks(frameworks.all());
    }

    @PutMapping("/{technique}")
    @PreAuthorize("hasRole('SYSTEM_ADMIN')")
    public List<FrameworkResponse> replace(@PathVariable TestTechnique technique, @RequestBody List<String> names) {
        return mapper.toFrameworks(frameworks.replace(technique, names));
    }
}
