package com.traceagile.domain.common;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** F-REQ-21 comparaison de deux versions ; NF-16 diff JSON de l'audit. */
class SnapshotDiffTest {

    @Test
    @DisplayName("F-REQ-21 seuls les champs modifiés, ajoutés ou retirés apparaissent, dans l'ordre")
    void diff() {
        Map<String, Object> before = new LinkedHashMap<>();
        before.put("title", "Panier");
        before.put("priority", "SHOULD");
        before.put("storyPoints", 3);
        before.put("criteria", List.of("[TEXT] A"));
        Map<String, Object> after = new LinkedHashMap<>();
        after.put("title", "Panier");
        after.put("priority", "MUST");
        after.put("criteria", List.of("[TEXT] A", "[TEXT] B"));
        after.put("externalRef", "JIRA-1");

        List<FieldChange> changes = SnapshotDiff.between(before, after);

        assertThat(changes).containsExactly(
                new FieldChange("priority", "SHOULD", "MUST"),
                new FieldChange("storyPoints", 3, null),
                new FieldChange("criteria", List.of("[TEXT] A"), List.of("[TEXT] A", "[TEXT] B")),
                new FieldChange("externalRef", null, "JIRA-1"));
    }

    @Test
    @DisplayName("F-REQ-21 deux versions identiques : aucune différence")
    void identical() {
        assertThat(SnapshotDiff.between(Map.of("a", 1), Map.of("a", 1))).isEmpty();
    }
}
