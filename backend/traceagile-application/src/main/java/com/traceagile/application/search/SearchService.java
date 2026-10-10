package com.traceagile.application.search;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.regex.Pattern;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * §13.1 recherche globale ({@code Ctrl+K}) par clé et par titre, et aperçu d'une clé au survol (ADR-0024).
 */
@Service
@Transactional(readOnly = true)
public class SearchService {

    public static final int LIMIT = 20;
    private static final Pattern KEY = Pattern.compile("([A-Za-z]{2,4})-(\\d+)");

    private final SearchIndex index;

    public SearchService(SearchIndex index) {
        this.index = index;
    }

    /** Type d'élément ; {@code prefix} de sa clé. */
    public enum ItemType {
        REQUIREMENT("REQ"),
        TEST("TC"),
        CAMPAIGN("CMP"),
        DEFECT("DEF"),
        RUN("RUN"),
        REPORT("RPT"),
        SPRINT("SPR"),
        RELEASE("REL");

        private final String prefix;

        ItemType(String prefix) {
            this.prefix = prefix;
        }

        public String prefix() {
            return prefix;
        }

        static Optional<ItemType> ofKey(String key) {
            String prefix = key.substring(0, key.indexOf('-')).toUpperCase(Locale.ROOT);
            for (ItemType type : values()) {
                if (type.prefix.equals(prefix)) {
                    return Optional.of(type);
                }
            }
            return Optional.empty();
        }
    }

    /**
     * Élément trouvé.
     *
     * @param detail  précision lisible (type d'exigence, nature du test, sévérité…)
     * @param status  statut technique (pour la couleur)
     */
    public record Hit(ItemType type, String key, String title, String detail, String status) {
    }

    /**
     * Clé exacte d'abord, puis clés qui commencent par la saisie, puis titres qui la contiennent ; au
     * plus {@value #LIMIT} résultats. Moins de 2 caractères : rien.
     */
    public List<Hit> search(String projectKey, String q) {
        String text = q == null ? "" : q.strip();
        if (text.length() < 2) {
            return List.of();
        }
        List<Hit> hits = new ArrayList<>();
        for (ItemType type : ItemType.values()) {
            hits.addAll(index.search(projectKey, type, text, LIMIT));
        }
        String upper = text.toUpperCase(Locale.ROOT);
        return hits.stream()
                .sorted(Comparator.comparingInt((Hit h) -> h.key().equals(upper) ? 0 : h.key().startsWith(upper) ? 1 : 2)
                        .thenComparing(h -> h.type().ordinal())
                        .thenComparingInt(h -> number(h.key())))
                .distinct()
                .limit(LIMIT)
                .toList();
    }

    /** Aperçu d'une clé ({@code REQ-12}, {@code TC-45}…), vide si elle n'existe pas dans le projet. */
    public Optional<Hit> find(String projectKey, String key) {
        String k = key == null ? "" : key.strip().toUpperCase(Locale.ROOT);
        if (!KEY.matcher(k).matches()) {
            return Optional.empty();
        }
        return ItemType.ofKey(k).flatMap(type -> index.find(projectKey, type, k));
    }

    private static int number(String key) {
        try {
            return Integer.parseInt(key.substring(key.lastIndexOf('-') + 1));
        } catch (NumberFormatException e) {
            return Integer.MAX_VALUE;
        }
    }
}
