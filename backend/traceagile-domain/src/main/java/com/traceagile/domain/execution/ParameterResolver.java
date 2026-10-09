package com.traceagile.domain.execution;

import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** ADR-0013 / ADR-0016 remplace les {@code ${nom}} d'un pas par leur valeur ; un paramètre sans valeur reste tel quel. */
public final class ParameterResolver {

    private static final Pattern VARIABLE = Pattern.compile("\\$\\{([\\w.-]+)}");

    private ParameterResolver() {
    }

    public static String resolve(String text, Map<String, String> values) {
        if (text == null) {
            return null;
        }
        Matcher matcher = VARIABLE.matcher(text);
        StringBuilder out = new StringBuilder();
        while (matcher.find()) {
            String value = values.get(matcher.group(1));
            matcher.appendReplacement(out, Matcher.quoteReplacement(value != null ? value : matcher.group()));
        }
        matcher.appendTail(out);
        return out.toString();
    }
}
