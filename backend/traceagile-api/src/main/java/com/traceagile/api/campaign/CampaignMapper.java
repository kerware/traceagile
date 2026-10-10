package com.traceagile.api.campaign;

import com.traceagile.api.campaign.CampaignDtos.AttemptResponse;
import com.traceagile.api.campaign.CampaignDtos.CampaignDetail;
import com.traceagile.api.campaign.CampaignDtos.CampaignRef;
import com.traceagile.api.campaign.CampaignDtos.CampaignSummary;
import com.traceagile.api.campaign.CampaignDtos.DataSetRef;
import com.traceagile.api.campaign.CampaignDtos.DefectDetail;
import com.traceagile.api.campaign.CampaignDtos.DefectExecutionRef;
import com.traceagile.api.campaign.CampaignDtos.DefectRef;
import com.traceagile.api.campaign.CampaignDtos.DefectSummary;
import com.traceagile.api.campaign.CampaignDtos.ExecutionDetail;
import com.traceagile.api.campaign.CampaignDtos.ItemResponse;
import com.traceagile.api.campaign.CampaignDtos.MyExecutionResponse;
import com.traceagile.api.campaign.CampaignDtos.ProgressResponse;
import com.traceagile.api.campaign.CampaignDtos.RequirementExecutionResponse;
import com.traceagile.api.campaign.CampaignDtos.DefectRequirementRef;
import com.traceagile.api.campaign.CampaignDtos.StepResultResponse;
import com.traceagile.api.campaign.CampaignDtos.TestRef;
import com.traceagile.api.campaign.CampaignDtos.UserRef;
import com.traceagile.api.campaign.CampaignDtos.WorkloadResponse;
import com.traceagile.application.campaign.CampaignService;
import com.traceagile.domain.administration.User;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.defect.Defect;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestKind;
import java.util.List;
import org.springframework.stereotype.Component;

/** Campagnes, exécutions, anomalies → DTO (mapping explicite : structures calculées et imbriquées). */
@Component
public class CampaignMapper {

    UserRef user(User user) {
        return user == null ? null : new UserRef(user.getLogin(), user.getDisplayName());
    }

    public TestRef test(TestCase test) {
        Integer duration = test.getKind() == TestKind.EXPLORATORY ? Integer.valueOf(test.getCharter().getTimeboxMin()) : test.getEstimatedDurationMin();
        return new TestRef(test.getKey(), test.getTitle(), test.getKind(), test.getAutomation() == null ? null : test.getAutomation().getTechnique(),
                test.getStatus(), test.getPriority(), test.getCurrentVersion(), duration, test.isFlaky() ? Boolean.TRUE : null);
    }

    public CampaignRef ref(Campaign c) {
        return new CampaignRef(c.getKey(), c.getName(), c.getEnvironment(), c.getBuildVersion(), c.getStatus());
    }

    List<DataSetRef> dataSets(TestCase test) {
        return test.getDataSets().stream().map(d -> new DataSetRef(d.name(), d.rows().size())).toList();
    }

    CampaignSummary summary(Campaign c) {
        CampaignService.Progress p = CampaignService.progress(c);
        return new CampaignSummary(c.getKey(), c.getName(), c.getScopeType(), c.getSprint() == null ? null : c.getSprint().getKey(),
                c.getRelease() == null ? null : c.getRelease().getKey(), c.getEnvironment(), c.getBuildVersion(), c.getStatus(),
                c.getPlannedStart(), c.getPlannedEnd(),
                new ProgressResponse(p.total(), p.byStatus(), p.executed(), p.executedPercent(), p.passRate()), c.getVersion(), c.getFolder());
    }

    ItemResponse item(CampaignItem i) {
        Execution latest = i.latest();
        return new ItemResponse(i.getId(), i.getPosition(), test(i.getTestCase()), i.getTestCaseVersion(), user(i.getAssignee()),
                i.isExecutedByServer(), i.getRiskScore(), i.lastStatus(), i.getExecutions().size(), latest == null ? null : latest.getId(),
                latest == null ? null : latest.getEndedAt() != null ? latest.getEndedAt() : latest.getStartedAt(),
                i.getDataSetName(), i.getDataSetRow(), i.dataSetValues(), dataSets(i.getTestCase()));
    }

    CampaignDetail detail(Campaign c) {
        return new CampaignDetail(summary(c), c.getItems().stream().map(this::item).toList(),
                CampaignService.workload(c).stream().map(w -> new WorkloadResponse(user(w.assignee()), w.manualMinutes(),
                        w.exploratoryMinutes(), w.tests(), w.unestimated())).toList());
    }

    MyExecutionResponse mine(CampaignItem i) {
        Execution latest = i.latest();
        return new MyExecutionResponse(i.getId(), ref(i.getCampaign()), test(i.getTestCase()), i.getPosition(), i.lastStatus(),
                i.getExecutions().size(), latest == null ? null : latest.getId(), dataSets(i.getTestCase()), i.getDataSetName(), i.getDataSetRow());
    }

    AttemptResponse attempt(Execution e) {
        return new AttemptResponse(e.getId(), e.getAttempt(), e.getStatus(), e.getStartedAt(), e.getEndedAt(), e.getExecutedBy(), e.getOrigin(),
                e.getDataSetName(), e.getDataSetRow());
    }

    DefectRef defectRef(Defect d) {
        return new DefectRef(d.getKey(), d.getTitle(), d.getSeverity(), d.getStatus());
    }

    ExecutionDetail execution(Execution e, List<Defect> defects) {
        CampaignItem item = e.getItem();
        boolean latest = item.latest() != null && item.latest().getId().equals(e.getId());
        return new ExecutionDetail(e.getId(), item.getId(), test(e.getTestCase()), ref(item.getCampaign()), e.getAttempt(),
                e.getTestCaseVersion(), e.getStatus(), e.derivedStatus(), e.isStatusOverridden(), e.getStartedAt(), e.getEndedAt(),
                e.getDurationMs(), e.getComment(), e.getExecutedBy(), e.getOrigin(), e.getDataSetName(), e.getDataSetRow(),
                e.getParameterValues(),
                e.getSteps().stream().map(s -> new StepResultResponse(s.getId(), s.getPosition(), s.getAction(), s.getExpectedResult(), s.getTestData(),
                        s.getStatus(), s.getActualResult(), s.getCalledFrom())).toList(),
                defects.stream().map(this::defectRef).toList(),
                item.getExecutions().stream().map(this::attempt).toList(),
                latest && !item.getCampaign().getStatus().isClosed(),
                dataSets(e.getTestCase()));
    }

    RequirementExecutionResponse requirementExecution(Execution e) {
        return new RequirementExecutionResponse(e.getId(), test(e.getTestCase()), ref(e.getItem().getCampaign()), e.getAttempt(), e.getStatus(),
                e.getStartedAt(), e.getEndedAt(), e.getExecutedBy(), e.getOrigin(), e.getDataSetName(), e.getDataSetRow());
    }

    DefectSummary defectSummary(Defect d) {
        return new DefectSummary(d.getKey(), d.getTitle(), d.getSeverity(), d.getStatus(), d.getExternalRef(),
                d.getRequirements().stream().map(r -> r.getKey()).toList(), d.getExecutions().size(), d.getCreatedAt(), d.getCreatedBy(),
                d.getVersion());
    }

    DefectDetail defect(Defect d) {
        return new DefectDetail(defectSummary(d), d.getDescription(), List.copyOf(d.getStatus().nextStatuses()),
                d.getRequirements().stream().map(r -> new DefectRequirementRef(r.getKey(), r.getTitle())).toList(),
                d.getExecutions().stream().map(e -> new DefectExecutionRef(e.getId(), e.getTestCase().getKey(),
                        e.getItem().getCampaign().getKey(), e.getAttempt(), e.getStatus())).toList(), d.getId());
    }
}
