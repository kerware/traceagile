package com.traceagile.infrastructure.persistence;

import com.traceagile.application.testcase.TestCaseFilter;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.traceability.TraceEntityType;
import com.traceagile.domain.traceability.TraceLink;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;

/** §12 GET /test-cases : filtres kind, technique, status, tag, requirement, orphan, candidats, dossier, texte. */
class TestCaseSearchFragmentImpl implements TestCaseSearchFragment {

    private final JpaTestCaseRepository repository;

    TestCaseSearchFragmentImpl(@Lazy JpaTestCaseRepository repository) {
        this.repository = repository;
    }

    @Override
    public Page<TestCase> search(String projectKey, TestCaseFilter filter, Pageable pageable) {
        Specification<TestCase> specification = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(root.get("project").get("key"), projectKey));
            if (!filter.kinds().isEmpty()) {
                predicates.add(root.get("kind").in(filter.kinds()));
            }
            if (!filter.statuses().isEmpty()) {
                predicates.add(root.get("status").in(filter.statuses()));
            }
            if (!filter.techniques().isEmpty()) {
                predicates.add(root.join("automation", JoinType.LEFT).get("technique").in(filter.techniques()));
            }
            if (filter.tag() != null) {
                Join<TestCase, String> tags = root.join("tags");
                predicates.add(cb.equal(tags, filter.tag()));
            }
            if (filter.automationCandidate() != null) {
                predicates.add(cb.equal(root.get("automationCandidate"), filter.automationCandidate()));
            }
            if (filter.folder() != null) {
                predicates.add(cb.or(cb.equal(root.get("folder"), filter.folder()), cb.like(root.get("folder"), filter.folder() + "/%")));
            }
            if (filter.q() != null) {
                String like = "%" + filter.q().toLowerCase(Locale.ROOT) + "%";
                predicates.add(cb.or(cb.like(cb.lower(root.get("key")), like), cb.like(cb.lower(root.get("title")), like)));
            }
            if (filter.requirementKey() != null || filter.orphan() != null) {
                Subquery<UUID> linked = query.subquery(UUID.class);
                Root<TraceLink> link = linked.from(TraceLink.class);
                List<Predicate> linkPredicates = new ArrayList<>();
                linkPredicates.add(cb.equal(link.get("sourceId"), root.get("id")));
                linkPredicates.add(cb.equal(link.get("targetType"), TraceEntityType.REQUIREMENT));
                if (filter.requirementKey() != null) {
                    Subquery<UUID> requirement = query.subquery(UUID.class);
                    Root<Requirement> r = requirement.from(Requirement.class);
                    requirement.select(r.get("id")).where(cb.equal(r.get("key"), filter.requirementKey()),
                            cb.equal(r.get("project").get("key"), projectKey));
                    linkPredicates.add(link.get("targetId").in(requirement));
                }
                linked.select(link.get("id")).where(linkPredicates.toArray(Predicate[]::new));
                if (filter.requirementKey() != null) {
                    predicates.add(cb.exists(linked));
                }
                if (filter.orphan() != null) {
                    predicates.add(filter.orphan() ? cb.not(cb.exists(linked)) : cb.exists(linked));
                }
            }
            if (query.getResultType() != Long.class && query.getResultType() != long.class) {
                query.distinct(true);
            }
            return cb.and(predicates.toArray(Predicate[]::new));
        };
        return repository.findAll(specification, withDefaultSort(pageable));
    }

    /** Tri par défaut : clé ; « key » trie sur la partie numérique (TC-2 avant TC-10). */
    private static Pageable withDefaultSort(Pageable pageable) {
        Sort sort = pageable.getSort().isUnsorted() ? Sort.by("keyNumber") : Sort.by(pageable.getSort().stream()
                .map(order -> order.getProperty().equals("key") ? order.withProperty("keyNumber") : order).toList());
        return pageable.isPaged() ? PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(), sort) : Pageable.unpaged(sort);
    }
}
