package com.traceagile.api.testcase;

import com.traceagile.api.testcase.TestCaseDtos.LinkedTestResponse;
import com.traceagile.api.testcase.TestCaseDtos.StepUsageResponse;
import com.traceagile.api.testcase.TestCaseDtos.TestCaseDetail;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.application.testcase.BddService;
import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestKind;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** F-REQ-11 génération d'un test BDD, F-AUT-04 étapes connues, onglet « Tests liés » d'une exigence. */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}")
@Tag(name = "Tests")
public class BddController {

    private final BddService bdd;
    private final RequirementService requirements;
    private final TraceLinkService links;
    private final TestPermissions permissions;
    private final TestCaseController testCases;
    private final TestCaseMapper mapper;

    public BddController(BddService bdd, RequirementService requirements, TraceLinkService links, TestPermissions permissions,
                         TestCaseController testCases, TestCaseMapper mapper) {
        this.bdd = bdd;
        this.requirements = requirements;
        this.links = links;
        this.permissions = permissions;
        this.testCases = testCases;
        this.mapper = mapper;
    }

    /** F-REQ-11 un test automatisé BDD par scénario du critère, lié à l'exigence et au critère. */
    @PostMapping("/acceptance-criteria/{id}/generate-test")
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public ResponseEntity<List<TestCaseDetail>> generateTest(@PathVariable String projectKey, @PathVariable UUID id,
                                                             Authentication authentication) {
        permissions.checkWrite(authentication, projectKey, TestKind.AUTOMATED);
        List<TestCase> generated = bdd.generateFromCriterion(projectKey, id);
        return ResponseEntity.status(HttpStatus.CREATED).body(generated.stream().map(t -> testCases.detail(t, List.of())).toList());
    }

    /** F-AUT-04 autocomplétion : étapes des tests BDD et des critères Gherkin du projet. */
    @GetMapping("/gherkin/steps")
    @PreAuthorize("hasPermission(#projectKey, 'Project', 'PROJECT_READ')")
    public List<StepUsageResponse> steps(@PathVariable String projectKey, @RequestParam(required = false) String q) {
        List<String> criteria = requirements.backlog(projectKey).stream()
                .flatMap(r -> r.getCriteria().stream())
                .filter(c -> c.getFormat() == CriterionFormat.GHERKIN)
                .map(AcceptanceCriterion::getContent)
                .toList();
        return bdd.steps(projectKey, criteria, q).stream().map(s -> new StepUsageResponse(s.text(), s.count())).toList();
    }

    /** §13.2 fiche exigence, onglet « Tests liés ». */
    @GetMapping("/requirements/{key}/test-cases")
    @PreAuthorize("hasPermission(#projectKey, 'Project', 'REQUIREMENT_READ')")
    public List<LinkedTestResponse> linkedTests(@PathVariable String projectKey, @PathVariable String key) {
        return links.testsOf(requirements.get(projectKey, key)).stream().map(mapper::toResponse).toList();
    }
}
