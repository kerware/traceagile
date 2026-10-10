package com.traceagile.application.defect;

import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.attachment.AttachmentService;
import com.traceagile.application.audit.AuditService;
import com.traceagile.application.common.KeyGenerator;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.common.VersionConflictException;
import com.traceagile.application.execution.ExecutionService;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.audit.AuditAction;
import com.traceagile.domain.defect.Defect;
import com.traceagile.domain.defect.DefectSeverity;
import com.traceagile.domain.defect.DefectStatus;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.testcase.TestCase;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** §8.6 anomalies (F-DEF-01, F-DEF-02) ; F-EXE-03 création depuis une exécution. */
@Service
@Transactional
public class DefectService {

    public static final String AUDIT_TYPE = "DEFECT";

    /** {@code requirementKeys == null} à la création depuis une exécution : exigences couvertes par le test. */
    public record DefectCommand(String title, String description, DefectSeverity severity, String externalRef, List<String> requirementKeys) {
    }

    public record DefectPatch(Optional<String> title, Optional<String> description, Optional<DefectSeverity> severity,
                              Optional<DefectStatus> status, Optional<String> externalRef, Optional<List<String>> requirementKeys) {
    }

    public record DefectFilter(Set<DefectStatus> statuses, Set<DefectSeverity> severities, String requirementKey, String q) {
    }

    private final DefectRepository defects;
    private final ProjectRepository projects;
    private final RequirementService requirements;
    private final ExecutionService executions;
    private final TraceLinkService links;
    private final KeyGenerator keys;
    private final AuditService audit;

    private final AttachmentService attachments;

    public DefectService(DefectRepository defects, ProjectRepository projects, RequirementService requirements, ExecutionService executions,
                         TraceLinkService links, KeyGenerator keys, AuditService audit,
                         AttachmentService attachments) {
        this.attachments = attachments;
        this.defects = defects;
        this.projects = projects;
        this.requirements = requirements;
        this.executions = executions;
        this.links = links;
        this.keys = keys;
        this.audit = audit;
    }

    @Transactional(readOnly = true)
    public List<Defect> list(String projectKey, DefectFilter filter) {
        String q = filter.q() == null || filter.q().isBlank() ? null : filter.q().strip().toLowerCase(Locale.ROOT);
        return defects.findByProject_KeyOrderByKeyNumberDesc(projectKey).stream()
                .filter(d -> filter.statuses() == null || filter.statuses().isEmpty() || filter.statuses().contains(d.getStatus()))
                .filter(d -> filter.severities() == null || filter.severities().isEmpty() || filter.severities().contains(d.getSeverity()))
                .filter(d -> filter.requirementKey() == null
                        || d.getRequirements().stream().anyMatch(r -> r.getKey().equals(filter.requirementKey())))
                .filter(d -> q == null || (d.getKey() + " " + d.getTitle()).toLowerCase(Locale.ROOT).contains(q))
                .toList();
    }

    @Transactional(readOnly = true)
    public Defect get(String projectKey, String key) {
        return defects.findByProject_KeyAndKey(projectKey, key)
                .orElseThrow(() -> new NotFoundException("DEFECT_NOT_FOUND", "Anomalie « " + key + " » introuvable."));
    }

    @Transactional(readOnly = true)
    public List<Defect> ofRequirement(Requirement requirement) {
        return defects.findByRequirements_IdOrderByKeyNumberDesc(requirement.getId());
    }

    /** ADR-0018 anomalies d'un test : celles liées à l'une de ses exécutions. */
    @Transactional(readOnly = true)
    public List<Defect> ofTest(TestCase test) {
        return defects.findDistinctByExecutions_TestCase_IdInOrderByKeyNumberDesc(List.of(test.getId()));
    }

    /** ADR-0018 anomalie vue depuis une exigence : rattachée ou non, et les tests liés qui l'ont révélée. */
    public record TracedDefect(Defect defect, boolean linked, List<String> viaTests) {
    }

    /**
     * ADR-0018 anomalies d'une exigence : celles qui lui sont rattachées, puis celles trouvées par
     * traçabilité (exécutions des tests qui la vérifient), de la plus récente à la plus ancienne.
     */
    @Transactional(readOnly = true)
    public List<TracedDefect> tracedFor(Requirement requirement) {
        Map<UUID, TestCase> tests = new LinkedHashMap<>();
        links.testsOf(requirement).forEach(l -> tests.put(l.testCase().getId(), l.testCase()));
        Map<UUID, Defect> all = new LinkedHashMap<>();
        defects.findByRequirements_IdOrderByKeyNumberDesc(requirement.getId()).forEach(d -> all.put(d.getId(), d));
        if (!tests.isEmpty()) {
            defects.findDistinctByExecutions_TestCase_IdInOrderByKeyNumberDesc(tests.keySet()).forEach(d -> all.putIfAbsent(d.getId(), d));
        }
        return all.values().stream().sorted(Comparator.comparingInt(Defect::getKeyNumber).reversed())
                .map(d -> new TracedDefect(d, d.getRequirements().stream().anyMatch(r -> r.getId().equals(requirement.getId())),
                        d.getExecutions().stream().map(e -> e.getTestCase()).filter(t -> tests.containsKey(t.getId()))
                                .map(TestCase::getKey).distinct().sorted(Comparator.comparingInt(DefectService::number)).toList()))
                .toList();
    }

    /** ADR-0018 rattacher une anomalie à une exigence. */
    public Defect linkRequirement(String projectKey, String defectKey, String requirementKey) {
        Defect defect = get(projectKey, defectKey);
        Map<String, Object> before = defect.snapshot();
        defect.linkRequirement(requirements.get(projectKey, requirementKey));
        audit.record(defect.getProject().getId(), AUDIT_TYPE, defect.getId(), defectKey, AuditAction.UPDATED, before, defect.snapshot());
        return defect;
    }

    private static int number(String key) {
        return Integer.parseInt(key.substring(key.lastIndexOf('-') + 1));
    }

    @Transactional(readOnly = true)
    public List<Defect> ofExecution(Execution execution) {
        return defects.findByExecutions_Id(execution.getId());
    }

    public Defect create(String projectKey, DefectCommand command) {
        Project project = projects.findByKey(projectKey)
                .orElseThrow(() -> new NotFoundException("PROJECT_NOT_FOUND", "Projet « " + projectKey + " » introuvable."));
        Defect defect = new Defect(project, keys.next(project, "DEF"), command.title(), command.description(),
                command.severity() == null ? DefectSeverity.MAJOR : command.severity());
        defect.setExternalRef(command.externalRef());
        defect.replaceRequirements(resolve(projectKey, command.requirementKeys() == null ? List.of() : command.requirementKeys()));
        Defect saved = defects.save(defect);
        audit.record(project.getId(), AUDIT_TYPE, saved.getId(), saved.getKey(), AuditAction.CREATED, Map.of(), saved.snapshot());
        return saved;
    }

    /** F-EXE-03 anomalie liée à l'exécution et, par défaut, aux exigences que le test vérifie. */
    public Defect createFromExecution(String projectKey, UUID executionId, DefectCommand command) {
        Execution execution = executions.get(projectKey, executionId);
        List<String> requirementKeys = command.requirementKeys() != null ? command.requirementKeys()
                : links.requirementsOf(execution.getTestCase()).stream().filter(l -> l.linkType().countsForCoverage())
                        .map(l -> l.requirement().getKey()).toList();
        Defect defect = create(projectKey, new DefectCommand(command.title(), command.description(), command.severity(),
                command.externalRef(), requirementKeys));
        defect.linkExecution(execution);
        // F-EXE-03 « captures » : celles des pas jusqu'au pas en échec (ADR-0024)
        attachments.copyStepCaptures(execution, defect.getId());
        return defect;
    }

    public Defect update(String projectKey, String key, DefectPatch patch, Long expectedVersion) {
        Defect defect = get(projectKey, key);
        VersionConflictException.check(expectedVersion, defect.getVersion());
        Map<String, Object> before = defect.snapshot();
        if (patch.title() != null) {
            defect.retitle(patch.title().orElse(null));
        }
        if (patch.description() != null) {
            defect.describe(patch.description().orElse(null));
        }
        if (patch.severity() != null && patch.severity().isPresent()) {
            defect.setSeverity(patch.severity().get());
        }
        if (patch.externalRef() != null) {
            defect.setExternalRef(patch.externalRef().orElse(null));
        }
        if (patch.requirementKeys() != null) {
            defect.replaceRequirements(resolve(projectKey, patch.requirementKeys().orElse(List.of())));
        }
        if (patch.status() != null && patch.status().isPresent()) {
            defect.changeStatus(patch.status().get());
        }
        audit.record(defect.getProject().getId(), AUDIT_TYPE, defect.getId(), key, AuditAction.UPDATED, before, defect.snapshot());
        return defect;
    }

    private List<Requirement> resolve(String projectKey, List<String> keys) {
        return keys.stream().distinct().map(k -> requirements.get(projectKey, k)).toList();
    }
}
