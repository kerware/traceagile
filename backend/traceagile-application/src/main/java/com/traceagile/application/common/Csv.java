package com.traceagile.application.common;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * F-REQ-23 CSV minimal (RFC 4180). Lecture : séparateur « ; » ou « , » détecté sur l'en-tête, BOM
 * ignoré. Écriture : « ; » et BOM UTF-8, pour une ouverture directe dans Excel en français (ADR-0011).
 */
public final class Csv {

    private Csv() {
    }

    public static List<List<String>> parse(String text) {
        String content = text.startsWith("﻿") ? text.substring(1) : text;
        char separator = detectSeparator(content);
        List<List<String>> rows = new ArrayList<>();
        List<String> row = new ArrayList<>();
        StringBuilder field = new StringBuilder();
        boolean quoted = false;
        int line = 1;
        for (int i = 0; i < content.length(); i++) {
            char c = content.charAt(i);
            if (quoted) {
                if (c == '"') {
                    if (i + 1 < content.length() && content.charAt(i + 1) == '"') {
                        field.append('"');
                        i++;
                    } else {
                        quoted = false;
                    }
                } else {
                    if (c == '\n') {
                        line++;
                    }
                    field.append(c);
                }
            } else if (c == '"' && field.isEmpty()) {
                quoted = true;
            } else if (c == separator) {
                row.add(field.toString());
                field.setLength(0);
            } else if (c == '\n' || c == '\r') {
                if (c == '\r' && i + 1 < content.length() && content.charAt(i + 1) == '\n') {
                    i++;
                }
                row.add(field.toString());
                field.setLength(0);
                addIfNotBlank(rows, row);
                row = new ArrayList<>();
                line++;
            } else {
                field.append(c);
            }
        }
        if (quoted) {
            throw new UnprocessableException("CSV_MALFORMED", "Guillemet non fermé vers la ligne " + line + ".");
        }
        row.add(field.toString());
        addIfNotBlank(rows, row);
        return rows;
    }

    public static String write(List<List<String>> rows) {
        StringBuilder out = new StringBuilder("﻿");
        for (List<String> row : rows) {
            out.append(row.stream().map(Csv::escape).collect(Collectors.joining(";"))).append("\r\n");
        }
        return out.toString();
    }

    private static String escape(String value) {
        if (value == null) {
            return "";
        }
        if (value.contains(";") || value.contains("\"") || value.contains("\n") || value.contains("\r") || value.contains(",")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }

    private static char detectSeparator(String content) {
        int end = content.indexOf('\n');
        String header = end < 0 ? content : content.substring(0, end);
        return header.chars().filter(c -> c == ';').count() >= header.chars().filter(c -> c == ',').count() ? ';' : ',';
    }

    private static void addIfNotBlank(List<List<String>> rows, List<String> row) {
        if (row.stream().anyMatch(f -> !f.isBlank())) {
            rows.add(row);
        }
    }
}
