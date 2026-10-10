package com.traceagile.application.automation;

import com.traceagile.application.execution.ExecutionRepository;
import com.traceagile.domain.automation.FlakyDetector;
import com.traceagile.domain.automation.FlakyDetector.Outcome;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.testcase.TestCase;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** F-EXE-11 recalcule l'indicateur « instable » d'un test après un nouveau résultat. */
@Service
@Transactional
public class FlakyService {

    private final ExecutionRepository executions;

    public FlakyService(ExecutionRepository executions) {
        this.executions = executions;
    }

    public void recompute(TestCase test) {
        test.markFlaky(FlakyDetector.isFlaky(executions.findByTestCase_IdOrderByStartedAtAsc(test.getId()).stream()
                .filter(Execution::isFinal)
                .map(e -> new Outcome(e.getItem().getCampaign().getBuildVersion(), e.getStatus()))
                .toList()));
    }
}
