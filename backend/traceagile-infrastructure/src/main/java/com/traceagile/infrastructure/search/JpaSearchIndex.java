package com.traceagile.infrastructure.search;

import com.traceagile.application.search.SearchIndex;
import com.traceagile.application.search.SearchService.Hit;
import com.traceagile.application.search.SearchService.ItemType;
import jakarta.persistence.EntityManager;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import org.springframework.stereotype.Component;

/**
 * ADR-0024 recherche par clé (préfixe) et par titre (contient, sans casse) : une requête JPQL par type,
 * qui renvoie clé, libellé, précision et statut.
 */
@Component
public class JpaSearchIndex implements SearchIndex {

    /** Entité, alias, libellé, précision, statut, chemin du projet. */
    private record Source(String entity, String label, String detail, String status, String project) {
    }

    private static Source source(ItemType type) {
        return switch (type) {
            case REQUIREMENT -> new Source("Requirement", "e.title", "e.type", "e.status", "e.project");
            case TEST -> new Source("TestCase", "e.title", "e.kind", "e.status", "e.project");
            case CAMPAIGN -> new Source("Campaign", "e.name", "e.scopeType", "e.status", "e.project");
            case DEFECT -> new Source("Defect", "e.title", "e.severity", "e.status", "e.project");
            case RUN -> new Source("AutomatedRun", "e.campaign.name", "e.campaign.key", "e.status", "e.campaign.project");
            case REPORT -> new Source("ReportSnapshot", "e.title", "e.scopeLabel", "e.frozen", "e.project");
            case SPRINT -> new Source("Sprint", "e.name", "e.startDate", "e.status", "e.project");
            case RELEASE -> new Source("Release", "e.name", "e.startDate", "e.status", "e.project");
        };
    }

    private final EntityManager em;

    public JpaSearchIndex(EntityManager em) {
        this.em = em;
    }

    @Override
    public List<Hit> search(String projectKey, ItemType type, String text, int limit) {
        Source s = source(type);
        String jpql = "select e.key, " + s.label() + ", " + s.detail() + ", " + s.status() + " from " + s.entity() + " e"
                + " where " + s.project() + ".key = :p and (upper(e.key) like :k escape '\\' or lower(" + s.label() + ") like :t escape '\\')"
                + " order by e.keyNumber desc";
        return em.createQuery(jpql, Object[].class)
                .setParameter("p", projectKey)
                .setParameter("k", escape(text.toUpperCase(Locale.ROOT)) + "%")
                .setParameter("t", "%" + escape(text.toLowerCase(Locale.ROOT)) + "%")
                .setMaxResults(limit)
                .getResultList().stream().map(row -> hit(type, row)).toList();
    }

    @Override
    public Optional<Hit> find(String projectKey, ItemType type, String key) {
        Source s = source(type);
        String jpql = "select e.key, " + s.label() + ", " + s.detail() + ", " + s.status() + " from " + s.entity() + " e"
                + " where " + s.project() + ".key = :p and e.key = :k";
        return em.createQuery(jpql, Object[].class).setParameter("p", projectKey).setParameter("k", key).setMaxResults(1)
                .getResultList().stream().findFirst().map(row -> hit(type, row));
    }

    private static Hit hit(ItemType type, Object[] row) {
        String status = row[3] == null ? null : type == ItemType.REPORT ? (Boolean.TRUE.equals(row[3]) ? "FROZEN" : "DRAFT") : row[3].toString();
        return new Hit(type, (String) row[0], (String) row[1], row[2] == null ? null : row[2].toString(), status);
    }

    /** Les jokers saisis ({@code %}, {@code _}) sont cherchés tels quels. */
    private static String escape(String text) {
        return text.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
    }
}
