package com.traceagile.domain.testcase;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Jeu de données nommé (ADR-0013) : une ligne par exécution, une valeur par paramètre. Une valeur
 * vide signifie « valeur par défaut du paramètre ». Valeurs scalaires JSON (texte, nombre, booléen).
 */
public record DataSet(String name, List<Map<String, Object>> rows) {

    public DataSet {
        name = name == null ? null : name.strip();
        rows = rows == null ? List.of() : rows.stream().map(r -> r == null ? Map.<String, Object>of() : copy(r)).toList();
    }

    public static DataSet of(String name, List<? extends Map<String, ?>> rows) {
        return new DataSet(name, rows == null ? null : rows.stream().map(DataSet::copy).toList());
    }

    private static Map<String, Object> copy(Map<String, ?> row) {
        return new LinkedHashMap<>(row);
    }
}
