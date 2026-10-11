package com.traceagile.executionserver.job.executor;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.stream.Stream;
import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * Lecture des rapports JUnit XML produits par les frameworks (Playwright, Cypress, Surefire, pytest,
 * Robot Framework --xunit, Cucumber) et choix des cas correspondant à l'identifiant du test.
 */
public final class JUnitReports {

    /** Un cas de test du rapport. */
    public record Case(String className, String name, String status, long durationMs, String message, String stackTrace) {
    }

    private JUnitReports() {
    }

    /** Tous les cas des fichiers .xml du dossier (récursif) ou du fichier. */
    public static List<Case> read(Path location) {
        List<Case> cases = new ArrayList<>();
        if (location == null || !Files.exists(location)) {
            return cases;
        }
        try (Stream<Path> files = Files.isDirectory(location) ? Files.walk(location) : Stream.of(location)) {
            for (Path file : files.filter(f -> f.toString().endsWith(".xml") && Files.isRegularFile(f)).toList()) {
                cases.addAll(parse(file));
            }
        } catch (IOException e) {
            return cases;
        }
        return cases;
    }

    static List<Case> parse(Path file) {
        List<Case> cases = new ArrayList<>();
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
            factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(file.toFile());
            NodeList nodes = doc.getElementsByTagName("testcase");
            for (int i = 0; i < nodes.getLength(); i++) {
                Element tc = (Element) nodes.item(i);
                String status = "PASSED";
                String message = null;
                String stack = null;
                Element problem = first(tc, "failure");
                if (problem != null) {
                    status = "FAILED";
                } else if ((problem = first(tc, "error")) != null) {
                    status = "ERROR";
                } else if (first(tc, "skipped") != null) {
                    status = "SKIPPED";
                }
                if (problem != null) {
                    message = problem.getAttribute("message").isBlank() ? firstLine(problem.getTextContent()) : problem.getAttribute("message");
                    stack = problem.getTextContent() == null ? null : problem.getTextContent().strip();
                }
                cases.add(new Case(tc.getAttribute("classname"), tc.getAttribute("name"), status, seconds(tc.getAttribute("time")), message, stack));
            }
        } catch (Exception e) {
            // rapport illisible : ignoré, le code de retour du framework décide
        }
        return cases;
    }

    /**
     * Cas correspondant à l'identifiant : nom exact, « classe#méthode », « Describe › titre » (Playwright),
     * nœud pytest « fichier::test » ; sans correspondance, tous les cas.
     */
    public static List<Case> matching(List<Case> cases, String identifier) {
        if (identifier == null || identifier.isBlank() || cases.isEmpty()) {
            return cases;
        }
        String id = normalize(identifier);
        String last = normalize(lastSegment(identifier));
        List<Case> exact = cases.stream().filter(c -> {
            String name = normalize(c.name());
            String full = normalize(c.className() + "#" + c.name());
            String dotted = normalize(c.className() + "." + c.name());
            return name.equals(id) || full.equals(id) || dotted.equals(id) || full.endsWith(id) || name.equals(last) || id.endsWith(" " + name);
        }).toList();
        return exact.isEmpty() ? cases : exact;
    }

    /** Synthèse : un échec ou une erreur l'emporte ; tous ignorés : SKIPPED ; aucun cas : null. */
    public static String status(List<Case> cases) {
        if (cases.isEmpty()) {
            return null;
        }
        if (cases.stream().anyMatch(c -> c.status().equals("ERROR"))) {
            return "ERROR";
        }
        if (cases.stream().anyMatch(c -> c.status().equals("FAILED"))) {
            return "FAILED";
        }
        return cases.stream().allMatch(c -> c.status().equals("SKIPPED")) ? "SKIPPED" : "PASSED";
    }

    /** Dernier élément d'un identifiant : « A › B › titre », « Classe#méthode », « fichier::test », « Suite.Test ». */
    public static String lastSegment(String identifier) {
        String id = identifier.strip();
        for (String separator : new String[] {" › ", " > ", "::", "#"}) {
            int index = id.lastIndexOf(separator);
            if (index >= 0) {
                id = id.substring(index + separator.length());
            }
        }
        return id;
    }

    private static String normalize(String text) {
        return text == null ? "" : text.strip().replace('’', '\'').replaceAll("\\s+", " ").toLowerCase(Locale.ROOT);
    }

    private static Element first(Element parent, String tag) {
        for (Node node = parent.getFirstChild(); node != null; node = node.getNextSibling()) {
            if (node instanceof Element element && element.getTagName().equals(tag)) {
                return element;
            }
        }
        return null;
    }

    private static String firstLine(String text) {
        if (text == null || text.isBlank()) {
            return null;
        }
        String stripped = text.strip();
        int newline = stripped.indexOf('\n');
        return newline < 0 ? stripped : stripped.substring(0, newline);
    }

    private static long seconds(String value) {
        try {
            return Math.round(Double.parseDouble(value.replace(",", "")) * 1000);
        } catch (NumberFormatException | NullPointerException e) {
            return 0;
        }
    }
}
