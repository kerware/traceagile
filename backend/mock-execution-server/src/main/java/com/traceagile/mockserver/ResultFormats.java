package com.traceagile.mockserver;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * ADR-0021 résultats d'un job aux formats standard : JUnit XML (un testcase par test, traces dans
 * system-out / system-err) et Jest JSON (structure de {@code jest --json}).
 */
final class ResultFormats {

    /** Résultat d'un test du job. */
    record TestResult(String testKey, String identifier, String technique, String status, long durationMs, String message, String stackTrace,
                      List<String> trace) {
    }

    private ResultFormats() {
    }

    static String junit(String runId, List<TestResult> results, Instant startedAt) {
        long failures = results.stream().filter(r -> r.status().equals("FAILED")).count();
        long errors = results.stream().filter(r -> r.status().equals("ERROR")).count();
        long skipped = results.stream().filter(r -> r.status().equals("SKIPPED")).count();
        double time = results.stream().mapToLong(TestResult::durationMs).sum() / 1000.0;
        StringBuilder xml = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
        xml.append("<testsuites name=\"").append(escape(runId)).append("\" tests=\"").append(results.size()).append("\" failures=\"").append(failures)
                .append("\" errors=\"").append(errors).append("\" skipped=\"").append(skipped).append("\" time=\"").append(time).append("\">\n");
        xml.append("  <testsuite name=\"").append(escape(runId)).append("\" tests=\"").append(results.size()).append("\" failures=\"").append(failures)
                .append("\" errors=\"").append(errors).append("\" skipped=\"").append(skipped).append("\" time=\"").append(time)
                .append("\" timestamp=\"").append(startedAt).append("\">\n");
        for (TestResult r : results) {
            String identifier = r.identifier() == null || r.identifier().isBlank() ? r.testKey() : r.identifier();
            int hash = identifier.indexOf('#');
            String className = hash > 0 ? identifier.substring(0, hash) : r.technique().toLowerCase();
            String name = hash > 0 ? identifier.substring(hash + 1) : identifier;
            xml.append("    <testcase classname=\"").append(escape(className)).append("\" name=\"").append(escape(name))
                    .append("\" time=\"").append(r.durationMs() / 1000.0).append("\">\n");
            switch (r.status()) {
                case "FAILED" -> xml.append("      <failure message=\"").append(escape(r.message())).append("\" type=\"AssertionError\">")
                        .append(escape(r.stackTrace())).append("</failure>\n");
                case "ERROR" -> xml.append("      <error message=\"").append(escape(r.message())).append("\" type=\"InfrastructureError\">")
                        .append(escape(r.stackTrace())).append("</error>\n");
                case "SKIPPED" -> xml.append("      <skipped/>\n");
                default -> {
                    // réussi
                }
            }
            xml.append("      <system-out>").append(escape(String.join("\n", r.trace()))).append("</system-out>\n");
            if (r.stackTrace() != null) {
                xml.append("      <system-err>").append(escape(r.stackTrace())).append("</system-err>\n");
            }
            xml.append("    </testcase>\n");
        }
        return xml.append("  </testsuite>\n</testsuites>\n").toString();
    }

    static String jest(ObjectMapper json, List<TestResult> results, Instant startedAt) {
        List<Map<String, Object>> assertions = new ArrayList<>();
        for (TestResult r : results) {
            String identifier = r.identifier() == null || r.identifier().isBlank() ? r.testKey() : r.identifier();
            int hash = identifier.indexOf('#');
            List<String> ancestors = hash > 0 ? List.of(identifier.substring(0, hash)) : List.of();
            String title = hash > 0 ? identifier.substring(hash + 1) : identifier;
            Map<String, Object> a = new LinkedHashMap<>();
            a.put("ancestorTitles", ancestors);
            a.put("title", title);
            a.put("fullName", String.join(" ", ancestors) + (ancestors.isEmpty() ? "" : " ") + title);
            a.put("status", switch (r.status()) {
                case "PASSED" -> "passed";
                case "SKIPPED" -> "pending";
                default -> "failed";
            });
            a.put("duration", r.durationMs());
            a.put("failureMessages", r.message() == null ? List.of() : List.of(r.message() + (r.stackTrace() == null ? "" : "\n" + r.stackTrace())));
            a.put("location", null);
            assertions.add(a);
        }
        long failed = results.stream().filter(r -> r.status().equals("FAILED") || r.status().equals("ERROR")).count();
        long passed = results.stream().filter(r -> r.status().equals("PASSED")).count();
        long pending = results.size() - failed - passed;
        Map<String, Object> file = new LinkedHashMap<>();
        file.put("name", "simulated.test.js");
        file.put("status", failed > 0 ? "failed" : "passed");
        file.put("startTime", startedAt.toEpochMilli());
        file.put("endTime", startedAt.toEpochMilli() + results.stream().mapToLong(TestResult::durationMs).sum());
        file.put("message", "");
        file.put("assertionResults", assertions);
        Map<String, Object> root = new LinkedHashMap<>();
        root.put("numTotalTests", results.size());
        root.put("numPassedTests", passed);
        root.put("numFailedTests", failed);
        root.put("numPendingTests", pending);
        root.put("success", failed == 0);
        root.put("startTime", startedAt.toEpochMilli());
        root.put("testResults", List.of(file));
        try {
            return json.writerWithDefaultPrettyPrinter().writeValueAsString(root);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
    }

    private static String escape(String text) {
        if (text == null) {
            return "";
        }
        return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
