package com.traceagile.api.requirement;

import com.traceagile.api.requirement.RequirementDtos.AuditEventResponse;
import com.traceagile.api.requirement.RequirementDtos.ChecklistItemResponse;
import com.traceagile.api.requirement.RequirementDtos.ChecklistResultResponse;
import com.traceagile.api.requirement.RequirementDtos.CriterionResponse;
import com.traceagile.api.requirement.RequirementDtos.FieldChangeResponse;
import com.traceagile.api.requirement.RequirementDtos.InvestDto;
import com.traceagile.api.requirement.RequirementDtos.PlanguageResponse;
import com.traceagile.api.requirement.RequirementDtos.RequirementDetail;
import com.traceagile.api.requirement.RequirementDtos.RequirementRef;
import com.traceagile.api.requirement.RequirementDtos.RequirementSummary;
import com.traceagile.api.requirement.RequirementDtos.RequirementTreeNode;
import com.traceagile.api.requirement.RequirementDtos.UserStoryResponse;
import com.traceagile.api.requirement.RequirementDtos.VersionResponse;
import com.traceagile.domain.audit.AuditEvent;
import com.traceagile.domain.common.FieldChange;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.requirement.ChecklistItem;
import com.traceagile.domain.requirement.ChecklistItemResult;
import com.traceagile.domain.requirement.Invest;
import com.traceagile.domain.requirement.Planguage;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementVersion;
import com.traceagile.domain.requirement.UserStory;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

/** §11.1 MapStruct : exigences ↔ DTO. Les champs calculés passent par des expressions ou méthodes par défaut. */
@Mapper
public interface RequirementMapper {

    @Mapping(target = "parentKey", source = "parent.key")
    @Mapping(target = "tags", expression = "java(java.util.List.copyOf(requirement.getTags()))")
    @Mapping(target = "criteriaCount", expression = "java(requirement.getCriteria().size())")
    @Mapping(target = "needsSplitting", expression = "java(requirement.needsSplitting())")
    RequirementSummary toSummary(Requirement requirement);

    @Mapping(target = "needsSplitting", expression = "java(requirement.needsSplitting())")
    @Mapping(target = "allowedTransitions", expression = "java(java.util.List.copyOf(requirement.getStatus().nextStatuses()))")
    @Mapping(target = "tags", expression = "java(java.util.List.copyOf(requirement.getTags()))")
    @Mapping(target = "applicableTransverseNfrs", source = "transverseNfrs")
    RequirementDetail toDetail(Requirement requirement, List<Requirement> transverseNfrs);

    RequirementRef toRef(Requirement requirement);

    List<RequirementRef> toRefs(List<Requirement> requirements);

    CriterionResponse toResponse(AcceptanceCriterion criterion);

    List<CriterionResponse> toCriteria(List<AcceptanceCriterion> criteria);

    InvestDto toDto(Invest invest);

    Invest toInvest(InvestDto invest);

    PlanguageResponse toResponse(Planguage planguage);

    default UserStoryResponse toResponse(UserStory story) {
        return new UserStoryResponse(story.asA(), story.iWant(), story.soThat(), story.sentence());
    }

    @Mapping(target = "rule", source = "rule")
    @Mapping(target = "automatic", expression = "java(item.isAutomatic())")
    ChecklistItemResponse toResponse(ChecklistItem item);

    List<ChecklistItemResponse> toItems(List<ChecklistItem> items);

    default ChecklistResultResponse toResponse(ChecklistItemResult result) {
        ChecklistItem item = result.item();
        return new ChecklistResultResponse(item.getId(), item.getLabel(), item.getRule(), item.isAutomatic(), result.outcome());
    }

    default List<ChecklistResultResponse> toResults(List<ChecklistItemResult> results) {
        return results.stream().map(this::toResponse).toList();
    }

    default FieldChangeResponse toResponse(FieldChange change) {
        return new FieldChangeResponse(change.field(), format(change.before()), format(change.after()));
    }

    default List<FieldChangeResponse> toChanges(List<FieldChange> changes) {
        return changes.stream().map(this::toResponse).toList();
    }

    default VersionResponse toResponse(RequirementVersion version) {
        Map<String, String> snapshot = new LinkedHashMap<>();
        version.getSnapshot().forEach((field, value) -> snapshot.put(field, format(value)));
        return new VersionResponse(version.getVersionNumber(), version.getChangeComment(), version.getCreatedAt(),
                version.getCreatedBy(), snapshot);
    }

    default AuditEventResponse toResponse(AuditEvent event) {
        return new AuditEventResponse(event.getAction().name(), event.getActor(), event.getTimestamp(), toChanges(event.getDiff()));
    }

    /** F-REQ-01 arbre : nœuds racines triés par rang, enfants triés par rang. */
    default List<RequirementTreeNode> toTree(List<Requirement> backlogByRank) {
        Map<String, List<Requirement>> byParent = new HashMap<>();
        List<Requirement> roots = new ArrayList<>();
        for (Requirement r : backlogByRank) {
            if (r.getParent() == null) {
                roots.add(r);
            } else {
                byParent.computeIfAbsent(r.getParent().getKey(), k -> new ArrayList<>()).add(r);
            }
        }
        return roots.stream().map(r -> node(r, byParent)).toList();
    }

    private RequirementTreeNode node(Requirement r, Map<String, List<Requirement>> byParent) {
        List<RequirementTreeNode> children = byParent.getOrDefault(r.getKey(), List.of()).stream()
                .map(child -> node(child, byParent)).toList();
        return new RequirementTreeNode(r.getKey(), r.getType(), r.getTitle(), r.getStatus(), r.getPriority(), r.getRiskLevel(),
                r.getStoryPoints(), r.getParent() == null ? null : r.getParent().getKey(), r.getRank(), r.getCriteria().size(),
                r.needsSplitting(), children);
    }

    /** Valeur d'instantané lisible : listes sur plusieurs lignes, nombres et booléens en texte. */
    private static String format(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Collection<?> list) {
            return list.isEmpty() ? null : String.join("\n", list.stream().map(String::valueOf).toList());
        }
        return String.valueOf(value);
    }
}
