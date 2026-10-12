package com.traceagile.domain.testcase;

import com.traceagile.domain.common.BusinessRuleException;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * ADR-0013 / ADR-0018 une ligne d'un jeu de données d'un test : nom exact du jeu, index (base 0),
 * nom de la ligne (ADR-0029) et valeurs non vides, qui remplacent les défauts des paramètres.
 */
public record DataSetRow(String dataSetName, int row, String rowName, Map<String, String> values) {

    /** {@code row} {@code null} = première ligne ; jeu ou ligne inconnus : 422 EXECUTION_DATASET_UNKNOWN. */
    public static DataSetRow of(TestCase test, String dataSetName, Integer row) {
        DataSet set = find(test, dataSetName);
        int index = row == null ? 0 : row;
        if (index < 0 || index >= set.rows().size()) {
            throw new BusinessRuleException("EXECUTION_DATASET_UNKNOWN", "Le jeu « " + set.name() + " » n'a pas de ligne " + (index + 1) + ".");
        }
        return of(set, index);
    }

    /** ADR-0029 ligne désignée par son nom ; jeu ou ligne inconnus : 422 EXECUTION_DATASET_UNKNOWN. */
    public static DataSetRow named(TestCase test, String dataSetName, String rowName) {
        DataSet set = find(test, dataSetName);
        int index = set.indexOf(rowName);
        if (index < 0) {
            throw new BusinessRuleException("EXECUTION_DATASET_UNKNOWN",
                    "Le jeu « " + set.name() + " » de " + test.getKey() + " n'a pas de ligne « " + rowName + " ».");
        }
        return of(set, index);
    }

    /** Nombre de lignes du jeu (0 s'il n'existe pas). */
    public static int size(TestCase test, String dataSetName) {
        return test.getDataSets().stream().filter(d -> d.name().equalsIgnoreCase(dataSetName)).findFirst().map(d -> d.rows().size()).orElse(0);
    }

    private static DataSet find(TestCase test, String dataSetName) {
        return test.getDataSets().stream().filter(d -> d.name().equalsIgnoreCase(dataSetName)).findFirst()
                .orElseThrow(() -> new BusinessRuleException("EXECUTION_DATASET_UNKNOWN",
                        "Jeu de données « " + dataSetName + " » inconnu pour " + test.getKey() + "."));
    }

    private static DataSetRow of(DataSet set, int index) {
        Map<String, String> values = new LinkedHashMap<>();
        set.rows().get(index).forEach((name, value) -> {
            if (value != null && !String.valueOf(value).isEmpty()) {
                values.put(name, String.valueOf(value));
            }
        });
        return new DataSetRow(set.name(), index, set.rowNames().get(index), values);
    }
}
