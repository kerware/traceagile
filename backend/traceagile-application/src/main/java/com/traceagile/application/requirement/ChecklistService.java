package com.traceagile.application.requirement;

import com.traceagile.application.administration.ProjectCreated;
import com.traceagile.application.administration.ProjectRepository;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.requirement.ChecklistEvaluator;
import com.traceagile.domain.requirement.ChecklistItem;
import com.traceagile.domain.requirement.ChecklistItemResult;
import com.traceagile.domain.requirement.ChecklistKind;
import com.traceagile.domain.requirement.ChecklistRule;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.VerificationFacts;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** F-REQ-19 / F-REQ-20 DoR et DoD : paramétrage par projet et évaluation par exigence. */
@Service
@Transactional
public class ChecklistService {

    /** Item d'une liste à enregistrer : {@code id} null pour un nouvel item, {@code rule} null pour un item manuel. */
    public record ItemDraft(UUID id, String label, ChecklistRule rule) {
    }

    private final ChecklistItemRepository items;
    private final ProjectRepository projects;
    private final VerificationFacts facts;

    public ChecklistService(ChecklistItemRepository items, ProjectRepository projects, VerificationFacts facts) {
        this.items = items;
        this.projects = projects;
        this.facts = facts;
    }

    /** Un nouveau projet reçoit la DoR et la DoD par défaut. */
    @EventListener
    public void onProjectCreated(ProjectCreated event) {
        Project project = project(event.projectKey());
        ChecklistItem.defaults(project).forEach(items::save);
    }

    @Transactional(readOnly = true)
    public List<ChecklistItem> items(String projectKey, ChecklistKind kind) {
        return items.findByProject_KeyAndKindOrderByPositionAsc(projectKey, kind);
    }

    /**
     * Remplace la liste {@code kind} du projet. Les items conservés (même {@code id}) gardent les
     * coches déjà posées ; les items retirés sont supprimés avec leurs coches.
     */
    public List<ChecklistItem> replace(String projectKey, ChecklistKind kind, List<ItemDraft> drafts) {
        Project project = project(projectKey);
        Map<UUID, ChecklistItem> existing = new HashMap<>();
        items(projectKey, kind).forEach(item -> existing.put(item.getId(), item));
        List<ChecklistItem> result = new ArrayList<>();
        int position = 1;
        for (ItemDraft draft : drafts) {
            ChecklistItem previous = draft.id() == null ? null : existing.remove(draft.id());
            if (draft.id() != null && previous == null) {
                throw new BusinessRuleException("CHECKLIST_ITEM_UNKNOWN", "Item inconnu dans cette liste : " + draft.id());
            }
            if (previous != null) {
                previous.update(position, draft.label(), draft.rule());
                result.add(previous);
            } else {
                result.add(items.save(new ChecklistItem(project, kind, position, draft.label(), draft.rule())));
            }
            position++;
        }
        existing.values().forEach(items::delete);
        return result;
    }

    @Transactional(readOnly = true)
    public List<ChecklistItemResult> evaluate(Requirement requirement, ChecklistKind kind) {
        return ChecklistEvaluator.evaluate(requirement, items(requirement.getProject().getKey(), kind), facts);
    }

    /** F-REQ-19 coche ou décoche un item manuel sur une exigence. */
    public void check(Requirement requirement, UUID itemId, boolean checked) {
        ChecklistItem item = items.findById(itemId)
                .filter(i -> i.getProject().getKey().equals(requirement.getProject().getKey()))
                .orElseThrow(() -> new NotFoundException("CHECKLIST_ITEM_NOT_FOUND", "Item de DoR / DoD introuvable."));
        requirement.check(item, checked);
    }

    private Project project(String key) {
        return projects.findByKey(key)
                .orElseThrow(() -> new NotFoundException("PROJECT_NOT_FOUND", "Projet « " + key + " » introuvable."));
    }
}
