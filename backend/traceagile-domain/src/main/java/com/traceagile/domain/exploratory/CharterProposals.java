package com.traceagile.domain.exploratory;

import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.requirement.NfrCategory;
import com.traceagile.domain.requirement.Requirement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * F-EXP-04 « Générer des chartes » depuis une exigence (ADR-0019) : une charte par critère
 * d'acceptation (mission : le critère), une par ENF transverse applicable (mission : la qualité
 * visée, heuristique adaptée à sa catégorie ISO 25010).
 */
public final class CharterProposals {

    private static final Pattern SCENARIO = Pattern.compile("(?m)^\\s*(?:Scénario|Scenario|Plan du scénario|Scenario Outline|Exemple)\\s*:\\s*(.+)$");
    private static final int MAX_TITLE = 200;
    /** Les champs de mission font 500 caractères au plus. */
    private static final int MAX_SUMMARY = 300;

    private static final Map<NfrCategory, String> HEURISTIC_BY_CATEGORY = Map.of(
            NfrCategory.PERFORMANCE, "Goldilocks",
            NfrCategory.SECURITY, "CRUD",
            NfrCategory.USABILITY, "FEW HICCUPPS",
            NfrCategory.ACCESSIBILITY, "FEW HICCUPPS",
            NfrCategory.RELIABILITY, "Tours de Whittaker",
            NfrCategory.COMPATIBILITY, "SFDIPOT",
            NfrCategory.MAINTAINABILITY, "SFDIPOT",
            NfrCategory.PORTABILITY, "SFDIPOT");

    private CharterProposals() {
    }

    public static List<CharterProposal> from(Requirement requirement, List<Requirement> transverseNfrs) {
        List<CharterProposal> proposals = new ArrayList<>();
        String target = requirement.getTitle();
        List<String> areas = requirement.getParent() == null ? List.of(target) : List.of(requirement.getParent().getTitle());
        for (AcceptanceCriterion criterion : requirement.getCriteria()) {
            String summary = summary(criterion);
            proposals.add(new CharterProposal("CRITERION", criterion.getPosition(), title(target, summary), target,
                    "des données variées et des cas limites", "ce qui met en défaut « " + summary + " »", areas, List.of("SFDIPOT"),
                    List.of(requirement.getKey())));
        }
        for (Requirement nfr : transverseNfrs) {
            String heuristic = nfr.getCategory() == null ? "FEW HICCUPPS" : HEURISTIC_BY_CATEGORY.getOrDefault(nfr.getCategory(), "SFDIPOT");
            String quality = nfr.getCategory() == null ? "l'exigence non fonctionnelle" : nfr.getCategory().name().toLowerCase();
            proposals.add(new CharterProposal("NFR", null, title(target, nfr.getTitle()), target,
                    "des conditions dégradées (" + quality + ")", "les écarts à « " + nfr.getTitle() + " »", areas, List.of(heuristic),
                    List.of(requirement.getKey(), nfr.getKey())));
        }
        return proposals;
    }

    /** Titre d'un scénario Gherkin, sinon première ligne du critère. */
    static String summary(AcceptanceCriterion criterion) {
        String content = criterion.getContent().strip();
        if (criterion.getFormat() == CriterionFormat.GHERKIN) {
            Matcher matcher = SCENARIO.matcher(content);
            if (matcher.find()) {
                String name = matcher.group(1).strip();
                return name.length() <= MAX_SUMMARY ? name : name.substring(0, MAX_SUMMARY - 1) + "…";
            }
        }
        String line = content.lines().findFirst().orElse(content).strip();
        return line.length() <= MAX_SUMMARY ? line : line.substring(0, MAX_SUMMARY - 1) + "…";
    }

    private static String title(String target, String detail) {
        String title = "Explorer « " + target + " » : " + detail;
        return title.length() <= MAX_TITLE ? title : title.substring(0, MAX_TITLE - 1) + "…";
    }
}
