package com.traceagile.application.search;

import com.traceagile.application.search.SearchService.Hit;
import com.traceagile.application.search.SearchService.ItemType;
import java.util.List;
import java.util.Optional;

/** Port de recherche par clé et par titre, un type d'élément à la fois (ADR-0024). */
public interface SearchIndex {

    List<Hit> search(String projectKey, ItemType type, String text, int limit);

    Optional<Hit> find(String projectKey, ItemType type, String key);
}
