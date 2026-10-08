package com.traceagile.application.testcase;

import com.traceagile.domain.testcase.AutomationFramework;
import com.traceagile.domain.testcase.TestTechnique;
import java.util.List;

/** Port de la donnée de référence des frameworks (F-AUT-01). */
public interface AutomationFrameworkRepository {

    List<AutomationFramework> findAllByOrderByTechniqueAscPositionAsc();

    List<AutomationFramework> findByTechniqueOrderByPositionAsc(TestTechnique technique);

    AutomationFramework save(AutomationFramework framework);

    void delete(AutomationFramework framework);
}
