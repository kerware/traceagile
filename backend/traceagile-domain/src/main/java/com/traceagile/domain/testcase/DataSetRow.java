package com.traceagile.domain.testcase;

import com.traceagile.domain.common.BusinessRuleException;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * ADR-0013 / ADR-0018 une ligne d'un jeu de données d'un test : nom exact du jeu, index (base 0) et
 * valeurs non vides, qui remplacent les défauts des paramètres.
 */
public record DataSetRow(String dataSetName, int row, Map<String, String> values) {

    /** {@code row} {@code null} = première ligne ; jeu ou ligne inconnus : 422 EXECUTION_DATASET_UNKNOWN. */
    public static DataSetRow of(TestCase test, String dataSetName, Integer row) {
        DataSet set = test.getDataSets().stream().filter(d -> d.name().equalsIgnoreCase(dataSetName)).findFirst()
                .orElseThrow(() -> new BusinessRuleException("EXECUTION_DATASET_UNKNOWN",
                        "Jeu de données « " + dataSetName + " » inconnu pour " + test.getKey() + "."));
        int index = row == null ? 0 : row;
        if (index < 0 || index >= set.rows().size()) {
            throw new BusinessRuleException("EXECUTION_DATASET_UNKNOWN", "Le jeu « " + set.name() + " » n'a pas de ligne " + (index + 1) + ".");
        }
        Map<String, String> values = new LinkedHashMap<>();
        set.rows().get(index).forEach((name, value) -> {
            if (value != null && !String.valueOf(value).isEmpty()) {
                values.put(name, String.valueOf(value));
            }
        });
        return new DataSetRow(set.name(), index, values);
    }

    /** Nombre de lignes du jeu (0 s'il n'existe pas). */
    public static int size(TestCase test, String dataSetName) {
        return test.getDataSets().stream().filter(d -> d.name().equalsIgnoreCase(dataSetName)).findFirst().map(d -> d.rows().size()).orElse(0);
    }
}
