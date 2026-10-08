package com.traceagile.infrastructure.persistence;

import com.traceagile.application.requirement.RequirementFilter;
import com.traceagile.domain.requirement.Requirement;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.jdbc.core.JdbcTemplate;

/**
 * F-REQ-01 / F-REQ-04 Recherche du backlog. Le texte libre passe par l'index {@code tsvector}
 * (français) complété d'une recherche par sous-chaîne (préfixes de mots, clés partielles), puis les
 * filtres structurés sont appliqués par une {@link Specification}. Tri par défaut : le rang.
 */
class RequirementSearchFragmentImpl implements RequirementSearchFragment {

    private static final String FULL_TEXT = """
            select r.id from requirements r join projects p on p.id = r.project_id
            where p.project_key = ?
              and (r.search_vector @@ websearch_to_tsquery('french', ?) or r.search_text ilike ?)
            """;

    private final JpaRequirementRepository repository;
    private final JdbcTemplate jdbc;

    RequirementSearchFragmentImpl(@Lazy JpaRequirementRepository repository, JdbcTemplate jdbc) {
        this.repository = repository;
        this.jdbc = jdbc;
    }

    @Override
    public Page<Requirement> search(String projectKey, RequirementFilter filter, Pageable pageable) {
        List<UUID> matching = null;
        if (filter.q() != null) {
            matching = jdbc.queryForList(FULL_TEXT, UUID.class, projectKey, filter.q(), "%" + escapeLike(filter.q()) + "%");
            if (matching.isEmpty()) {
                return new PageImpl<>(List.of(), pageable, 0);
            }
        }
        List<UUID> ids = matching;
        Specification<Requirement> specification = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(root.get("project").get("key"), projectKey));
            if (!filter.types().isEmpty()) {
                predicates.add(root.get("type").in(filter.types()));
            }
            if (!filter.statuses().isEmpty()) {
                predicates.add(root.get("status").in(filter.statuses()));
            }
            if (!filter.priorities().isEmpty()) {
                predicates.add(root.get("priority").in(filter.priorities()));
            }
            if (!filter.risks().isEmpty()) {
                predicates.add(root.get("riskLevel").in(filter.risks()));
            }
            if (filter.tag() != null) {
                Join<Requirement, String> tags = root.join("tags");
                predicates.add(cb.equal(tags, filter.tag()));
            }
            if (ids != null) {
                predicates.add(root.get("id").in(ids));
            }
            return cb.and(predicates.toArray(Predicate[]::new));
        };
        return repository.findAll(specification, withDefaultSort(pageable));
    }

    /** Tri par rang par défaut ; « key » trie sur la partie numérique (REQ-2 avant REQ-10). */
    private static Pageable withDefaultSort(Pageable pageable) {
        Sort sort = pageable.getSort().isUnsorted() ? Sort.by("rank") : Sort.by(pageable.getSort().stream()
                .map(order -> order.getProperty().equals("key") ? order.withProperty("keyNumber") : order)
                .toList());
        return pageable.isPaged()
                ? org.springframework.data.domain.PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(), sort)
                : Pageable.unpaged(sort);
    }

    private static String escapeLike(String value) {
        return value.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
    }
}
