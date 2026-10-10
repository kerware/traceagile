package com.traceagile.application.requirement;

import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.domain.requirement.RiskLevel;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

/**
 * F-REQ-01 Filtres de la liste du backlog ; F-REQ-04 recherche plein texte {@code q} ; {@code sprint}
 * : exigences au périmètre de ce sprint (§12, lot 4) ; {@code ids} : restriction calculée (filtre
 * {@code verification}, ADR-0024).
 */
public record RequirementFilter(
        Set<RequirementType> types,
        Set<RequirementStatus> statuses,
        Set<Priority> priorities,
        Set<RiskLevel> risks,
        String tag,
        String q,
        String sprint,
        Set<UUID> ids) {

    public static final RequirementFilter NONE = new RequirementFilter(null, null, null, null, null, null, null);

    public RequirementFilter(Set<RequirementType> types, Set<RequirementStatus> statuses, Set<Priority> priorities, Set<RiskLevel> risks,
                             String tag, String q, String sprint) {
        this(types, statuses, priorities, risks, tag, q, sprint, null);
    }

    public RequirementFilter(Set<RequirementType> types, Set<RequirementStatus> statuses, Set<Priority> priorities, Set<RiskLevel> risks,
                             String tag, String q) {
        this(types, statuses, priorities, risks, tag, q, null);
    }

    public RequirementFilter {
        types = types == null ? Set.of() : Set.copyOf(types);
        statuses = statuses == null ? Set.of() : Set.copyOf(statuses);
        priorities = priorities == null ? Set.of() : Set.copyOf(priorities);
        risks = risks == null ? Set.of() : Set.copyOf(risks);
        tag = tag == null || tag.isBlank() ? null : tag.strip().toLowerCase(Locale.ROOT);
        q = q == null || q.isBlank() ? null : q.strip();
        sprint = sprint == null || sprint.isBlank() ? null : sprint.strip();
        // §12 filtre « verification » : restriction aux exigences de ces statuts calculés (null = sans restriction)
        ids = ids == null ? null : Set.copyOf(ids);
    }
}
