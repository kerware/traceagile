package com.traceagile.application.requirement;

import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.domain.requirement.RiskLevel;
import java.util.Locale;
import java.util.Set;

/**
 * F-REQ-01 Filtres de la liste du backlog ; F-REQ-04 recherche plein texte {@code q}. Les filtres
 * par sprint (lot 4) et par statut de vérification (lot 3) s'ajouteront ici.
 */
public record RequirementFilter(
        Set<RequirementType> types,
        Set<RequirementStatus> statuses,
        Set<Priority> priorities,
        Set<RiskLevel> risks,
        String tag,
        String q) {

    public static final RequirementFilter NONE = new RequirementFilter(null, null, null, null, null, null);

    public RequirementFilter {
        types = types == null ? Set.of() : Set.copyOf(types);
        statuses = statuses == null ? Set.of() : Set.copyOf(statuses);
        priorities = priorities == null ? Set.of() : Set.copyOf(priorities);
        risks = risks == null ? Set.of() : Set.copyOf(risks);
        tag = tag == null || tag.isBlank() ? null : tag.strip().toLowerCase(Locale.ROOT);
        q = q == null || q.isBlank() ? null : q.strip();
    }
}
