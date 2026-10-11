package com.traceagile.application.automation;

import com.traceagile.application.audit.AuditService;
import com.traceagile.application.automation.AutomationRepositories.AutomatedRunRepository;
import com.traceagile.application.automation.AutomationRepositories.ProcessedWebhookEventRepository;
import com.traceagile.application.automation.AutomationRepositories.RunArtifactRepository;
import com.traceagile.application.automation.ExecutionServerClient.JobRequest;
import com.traceagile.application.automation.ExecutionServerClient.JobTest;
import com.traceagile.application.automation.ExecutionServerClient.ServerConnection;
import com.traceagile.application.campaign.CampaignService;
import com.traceagile.application.common.KeyGenerator;
import com.traceagile.application.requirement.NfrMeasurementService;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.execution.ExecutionRepository;
import com.traceagile.domain.audit.AuditAction;
import com.traceagile.domain.automation.AutomatedRun;
import com.traceagile.domain.automation.ExecutionServer;
import com.traceagile.domain.automation.ProcessedWebhookEvent;
import com.traceagile.domain.automation.RunArtifact;
import com.traceagile.domain.automation.RunStatus;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.testcase.AutomatedTestDefinition;
import com.traceagile.domain.testcase.DataSet;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestTechnique;
import java.time.Clock;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * §8.5 runs automatisés (ADR-0020) : lancement (F-EXE-06), envoi au serveur hors transaction (§10.3),
 * webhooks signés et idempotents (§10.4), annulation (F-EXE-08), relance des échecs (F-EXE-09),
 * polling de secours puis TIMEOUT. Chaque changement publie {@link RunChanged} (temps réel, F-EXE-07).
 */
@Service
public class AutomatedRunService {

    /** Publié à chaque changement d'un run (diffusé en SSE après validation de la transaction). */
    public record RunChanged(String projectKey, String runKey, String campaignKey) {
    }

    public record LaunchCommand(UUID serverId, List<UUID> itemIds, Integer timeoutMinutes) {
    }

    /** Signature de webhook absente ou invalide → 401. */
    public static class InvalidSignatureException extends RuntimeException {
        public InvalidSignatureException() {
            super("Signature du webhook invalide.");
        }
    }

    public static final String AUDIT_TYPE = "RUN";
    private static final Logger LOG = LoggerFactory.getLogger(AutomatedRunService.class);
    private static final int DEFAULT_TIMEOUT = 30;

    private final AutomatedRunRepository runs;
    private final ExecutionRepository executions;
    private final ProcessedWebhookEventRepository processed;
    private final RunArtifactRepository artifacts;
    private final CampaignService campaigns;
    private final ExecutionServerService servers;
    private final ExecutionServerClient client;
    private final FlakyService flaky;
    private final KeyGenerator keys;
    private final AuditService audit;
    private final ApplicationEventPublisher events;
    private final TransactionTemplate tx;
    private final Clock clock;
    private final String callbackUrl;

    private final NfrMeasurementService measurements;

    public AutomatedRunService(AutomatedRunRepository runs, ExecutionRepository executions, ProcessedWebhookEventRepository processed,
                               RunArtifactRepository artifacts, NfrMeasurementService measurements,
                               CampaignService campaigns, ExecutionServerService servers, ExecutionServerClient client, FlakyService flaky,
                               KeyGenerator keys, AuditService audit, ApplicationEventPublisher events, PlatformTransactionManager transactions,
                               Clock clock, @Value("${traceagile.automation.callback-url:http://localhost:8085/api/v1/execution-callbacks}") String callbackUrl) {
        this.runs = runs;
        this.executions = executions;
        this.processed = processed;
        this.artifacts = artifacts;
        this.measurements = measurements;
        this.campaigns = campaigns;
        this.servers = servers;
        this.client = client;
        this.flaky = flaky;
        this.keys = keys;
        this.audit = audit;
        this.events = events;
        this.tx = new TransactionTemplate(transactions);
        this.clock = clock;
        this.callbackUrl = callbackUrl;
    }

    // ---------------------------------------------------------------- lecture

    @Transactional(readOnly = true)
    public AutomatedRun get(String projectKey, String runKey) {
        return runs.findByProject_KeyAndKey(projectKey, runKey)
                .orElseThrow(() -> new NotFoundException("RUN_NOT_FOUND", "Run « " + runKey + " » introuvable."));
    }

    @Transactional(readOnly = true)
    public List<AutomatedRun> ofCampaign(String projectKey, String campaignKey) {
        return runs.findByCampaign_IdOrderByKeyNumberDesc(campaigns.get(projectKey, campaignKey).getId());
    }

    @Transactional(readOnly = true)
    public List<AutomatedRun> ofProject(String projectKey) {
        return runs.findByProject_KeyOrderByKeyNumberDesc(projectKey);
    }

    /** Tentatives du run, dans l'ordre de la campagne. */
    @Transactional(readOnly = true)
    public List<Execution> executionsOf(AutomatedRun run) {
        return executions.findByRun_Id(run.getId()).stream().sorted(Comparator.comparingInt(e -> e.getItem().getPosition())).toList();
    }

    // ---------------------------------------------------------------- lancement (F-EXE-06, F-EXE-09)

    /** F-EXE-06 crée le run QUEUED et ses tentatives ; l'envoi au serveur suit ({@link #dispatch}). */
    @Transactional
    public AutomatedRun launch(String projectKey, String campaignKey, LaunchCommand command, String login) {
        Campaign campaign = campaigns.get(projectKey, campaignKey);
        List<CampaignItem> items;
        if (command.itemIds() == null || command.itemIds().isEmpty()) {
            items = campaign.getItems().stream().filter(i -> i.getTestCase().getKind() == TestKind.AUTOMATED).toList();
        } else {
            items = command.itemIds().stream().map(id -> campaign.getItems().stream().filter(i -> i.getId().equals(id)).findFirst()
                    .orElseThrow(() -> new NotFoundException("CAMPAIGN_ITEM_NOT_FOUND", "Test de campagne introuvable dans " + campaignKey + "."))).toList();
        }
        return queue(campaign, items, command, login, null);
    }

    /** F-EXE-09 nouveau run avec les seuls tests en échec (ou en erreur) du run donné. */
    @Transactional
    public AutomatedRun rerunFailed(String projectKey, String runKey, String login) {
        AutomatedRun source = get(projectKey, runKey);
        if (!source.isFinal()) {
            throw new BusinessRuleException("RUN_NOT_FINISHED", "Attendez la fin du run " + runKey + " avant de relancer ses échecs.");
        }
        List<CampaignItem> failed = executionsOf(source).stream()
                .filter(e -> e.getStatus() == ExecutionStatus.FAILED || e.getStatus() == ExecutionStatus.ERROR)
                .map(Execution::getItem).distinct().toList();
        if (failed.isEmpty()) {
            throw new BusinessRuleException("RUN_NOTHING_TO_RERUN", "Le run " + runKey + " n'a aucun test en échec.");
        }
        return queue(source.getCampaign(), failed, new LaunchCommand(source.getServer().getId(), null, source.getTimeoutMinutes()), login, runKey);
    }

    private AutomatedRun queue(Campaign campaign, List<CampaignItem> items, LaunchCommand command, String login, String rerunOf) {
        ExecutionServer server = servers.get(command.serverId());
        server.ensureUsable();
        if (items.isEmpty()) {
            throw new BusinessRuleException("RUN_NO_TEST", "Aucun test automatisé à lancer dans " + campaign.getKey() + ".");
        }
        List<String> notAutomated = items.stream().filter(i -> i.getTestCase().getKind() != TestKind.AUTOMATED).map(i -> i.getTestCase().getKey()).toList();
        if (!notAutomated.isEmpty()) {
            throw new BusinessRuleException("RUN_TEST_NOT_AUTOMATED", "Seuls les tests automatisés partent sur un serveur : " + String.join(", ", notAutomated) + ".");
        }
        List<String> busy = items.stream().filter(i -> i.latest() != null && !i.latest().isFinal()).map(i -> i.getTestCase().getKey()).toList();
        if (!busy.isEmpty()) {
            throw new BusinessRuleException("RUN_ITEM_BUSY", "Tests déjà en cours d'exécution : " + String.join(", ", busy) + ".");
        }
        Set<TestTechnique> unsupported = new java.util.TreeSet<>();
        items.forEach(i -> {
            TestTechnique technique = i.getTestCase().getAutomation().getTechnique();
            if (!server.supports(technique)) {
                unsupported.add(technique);
            }
        });
        if (!unsupported.isEmpty()) {
            throw new BusinessRuleException("RUN_TECHNIQUE_UNSUPPORTED", "Le serveur « " + server.getName() + " » ne sait pas exécuter : " + unsupported + ".");
        }
        Instant now = clock.instant();
        int timeout = command.timeoutMinutes() == null ? DEFAULT_TIMEOUT : command.timeoutMinutes();
        AutomatedRun run = runs.save(AutomatedRun.queue(campaign.getProject(), keys.next(campaign.getProject(), "RUN"), campaign, server, login, now, timeout));
        if (rerunOf != null) {
            run.markRerunOf(rerunOf);
        }
        items.forEach(item -> executions.save(Execution.automated(item, run, now)));
        audit.record(campaign.getProject().getId(), AUDIT_TYPE, run.getId(), run.getKey(), AuditAction.CREATED, Map.of(), snapshot(run));
        publish(run);
        return run;
    }

    /**
     * §10.3 envoie le job au serveur, hors transaction (les webhooks peuvent arriver avant la réponse) :
     * le run passe DISPATCHED, ou FAILED si le serveur refuse ou ne répond pas.
     */
    public void dispatch(String projectKey, String runKey) {
        record Prepared(ServerConnection connection, JobRequest job) {
        }
        Prepared prepared = tx.execute(status -> {
            AutomatedRun run = get(projectKey, runKey);
            return new Prepared(servers.connection(run.getServer()), job(run));
        });
        String jobId;
        try {
            jobId = client.submit(prepared.connection(), prepared.job());
        } catch (ExecutionServerClient.UnauthorizedException e) {
            fail(projectKey, runKey, "SERVER_UNAUTHORIZED", "Le serveur refuse le jeton : appairez-le à nouveau.", true);
            return;
        } catch (RuntimeException e) {
            fail(projectKey, runKey, "SERVER_UNREACHABLE", "Envoi au serveur impossible : " + e.getMessage(), false);
            return;
        }
        for (int attempt = 0; attempt < 3; attempt++) {
            try {
                tx.executeWithoutResult(status -> {
                    AutomatedRun run = get(projectKey, runKey);
                    if (!run.isFinal()) {
                        run.dispatched(jobId, clock.instant());
                        publish(run);
                    }
                });
                return;
            } catch (OptimisticLockingFailureException e) {
                LOG.debug("Run {} modifié par un webhook pendant l'envoi : nouvel essai", runKey);
            }
        }
    }

    private void fail(String projectKey, String runKey, String code, String message, boolean unauthorized) {
        tx.executeWithoutResult(status -> {
            AutomatedRun run = get(projectKey, runKey);
            if (unauthorized) {
                run.getServer().reportUnauthorized(clock.instant());
            }
            if (!run.isFinal()) {
                run.failed(code, message, clock.instant());
                abandonPending(run, ExecutionStatus.ERROR, message);
                publish(run);
            }
        });
    }

    private JobRequest job(AutomatedRun run) {
        List<Execution> pending = executionsOf(run);
        String repository = null;
        String branch = null;
        List<JobTest> tests = new ArrayList<>();
        for (Execution execution : pending) {
            AutomatedTestDefinition def = execution.getTestCase().getAutomation();
            repository = repository == null ? def.getRepositoryUrl() : repository;
            branch = branch == null ? def.getBranch() : branch;
            List<String> tags = new ArrayList<>(def.getExecutionTags());
            execution.getTestCase().getTags().forEach(tags::add);
            Map<String, Object> dataSet = null;
            List<DataSet> sets = execution.getTestCase().getDataSets();
            if (!sets.isEmpty()) {
                dataSet = new LinkedHashMap<>();
                dataSet.put("name", sets.getFirst().name());
                dataSet.put("rows", sets.getFirst().rows());
            }
            tests.add(new JobTest(execution.getId().toString(), execution.getTestCase().getKey(), def.getTechnique(), def.getFramework(),
                    def.getPath(), def.getTestIdentifier(), def.getGherkinSource(), dataSet, def.getParameters(), tags.stream().distinct().toList()));
        }
        Campaign campaign = run.getCampaign();
        return new JobRequest(runId(run), run.getProject().getKey(), campaign.getKey(), run.getEnvironment(), run.getBuildVersion(), callbackUrl,
                repository, branch, tests, run.getTimeoutMinutes(), 4, 0);
    }

    /**
     * ADR-0020 identifiant du run pour le serveur, qualifié par le projet (« SHOP/RUN-1 ») : un serveur
     * partagé par plusieurs projets rend le même job pour le même runId (idempotence §10.1).
     */
    static String runId(AutomatedRun run) {
        return run.getProject().getKey() + "/" + run.getKey();
    }

    // ---------------------------------------------------------------- webhooks (§10.4)

    /**
     * §10.4 vérifie la signature HMAC avec le secret du serveur du run ({@code runId} inconnu : 404),
     * ignore un événement déjà traité (eventId), puis l'applique.
     */
    @Transactional
    public void receive(RunEvent event, byte[] body, String signature) {
        int slash = event.runId().indexOf('/');
        List<AutomatedRun> candidates = slash < 0
                ? runs.findByKey(event.runId()) // runId d'avant la qualification par le projet
                : runs.findByProject_KeyAndKey(event.runId().substring(0, slash), event.runId().substring(slash + 1)).stream().toList();
        if (candidates.isEmpty()) {
            throw new NotFoundException("RUN_NOT_FOUND", "Run « " + event.runId() + " » inconnu.");
        }
        AutomatedRun run = candidates.stream()
                .filter(r -> com.traceagile.domain.automation.WebhookSignature.verify(servers.webhookSecret(r.getServer()), body, signature))
                .filter(r -> event.jobId() == null || r.getExternalJobId() == null || r.getExternalJobId().equals(event.jobId()))
                .findFirst().orElseThrow(InvalidSignatureException::new);
        if (event.eventId() == null || processed.existsById(event.eventId())) {
            return;
        }
        processed.save(new ProcessedWebhookEvent(event.eventId(), run.getId(), clock.instant()));
        apply(run, event);
    }

    private void apply(AutomatedRun run, RunEvent event) {
        if (run.isFinal()) {
            return; // événement tardif d'un run annulé, expiré ou terminé
        }
        Instant at = event.occurredAt() == null ? clock.instant() : event.occurredAt();
        event.artifacts().forEach(ref -> remember(run, ref));
        switch (event.event()) {
            case "JOB_STARTED" -> run.started(event.agent(), at);
            case "TEST_STARTED" -> execution(run, event.executionId()).ifPresent(e -> {
                e.automatedStarted(at);
                run.touch(at);
            });
            case "TEST_FINISHED" -> execution(run, event.executionId()).ifPresent(e -> {
                if (!e.isFinal()) {
                    e.automatedFinished(ExecutionStatus.valueOf(event.status()), event.durationMs(), message(event), at);
                    flaky.recompute(e.getTestCase());
                    measurements.fromRun(e, run.getKey(), event.metrics(), at);
                }
                run.touch(at);
            });
            case "JOB_FINISHED" -> {
                if ("CANCELLED".equals(event.status())) {
                    run.cancel(at);
                    abandonPending(run, ExecutionStatus.SKIPPED, "Job annulé par le serveur");
                } else {
                    run.finished("FAILED".equals(event.status()) ? RunStatus.FAILED : RunStatus.COMPLETED, event.summary(), event.reportUrl(),
                            event.logsUrl(), at);
                    abandonPending(run, ExecutionStatus.SKIPPED, "Non exécuté par le serveur");
                }
            }
            case "JOB_ERROR" -> {
                run.failed(event.errorCode(), event.message(), at);
                abandonPending(run, ExecutionStatus.ERROR, event.message());
            }
            default -> LOG.info("Événement {} ignoré pour le run {}", event.event(), run.getKey());
        }
        publish(run);
    }

    // ---------------------------------------------------------------- artefacts (ADR-0021)

    /**
     * ADR-0021 artefacts du run : ceux annoncés par les webhooks, complétés par la liste du serveur
     * (s'il répond) une fois le run terminé — avant, un webhook pourrait enregistrer le même artefact
     * en même temps ; dans l'ordre : copies d'écran, puis traces, résultats et rapports.
     */
    @Transactional
    public List<RunArtifact> artifactsOf(String projectKey, String runKey) {
        AutomatedRun run = get(projectKey, runKey);
        if (run.isFinal() && run.getExternalJobId() != null && run.getServer().isPaired()) {
            try {
                client.artifacts(servers.connection(run.getServer()), run.getExternalJobId()).forEach(ref -> remember(run, ref));
            } catch (RuntimeException e) {
                LOG.info("Liste des artefacts du run {} indisponible : {}", runKey, e.getMessage());
            }
        }
        return artifacts.findByRun_Id(run.getId()).stream()
                .sorted(Comparator.comparing((RunArtifact a) -> a.getKind() != RunArtifact.Kind.SCREENSHOT).thenComparing(RunArtifact::getName))
                .toList();
    }

    /** ADR-0021 contenu d'un artefact, relu sur le serveur avec le jeton qu'il a émis. */
    @Transactional(readOnly = true)
    public ExecutionServerClient.ArtifactContent artifact(String projectKey, String runKey, String name) {
        AutomatedRun run = get(projectKey, runKey);
        RunArtifact artifact = artifacts.findByRun_IdAndName(run.getId(), name)
                .orElseThrow(() -> new NotFoundException("ARTIFACT_NOT_FOUND", "Artefact « " + name + " » inconnu pour le run " + runKey + "."));
        if (run.getExternalJobId() == null) {
            throw new NotFoundException("ARTIFACT_NOT_FOUND", "Le run " + runKey + " n'a pas de job sur le serveur.");
        }
        try {
            ExecutionServerClient.ArtifactContent content = client.download(servers.connection(run.getServer()), run.getExternalJobId(), name);
            return new ExecutionServerClient.ArtifactContent(content.content(),
                    content.contentType() == null ? artifact.getContentType() : content.contentType());
        } catch (ExecutionServerClient.UnauthorizedException e) {
            throw new BusinessRuleException("SERVER_UNAUTHORIZED", "Le serveur refuse le jeton : appairez-le à nouveau.");
        } catch (ExecutionServerClient.UnavailableException e) {
            throw new BusinessRuleException("ARTIFACT_UNAVAILABLE", "Artefact indisponible sur le serveur : " + e.getMessage());
        }
    }

    /** Copie d'écran d'une tentative (nom de l'artefact), s'il y en a une. */
    @Transactional(readOnly = true)
    public Map<UUID, String> screenshotsOf(AutomatedRun run) {
        Map<UUID, String> byExecution = new LinkedHashMap<>();
        artifacts.findByRun_Id(run.getId()).stream()
                .filter(a -> a.getKind() == RunArtifact.Kind.SCREENSHOT && a.getExecution() != null)
                .forEach(a -> byExecution.putIfAbsent(a.getExecution().getId(), a.getName()));
        return byExecution;
    }

    private void remember(AutomatedRun run, RunEvent.ArtifactRef ref) {
        if (ref.name() == null || ref.name().isBlank() || ref.name().contains("/") || ref.name().contains("..")
                || artifacts.findByRun_IdAndName(run.getId(), ref.name()).isPresent()) {
            return;
        }
        Execution execution = ref.executionId() == null ? null : execution(run, ref.executionId()).orElse(null);
        artifacts.save(new RunArtifact(run, execution, ref.name(), ref.type(), RunArtifact.Kind.of(ref.kind(), ref.name()), ref.size()));
    }

    private java.util.Optional<Execution> execution(AutomatedRun run, String executionId) {
        try {
            return executions.findById(UUID.fromString(executionId)).filter(e -> e.getRun() != null && e.getRun().getId().equals(run.getId()));
        } catch (IllegalArgumentException | NullPointerException e) {
            return java.util.Optional.empty();
        }
    }

    private static String message(RunEvent event) {
        if (event.message() == null) {
            return null;
        }
        return event.stackTrace() == null ? event.message() : event.message() + "\n" + event.stackTrace();
    }

    private void abandonPending(AutomatedRun run, ExecutionStatus status, String reason) {
        executions.findByRun_Id(run.getId()).forEach(e -> e.abandon(status, reason, clock.instant()));
    }

    // ---------------------------------------------------------------- annulation, timeout (F-EXE-08, §10.4)

    /** F-EXE-08 annule le run (et le job, au mieux) ; les tests non terminés sont « ignorés ». */
    @Transactional
    public AutomatedRun cancel(String projectKey, String runKey, String login) {
        AutomatedRun run = get(projectKey, runKey);
        if (run.isFinal()) {
            throw new BusinessRuleException("RUN_FINISHED", "Le run " + runKey + " est terminé (" + run.getStatus() + ").");
        }
        Map<String, Object> before = snapshot(run);
        if (run.getExternalJobId() != null) {
            try {
                client.cancel(servers.connection(run.getServer()), run.getExternalJobId());
            } catch (RuntimeException e) {
                LOG.warn("Annulation du job {} sur {} impossible : {}", run.getExternalJobId(), run.getServer().getName(), e.getMessage());
            }
        }
        run.cancel(clock.instant());
        abandonPending(run, ExecutionStatus.SKIPPED, "Run annulé par " + login);
        audit.record(run.getProject().getId(), AUDIT_TYPE, run.getId(), run.getKey(), AuditAction.STATUS_CHANGED, before, snapshot(run));
        publish(run);
        return run;
    }

    /**
     * §10.4 tâche planifiée (chaque minute) : un run sans nouvelles depuis timeoutMinutes + 5 min est
     * d'abord relu par polling (§10.1) ; s'il reste sans résultat, il passe TIMEOUT.
     */
    public void checkTimeouts() {
        List<String[]> overdue = tx.execute(status -> runs.findByStatusIn(List.of(RunStatus.QUEUED, RunStatus.DISPATCHED, RunStatus.RUNNING)).stream()
                .filter(r -> r.isOverdue(clock.instant())).map(r -> new String[] {r.getProject().getKey(), r.getKey()}).toList());
        for (String[] key : overdue == null ? List.<String[]>of() : overdue) {
            poll(key[0], key[1]);
            tx.executeWithoutResult(status -> {
                AutomatedRun run = get(key[0], key[1]);
                if (run.isOverdue(clock.instant())) {
                    run.timeout(clock.instant());
                    abandonPending(run, ExecutionStatus.ERROR, run.getErrorMessage());
                    publish(run);
                }
            });
        }
    }

    /** §10.1 mode polling : applique les événements que le serveur a émis mais qui ne sont pas arrivés. */
    public void poll(String projectKey, String runKey) {
        record Target(ServerConnection connection, String jobId) {
        }
        Target target = tx.execute(status -> {
            AutomatedRun run = get(projectKey, runKey);
            return run.getExternalJobId() == null || !run.getServer().isPaired() ? null : new Target(servers.connection(run.getServer()), run.getExternalJobId());
        });
        if (target == null) {
            return;
        }
        List<RunEvent> missed;
        try {
            missed = client.poll(target.connection(), target.jobId());
        } catch (RuntimeException e) {
            LOG.info("Polling du run {} impossible : {}", runKey, e.getMessage());
            return;
        }
        tx.executeWithoutResult(status -> {
            AutomatedRun run = get(projectKey, runKey);
            for (RunEvent event : missed) {
                if (event.eventId() != null && !processed.existsById(event.eventId())) {
                    processed.save(new ProcessedWebhookEvent(event.eventId(), run.getId(), clock.instant()));
                    apply(run, event);
                }
            }
        });
    }

    /** F-EXE-07 journaux du job (texte), lus sur le serveur. */
    @Transactional(readOnly = true)
    public String logs(String projectKey, String runKey) {
        AutomatedRun run = get(projectKey, runKey);
        if (run.getExternalJobId() == null) {
            return "";
        }
        try {
            return client.logs(servers.connection(run.getServer()), run.getExternalJobId());
        } catch (RuntimeException e) {
            return "Journaux indisponibles : " + e.getMessage();
        }
    }

    private void publish(AutomatedRun run) {
        events.publishEvent(new RunChanged(run.getProject().getKey(), run.getKey(), run.getCampaign().getKey()));
    }

    private static Map<String, Object> snapshot(AutomatedRun run) {
        Map<String, Object> s = new LinkedHashMap<>();
        s.put("status", run.getStatus().name());
        s.put("server", run.getServer().getName());
        s.put("campaign", run.getCampaign().getKey());
        s.put("rerunOf", run.getRerunOf());
        return s;
    }
}
