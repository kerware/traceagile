package com.traceagile.api.demo;

import com.traceagile.application.reporting.ReportService;
import com.traceagile.application.reporting.ReportService.DefinitionCommand;
import com.traceagile.application.reporting.ReportService.GenerateCommand;
import com.traceagile.domain.reporting.ReportDefinition;
import com.traceagile.domain.reporting.ReportFormat;
import com.traceagile.domain.reporting.ReportScopeType;
import com.traceagile.domain.reporting.ReportSection;
import java.util.List;
import org.springframework.stereotype.Component;

/**
 * §15.1 rapports de démonstration (lot 8, ADR-0023), idempotent : le bilan figé de SPR-1 vient de sa
 * clôture ; on ajoute la définition personnalisée « Synthèse qualité » (Word) et un bilan de SPR-2 en
 * cours, non figé.
 */
@Component
public class DemoReportLoader {

    static final String QUALITY = "Synthèse qualité";

    private final ReportService reports;

    public DemoReportLoader(ReportService reports) {
        this.reports = reports;
    }

    public void load(String project) {
        List<ReportDefinition> definitions = reports.definitions(project);
        if (definitions.stream().noneMatch(d -> d.getName().equals(QUALITY))) {
            reports.createDefinition(project, new DefinitionCommand(QUALITY,
                    "Pour le comité qualité : couverture, burndown, exécution et listes détaillées.", ReportScopeType.SPRINT,
                    List.of(ReportSection.SUMMARY, ReportSection.BURNDOWN, ReportSection.COVERAGE, ReportSection.EXECUTION, ReportSection.DEFECT_LIST,
                            ReportSection.TEST_RESULTS), ReportFormat.DOCX, true, true));
        }
        if (reports.list(project).stream().noneMatch(r -> r.getScope().equals("sprint:SPR-2"))) {
            ReportDefinition sprintReview = definitions.stream().filter(d -> d.isBuiltIn() && d.getName().equals(ReportDefinition.SPRINT_REVIEW))
                    .findFirst().orElseThrow();
            reports.generate(project, new GenerateCommand(sprintReview.getId(), "SPR-2", null), "po");
        }
    }
}
