package com.traceagile.api.traceability;

import com.traceagile.api.traceability.TraceabilityDtos.CampaignItem;
import com.traceagile.api.traceability.TraceabilityDtos.CoverageResponse;
import com.traceagile.api.traceability.TraceabilityDtos.CriterionTraceResponse;
import com.traceagile.api.traceability.TraceabilityDtos.DefectItem;
import com.traceagile.api.traceability.TraceabilityDtos.ImpactResponse;
import com.traceagile.api.traceability.TraceabilityDtos.ImpactedTestResponse;
import com.traceagile.api.traceability.TraceabilityDtos.IndicatorResponse;
import com.traceagile.api.traceability.TraceabilityDtos.MatrixCell;
import com.traceagile.api.traceability.TraceabilityDtos.MatrixRequirement;
import com.traceagile.api.traceability.TraceabilityDtos.MatrixResponse;
import com.traceagile.api.traceability.TraceabilityDtos.OrphansResponse;
import com.traceagile.api.traceability.TraceabilityDtos.RequirementCoverageResponse;
import com.traceagile.api.traceability.TraceabilityDtos.RequirementItem;
import com.traceagile.api.traceability.TraceabilityDtos.TestItem;
import com.traceagile.api.traceability.TraceabilityDtos.TestTraceResponse;
import com.traceagile.api.traceability.TraceabilityDtos.TraceLinkResponse;
import com.traceagile.api.traceability.TraceabilityDtos.TraceNodeResponse;
import com.traceagile.api.traceability.TraceabilityDtos.TraceTreeResponse;
import com.traceagile.application.traceability.ExecutionResults.CampaignRef;
import com.traceagile.application.traceability.ExecutionResults.DefectRef;
import com.traceagile.application.traceability.TraceLinkService.LinkView;
import com.traceagile.application.traceability.TraceabilityService.CoverageReport;
import com.traceagile.application.traceability.TraceabilityService.Impact;
import com.traceagile.application.traceability.TraceabilityService.Matrix;
import com.traceagile.application.traceability.TraceabilityService.Orphans;
import com.traceagile.application.traceability.TraceabilityService.TraceNode;
import com.traceagile.application.traceability.TraceabilityService.TraceTree;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.traceability.CoverageCalculator.Indicator;
import org.springframework.stereotype.Component;

/** Résultats de lecture de la traçabilité → DTO (mapping explicite : structures imbriquées et calculées). */
@Component
public class TraceabilityMapper {

    TraceLinkResponse toResponse(LinkView view) {
        return new TraceLinkResponse(view.link().getId(), view.test().getKey(), view.requirement().getKey(), view.link().getLinkType(),
                view.link().getOrigin(), view.criterionPositions(), view.link().isSuspect(), view.link().getSuspectSince(),
                view.link().getVersion());
    }

    RequirementItem item(Requirement r) {
        return new RequirementItem(r.getKey(), r.getTitle(), r.getType(), r.getStatus(), r.getRiskLevel());
    }

    TestItem item(TestCase test, ExecutionStatus lastResult) {
        return new TestItem(test.getKey(), test.getTitle(), test.getKind(),
                test.getAutomation() == null ? null : test.getAutomation().getTechnique(), test.getStatus(), lastResult);
    }

    DefectItem item(DefectRef defect) {
        return new DefectItem(defect.key(), defect.title(), defect.severity(), defect.status());
    }

    CampaignItem item(CampaignRef campaign) {
        return new CampaignItem(campaign.key(), campaign.name(), campaign.status());
    }

    IndicatorResponse indicator(Indicator indicator) {
        return new IndicatorResponse(indicator.numerator(), indicator.denominator(), indicator.percent());
    }

    MatrixResponse toResponse(Matrix matrix) {
        return new MatrixResponse(matrix.scope(),
                matrix.rows().stream().map(r -> new MatrixRequirement(r.requirement().getKey(), r.requirement().getTitle(),
                        r.requirement().getType(), r.requirement().getStatus(),
                        r.requirement().getParent() == null ? null : r.requirement().getParent().getKey(), r.depth(), r.leaf(),
                        r.status())).toList(),
                matrix.columns().stream().map(c -> item(c.test(), c.lastResult())).toList(),
                matrix.cells().stream().map(c -> new MatrixCell(c.requirement().getKey(), c.test().getKey(), c.link().getId(),
                        c.link().getLinkType(), c.link().getOrigin(), c.criterionPositions(), c.link().isSuspect(), c.lastResult(),
                        c.link().getVersion())).toList());
    }

    CoverageResponse toResponse(CoverageReport report) {
        var c = report.coverage();
        return new CoverageResponse(report.scope(), indicator(c.design()), indicator(c.criteria()), indicator(c.execution()),
                indicator(c.validation()), indicator(c.riskWeighted()),
                report.requirements().stream().map(r -> new RequirementCoverageResponse(r.requirement().getKey(),
                        r.requirement().getTitle(), r.requirement().getType(), r.depth(), r.leaf(), r.requirement().getRiskLevel(),
                        r.status(), r.coveringTests(), r.executedTests(), r.passedTests())).toList());
    }

    OrphansResponse toResponse(Orphans orphans) {
        return new OrphansResponse(
                orphans.requirementsWithoutTests().stream().map(this::item).toList(),
                orphans.testsWithoutRequirement().stream().map(t -> item(t, null)).toList(),
                orphans.defectsWithoutRequirement().stream().map(this::item).toList(),
                orphans.automatedNeverExecuted().stream().map(t -> item(t, null)).toList());
    }

    TraceNodeResponse node(TraceNode node) {
        Requirement r = node.requirement();
        return new TraceNodeResponse(r.getKey(), r.getTitle(), r.getType(), r.getStatus(), node.status(),
                node.children().stream().map(this::node).toList());
    }

    TraceTreeResponse toResponse(TraceTree tree) {
        return new TraceTreeResponse(node(tree.node()),
                tree.ancestors().stream().map(this::node).toList(),
                tree.criteria().stream().map(c -> new CriterionTraceResponse(c.criterion().getPosition(), c.criterion().getFormat(),
                        c.criterion().getContent(), c.status(), c.tests().stream().map(TestCase::getKey).toList())).toList(),
                tree.tests().stream().map(t -> new TestTraceResponse(
                        item(t.test(), t.lastExecution() == null ? null : t.lastExecution().status()), t.link().getId(),
                        t.link().getLinkType(), t.link().getOrigin(), t.link().isSuspect(), t.criterionPositions(),
                        t.lastExecution() == null ? null : t.lastExecution().executedAt())).toList(),
                tree.defects().stream().map(this::item).toList());
    }

    ImpactResponse toResponse(Impact impact) {
        return new ImpactResponse(item(impact.requirement()),
                impact.tests().stream().map(i -> new ImpactedTestResponse(item(i.test(), null), item(i.via()), i.link().getId(),
                        i.link().getLinkType(), i.link().isSuspect())).toList(),
                impact.campaigns().stream().map(this::item).toList());
    }
}
