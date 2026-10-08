package com.traceagile.application.requirement;

import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.application.common.VersionConflictException;
import com.traceagile.domain.audit.AuditAction;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.traceability.TraceEntityType;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** F-REQ-09 / F-REQ-10 critères d'acceptation ordonnés, en texte ou en Gherkin validé. */
@Service
@Transactional
public class AcceptanceCriterionService {

    private final RequirementService requirements;
    private final AcceptanceCriterionRepository criteria;
    private final TraceLinkService links;

    public AcceptanceCriterionService(RequirementService requirements, AcceptanceCriterionRepository criteria,
                                      TraceLinkService links) {
        this.requirements = requirements;
        this.criteria = criteria;
        this.links = links;
    }

    public AcceptanceCriterion add(String projectKey, String requirementKey, CriterionFormat format, String content) {
        Requirement requirement = requirements.get(projectKey, requirementKey);
        validate(format, content);
        Map<String, Object> before = requirement.snapshot();
        AcceptanceCriterion criterion = requirement.addCriterion(format, content);
        requirements.changed(requirement, AuditAction.UPDATED, before);
        return criterion;
    }

    public AcceptanceCriterion update(String projectKey, UUID id, CriterionFormat format, String content, Long expectedVersion) {
        AcceptanceCriterion criterion = get(projectKey, id);
        VersionConflictException.check(expectedVersion, criterion.getVersion());
        CriterionFormat newFormat = format == null ? criterion.getFormat() : format;
        String newContent = content == null ? criterion.getContent() : content;
        validate(newFormat, newContent);
        Requirement requirement = criterion.getRequirement();
        Map<String, Object> before = requirement.snapshot();
        requirement.rewriteCriterion(criterion, newFormat, newContent);
        requirements.changed(requirement, AuditAction.UPDATED, before);
        return criterion;
    }

    public void delete(String projectKey, UUID id) {
        AcceptanceCriterion criterion = get(projectKey, id);
        Requirement requirement = criterion.getRequirement();
        Map<String, Object> before = requirement.snapshot();
        links.deleteLinksTo(TraceEntityType.ACCEPTANCE_CRITERION, criterion.getId());
        requirement.removeCriterion(criterion);
        requirements.changed(requirement, AuditAction.UPDATED, before);
    }

    public Requirement reorder(String projectKey, String requirementKey, List<UUID> orderedIds) {
        Requirement requirement = requirements.get(projectKey, requirementKey);
        Map<String, Object> before = requirement.snapshot();
        List<AcceptanceCriterion> ordered = orderedIds.stream()
                .map(id -> requirement.getCriteria().stream().filter(c -> c.getId().equals(id)).findFirst()
                        .orElseThrow(() -> new BusinessRuleException("CRITERIA_ORDER_INVALID",
                                "Le critère " + id + " n'appartient pas à " + requirementKey + ".")))
                .toList();
        requirement.reorderCriteria(ordered);
        requirements.changed(requirement, AuditAction.UPDATED, before);
        return requirement;
    }

    @Transactional(readOnly = true)
    public AcceptanceCriterion get(String projectKey, UUID id) {
        return criteria.findById(id)
                .filter(c -> c.getRequirement().getProject().getKey().equals(projectKey))
                .orElseThrow(() -> new NotFoundException("CRITERION_NOT_FOUND", "Critère d'acceptation introuvable."));
    }

    private void validate(CriterionFormat format, String content) {
        requirements.validateCriterion(format, content);
    }
}
