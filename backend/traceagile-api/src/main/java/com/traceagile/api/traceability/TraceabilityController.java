package com.traceagile.api.traceability;

import com.traceagile.api.testcase.TestPermissions;
import com.traceagile.api.traceability.TraceabilityDtos.CoverageResponse;
import com.traceagile.api.traceability.TraceabilityDtos.CreateLinkRequest;
import com.traceagile.api.traceability.TraceabilityDtos.ImpactResponse;
import com.traceagile.api.traceability.TraceabilityDtos.MatrixResponse;
import com.traceagile.api.traceability.TraceabilityDtos.OrphansResponse;
import com.traceagile.api.traceability.TraceabilityDtos.TraceLinkResponse;
import com.traceagile.api.traceability.TraceabilityDtos.TraceTreeResponse;
import com.traceagile.api.traceability.TraceabilityDtos.UpdateLinkRequest;
import com.traceagile.api.web.Versions;
import com.traceagile.application.common.UnprocessableException;
import com.traceagile.application.testcase.TestCaseService;
import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.application.traceability.TraceLinkService.LinkView;
import com.traceagile.application.traceability.TraceabilityService;
import com.traceagile.application.traceability.TraceabilityService.Matrix;
import com.traceagile.domain.testcase.TestKind;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.Set;
import java.util.UUID;
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
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * §12 Traçabilité et couverture (§7) : liens (F-TRA-01 à F-TRA-03), matrice et export (F-TRA-04,
 * F-TRA-08), arbre (F-TRA-05), orphelins (F-TRA-06), impact (F-TRA-07), indicateurs (§7.2).
 */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}")
@Tag(name = "Traçabilité")
public class TraceabilityController {

    static final String READ = "hasPermission(#projectKey, 'Project', 'REQUIREMENT_READ')";

    private final TraceLinkService links;
    private final TraceabilityService traceability;
    private final TestCaseService tests;
    private final TestPermissions permissions;
    private final TraceabilityMapper mapper;
    private final MatrixExporter exporter;

    public TraceabilityController(TraceLinkService links, TraceabilityService traceability, TestCaseService tests,
                                  TestPermissions permissions, TraceabilityMapper mapper, MatrixExporter exporter) {
        this.links = links;
        this.traceability = traceability;
        this.tests = tests;
        this.permissions = permissions;
        this.mapper = mapper;
        this.exporter = exporter;
    }

    // ---------------------------------------------------------------- liens

    /** F-TRA-01 lien depuis la fiche exigence ou la matrice : il faut pouvoir modifier le test (§2.2). */
    @PostMapping("/trace-links")
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public ResponseEntity<TraceLinkResponse> create(@PathVariable String projectKey, Authentication authentication,
                                                    @Valid @RequestBody CreateLinkRequest request) {
        permissions.checkWrite(authentication, projectKey, tests.get(projectKey, request.testKey()).getKind());
        LinkView view = links.link(projectKey, request.testKey(), request.requirementKey(), request.linkType(), request.criterionPositions());
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/trace-links/" + view.link().getId()))
                .eTag(Versions.etag(view.link())).body(mapper.toResponse(view));
    }

    /** F-TRA-02 changement de type (If-Match facultatif). */
    @PatchMapping(path = "/trace-links/{id}", consumes = {"application/merge-patch+json", "application/json"})
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public ResponseEntity<TraceLinkResponse> update(@PathVariable String projectKey, @PathVariable UUID id, Authentication authentication,
                                                    @RequestHeader(name = HttpHeaders.IF_MATCH, required = false) String ifMatch,
                                                    @Valid @RequestBody UpdateLinkRequest request) {
        checkWrite(authentication, projectKey, id);
        LinkView view = links.changeType(projectKey, id, request.linkType(), Versions.parseIfMatch(ifMatch));
        return ResponseEntity.ok().eTag(Versions.etag(view.link())).body(mapper.toResponse(view));
    }

    @DeleteMapping("/trace-links/{id}")
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public ResponseEntity<Void> delete(@PathVariable String projectKey, @PathVariable UUID id, Authentication authentication) {
        checkWrite(authentication, projectKey, id);
        links.unlink(projectKey, id);
        return ResponseEntity.noContent().build();
    }

    /** §3.3-7 le test a été revu : l'alerte de suspicion disparaît. */
    @PostMapping("/trace-links/{id}/review")
    @PreAuthorize(TestPermissions.WRITE_ANY)
    public TraceLinkResponse review(@PathVariable String projectKey, @PathVariable UUID id, Authentication authentication) {
        checkWrite(authentication, projectKey, id);
        return mapper.toResponse(links.review(projectKey, id));
    }

    // ---------------------------------------------------------------- vues

    /**
     * F-TRA-04 matrice exigences × tests. {@code scope} : {@code project} ou {@code requirement:REQ-n} ;
     * {@code tests=all} ajoute les tests non liés (pour créer un lien d'un clic).
     */
    @GetMapping("/traceability/matrix")
    @PreAuthorize(READ)
    public MatrixResponse matrix(@PathVariable String projectKey, @RequestParam(required = false) String scope,
                                 @RequestParam(defaultValue = "linked") String tests,
                                 @RequestParam(required = false) Set<TestKind> kind) {
        return mapper.toResponse(traceability.matrix(projectKey, scope, "all".equals(tests), kind));
    }

    /** F-TRA-08 export de la matrice en CSV ou en PDF. */
    @GetMapping(path = "/traceability/matrix/export", produces = {"text/csv", MediaType.APPLICATION_PDF_VALUE})
    @PreAuthorize(READ)
    public ResponseEntity<byte[]> export(@PathVariable String projectKey, @RequestParam(defaultValue = "csv") String format,
                                         @RequestParam(required = false) String scope,
                                         @RequestParam(defaultValue = "linked") String tests,
                                         @RequestParam(required = false) Set<TestKind> kind) {
        Matrix matrix = traceability.matrix(projectKey, scope, "all".equals(tests), kind);
        return switch (format) {
            case "csv" -> file(exporter.csv(matrix).getBytes(StandardCharsets.UTF_8), new MediaType("text", "csv", StandardCharsets.UTF_8),
                    projectKey + "-matrice.csv");
            case "pdf" -> file(exporter.pdf(matrix, projectKey), MediaType.APPLICATION_PDF, projectKey + "-matrice.pdf");
            default -> throw new UnprocessableException("EXPORT_FORMAT_UNKNOWN", "Format d'export inconnu : " + format + " (csv, pdf).");
        };
    }

    /** §7.2 les cinq indicateurs et le détail par exigence. */
    @GetMapping("/coverage")
    @PreAuthorize(READ)
    public CoverageResponse coverage(@PathVariable String projectKey, @RequestParam(required = false) String scope) {
        return mapper.toResponse(traceability.coverage(projectKey, scope));
    }

    /** F-TRA-06 rapport des orphelins. */
    @GetMapping("/traceability/orphans")
    @PreAuthorize(READ)
    public OrphansResponse orphans(@PathVariable String projectKey) {
        return mapper.toResponse(traceability.orphans(projectKey));
    }

    /** F-TRA-05 arbre de traçabilité d'une exigence. */
    @GetMapping("/requirements/{key}/trace-tree")
    @PreAuthorize(READ)
    public TraceTreeResponse traceTree(@PathVariable String projectKey, @PathVariable String key) {
        return mapper.toResponse(traceability.traceTree(projectKey, key));
    }

    /** F-TRA-07 analyse d'impact d'une exigence. */
    @GetMapping("/requirements/{key}/impact")
    @PreAuthorize(READ)
    public ImpactResponse impact(@PathVariable String projectKey, @PathVariable String key) {
        return mapper.toResponse(traceability.impact(projectKey, key));
    }

    private void checkWrite(Authentication authentication, String projectKey, UUID linkId) {
        permissions.checkWrite(authentication, projectKey, links.testOf(projectKey, linkId).getKind());
    }

    private static ResponseEntity<byte[]> file(byte[] body, MediaType type, String name) {
        return ResponseEntity.ok().contentType(type)
                .header(HttpHeaders.CONTENT_DISPOSITION, ContentDisposition.attachment().filename(name).build().toString())
                .body(body);
    }
}
