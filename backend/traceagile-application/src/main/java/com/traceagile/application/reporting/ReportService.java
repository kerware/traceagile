package com.traceagile.application.reporting;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.common.ConflictException;
import com.traceagile.application.common.KeyGenerator;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.planning.PlanningService.SprintClosed;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.reporting.ReportDefinition;
import com.traceagile.domain.reporting.ReportFormat;
import com.traceagile.domain.reporting.ReportScopeType;
import com.traceagile.domain.reporting.ReportSection;
import com.traceagile.domain.reporting.ReportSnapshot;
import com.traceagile.domain.reporting.Verdict;
import com.traceagile.domain.reporting.VerdictRules;
import java.text.Normalizer;
import java.time.Clock;
import java.time.Instant;
import java.util.EnumMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §9 / ADR-0023 rapports : définitions configurables, génération d'instantanés {@code RPT-n}, exports
 * dans tous les formats, gel (F-RPT-04), verdict modifié par le PO, bilan figé à la clôture du sprint.
 */
@Service
@Transactional
public class ReportService {

    private static final ObjectMapper JSON = JsonMapper.builder().build();

    private final ReportDefinitionRepository definitions;
    private final ReportSnapshotRepository snapshots;
    private final ProjectRepository projects;
    private final ReportCalculator calculator;
    private final KeyGenerator keys;
    private final Map<ReportFormat, ReportRenderer> renderers = new EnumMap<>(ReportFormat.class);
    private final Clock clock;

    public ReportService(ReportDefinitionRepository definitions, ReportSnapshotRepository snapshots, ProjectRepository projects,
                         ReportCalculator calculator, KeyGenerator keys, List<ReportRenderer> renderers, Clock clock) {
        this.definitions = definitions;
        this.snapshots = snapshots;
        this.projects = projects;
        this.calculator = calculator;
        this.keys = keys;
        this.clock = clock;
        renderers.forEach(r -> this.renderers.put(r.format(), r));
    }

    /** Champs d'une définition (création, modification). */
    public record DefinitionCommand(String name, String description, ReportScopeType scopeType, List<ReportSection> sections,
                                    ReportFormat defaultFormat, boolean includeCharts, boolean includeDetails) {
    }

    /** Génération : définition, sprint ou release visé ({@code null} pour le projet), titre facultatif. */
    public record GenerateCommand(UUID definitionId, String scopeKey, String title) {
    }

    /** Fichier produit. */
    public record Rendered(byte[] content, String contentType, String fileName) {
    }

    // ---------------------------------------------------------------- définitions

    /** Définitions du projet ; les deux définitions intégrées sont créées au premier accès. */
    public List<ReportDefinition> definitions(String projectKey) {
        Project project = project(projectKey);
        if (definitions.findByProject_KeyAndName(projectKey, ReportDefinition.SPRINT_REVIEW).isEmpty()) {
            definitions.save(ReportDefinition.sprintReview(project));
        }
        if (definitions.findByProject_KeyAndName(projectKey, ReportDefinition.RELEASE_REVIEW).isEmpty()) {
            definitions.save(ReportDefinition.releaseReview(project));
        }
        return definitions.findByProject_KeyOrderByBuiltInDescNameAsc(projectKey);
    }

    public ReportDefinition definition(String projectKey, UUID id) {
        return definitions.findByIdAndProject_Key(id, projectKey)
                .orElseThrow(() -> new NotFoundException("REPORT_DEFINITION_NOT_FOUND", "Définition de rapport introuvable."));
    }

    public ReportDefinition createDefinition(String projectKey, DefinitionCommand c) {
        ensureUniqueName(projectKey, c.name(), null);
        return definitions.save(new ReportDefinition(project(projectKey), c.name(), c.description(), c.scopeType(), c.sections(), c.defaultFormat(),
                c.includeCharts(), c.includeDetails()));
    }

    public ReportDefinition updateDefinition(String projectKey, UUID id, DefinitionCommand c) {
        ReportDefinition definition = definition(projectKey, id);
        definition.ensureEditable();
        ensureUniqueName(projectKey, c.name(), definition);
        definition.update(c.name(), c.description(), c.scopeType(), c.sections(), c.defaultFormat(), c.includeCharts(), c.includeDetails());
        return definition;
    }

    /** Copie modifiable d'une définition (intégrée ou non) : « Copie de … ». */
    public ReportDefinition duplicateDefinition(String projectKey, UUID id) {
        ReportDefinition source = definition(projectKey, id);
        String name = "Copie de " + source.getName();
        for (int n = 2; definitions.existsByProject_KeyAndNameIgnoreCase(projectKey, name); n++) {
            name = "Copie de " + source.getName() + " (" + n + ")";
        }
        return definitions.save(new ReportDefinition(source.getProject(), name, source.getDescription(), source.getScopeType(), source.getSections(),
                source.getDefaultFormat(), source.isIncludeCharts(), source.isIncludeDetails()));
    }

    public void deleteDefinition(String projectKey, UUID id) {
        ReportDefinition definition = definition(projectKey, id);
        definition.ensureEditable();
        definitions.delete(definition);
    }

    private void ensureUniqueName(String projectKey, String name, ReportDefinition self) {
        if (name == null) {
            return;
        }
        definitions.findByProject_KeyAndName(projectKey, name.strip())
                .filter(other -> self == null || !other.getId().equals(self.getId()))
                .ifPresent(other -> {
                    throw new ConflictException("REPORT_DEFINITION_DUPLICATE", "Une définition « " + name.strip() + " » existe déjà.");
                });
    }

    // ---------------------------------------------------------------- génération, consultation

    /** ADR-0023 génère un instantané {@code RPT-n} (non figé). */
    public ReportSnapshot generate(String projectKey, GenerateCommand command, String login) {
        ReportDefinition definition = definition(projectKey, command.definitionId());
        ReportCalculator.Computed computed = calculator.compute(projectKey, definition.getScopeType(), command.scopeKey(), definition.getSections(), login);
        String title = command.title() == null || command.title().isBlank()
                ? definition.getName() + " — " + computed.scopeLabel() : command.title();
        return save(definition, computed, title);
    }

    private ReportSnapshot save(ReportDefinition definition, ReportCalculator.Computed computed, String title) {
        Project project = definition.getProject();
        boolean withVerdict = definition.getSections().contains(ReportSection.SUMMARY) || definition.getSections().contains(ReportSection.RECOMMENDATION);
        ReportSnapshot snapshot = new ReportSnapshot(project, keys.next(project, "RPT"), title, definition.getName(), definition.getScopeType(),
                computed.scope(), computed.scopeLabel(), applicable(definition), definition.isIncludeCharts(), definition.isIncludeDetails(),
                toMap(computed.data()), withVerdict ? computed.evaluation().verdict() : null);
        return snapshots.save(snapshot);
    }

    private static List<ReportSection> applicable(ReportDefinition definition) {
        return definition.getSections().stream().filter(s -> s.appliesTo(definition.getScopeType())).toList();
    }

    @Transactional(readOnly = true)
    public List<ReportSnapshot> list(String projectKey) {
        project(projectKey);
        return snapshots.findByProject_KeyOrderByKeyNumberDesc(projectKey);
    }

    @Transactional(readOnly = true)
    public ReportSnapshot get(String projectKey, String key) {
        return snapshots.findByProject_KeyAndKey(projectKey, key)
                .orElseThrow(() -> new NotFoundException("REPORT_NOT_FOUND", "Rapport « " + key + " » introuvable."));
    }

    /** Données typées d'un instantané. */
    @Transactional(readOnly = true)
    public ReportData data(ReportSnapshot snapshot) {
        return JSON.convertValue(snapshot.getData(), ReportData.class);
    }

    /** F-RPT-03 export d'un instantané dans le format demandé (par défaut celui de sa définition, sinon PDF). */
    @Transactional(readOnly = true)
    public Rendered export(String projectKey, String key, ReportFormat format) {
        ReportSnapshot snapshot = get(projectKey, key);
        ReportDocumentBuilder.View view = new ReportDocumentBuilder.View(snapshot.getKey(), snapshot.getTitle(), snapshot.getDefinitionName(),
                snapshot.getSections(), snapshot.isIncludeCharts(), snapshot.isIncludeDetails(), snapshot.getVerdict(), snapshot.getComputedVerdict(),
                snapshot.getVerdictComment(), snapshot.getVerdictBy(), snapshot.isFrozen(), snapshot.getFrozenAt());
        return render(view, data(snapshot), format == null ? ReportFormat.PDF : format, snapshot.getKey() + "-" + slug(snapshot.getTitle()));
    }

    /** §12 bilan intégré d'un sprint ou d'une release, calculé à la demande, sans instantané. */
    public Rendered review(String projectKey, ReportScopeType type, String scopeKey, ReportFormat format, String login) {
        List<ReportDefinition> all = definitions(projectKey);
        String name = type == ReportScopeType.RELEASE ? ReportDefinition.RELEASE_REVIEW : ReportDefinition.SPRINT_REVIEW;
        ReportDefinition definition = all.stream().filter(d -> d.isBuiltIn() && d.getName().equals(name)).findFirst().orElseThrow();
        ReportCalculator.Computed computed = calculator.compute(projectKey, type, scopeKey, definition.getSections(), login);
        String title = definition.getName() + " — " + computed.scopeLabel();
        Verdict verdict = computed.evaluation().verdict();
        ReportDocumentBuilder.View view = new ReportDocumentBuilder.View(null, title, definition.getName(), applicable(definition),
                definition.isIncludeCharts(), definition.isIncludeDetails(), verdict, verdict, null, null, false, null);
        return render(view, computed.data(), format == null ? ReportFormat.JSON : format, slug(title));
    }

    private Rendered render(ReportDocumentBuilder.View view, ReportData data, ReportFormat format, String baseName) {
        ReportRenderer renderer = renderers.get(format);
        if (renderer == null) {
            throw new BusinessRuleException("REPORT_FORMAT_UNSUPPORTED", "Format « " + format + " » non disponible.");
        }
        ReportDocument document = ReportDocumentBuilder.build(view, data);
        return new Rendered(renderer.render(document, data), format.contentType(), baseName + "." + format.extension());
    }

    // ---------------------------------------------------------------- gel, verdict, suppression

    /** F-RPT-04 fige l'instantané (lien permanent, plus de suppression). */
    public ReportSnapshot freeze(String projectKey, String key, String login) {
        ReportSnapshot snapshot = get(projectKey, key);
        snapshot.freeze(login, Instant.now(clock));
        return snapshot;
    }

    /** §9.2 verdict modifié par le PO avec commentaire ; {@code null} = verdict calculé. */
    public ReportSnapshot overrideVerdict(String projectKey, String key, Verdict verdict, String comment, String login) {
        ReportSnapshot snapshot = get(projectKey, key);
        snapshot.overrideVerdict(verdict, comment, login, Instant.now(clock));
        return snapshot;
    }

    public void delete(String projectKey, String key) {
        ReportSnapshot snapshot = get(projectKey, key);
        snapshot.ensureDeletable();
        snapshots.delete(snapshot);
    }

    /** §9.2 « figé à la clôture » : le bilan du sprint est généré avec la définition intégrée, puis figé. */
    @EventListener
    public void onSprintClosed(SprintClosed event) {
        ReportDefinition definition = definitions(event.projectKey()).stream()
                .filter(d -> d.isBuiltIn() && d.getName().equals(ReportDefinition.SPRINT_REVIEW)).findFirst().orElseThrow();
        ReportCalculator.Computed computed = calculator.compute(event.projectKey(), ReportScopeType.SPRINT, event.sprintKey(),
                definition.getSections(), null);
        ReportSnapshot snapshot = save(definition, computed, definition.getName() + " — " + computed.scopeLabel());
        snapshot.freeze("clôture du sprint", Instant.now(clock));
    }

    // ---------------------------------------------------------------- règles de verdict

    @Transactional(readOnly = true)
    public VerdictRules verdictRules(String projectKey) {
        return project(projectKey).getVerdictRules();
    }

    public VerdictRules updateVerdictRules(String projectKey, VerdictRules rules) {
        Project project = project(projectKey);
        project.setVerdictRules(rules);
        return project.getVerdictRules();
    }

    // ---------------------------------------------------------------- outils

    private Project project(String projectKey) {
        return projects.findByKey(projectKey)
                .orElseThrow(() -> new NotFoundException("PROJECT_NOT_FOUND", "Projet « " + projectKey + " » introuvable."));
    }

    @SuppressWarnings("unchecked")
    static Map<String, Object> toMap(ReportData data) {
        return JSON.convertValue(data, Map.class);
    }

    /** Nom de fichier : « Bilan de sprint — SPR-2 » → « bilan-de-sprint-spr-2 ». */
    static String slug(String text) {
        String ascii = Normalizer.normalize(text, Normalizer.Form.NFD).replaceAll("\\p{M}", "");
        String slug = ascii.toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9]+", "-").replaceAll("(^-|-$)", "");
        return slug.length() > 80 ? slug.substring(0, 80) : slug.isEmpty() ? "rapport" : slug;
    }
}
