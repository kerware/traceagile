package com.traceagile.domain.testcase;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** F-AUT-06 tags Gherkin de traçabilité : {@code @REQ-12} (exigence) et {@code @AC-12-3} (critère n° 3 de REQ-12). */
public record GherkinTags(List<String> requirementKeys, List<CriterionTag> criteria) {

    private static final Pattern REQUIREMENT = Pattern.compile("(?<![\\w@])@REQ-(\\d+)\\b");
    private static final Pattern CRITERION = Pattern.compile("(?<![\\w@])@AC-(\\d+)-(\\d+)\\b");

    public record CriterionTag(String requirementKey, int position) {
    }

    public static GherkinTags parse(String source) {
        if (source == null) {
            return new GherkinTags(List.of(), List.of());
        }
        Set<String> requirements = new LinkedHashSet<>();
        Set<CriterionTag> criteria = new LinkedHashSet<>();
        for (String line : source.lines().toList()) {
            if (!line.strip().startsWith("@")) {
                continue;
            }
            Matcher r = REQUIREMENT.matcher(line);
            while (r.find()) {
                requirements.add("REQ-" + r.group(1));
            }
            Matcher c = CRITERION.matcher(line);
            while (c.find()) {
                criteria.add(new CriterionTag("REQ-" + c.group(1), Integer.parseInt(c.group(2))));
            }
        }
        return new GherkinTags(List.copyOf(requirements), List.copyOf(criteria));
    }

    /** Exigences citées directement ou au travers d'un critère. */
    public List<String> allRequirementKeys() {
        Set<String> keys = new LinkedHashSet<>(requirementKeys);
        criteria.forEach(c -> keys.add(c.requirementKey()));
        return List.copyOf(keys);
    }
}
