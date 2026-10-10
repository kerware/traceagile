package com.traceagile.infrastructure.reports;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.application.automation.ReportParser;
import com.traceagile.application.common.UnprocessableException;
import com.traceagile.domain.execution.ExecutionStatus;
import java.io.ByteArrayInputStream;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.springframework.stereotype.Component;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * F-EXE-10 lecture des rapports (ADR-0020). JUnit : un résultat par {@code testcase}, identifiants
 * « Classe#méthode » ; Cucumber : un par scénario, identifiant = nom ; Robot : un par {@code test} ;
 * Playwright : un par spec, dernière tentative retenue. Le XML est lu sans DTD ni entité externe.
 */
@Component
public class ReportParsers implements ReportParser {

    private static final ObjectMapper JSON = new ObjectMapper();
    private static final Pattern TAG_IN_TITLE = Pattern.compile("@[\\w-]+");
    private static final DateTimeFormatter ROBOT_TIME = DateTimeFormatter.ofPattern("yyyyMMdd HH:mm:ss.SSS");

    @Override
    public List<ReportResult> parse(ReportFormat format, byte[] content) {
        try {
            List<ReportResult> results = switch (format) {
                case JUNIT -> junit(xml(content));
                case CUCUMBER -> cucumber(JSON.readTree(content));
                case ROBOT -> robot(xml(content));
                case PLAYWRIGHT -> playwright(JSON.readTree(content));
            };
            if (results.isEmpty()) {
                throw new IllegalArgumentException("aucun test");
            }
            return results;
        } catch (UnprocessableException e) {
            throw e;
        } catch (Exception e) {
            throw new UnprocessableException("REPORT_INVALID", "Le fichier n'est pas un rapport " + format + " lisible (" + e.getMessage() + ").");
        }
    }

    // ---------------------------------------------------------------- JUnit XML

    private static List<ReportResult> junit(Document doc) {
        String root = doc.getDocumentElement().getTagName();
        if (!root.equals("testsuites") && !root.equals("testsuite")) {
            throw new IllegalArgumentException("racine <" + root + ">");
        }
        List<ReportResult> results = new ArrayList<>();
        NodeList cases = doc.getElementsByTagName("testcase");
        for (int i = 0; i < cases.getLength(); i++) {
            Element tc = (Element) cases.item(i);
            String className = tc.getAttribute("classname");
            String name = tc.getAttribute("name");
            String simple = className.contains(".") ? className.substring(className.lastIndexOf('.') + 1) : className;
            LinkedHashSet<String> ids = new LinkedHashSet<>();
            if (!className.isEmpty()) {
                ids.add(className + "#" + name);
                ids.add(simple + "#" + name);
            }
            ids.add(name);
            ExecutionStatus status = ExecutionStatus.PASSED;
            String message = null;
            Element failure = child(tc, "failure");
            Element error = child(tc, "error");
            if (failure != null) {
                status = ExecutionStatus.FAILED;
                message = attributeOrText(failure);
            } else if (error != null) {
                status = ExecutionStatus.ERROR;
                message = attributeOrText(error);
            } else if (child(tc, "skipped") != null) {
                status = ExecutionStatus.SKIPPED;
            }
            results.add(new ReportResult(name, List.copyOf(ids), status, seconds(tc.getAttribute("time")), message, List.of()));
        }
        return results;
    }

    // ---------------------------------------------------------------- Cucumber JSON

    private static List<ReportResult> cucumber(JsonNode root) {
        if (!root.isArray()) {
            throw new IllegalArgumentException("tableau de fonctionnalités attendu");
        }
        List<ReportResult> results = new ArrayList<>();
        for (JsonNode feature : root) {
            for (JsonNode element : feature.path("elements")) {
                if ("background".equals(element.path("type").asText())) {
                    continue;
                }
                String name = element.path("name").asText();
                boolean failed = false;
                boolean allSkipped = true;
                long nanos = 0;
                String message = null;
                for (JsonNode step : element.path("steps")) {
                    JsonNode result = step.path("result");
                    String s = result.path("status").asText();
                    nanos += result.path("duration").asLong(0);
                    if (s.equals("failed")) {
                        failed = true;
                        message = message == null ? textOrNull(result.path("error_message")) : message;
                    }
                    if (s.equals("passed") || s.equals("failed")) {
                        allSkipped = false;
                    }
                }
                List<String> tags = new ArrayList<>();
                element.path("tags").forEach(t -> tags.add(t.path("name").asText()));
                ExecutionStatus status = failed ? ExecutionStatus.FAILED : allSkipped ? ExecutionStatus.SKIPPED : ExecutionStatus.PASSED;
                results.add(new ReportResult(name, List.of(name), status, nanos / 1_000_000, message, tags));
            }
        }
        return results;
    }

    // ---------------------------------------------------------------- Robot output.xml

    private static List<ReportResult> robot(Document doc) {
        if (!doc.getDocumentElement().getTagName().equals("robot")) {
            throw new IllegalArgumentException("racine <robot> attendue");
        }
        List<ReportResult> results = new ArrayList<>();
        NodeList tests = doc.getElementsByTagName("test");
        for (int i = 0; i < tests.getLength(); i++) {
            Element test = (Element) tests.item(i);
            String name = test.getAttribute("name");
            Element status = child(test, "status");
            ExecutionStatus result = switch (status == null ? "" : status.getAttribute("status")) {
                case "PASS" -> ExecutionStatus.PASSED;
                case "FAIL" -> ExecutionStatus.FAILED;
                case "SKIP", "NOT RUN" -> ExecutionStatus.SKIPPED;
                default -> ExecutionStatus.ERROR;
            };
            List<String> tags = new ArrayList<>();
            Element tagsNode = child(test, "tags");
            if (tagsNode != null) {
                NodeList tagList = tagsNode.getElementsByTagName("tag");
                for (int j = 0; j < tagList.getLength(); j++) {
                    tags.add(tagList.item(j).getTextContent().strip());
                }
            }
            String message = status == null || status.getTextContent().isBlank() ? null : status.getTextContent().strip();
            results.add(new ReportResult(name, List.of(name), result, status == null ? null : robotDuration(status), message, tags));
        }
        return results;
    }

    private static Long robotDuration(Element status) {
        if (!status.getAttribute("elapsed").isEmpty()) {
            return seconds(status.getAttribute("elapsed"));
        }
        if (!status.getAttribute("starttime").isEmpty() && !status.getAttribute("endtime").isEmpty()) {
            return Duration.between(LocalDateTime.parse(status.getAttribute("starttime"), ROBOT_TIME),
                    LocalDateTime.parse(status.getAttribute("endtime"), ROBOT_TIME)).toMillis();
        }
        return null;
    }

    // ---------------------------------------------------------------- Playwright JSON

    private static List<ReportResult> playwright(JsonNode root) {
        if (!root.has("suites")) {
            throw new IllegalArgumentException("« suites » attendu");
        }
        List<ReportResult> results = new ArrayList<>();
        root.path("suites").forEach(suite -> playwrightSuite(suite, List.of(), results));
        return results;
    }

    private static void playwrightSuite(JsonNode suite, List<String> parents, List<ReportResult> results) {
        List<String> path = new ArrayList<>(parents);
        if (!suite.path("title").asText().isEmpty()) {
            path.add(suite.path("title").asText());
        }
        for (JsonNode spec : suite.path("specs")) {
            String title = spec.path("title").asText();
            List<String> full = new ArrayList<>(path);
            full.add(title);
            LinkedHashSet<String> ids = new LinkedHashSet<>();
            for (int i = 0; i < full.size(); i++) {
                ids.add(String.join(" › ", full.subList(i, full.size())));
            }
            JsonNode last = null;
            for (JsonNode test : spec.path("tests")) {
                for (JsonNode result : test.path("results")) {
                    last = result;
                }
            }
            ExecutionStatus status = last == null ? ExecutionStatus.SKIPPED : switch (last.path("status").asText()) {
                case "passed" -> ExecutionStatus.PASSED;
                case "failed", "timedOut" -> ExecutionStatus.FAILED;
                case "skipped" -> ExecutionStatus.SKIPPED;
                default -> ExecutionStatus.ERROR;
            };
            List<String> tags = new ArrayList<>();
            spec.path("tags").forEach(t -> tags.add(t.asText()));
            Matcher inTitle = TAG_IN_TITLE.matcher(title);
            while (inTitle.find()) {
                tags.add(inTitle.group());
            }
            String message = last == null ? null : textOrNull(last.path("error").path("message"));
            results.add(new ReportResult(title, List.copyOf(ids), status, last == null ? null : last.path("duration").asLong(0), message, tags));
        }
        suite.path("suites").forEach(child -> playwrightSuite(child, path, results));
    }

    // ---------------------------------------------------------------- outils

    private static Document xml(byte[] content) throws Exception {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
        factory.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
        factory.setXIncludeAware(false);
        factory.setExpandEntityReferences(false);
        DocumentBuilder builder = factory.newDocumentBuilder();
        builder.setErrorHandler(null);
        return builder.parse(new ByteArrayInputStream(content));
    }

    private static Element child(Element parent, String tag) {
        for (Node n = parent.getFirstChild(); n != null; n = n.getNextSibling()) {
            if (n instanceof Element e && e.getTagName().equals(tag)) {
                return e;
            }
        }
        return null;
    }

    private static String attributeOrText(Element element) {
        String message = element.getAttribute("message");
        if (!message.isBlank()) {
            return message.strip();
        }
        String text = element.getTextContent();
        return text == null || text.isBlank() ? null : text.strip();
    }

    private static Long seconds(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return Math.round(Double.parseDouble(value.replace(",", "").strip()) * 1000);
    }

    private static String textOrNull(JsonNode node) {
        return node.isMissingNode() || node.isNull() || node.asText().isBlank() ? null : node.asText().strip();
    }
}
