package com.traceagile.application.requirement;

import com.traceagile.application.common.ApplicationException;
import com.traceagile.application.common.Csv;
import com.traceagile.application.common.UnprocessableException;
import com.traceagile.application.requirement.RequirementService.CreateRequirementCommand;
import com.traceagile.application.requirement.RequirementService.CriterionDraft;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementType;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * F-REQ-23 Import CSV d'exigences (tout ou rien) et export CSV du backlog filtré. Colonnes : type,
 * parent key, title, asA, iWant, soThat, priority, points, tags, acceptance criteria (séparés par
 * « || »). Choix de format consignés dans ADR-0011.
 */
@Service
@Transactional
public class RequirementCsvService {

    static final List<String> COLUMNS = List.of("type", "parent key", "title", "asA", "iWant", "soThat", "priority",
            "points", "tags", "acceptance criteria");
    static final String CRITERIA_SEPARATOR = "||";
    private static final Pattern GHERKIN_START = Pattern.compile(
            "^\\s*(#\\s*language|@|feature:|fonctionnalité:|rule:|règle:|background:|contexte:|scenario|scénario|"
                    + "plan du scénario|example:|exemple:|given |étant donné|etant donné|soit )",
            Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);

    private final RequirementService requirements;

    public RequirementCsvService(RequirementService requirements) {
        this.requirements = requirements;
    }

    /** @return les clés créées, dans l'ordre du fichier */
    public List<String> importCsv(String projectKey, String content) {
        List<List<String>> rows = Csv.parse(content);
        if (rows.isEmpty()) {
            throw new UnprocessableException("CSV_EMPTY", "Le fichier ne contient aucune ligne.");
        }
        Map<String, Integer> header = header(rows.getFirst());
        Map<String, String> fileKeys = new HashMap<>();
        List<String> created = new ArrayList<>();
        List<Map<String, Object>> errors = new ArrayList<>();
        for (int i = 1; i < rows.size(); i++) {
            int line = i + 1;
            Map<String, String> row = values(header, rows.get(i));
            try {
                String parent = row.get("parent key");
                CreateRequirementCommand command = new CreateRequirementCommand(
                        parseEnum(RequirementType.class, row.get("type"), "type"),
                        row.get("title"),
                        parent == null ? null : fileKeys.getOrDefault(parent, parent),
                        RequirementPatch.builder()
                                .userStory(row.get("asA"), row.get("iWant"), row.get("soThat"))
                                .priority(row.get("priority") == null ? null : parseEnum(Priority.class, row.get("priority"), "priority"))
                                .storyPoints(parsePoints(row.get("points")))
                                .tags(row.get("tags") == null ? null : Arrays.stream(row.get("tags").split(",")).map(String::strip).toList())
                                .build(),
                        criteria(row.get("acceptance criteria")));
                Requirement requirement = requirements.create(projectKey, command);
                if (row.get("key") != null) {
                    fileKeys.put(row.get("key"), requirement.getKey());
                }
                created.add(requirement.getKey());
            } catch (BusinessRuleException e) {
                errors.add(lineError(line, e.getMessage()));
            } catch (ApplicationException e) {
                errors.add(lineError(line, e.getMessage()));
            }
        }
        if (!errors.isEmpty()) {
            throw new UnprocessableException("CSV_INVALID", errors.size() + " ligne(s) en erreur, rien n'a été importé.",
                    Map.of("lineErrors", errors));
        }
        return created;
    }

    @Transactional(readOnly = true)
    public String exportCsv(String projectKey, RequirementFilter filter) {
        List<List<String>> rows = new ArrayList<>();
        List<String> header = new ArrayList<>();
        header.add("key");
        header.addAll(COLUMNS);
        header.add("status");
        header.add("risk");
        rows.add(header);
        for (Requirement r : requirements.search(projectKey, filter, Pageable.unpaged(Sort.by("rank"))).getContent()) {
            rows.add(Arrays.asList(
                    r.getKey(),
                    r.getType().name(),
                    r.getParent() == null ? "" : r.getParent().getKey(),
                    r.getTitle(),
                    nullToEmpty(r.getUserStory().asA()),
                    nullToEmpty(r.getUserStory().iWant()),
                    nullToEmpty(r.getUserStory().soThat()),
                    r.getPriority().name(),
                    r.getStoryPoints() == null ? "" : r.getStoryPoints().toString(),
                    String.join(", ", r.getTags()),
                    r.getCriteria().stream().map(AcceptanceCriterion::getContent).collect(Collectors.joining(" " + CRITERIA_SEPARATOR + " ")),
                    r.getStatus().name(),
                    r.getRiskLevel().name()));
        }
        return Csv.write(rows);
    }

    private static Map<String, Integer> header(List<String> cells) {
        Map<String, Integer> header = new HashMap<>();
        for (int i = 0; i < cells.size(); i++) {
            String name = cells.get(i).strip().toLowerCase(Locale.ROOT);
            if (name.equals("key")) {
                header.put("key", i);
            }
            for (String column : COLUMNS) {
                if (column.toLowerCase(Locale.ROOT).equals(name)) {
                    header.put(column, i);
                }
            }
        }
        if (!header.containsKey("type") || !header.containsKey("title")) {
            throw new UnprocessableException("CSV_HEADER_INVALID",
                    "L'en-tête doit contenir au moins les colonnes « type » et « title ». Colonnes attendues : "
                            + String.join(", ", COLUMNS) + ".");
        }
        return header;
    }

    private static Map<String, String> values(Map<String, Integer> header, List<String> cells) {
        Map<String, String> row = new LinkedHashMap<>();
        header.forEach((column, index) -> {
            String value = index < cells.size() ? cells.get(index).strip() : "";
            row.put(column, value.isEmpty() ? null : value);
        });
        return row;
    }

    private static List<CriterionDraft> criteria(String cell) {
        if (cell == null) {
            return List.of();
        }
        return Arrays.stream(cell.split(Pattern.quote(CRITERIA_SEPARATOR)))
                .map(String::strip)
                .filter(c -> !c.isEmpty())
                .map(c -> new CriterionDraft(GHERKIN_START.matcher(c).find() ? CriterionFormat.GHERKIN : CriterionFormat.TEXT, c))
                .toList();
    }

    private static <E extends Enum<E>> E parseEnum(Class<E> type, String value, String column) {
        if (value == null) {
            throw new BusinessRuleException("CSV_VALUE_REQUIRED", "La colonne « " + column + " » est obligatoire.");
        }
        try {
            return Enum.valueOf(type, value.strip().toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException e) {
            throw new BusinessRuleException("CSV_VALUE_INVALID", "Valeur « " + value + " » inconnue pour « " + column
                    + " » (valeurs : " + Arrays.toString(type.getEnumConstants()) + ").");
        }
    }

    private static Integer parsePoints(String value) {
        if (value == null) {
            return null;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            throw new BusinessRuleException("CSV_VALUE_INVALID", "Points invalides : « " + value + " ».");
        }
    }

    private static Map<String, Object> lineError(int line, String message) {
        Map<String, Object> error = new LinkedHashMap<>();
        error.put("line", line);
        error.put("message", message);
        return error;
    }

    private static String nullToEmpty(String value) {
        return value == null ? "" : value;
    }
}
