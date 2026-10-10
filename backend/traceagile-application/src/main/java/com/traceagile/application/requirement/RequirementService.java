package com.traceagile.application.requirement;

import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.audit.AuditService;
import com.traceagile.application.execution.ExecutionRepository;
import com.traceagile.application.common.KeyGenerator;
import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.common.UnprocessableException;
import com.traceagile.application.common.VersionConflictException;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.audit.AuditAction;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.common.FieldChange;
import com.traceagile.domain.common.Rank;
import com.traceagile.domain.requirement.ChecklistEvaluator;
import com.traceagile.domain.requirement.ChecklistItemResult;
import com.traceagile.domain.requirement.ChecklistKind;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.domain.requirement.RequirementVersion;
import com.traceagile.domain.traceability.TraceEntityType;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** §4 Gestion des exigences : backlog, fiche, hiérarchie, rang, statut, DoR / DoD. */
@Service
@Transactional
public class RequirementService {

    static final String KEY_PREFIX = "REQ";

    public record CreateRequirementCommand(RequirementType type, String title, String parentKey, RequirementPatch details,
                                           List<CriterionDraft> criteria) {
        public CreateRequirementCommand(RequirementType type, String title, String parentKey, RequirementPatch details) {
            this(type, title, parentKey, details, List.of());
        }
    }

    public record CriterionDraft(CriterionFormat format, String content) {
    }

    /**
     * F-REQ-02 / F-REQ-03 déplacement : {@code parentKey} null place à la racine ; l'exigence est
     * insérée après {@code afterKey} et avant {@code beforeKey} (l'un ou l'autre peut manquer).
     */
    public record MoveCommand(String parentKey, String beforeKey, String afterKey) {
    }

    private final RequirementRepository requirements;
    private final RequirementVersionRepository versions;
    private final ProjectRepository projects;
    private final KeyGenerator keys;
    private final ChecklistService checklists;
    private final AuditService audit;
    private final ApplicationEventPublisher events;
    private final GherkinValidator gherkin;
    private final TraceLinkService links;
    private final ExecutionRepository executions;
    private final CommentRepository comments;

    public RequirementService(RequirementRepository requirements, RequirementVersionRepository versions,
                              ProjectRepository projects, KeyGenerator keys, ChecklistService checklists,
                              AuditService audit, ApplicationEventPublisher events, GherkinValidator gherkin,
                              TraceLinkService links, ExecutionRepository executions, CommentRepository comments) {
        this.comments = comments;
        this.executions = executions;
        this.gherkin = gherkin;
        this.links = links;
        this.requirements = requirements;
        this.versions = versions;
        this.projects = projects;
        this.keys = keys;
        this.checklists = checklists;
        this.audit = audit;
        this.events = events;
    }

    // ---------------------------------------------------------------- lecture

    @Transactional(readOnly = true)
    public Requirement get(String projectKey, String key) {
        return requirements.findByProject_KeyAndKey(projectKey, key)
                .orElseThrow(() -> new NotFoundException("REQ_NOT_FOUND", "Exigence « " + key + " » introuvable."));
    }

    /** F-REQ-01 vue arbre : tout le backlog trié par rang (l'arbre est construit par l'appelant). */
    @Transactional(readOnly = true)
    public List<Requirement> backlog(String projectKey) {
        return requirements.findByProject_KeyOrderByRankAsc(projectKey);
    }

    /** F-REQ-01 vue liste ; F-REQ-04 recherche plein texte. */
    @Transactional(readOnly = true)
    public Page<Requirement> search(String projectKey, RequirementFilter filter, Pageable pageable) {
        return requirements.search(projectKey, filter, pageable);
    }

    /** F-REQ-17 ENF transverses qui s'appliquent à cette exigence. */
    @Transactional(readOnly = true)
    public List<Requirement> applicableTransverseNfrs(Requirement requirement) {
        return requirements.findByProject_KeyAndTypeAndTransverseTrue(requirement.getProject().getKey(), RequirementType.NON_FUNCTIONAL)
                .stream().filter(nfr -> nfr.appliesTransverselyTo(requirement)).toList();
    }

    // ---------------------------------------------------------------- écriture

    public Requirement create(String projectKey, CreateRequirementCommand command) {
        Project project = projects.findByKey(projectKey)
                .orElseThrow(() -> new NotFoundException("PROJECT_NOT_FOUND", "Projet « " + projectKey + " » introuvable."));
        Requirement requirement = new Requirement(project, keys.next(project, KEY_PREFIX), command.type(), command.title(), lastRankPlusOne(projectKey));
        if (command.parentKey() != null) {
            requirement.moveUnder(get(projectKey, command.parentKey()));
        }
        requirement.checkHierarchy();
        if (command.details() != null) {
            command.details().applyTo(requirement);
        }
        for (CriterionDraft criterion : command.criteria()) {
            validateCriterion(criterion.format(), criterion.content());
            requirement.addCriterion(criterion.format(), criterion.content());
        }
        Requirement saved = requirements.save(requirement);
        audit.record(project.getId(), AuditService.REQUIREMENT, saved.getId(), saved.getKey(), AuditAction.CREATED, Map.of(), saved.snapshot());
        return saved;
    }

    /** §12 PATCH : merge-patch avec verrou optimiste {@code If-Match}. */
    public Requirement update(String projectKey, String key, RequirementPatch patch, Long expectedVersion) {
        Requirement requirement = get(projectKey, key);
        VersionConflictException.check(expectedVersion, requirement.getVersion());
        Map<String, Object> before = requirement.snapshot();
        patch.applyTo(requirement);
        changed(requirement, AuditAction.UPDATED, before);
        return requirement;
    }

    public Requirement move(String projectKey, String key, MoveCommand command) {
        Requirement requirement = get(projectKey, key);
        Map<String, Object> before = requirement.snapshot();
        Requirement parent = command.parentKey() == null ? null : get(projectKey, command.parentKey());
        if (parent != requirement.getParent()) {
            requirement.moveUnder(parent);
        }
        if (command.beforeKey() != null || command.afterKey() != null) {
            String lower = command.afterKey() == null ? null : get(projectKey, command.afterKey()).getRank();
            String upper = command.beforeKey() == null ? null : get(projectKey, command.beforeKey()).getRank();
            try {
                requirement.setRank(Rank.between(lower, upper));
            } catch (IllegalArgumentException e) {
                throw new BusinessRuleException("REQ_RANK_INVALID", "afterKey doit précéder beforeKey dans le backlog.");
            }
        }
        changed(requirement, AuditAction.MOVED, before);
        return requirement;
    }

    /** F-REQ-02 la copie est placée juste après l'original. */
    public Requirement duplicate(String projectKey, String key) {
        Requirement original = get(projectKey, key);
        String next = requirements.findFirstByProject_KeyAndRankGreaterThanOrderByRankAsc(projectKey, original.getRank())
                .map(Requirement::getRank).orElse(null);
        Requirement copy = requirements.save(original.duplicate(keys.next(original.getProject(), KEY_PREFIX),
                Rank.between(original.getRank(), next)));
        audit.record(copy.getProject().getId(), AuditService.REQUIREMENT, copy.getId(), copy.getKey(), AuditAction.CREATED,
                Map.of(), copy.snapshot());
        return copy;
    }

    /**
     * §3.2 changement de statut. Vers READY et DONE, la DoR / DoD est évaluée (F-REQ-20) : un item
     * automatique insatisfait bloque, un item manuel non coché demande {@code acknowledgeUnmet}.
     * Le passage à READY fige une version (F-REQ-21).
     */
    public Requirement changeStatus(String projectKey, String key, RequirementStatus target, boolean acknowledgeUnmet) {
        Requirement requirement = get(projectKey, key);
        Map<String, Object> before = requirement.snapshot();
        ChecklistKind kind = target == RequirementStatus.READY ? ChecklistKind.DOR
                : target == RequirementStatus.DONE ? ChecklistKind.DOD : null;
        if (kind != null && requirement.getStatus().canMoveTo(target)) {
            List<ChecklistItemResult> results = checklists.evaluate(requirement, kind);
            List<ChecklistItemResult> blocking = ChecklistEvaluator.blocking(results);
            List<ChecklistItemResult> toAcknowledge = ChecklistEvaluator.needingAcknowledgement(results);
            if (!blocking.isEmpty()) {
                throw new UnprocessableException("CHECKLIST_NOT_SATISFIED",
                        "La " + label(kind) + " n'est pas satisfaite : " + String.join(", ", labels(blocking)) + ".",
                        Map.of("checklist", kind.name(), "unmetItems", labels(blocking)));
            }
            List<String> unmet = new java.util.ArrayList<>(labels(toAcknowledge));
            long openQuestions = target == RequirementStatus.READY ? comments.countByRequirement_IdAndQuestionTrueAndResolvedAtIsNull(requirement.getId()) : 0;
            if (openQuestions > 0) {
                // F-REQ-15 questions ouvertes de l'atelier : avertissement contournable comme un item manuel
                unmet.add(openQuestions + " question(s) ouverte(s) (Example Mapping)");
            }
            if (!unmet.isEmpty() && !acknowledgeUnmet) {
                throw new UnprocessableException("CHECKLIST_ACKNOWLEDGEMENT_REQUIRED",
                        "Des items de la " + label(kind) + " ne sont pas satisfaits : " + String.join(", ", unmet) + ".",
                        Map.of("checklist", kind.name(), "unmetItems", unmet));
            }
        }
        requirement.changeStatus(target);
        if (target == RequirementStatus.READY) {
            versions.save(RequirementVersion.freeze(requirement, "Passage à READY"));
        }
        changed(requirement, AuditAction.STATUS_CHANGED, before);
        return requirement;
    }

    /**
     * F-PLN-06 transition décidée par la planification (READY ⇄ IN_SPRINT) : sans liste de contrôle
     * (la DoR a été vérifiée au passage à READY) ni version figée ; auditée comme un changement de statut.
     */
    public void applyPlanningStatus(Requirement requirement, RequirementStatus target) {
        if (requirement.getStatus() == target) {
            return;
        }
        Map<String, Object> before = requirement.snapshot();
        requirement.changeStatus(target);
        changed(requirement, AuditAction.STATUS_CHANGED, before);
    }

    /** §3.3-6 suppression d'une exigence sans enfant (jamais exécutée, vérifié à partir du lot 5). */
    public void delete(String projectKey, String key) {
        Requirement requirement = get(projectKey, key);
        requirement.ensureDeletable();
        // §3.3-6 une exigence dont un test lié a été exécuté ne se supprime pas : on la passe OBSOLETE.
        List<java.util.UUID> testIds = links.testsOf(requirement).stream().map(l -> l.testCase().getId()).toList();
        if (!testIds.isEmpty() && executions.existsByTestCase_IdIn(testIds)) {
            throw new BusinessRuleException("REQ_ALREADY_EXECUTED",
                    key + " a des tests déjà exécutés : passez-la à « Obsolète » plutôt que de la supprimer.");
        }
        Map<String, Object> before = requirement.snapshot();
        if (requirement.getParent() != null) {
            requirement.moveUnder(null);
        }
        audit.record(requirement.getProject().getId(), AuditService.REQUIREMENT, requirement.getId(), key,
                AuditAction.DELETED, before, Map.of());
        links.deleteLinksTo(TraceEntityType.REQUIREMENT, requirement.getId());
        requirement.getCriteria().forEach(c -> links.deleteLinksTo(TraceEntityType.ACCEPTANCE_CRITERION, c.getId()));
        requirements.delete(requirement);
    }

    public Requirement check(String projectKey, String key, UUID itemId, boolean checked) {
        Requirement requirement = get(projectKey, key);
        checklists.check(requirement, itemId, checked);
        return requirement;
    }

    // ---------------------------------------------------------------- outils

    /** F-REQ-10 un critère Gherkin invalide est refusé avec la liste des erreurs. */
    public void validateCriterion(CriterionFormat format, String content) {
        if (format != CriterionFormat.GHERKIN || content == null || content.isBlank()) {
            return;
        }
        GherkinValidator.GherkinValidation validation = gherkin.validate(content);
        if (!validation.valid()) {
            throw new UnprocessableException("GHERKIN_INVALID", "Le scénario Gherkin contient des erreurs de syntaxe.",
                    Map.of("gherkinErrors", validation.errors()));
        }
    }

    /** Audit + événement de domaine RequirementChanged si quelque chose a changé. */
    void changed(Requirement requirement, AuditAction action, Map<String, Object> before) {
        List<FieldChange> diff = audit.record(requirement.getProject().getId(), AuditService.REQUIREMENT, requirement.getId(),
                requirement.getKey(), action, before, requirement.snapshot());
        if (!diff.isEmpty()) {
            events.publishEvent(new RequirementChanged(requirement.getProject().getKey(), requirement.getKey(),
                    diff.stream().map(FieldChange::field).collect(java.util.stream.Collectors.toSet())));
        }
    }

    String lastRankPlusOne(String projectKey) {
        return Rank.between(requirements.findFirstByProject_KeyOrderByRankDesc(projectKey).map(Requirement::getRank).orElse(null), null);
    }

    private static String label(ChecklistKind kind) {
        return kind == ChecklistKind.DOR ? "Definition of Ready" : "Definition of Done";
    }

    private static List<String> labels(List<ChecklistItemResult> results) {
        return results.stream().map(r -> r.item().getLabel()).toList();
    }
}
