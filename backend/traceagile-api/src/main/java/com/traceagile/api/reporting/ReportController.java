package com.traceagile.api.reporting;

import com.traceagile.api.reporting.ReportDtos.GenerateReportRequest;
import com.traceagile.api.reporting.ReportDtos.ReportDefinitionRequest;
import com.traceagile.api.reporting.ReportDtos.ReportDefinitionResponse;
import com.traceagile.api.reporting.ReportDtos.ReportDetailResponse;
import com.traceagile.api.reporting.ReportDtos.ReportSummaryResponse;
import com.traceagile.api.reporting.ReportDtos.VerdictRequest;
import com.traceagile.api.reporting.ReportDtos.VerdictRulesDto;
import com.traceagile.application.reporting.DashboardService;
import com.traceagile.application.reporting.ReportService;
import com.traceagile.application.reporting.ReportService.DefinitionCommand;
import com.traceagile.application.reporting.ReportService.GenerateCommand;
import com.traceagile.application.reporting.ReportService.Rendered;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.reporting.ReportDefinition;
import com.traceagile.domain.reporting.ReportFormat;
import com.traceagile.domain.reporting.ReportScopeType;
import com.traceagile.domain.reporting.ReportSnapshot;
import com.traceagile.domain.reporting.VerdictRules;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** §12 Rapports : tableau de bord (§9.1), bilans (§9.2, §9.3), rapports configurables et exports (F-RPT-03, F-RPT-04, ADR-0023). */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}")
@Tag(name = "Rapports")
public class ReportController {

    static final String READ = "hasPermission(#projectKey, 'Project', 'PROJECT_READ')";
    /** ADR-0023 définitions, génération, gel : administrateur, PO, testeur. */
    static final String WRITE = "hasPermission(#projectKey, 'Project', 'REPORT_WRITE')";
    /** §9.2 verdict « modifiable par le PO » : qui valide les exigences. */
    static final String VERDICT = "hasPermission(#projectKey, 'Project', 'REQUIREMENT_WRITE')";
    static final String ADMIN = "hasPermission(#projectKey, 'Project', 'PROJECT_ADMIN')";

    private final ReportService reports;
    private final DashboardService dashboards;

    public ReportController(ReportService reports, DashboardService dashboards) {
        this.reports = reports;
        this.dashboards = dashboards;
    }

    /** F-RPT-01 / F-RPT-02 widgets et séries du tableau de bord, en une requête. */
    @GetMapping("/dashboard")
    @PreAuthorize(READ)
    public DashboardService.Dashboard dashboard(@PathVariable String projectKey, Authentication authentication) {
        return dashboards.dashboard(projectKey, authentication.getName());
    }

    // ---------------------------------------------------------------- définitions

    @GetMapping("/report-definitions")
    @PreAuthorize(READ)
    public List<ReportDefinitionResponse> definitions(@PathVariable String projectKey) {
        return reports.definitions(projectKey).stream().map(ReportController::definition).toList();
    }

    @PostMapping("/report-definitions")
    @PreAuthorize(WRITE)
    @ResponseStatus(HttpStatus.CREATED)
    public ReportDefinitionResponse createDefinition(@PathVariable String projectKey, @Valid @RequestBody ReportDefinitionRequest r) {
        return definition(reports.createDefinition(projectKey, command(r)));
    }

    /** Remplacement complet (formulaire de la définition) ; une définition intégrée est refusée (422). */
    @PutMapping("/report-definitions/{id}")
    @PreAuthorize(WRITE)
    public ReportDefinitionResponse updateDefinition(@PathVariable String projectKey, @PathVariable UUID id, @Valid @RequestBody ReportDefinitionRequest r) {
        return definition(reports.updateDefinition(projectKey, id, command(r)));
    }

    @PostMapping("/report-definitions/{id}/duplicate")
    @PreAuthorize(WRITE)
    @ResponseStatus(HttpStatus.CREATED)
    public ReportDefinitionResponse duplicateDefinition(@PathVariable String projectKey, @PathVariable UUID id) {
        return definition(reports.duplicateDefinition(projectKey, id));
    }

    @DeleteMapping("/report-definitions/{id}")
    @PreAuthorize(WRITE)
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteDefinition(@PathVariable String projectKey, @PathVariable UUID id) {
        reports.deleteDefinition(projectKey, id);
    }

    // ---------------------------------------------------------------- rapports générés

    @PostMapping("/reports")
    @PreAuthorize(WRITE)
    @ResponseStatus(HttpStatus.CREATED)
    public ReportDetailResponse generate(@PathVariable String projectKey, @Valid @RequestBody GenerateReportRequest r, Authentication authentication) {
        return detail(reports.generate(projectKey, new GenerateCommand(r.definitionId(), r.scopeKey(), r.title()), authentication.getName()));
    }

    @GetMapping("/reports")
    @PreAuthorize(READ)
    public List<ReportSummaryResponse> list(@PathVariable String projectKey) {
        return reports.list(projectKey).stream().map(ReportController::summary).toList();
    }

    /** F-RPT-04 lien permanent d'un rapport (figé ou non). */
    @GetMapping("/reports/{reportKey}")
    @PreAuthorize(READ)
    public ReportDetailResponse get(@PathVariable String projectKey, @PathVariable String reportKey) {
        return detail(reports.get(projectKey, reportKey));
    }

    /** F-RPT-03 export : html, pdf, docx, xlsx, md, csv, json ; {@code download} : pièce jointe plutôt qu'affichage. */
    @GetMapping("/reports/{reportKey}/export")
    @PreAuthorize(READ)
    @Operation(summary = "Exporter un rapport (HTML, PDF, Word, Excel, Markdown, CSV, JSON)")
    public ResponseEntity<byte[]> export(@PathVariable String projectKey, @PathVariable String reportKey,
                                         @RequestParam(defaultValue = "pdf") String format, @RequestParam(defaultValue = "true") boolean download) {
        return file(reports.export(projectKey, reportKey, format(format)), download);
    }

    @PostMapping("/reports/{reportKey}/freeze")
    @PreAuthorize(WRITE)
    public ReportDetailResponse freeze(@PathVariable String projectKey, @PathVariable String reportKey, Authentication authentication) {
        return detail(reports.freeze(projectKey, reportKey, authentication.getName()));
    }

    @PutMapping("/reports/{reportKey}/verdict")
    @PreAuthorize(VERDICT)
    public ReportDetailResponse verdict(@PathVariable String projectKey, @PathVariable String reportKey, @Valid @RequestBody VerdictRequest r,
                                        Authentication authentication) {
        return detail(reports.overrideVerdict(projectKey, reportKey, r.verdict(), r.comment(), authentication.getName()));
    }

    @DeleteMapping("/reports/{reportKey}")
    @PreAuthorize(WRITE)
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable String projectKey, @PathVariable String reportKey) {
        reports.delete(projectKey, reportKey);
    }

    // ---------------------------------------------------------------- bilans à la demande (§12)

    /** §12 {@code GET /sprints/{key}/report?format=json} : bilan de sprint calculé à la demande. */
    @GetMapping("/sprints/{sprintKey}/report")
    @PreAuthorize(READ)
    public ResponseEntity<byte[]> sprintReview(@PathVariable String projectKey, @PathVariable String sprintKey,
                                               @RequestParam(defaultValue = "json") String format, @RequestParam(defaultValue = "false") boolean download,
                                               Authentication authentication) {
        return file(reports.review(projectKey, ReportScopeType.SPRINT, sprintKey, format(format), authentication.getName()), download);
    }

    @GetMapping("/releases/{releaseKey}/report")
    @PreAuthorize(READ)
    public ResponseEntity<byte[]> releaseReview(@PathVariable String projectKey, @PathVariable String releaseKey,
                                                @RequestParam(defaultValue = "json") String format, @RequestParam(defaultValue = "false") boolean download,
                                                Authentication authentication) {
        return file(reports.review(projectKey, ReportScopeType.RELEASE, releaseKey, format(format), authentication.getName()), download);
    }

    // ---------------------------------------------------------------- règles de verdict

    @GetMapping("/verdict-rules")
    @PreAuthorize(READ)
    public VerdictRulesDto verdictRules(@PathVariable String projectKey) {
        return rules(reports.verdictRules(projectKey));
    }

    @PutMapping("/verdict-rules")
    @PreAuthorize(ADMIN)
    public VerdictRulesDto updateVerdictRules(@PathVariable String projectKey, @Valid @RequestBody VerdictRulesDto r) {
        return rules(reports.updateVerdictRules(projectKey, new VerdictRules(r.goMinValidation(), r.reservedMinValidation(),
                r.goForbidsCriticalDefects(), r.goRequiresCriticalRequirements(), r.reservedForbidsBlockerDefects())));
    }

    // ---------------------------------------------------------------- correspondances

    /** « pdf », « PDF », « md » (Markdown), « word » (DOCX), « excel » (XLSX). */
    static ReportFormat format(String value) {
        String v = value == null ? "" : value.strip().toUpperCase(Locale.ROOT);
        return switch (v) {
            case "MD" -> ReportFormat.MARKDOWN;
            case "WORD" -> ReportFormat.DOCX;
            case "EXCEL" -> ReportFormat.XLSX;
            default -> {
                try {
                    yield ReportFormat.valueOf(v);
                } catch (IllegalArgumentException e) {
                    throw new BusinessRuleException("REPORT_FORMAT_UNSUPPORTED",
                            "Format « " + value + " » inconnu (html, pdf, docx, xlsx, md, csv, json).");
                }
            }
        };
    }

    private static ResponseEntity<byte[]> file(Rendered rendered, boolean download) {
        ContentDisposition disposition = (download ? ContentDisposition.attachment() : ContentDisposition.inline()).filename(rendered.fileName()).build();
        return ResponseEntity.ok().contentType(MediaType.parseMediaType(rendered.contentType()))
                .header(HttpHeaders.CONTENT_DISPOSITION, disposition.toString())
                .header("X-Content-Type-Options", "nosniff")
                .body(rendered.content());
    }

    private static DefinitionCommand command(ReportDefinitionRequest r) {
        return new DefinitionCommand(r.name(), r.description(), r.scopeType(), r.sections(), r.defaultFormat(), r.includeCharts(), r.includeDetails());
    }

    static ReportDefinitionResponse definition(ReportDefinition d) {
        return new ReportDefinitionResponse(d.getId(), d.getName(), d.getDescription(), d.getScopeType(), d.getSections(), d.getDefaultFormat(),
                d.isIncludeCharts(), d.isIncludeDetails(), d.isBuiltIn());
    }

    static ReportSummaryResponse summary(ReportSnapshot s) {
        return new ReportSummaryResponse(s.getKey(), s.getTitle(), s.getDefinitionName(), s.getScopeType(), s.getScope(), s.getScopeLabel(),
                s.getVerdict(), s.getComputedVerdict(), s.isFrozen(), s.getFrozenAt(), s.getFrozenBy(), s.getCreatedAt(), s.getCreatedBy());
    }

    private ReportDetailResponse detail(ReportSnapshot s) {
        return new ReportDetailResponse(summary(s), s.getSections(), s.isIncludeCharts(), s.isIncludeDetails(), s.getVerdictOverride(),
                s.getVerdictComment(), s.getVerdictBy(), s.getVerdictAt(), reports.data(s));
    }

    private static VerdictRulesDto rules(VerdictRules r) {
        return new VerdictRulesDto(r.goMinValidation(), r.reservedMinValidation(), r.goForbidsCriticalDefects(), r.goRequiresCriticalRequirements(),
                r.reservedForbidsBlockerDefects());
    }
}
