package com.traceagile.domain.common;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/** Différence champ par champ entre deux instantanés (F-REQ-21 comparaison de versions, NF-16 audit). */
public final class SnapshotDiff {

    private SnapshotDiff() {
    }

    /** Champs de {@code before} puis champs nouveaux de {@code after}, dans leur ordre d'origine. */
    public static List<FieldChange> between(Map<String, ?> before, Map<String, ?> after) {
        Set<String> fields = new LinkedHashSet<>(before.keySet());
        fields.addAll(after.keySet());
        List<FieldChange> changes = new ArrayList<>();
        for (String field : fields) {
            Object previous = before.get(field);
            Object next = after.get(field);
            if (!Objects.equals(previous, next)) {
                changes.add(new FieldChange(field, previous, next));
            }
        }
        return changes;
    }
}
