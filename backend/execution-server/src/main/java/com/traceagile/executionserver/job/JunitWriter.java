package com.traceagile.executionserver.job;

import com.traceagile.executionserver.job.JobStore.TestRow;
import java.util.List;

/** ADR-0021 rapport JUnit XML du job (un cas par test TraceAgile), joint comme artefact « junit.xml ». */
final class JunitWriter {

    private JunitWriter() {
    }

    static String write(String runId, List<TestRow> tests) {
        long failures = tests.stream().filter(t -> t.status().equals("FAILED")).count();
        long errors = tests.stream().filter(t -> t.status().equals("ERROR")).count();
        long skipped = tests.stream().filter(t -> t.status().equals("SKIPPED")).count();
        double time = tests.stream().mapToLong(t -> t.durationMs() == null ? 0 : t.durationMs()).sum() / 1000.0;
        StringBuilder xml = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
        xml.append("<testsuites name=\"").append(escape(runId)).append("\" tests=\"").append(tests.size()).append("\" failures=\"").append(failures)
                .append("\" errors=\"").append(errors).append("\" skipped=\"").append(skipped).append("\" time=\"").append(time).append("\">\n");
        xml.append("  <testsuite name=\"").append(escape(runId)).append("\" tests=\"").append(tests.size()).append("\" failures=\"").append(failures)
                .append("\" errors=\"").append(errors).append("\" skipped=\"").append(skipped).append("\" time=\"").append(time).append("\">\n");
        for (TestRow test : tests) {
            String identifier = test.spec().testIdentifier() == null ? test.spec().testKey() : test.spec().testIdentifier();
            xml.append("    <testcase classname=\"").append(escape(test.spec().framework() == null ? "traceagile" : test.spec().framework()))
                    .append("\" name=\"").append(escape(identifier)).append("\" time=\"").append(test.durationMs() == null ? 0 : test.durationMs() / 1000.0)
                    .append("\">");
            switch (test.status()) {
                case "FAILED" -> xml.append("<failure message=\"").append(escape(test.message())).append("\"/>");
                case "ERROR" -> xml.append("<error message=\"").append(escape(test.message())).append("\"/>");
                case "SKIPPED" -> xml.append("<skipped/>");
                default -> { }
            }
            xml.append("<properties><property name=\"testKey\" value=\"").append(escape(test.spec().testKey())).append("\"/></properties>");
            xml.append("</testcase>\n");
        }
        xml.append("  </testsuite>\n</testsuites>\n");
        return xml.toString();
    }

    static String escape(String text) {
        if (text == null) {
            return "";
        }
        return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replaceAll("[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F]", "");
    }
}
