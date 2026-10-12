package com.traceagile.domain.testcase;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/**
 * Jeu de données nommé (ADR-0013) : une ligne par exécution, une valeur par paramètre. Une valeur
 * vide signifie « valeur par défaut du paramètre ». Valeurs scalaires JSON (texte, nombre, booléen).
 * ADR-0029 chaque ligne a un nom ({@code rowNames}, même ordre que {@code rows}) par lequel on la
 * désigne (appel d'un cas de test, campagne, exécution) ; un nom absent prend la première valeur de
 * la ligne (« standard_user »), ou « Ligne n ».
 */
public record DataSet(String name, List<Map<String, Object>> rows, List<String> rowNames) {

    public DataSet {
        name = name == null ? null : name.strip();
        rows = rows == null ? List.of() : rows.stream().map(r -> r == null ? Map.<String, Object>of() : copy(r)).toList();
        rowNames = names(rows, rowNames);
    }

    public DataSet(String name, List<Map<String, Object>> rows) {
        this(name, rows, null);
    }

    public static DataSet of(String name, List<? extends Map<String, ?>> rows) {
        return of(name, rows, null);
    }

    public static DataSet of(String name, List<? extends Map<String, ?>> rows, List<String> rowNames) {
        return new DataSet(name, rows == null ? null : rows.stream().map(DataSet::copy).toList(), rowNames);
    }

    /** Index (base 0) de la ligne de ce nom, sans tenir compte de la casse ; -1 si aucune. */
    public int indexOf(String rowName) {
        for (int i = 0; i < rowNames.size(); i++) {
            if (rowNames.get(i).equalsIgnoreCase(rowName == null ? "" : rowName.strip())) {
                return i;
            }
        }
        return -1;
    }

    /** Noms donnés en double dans ce jeu (pour l'erreur TEST_DATASET_ROW_NAME_DUPLICATED). */
    public List<String> duplicatedRowNames() {
        Set<String> seen = new HashSet<>();
        return rowNames.stream().filter(n -> !seen.add(n.toLowerCase(Locale.ROOT))).toList();
    }

    private static List<String> names(List<Map<String, Object>> rows, List<String> given) {
        List<String> names = new ArrayList<>();
        Set<String> taken = new HashSet<>();
        // noms donnés d'abord (un doublon donné reste visible : TestCase le refuse), puis noms par défaut
        for (int i = 0; i < rows.size(); i++) {
            String name = given != null && i < given.size() && given.get(i) != null ? given.get(i).strip() : "";
            names.add(name);
            if (!name.isEmpty()) {
                taken.add(name.toLowerCase(Locale.ROOT));
            }
        }
        for (int i = 0; i < rows.size(); i++) {
            if (names.get(i).isEmpty()) {
                String base = rows.get(i).values().stream().filter(Objects::nonNull).map(String::valueOf).map(String::strip)
                        .filter(v -> !v.isEmpty()).findFirst().orElse("Ligne " + (i + 1));
                String candidate = base;
                for (int n = 2; taken.contains(candidate.toLowerCase(Locale.ROOT)); n++) {
                    candidate = base + " (" + n + ")";
                }
                taken.add(candidate.toLowerCase(Locale.ROOT));
                names.set(i, candidate);
            }
        }
        return List.copyOf(names);
    }

    private static Map<String, Object> copy(Map<String, ?> row) {
        return new LinkedHashMap<>(row);
    }
}
