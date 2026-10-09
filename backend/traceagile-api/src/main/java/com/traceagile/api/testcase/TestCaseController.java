package com.traceagile.api.testcase;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.api.requirement.RequirementDtos.AuditEventResponse;
import com.traceagile.api.requirement.RequirementDtos.FieldChangeResponse;
import com.traceagile.api.requirement.RequirementMapper;
import com.traceagile.api.testcase.TestCaseDtos.CreateTestCaseRequest;
import com.traceagile.api.testcase.TestCaseDtos.DiscoveryResponse;
import com.traceagile.api.testcase.TestCaseDtos.FeatureImportResponse;
import com.traceagile.api.testcase.TestCaseDtos.LinkRequest;
import com.traceagile.api.testcase.TestCaseDtos.RequirementLinkResponse;
import com.traceagile.api.testcase.TestCaseDtos.TestCaseDetail;
import com.traceagile.api.testcase.TestCaseDtos.TestCaseFieldsRequest;
import com.traceagile.api.testcase.TestCaseDtos.TestCaseGroup;
import com.traceagile.api.testcase.TestCaseDtos.TestCaseSummary;
import com.traceagile.api.testcase.TestCaseDtos.TestStatusRequest;
import com.traceagile.api.testcase.TestCaseDtos.TestVersionResponse;
import com.traceagile.api.web.MergePatch;
import com.traceagile.api.web.PageResponse;
import com.traceagile.api.web.Versions;
import com.traceagile.application.audit.AuditService;
import com.traceagile.application.common.UnprocessableException;
import com.traceagile.application.testcase.BddService;
import com.traceagile.application.testcase.BddService.FeatureFile;
import com.traceagile.application.testcase.DiscoveryService;
import com.traceagile.application.testcase.DiscoveryService.DiscoveryReport;
import com.traceagile.application.testcase.TestCaseFilter;
import com.traceagile.application.testcase.TestCasePatch;
import com.traceagile.application.testcase.TestCasePatch.StepDraft;
import com.traceagile.application.testcase.TestCaseService;
import com.traceagile.application.testcase.TestCaseService.CreateTestCaseCommand;
import com.traceagile.application.testcase.TestCaseService.TestCaseResult;
import com.traceagile.application.testcase.TestFolderService;
import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.application.traceability.TraceLinkService.LinkDraft;
import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.testcase.DataSet;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestParameter;
import com.traceagile.domain.testcase.TestTechnique;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.Validator;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

/** §12 Cas de test (§6) ; droits du §2.2 selon la nature du test (TestPermissions). */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}/test-cases")
@Tag(name = "Tests")
public class TestCaseController {

    private final TestCaseService tests;
    private final TestFolderService folders;
    private final BddService bdd;
    private final DiscoveryService discovery;
    private final TraceLinkService links;
    private final AuditService audit;
    private final TestPermissions permissions;
    private final TestCaseMapper mapper;
    private final RequirementMapper requirementMapper;
    private final ObjectMapper json;
    private final Validator validator;

    public TestCaseController(TestCaseService tests, TestFolderService folders, BddService bdd, DiscoveryService discovery, TraceLinkService links,
                              AuditService audit, TestPermissions permissions, TestCaseMapper mapper,
                              RequirementMapper requirementMapper, ObjectMapper json, Validator validator) {
        this.tests = tests;
        this.folders = folders;
        this.bdd = bdd;
        this.discovery = discovery;
        this.links = links;
        this.audit = audit;
        this.permissions = permissions;
        this.mapper = mapper;
        this.requirementMapper = requirementMapper;
        this.json = json;
        this.validator = validator;
    }

    // ---------------------------------------------------------------- référentiel

    @GetMapping
    @PreAuthorize(TestPermissions.READ)
    public PageResponse<TestCaseSummary> list(@PathVariable String projectKey,
                                              @RequestParam(required = false) Set<TestKind> kind,
                                              @RequestParam(required = false) Set<TestTechnique> technique,
                                              @RequestParam(required = false) Set<TestCaseStatus> status,
                                              @RequestParam(required = false) String tag,
                                              @RequestParam(required = false) String requirement,
                                              @RequestParam(required = false) Boolean orphan,
                                              @RequestParam(required = false) Boolean automationCandidate,
                                              @RequestParam(required = false) String folder,
                                              @RequestParam(required = false) String q,
                                              @ParameterObject Pageable pageable) {
        TestCaseFilter filter = new TestCaseFilter(kind, technique, status, tag, requirement, orphan, automationCandidate, folder, q);
        var page = tests.search(projectKey, filter, pageable);
        Map<UUID, Long> counts = tests.executionCounts(page.getContent());
        return PageResponse.of(page, t -> mapper.toSummary(t, counts.getOrDefault(t.getId(), 0L)));
    }

    /** §13.2 référentiel par dossier ({@code folder}) ou par fonctionnalité Gherkin ({@code feature}). */
    @GetMapping("/tree")
    @PreAuthorize(TestPermissions.READ)
    public List<TestCaseGroup> tree(@PathVariable String projectKey, @RequestParam(defaultValue = "folder") String groupBy) {
        Map<String, List<TestCaseSummary>> groups = new LinkedHashMap<>();
        List<TestCase> all = tests.all(projectKey);
        Map<UUID, Long> counts = tests.executionCounts(all);
        for (TestCase test : all) {
            String name = "feature".equals(groupBy)
                    ? test.getAutomation() == null ? null : test.getAutomation().getFeatureName()
                    : test.getFolder();
            groups.computeIfAbsent(Objects.toString(name, ""), n -> new ArrayList<>()).add(mapper.toSummary(test, counts.getOrDefault(test.getId(), 0L)));
        }
        if (!"feature".equals(groupBy)) {
            // ADR-0013 dossiers explicites encore vides
            folders.explicit(projectKey).forEach(path -> groups.computeIfAbsent(path, n -> new ArrayList<>()));
        }
        return groups.entrySet().stream()
                .sorted(Comparator.comparing((Map.Entry<String, List<TestCaseSummary>> e) -> e.getKey().isEmpty())
                        .thenComparing(Map.Entry::getKey, String.CASE_INSENSITIVE_ORDER))
                .map(e -> new TestCaseGroup(e.getKey(), e.getValue()))
                .toList();
    }

    @PostMapping
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public ResponseEntity<TestCaseDetail> create(@PathVariable String projectKey, Authentication authentication,
                                                 @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(
                                                         schema = @Schema(implementation = CreateTestCaseRequest.class)))
                                                 @RequestBody JsonNode body) {
        MergePatch head = MergePatch.of(body, CreateTestCaseRequest.class, json, validator);
        MergePatch fields = MergePatch.of(body, TestCaseFieldsRequest.class, json, validator);
        TestKind kind = head.field("kind", TestKind.class).orElseThrow();
        permissions.checkWrite(authentication, projectKey, kind);
        List<LinkDraft> drafts = linkDrafts(head.field("links", new TypeReference<List<LinkRequest>>() { }));
        TestCaseResult result = tests.create(projectKey, new CreateTestCaseCommand(kind, head.field("title", String.class).orElseThrow(),
                fieldValue(head.field("technique", TestTechnique.class)), fieldValue(head.field("framework", String.class)),
                toPatch(fields, false), drafts));
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/test-cases/" + result.testCase().getKey()))
                .eTag(Versions.etag(result.testCase()))
                .body(detail(result.testCase(), result.warnings()));
    }

    @GetMapping("/{key}")
    @PreAuthorize(TestPermissions.READ)
    public ResponseEntity<TestCaseDetail> get(@PathVariable String projectKey, @PathVariable String key) {
        TestCase test = tests.get(projectKey, key);
        return ResponseEntity.ok().eTag(Versions.etag(test)).body(detail(test, List.of()));
    }

    /** §12 PATCH merge-patch avec If-Match ; F-AUT-10 nouvelle version si la modification est significative. */
    @PatchMapping(path = "/{key}", consumes = {"application/merge-patch+json", "application/json"})
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public ResponseEntity<TestCaseDetail> update(@PathVariable String projectKey, @PathVariable String key, Authentication authentication,
                                                 @RequestHeader(name = HttpHeaders.IF_MATCH, required = false) String ifMatch,
                                                 @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(
                                                         schema = @Schema(implementation = TestCaseFieldsRequest.class)))
                                                 @RequestBody JsonNode body) {
        permissions.checkWrite(authentication, projectKey, tests.get(projectKey, key).getKind());
        MergePatch fields = MergePatch.of(body, TestCaseFieldsRequest.class, json, validator);
        TestCaseResult result = tests.update(projectKey, key, toPatch(fields, true), Versions.parseIfMatch(ifMatch));
        return ResponseEntity.ok().eTag(Versions.etag(result.testCase())).body(detail(result.testCase(), result.warnings()));
    }

    @DeleteMapping("/{key}")
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public ResponseEntity<Void> delete(@PathVariable String projectKey, @PathVariable String key, Authentication authentication) {
        permissions.checkWrite(authentication, projectKey, tests.get(projectKey, key).getKind());
        tests.delete(projectKey, key);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{key}/status")
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public ResponseEntity<TestCaseDetail> changeStatus(@PathVariable String projectKey, @PathVariable String key,
                                                       Authentication authentication, @Valid @RequestBody TestStatusRequest request) {
        permissions.checkWrite(authentication, projectKey, tests.get(projectKey, key).getKind());
        TestCase test = tests.changeStatus(projectKey, key, request.status());
        return ResponseEntity.ok().eTag(Versions.etag(test)).body(detail(test, List.of()));
    }

    // ---------------------------------------------------------------- traçabilité

    @GetMapping("/{key}/requirements")
    @PreAuthorize(TestPermissions.READ)
    public List<RequirementLinkResponse> requirements(@PathVariable String projectKey, @PathVariable String key) {
        return links.requirementsOf(tests.get(projectKey, key)).stream().map(mapper::toResponse).toList();
    }

    /** F-TRA-01 / F-TRA-03 exigences (et critères) vérifiées par le test ; remplace la liste. */
    @PutMapping("/{key}/requirements")
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public List<RequirementLinkResponse> replaceRequirements(@PathVariable String projectKey, @PathVariable String key,
                                                             Authentication authentication,
                                                             @RequestBody List<@Valid LinkRequest> request) {
        permissions.checkWrite(authentication, projectKey, tests.get(projectKey, key).getKind());
        TestCase test = tests.replaceLinks(projectKey, key, linkDrafts(java.util.Optional.of(request)));
        return links.requirementsOf(test).stream().map(mapper::toResponse).toList();
    }

    // ---------------------------------------------------------------- versions, historique

    @GetMapping("/{key}/versions")
    @PreAuthorize(TestPermissions.READ)
    public List<TestVersionResponse> versions(@PathVariable String projectKey, @PathVariable String key) {
        return tests.versions(projectKey, key).stream().map(mapper::toResponse).toList();
    }

    @GetMapping("/{key}/versions/{from}/diff/{to}")
    @PreAuthorize(TestPermissions.READ)
    public List<FieldChangeResponse> diff(@PathVariable String projectKey, @PathVariable String key,
                                          @PathVariable int from, @PathVariable int to) {
        return requirementMapper.toChanges(tests.diff(projectKey, key, from, to));
    }

    @GetMapping("/{key}/history")
    @PreAuthorize(TestPermissions.READ)
    public PageResponse<AuditEventResponse> history(@PathVariable String projectKey, @PathVariable String key,
                                                    @ParameterObject Pageable pageable) {
        return PageResponse.of(audit.history(TestCaseService.AUDIT_TYPE, tests.get(projectKey, key).getId(), pageable),
                requirementMapper::toResponse);
    }

    // ---------------------------------------------------------------- .feature, découverte

    /** F-AUT-05 / F-AUT-07 import de fichiers .feature (ou d'un zip de .feature). */
    @PostMapping(path = "/import-feature", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public FeatureImportResponse importFeatures(@PathVariable String projectKey, Authentication authentication,
                                                @RequestPart("files") List<MultipartFile> files,
                                                @RequestParam(required = false) String framework) throws IOException {
        permissions.checkWrite(authentication, projectKey, TestKind.AUTOMATED);
        List<FeatureFile> features = new ArrayList<>();
        for (MultipartFile file : files) {
            String name = Objects.toString(file.getOriginalFilename(), "import.feature");
            if (name.toLowerCase().endsWith(".zip")) {
                try (ZipInputStream zip = new ZipInputStream(new ByteArrayInputStream(file.getBytes()))) {
                    ZipEntry entry;
                    while ((entry = zip.getNextEntry()) != null) {
                        if (!entry.isDirectory() && entry.getName().endsWith(".feature")) {
                            features.add(new FeatureFile(entry.getName(), new String(zip.readAllBytes(), StandardCharsets.UTF_8)));
                        }
                    }
                }
            } else {
                features.add(new FeatureFile(name, new String(file.getBytes(), StandardCharsets.UTF_8)));
            }
        }
        if (features.isEmpty()) {
            throw new UnprocessableException("FEATURE_NONE", "Aucun fichier .feature fourni.");
        }
        var result = bdd.importFeatures(projectKey, features, framework);
        return new FeatureImportResponse(result.created(), result.updated(), result.warnings());
    }

    /** F-AUT-07 export des scénarios en fichiers .feature regroupés dans un zip. */
    @GetMapping(path = "/export-feature", produces = "application/zip")
    @PreAuthorize(TestPermissions.READ)
    public ResponseEntity<byte[]> exportFeatures(@PathVariable String projectKey,
                                                 @RequestParam(required = false) List<String> keys) throws IOException {
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        try (ZipOutputStream zip = new ZipOutputStream(bytes, StandardCharsets.UTF_8)) {
            for (Map.Entry<String, String> file : bdd.exportFeatures(projectKey, keys).entrySet()) {
                zip.putNextEntry(new ZipEntry(file.getKey()));
                zip.write(file.getValue().getBytes(StandardCharsets.UTF_8));
                zip.closeEntry();
            }
        }
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType("application/zip"))
                .header(HttpHeaders.CONTENT_DISPOSITION, ContentDisposition.attachment().filename(projectKey + "-features.zip").build().toString())
                .body(bytes.toByteArray());
    }

    /** F-AUT-08 rapport de découverte des tests du dépôt. */
    @PostMapping("/discovery")
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public DiscoveryResponse discovery(@PathVariable String projectKey, Authentication authentication,
                                       @RequestBody DiscoveryReport report) {
        permissions.checkWrite(authentication, projectKey, TestKind.AUTOMATED);
        var result = discovery.importReport(projectKey, report);
        return new DiscoveryResponse(result.created(), result.updated(), result.disappeared(), result.warnings());
    }

    // ---------------------------------------------------------------- outils

    TestCaseDetail detail(TestCase test, List<String> warnings) {
        return mapper.toDetail(test, links.requirementsOf(test), warnings);
    }

    /** Merge-patch → commande ; à la création, le titre est déjà porté par la commande. */
    private TestCasePatch toPatch(MergePatch f, boolean includeTitle) {
        return new TestCasePatch(
                includeTitle ? f.field("title", String.class) : null,
                f.field("description", String.class), f.field("objective", String.class), f.field("priority", Priority.class),
                f.field("tags", new TypeReference<List<String>>() { }), f.field("estimatedDurationMin", Integer.class),
                f.field("folder", String.class), f.field("automationCandidate", Boolean.class),
                f.field("automationJustification", String.class),
                f.field("steps", new TypeReference<List<TestCaseDtos.StepRequest>>() { }) == null ? null
                        : f.field("steps", new TypeReference<List<TestCaseDtos.StepRequest>>() { })
                        .map(list -> list.stream().map(s -> new StepDraft(s.action(), s.expectedResult(), s.testData())).toList()),
                f.field("parameters", new TypeReference<List<TestCaseDtos.ParameterRequest>>() { }) == null ? null
                        : f.field("parameters", new TypeReference<List<TestCaseDtos.ParameterRequest>>() { })
                        .map(list -> list.stream().map(p -> new TestParameter(p.name(), p.defaultValue(), p.description())).toList()),
                f.field("explore", String.class), f.field("with", String.class), f.field("toDiscover", String.class),
                f.field("areas", new TypeReference<List<String>>() { }), f.field("heuristics", new TypeReference<List<String>>() { }),
                f.field("timeboxMin", Integer.class), f.field("setupNotes", String.class), f.field("targetedRisk", String.class),
                includeTitle ? f.field("technique", TestTechnique.class) : null,
                includeTitle ? f.field("framework", String.class) : null,
                f.field("language", String.class), f.field("repositoryUrl", String.class), f.field("branch", String.class),
                f.field("path", String.class), f.field("testIdentifier", String.class), f.field("gherkinSource", String.class),
                f.field("dataSets", new TypeReference<List<TestCaseDtos.DataSetDto>>() { }) == null ? null
                        : f.field("dataSets", new TypeReference<List<TestCaseDtos.DataSetDto>>() { })
                        .map(list -> list.stream().map(d -> new DataSet(d.name(), d.rows())).toList()),
                f.field("configuration", new TypeReference<Map<String, Object>>() { }),
                f.field("executionTags", new TypeReference<List<String>>() { }),
                f.field("environmentRequirements", new TypeReference<Map<String, String>>() { }));
    }

    private static List<LinkDraft> linkDrafts(java.util.Optional<List<LinkRequest>> requests) {
        if (requests == null) {
            return List.of();
        }
        return requests.orElse(List.of()).stream()
                .map(l -> new LinkDraft(l.requirementKey(), l.linkType(), l.criterionPositions())).toList();
    }

    private static <T> T fieldValue(java.util.Optional<T> field) {
        return field == null ? null : field.orElse(null);
    }
}
