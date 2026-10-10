package com.traceagile.api.automation;

import com.traceagile.api.automation.AutomationDtos.ReportImportLine;
import com.traceagile.api.automation.AutomationDtos.ReportImportResponse;
import com.traceagile.api.automation.AutomationDtos.LaunchRunRequest;
import com.traceagile.api.automation.AutomationDtos.RunArtifactResponse;
import com.traceagile.api.automation.AutomationDtos.RunDetail;
import com.traceagile.api.automation.AutomationDtos.RunSummaryResponse;
import com.traceagile.application.automation.AutomatedRunService;
import com.traceagile.application.automation.AutomatedRunService.LaunchCommand;
import com.traceagile.application.automation.ExecutionServerClient.ArtifactContent;
import com.traceagile.application.automation.ReportImportService;
import com.traceagile.application.automation.ReportImportService.ImportResult;
import com.traceagile.application.automation.ReportParser.ReportFormat;
import com.traceagile.domain.automation.AutomatedRun;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.io.IOException;
import java.net.URI;
import java.util.List;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

/** §12 Runs automatisés (§8.5 F-EXE-06 à F-EXE-09), temps réel (F-EXE-07), import de rapports (F-EXE-10). */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}")
@Tag(name = "Runs automatisés")
public class RunController {

    static final String READ = "hasPermission(#projectKey, 'Project', 'EXECUTION_READ')";
    /** §2.2 « Lancer des runs automatisés » : développeur et administrateur. */
    static final String LAUNCH = "hasPermission(#projectKey, 'Project', 'AUTOMATED_RUN_LAUNCH')";
    /** F-EXE-10 import : qui saisit des résultats ou lance des runs. */
    static final String IMPORT = "hasPermission(#projectKey, 'Project', 'EXECUTION_WRITE') or hasPermission(#projectKey, 'Project', 'AUTOMATED_RUN_LAUNCH')";

    private final AutomatedRunService runs;
    private final ReportImportService imports;
    private final RunEventStreams streams;
    private final AutomationMapper mapper;

    public RunController(AutomatedRunService runs, ReportImportService imports, RunEventStreams streams, AutomationMapper mapper) {
        this.runs = runs;
        this.imports = imports;
        this.streams = streams;
        this.mapper = mapper;
    }

    /** F-EXE-06 « Lancer sur… » : run QUEUED puis envoyé au serveur (DISPATCHED, ou FAILED s'il refuse). */
    @PostMapping("/campaigns/{campaignKey}/runs")
    @PreAuthorize(LAUNCH)
    public ResponseEntity<RunDetail> launch(@PathVariable String projectKey, @PathVariable String campaignKey, @Valid @RequestBody LaunchRunRequest r,
                                            Authentication authentication) {
        AutomatedRun run = runs.launch(projectKey, campaignKey, new LaunchCommand(r.serverId(), r.itemIds(), r.timeoutMinutes()), authentication.getName());
        runs.dispatch(projectKey, run.getKey());
        return created(projectKey, run.getKey());
    }

    @GetMapping("/campaigns/{campaignKey}/runs")
    @PreAuthorize(READ)
    public List<RunSummaryResponse> ofCampaign(@PathVariable String projectKey, @PathVariable String campaignKey) {
        return runs.ofCampaign(projectKey, campaignKey).stream().map(run -> mapper.summary(run, runs.executionsOf(run))).toList();
    }

    @GetMapping("/runs")
    @PreAuthorize(READ)
    public List<RunSummaryResponse> ofProject(@PathVariable String projectKey) {
        return runs.ofProject(projectKey).stream().map(run -> mapper.summary(run, runs.executionsOf(run))).toList();
    }

    @GetMapping("/runs/{runKey}")
    @PreAuthorize(READ)
    public RunDetail get(@PathVariable String projectKey, @PathVariable String runKey) {
        AutomatedRun run = runs.get(projectKey, runKey);
        return mapper.detail(run, runs.executionsOf(run), runs.screenshotsOf(run));
    }

    /** F-EXE-08 annulation. */
    @PostMapping("/runs/{runKey}/cancel")
    @PreAuthorize(LAUNCH)
    public RunDetail cancel(@PathVariable String projectKey, @PathVariable String runKey, Authentication authentication) {
        AutomatedRun run = runs.cancel(projectKey, runKey, authentication.getName());
        return mapper.detail(run, runs.executionsOf(run), runs.screenshotsOf(run));
    }

    /** F-EXE-09 relance des seuls tests en échec : nouveau run. */
    @PostMapping("/runs/{runKey}/rerun-failed")
    @PreAuthorize(LAUNCH)
    public ResponseEntity<RunDetail> rerunFailed(@PathVariable String projectKey, @PathVariable String runKey, Authentication authentication) {
        AutomatedRun run = runs.rerunFailed(projectKey, runKey, authentication.getName());
        runs.dispatch(projectKey, run.getKey());
        return created(projectKey, run.getKey());
    }

    /** F-EXE-07 flux temps réel d'un run (événement « run » à chaque changement). */
    @GetMapping(path = "/runs/{runKey}/events", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    @PreAuthorize(READ)
    public SseEmitter events(@PathVariable String projectKey, @PathVariable String runKey) {
        runs.get(projectKey, runKey);
        return streams.forRun(projectKey, runKey);
    }

    /** F-EXE-07 flux temps réel des runs d'une campagne. */
    @GetMapping(path = "/campaigns/{campaignKey}/run-events", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    @PreAuthorize(READ)
    public SseEmitter campaignEvents(@PathVariable String projectKey, @PathVariable String campaignKey) {
        return streams.forCampaign(projectKey, campaignKey);
    }

    /** F-EXE-07 journaux du job (texte), lus sur le serveur. */
    @GetMapping(path = "/runs/{runKey}/logs", produces = MediaType.TEXT_PLAIN_VALUE)
    @PreAuthorize(READ)
    public String logs(@PathVariable String projectKey, @PathVariable String runKey) {
        return runs.logs(projectKey, runKey);
    }

    /** ADR-0021 artefacts du run : copies d'écran des échecs, traces système, résultats JUnit XML et Jest JSON, rapport. */
    @GetMapping("/runs/{runKey}/artifacts")
    @PreAuthorize(READ)
    public List<RunArtifactResponse> artifacts(@PathVariable String projectKey, @PathVariable String runKey) {
        return runs.artifactsOf(projectKey, runKey).stream().map(mapper::artifact).toList();
    }

    /** ADR-0021 contenu d'un artefact, relu sur le serveur d'exécution avec le jeton qu'il a émis. */
    @GetMapping("/runs/{runKey}/artifacts/{name:.+}")
    @PreAuthorize(READ)
    public ResponseEntity<byte[]> artifact(@PathVariable String projectKey, @PathVariable String runKey, @PathVariable String name,
                                           @RequestParam(defaultValue = "false") boolean download) {
        ArtifactContent content = runs.artifact(projectKey, runKey, name);
        MediaType type;
        try {
            type = MediaType.parseMediaType(content.contentType());
        } catch (RuntimeException e) {
            type = MediaType.APPLICATION_OCTET_STREAM;
        }
        ContentDisposition disposition = (download ? ContentDisposition.attachment() : ContentDisposition.inline()).filename(name).build();
        return ResponseEntity.ok().contentType(type).header(HttpHeaders.CONTENT_DISPOSITION, disposition.toString())
                .header("X-Content-Type-Options", "nosniff").body(content.content());
    }

    /** F-EXE-10 import d'un rapport : {@code apply=false} pour l'aperçu, {@code createUnknown} crée les tests inconnus. */
    @PostMapping(path = "/campaigns/{campaignKey}/imports", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize(IMPORT)
    public ReportImportResponse importReport(@PathVariable String projectKey, @PathVariable String campaignKey, @RequestPart("file") MultipartFile file,
                                       @RequestParam ReportFormat format, @RequestParam(defaultValue = "false") boolean apply,
                                       @RequestParam(defaultValue = "false") boolean createUnknown) throws IOException {
        ImportResult result = imports.importReport(projectKey, campaignKey, format, file.getBytes(), file.getOriginalFilename(), apply, createUnknown);
        return new ReportImportResponse(result.lines().stream().map(l -> new ReportImportLine(l.name(), l.identifier(), l.status(), l.durationMs(),
                l.message(), l.requirementKeys(), l.testKey(), l.matchedBy())).toList(), result.created(), result.recorded(), result.applied());
    }

    private ResponseEntity<RunDetail> created(String projectKey, String runKey) {
        AutomatedRun run = runs.get(projectKey, runKey);
        return ResponseEntity.created(URI.create("/api/v1/projects/" + projectKey + "/runs/" + runKey)).body(mapper.detail(run, runs.executionsOf(run), runs.screenshotsOf(run)));
    }
}
