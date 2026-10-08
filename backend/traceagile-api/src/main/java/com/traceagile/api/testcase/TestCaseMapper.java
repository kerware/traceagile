package com.traceagile.api.testcase;

import com.traceagile.api.testcase.TestCaseDtos.AutomationResponse;
import com.traceagile.api.testcase.TestCaseDtos.CharterResponse;
import com.traceagile.api.testcase.TestCaseDtos.FrameworkResponse;
import com.traceagile.api.testcase.TestCaseDtos.LinkedTestResponse;
import com.traceagile.api.testcase.TestCaseDtos.RequirementLinkResponse;
import com.traceagile.api.testcase.TestCaseDtos.StepResponse;
import com.traceagile.api.testcase.TestCaseDtos.TestCaseDetail;
import com.traceagile.api.testcase.TestCaseDtos.TestCaseSummary;
import com.traceagile.api.testcase.TestCaseDtos.TestVersionResponse;
import com.traceagile.application.traceability.TraceLinkService.RequirementLink;
import com.traceagile.application.traceability.TraceLinkService.TestLink;
import com.traceagile.domain.requirement.AcceptanceCriterion;
import com.traceagile.domain.testcase.AutomatedTestDefinition;
import com.traceagile.domain.testcase.AutomationFramework;
import com.traceagile.domain.testcase.ExploratoryCharter;
import com.traceagile.domain.testcase.ManualStep;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseVersion;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

/** §11.1 MapStruct : cas de test ↔ DTO. */
@Mapper
public interface TestCaseMapper {

    @Mapping(target = "technique", source = "automation.technique")
    @Mapping(target = "framework", source = "automation.framework")
    @Mapping(target = "featureName", source = "automation.featureName")
    @Mapping(target = "tags", expression = "java(java.util.List.copyOf(test.getTags()))")
    @Mapping(target = "missingInRepository", expression = "java(test.getAutomation() != null && test.getAutomation().isMissingInRepository())")
    TestCaseSummary toSummary(TestCase test);

    StepResponse toResponse(ManualStep step);

    @Mapping(target = "missionSentence", expression = "java(charter.missionSentence())")
    CharterResponse toResponse(ExploratoryCharter charter);

    AutomationResponse toResponse(AutomatedTestDefinition automation);

    @Mapping(target = "name", source = "name")
    FrameworkResponse toResponse(AutomationFramework framework);

    List<FrameworkResponse> toFrameworks(List<AutomationFramework> frameworks);

    @Mapping(target = "allowedTransitions", expression = "java(java.util.List.copyOf(test.getStatus().nextStatuses()))")
    @Mapping(target = "tags", expression = "java(java.util.List.copyOf(test.getTags()))")
    @Mapping(target = "variables", expression = "java(test.variables())")
    @Mapping(target = "requirements", source = "links")
    @Mapping(target = "warnings", source = "warnings")
    TestCaseDetail toDetail(TestCase test, List<RequirementLink> links, List<String> warnings);

    default RequirementLinkResponse toResponse(RequirementLink link) {
        return new RequirementLinkResponse(link.requirement().getKey(), link.requirement().getTitle(), link.requirement().getType(),
                link.requirement().getStatus(), link.linkType(), link.origin(),
                link.criteria().stream().map(AcceptanceCriterion::getPosition).toList());
    }

    default LinkedTestResponse toResponse(TestLink link) {
        TestCase test = link.testCase();
        return new LinkedTestResponse(test.getKey(), test.getKind(), test.getTitle(), test.getStatus(),
                test.getAutomation() == null ? null : test.getAutomation().getTechnique(), link.linkType(), link.origin(),
                link.criterionPositions());
    }

    default TestVersionResponse toResponse(TestCaseVersion version) {
        Map<String, String> snapshot = new LinkedHashMap<>();
        version.getSnapshot().forEach((field, value) -> snapshot.put(field, value == null ? null
                : value instanceof List<?> list ? String.join("\n", list.stream().map(String::valueOf).toList()) : String.valueOf(value)));
        return new TestVersionResponse(version.getVersionNumber(), version.getCreatedAt(), version.getCreatedBy(), snapshot);
    }
}
