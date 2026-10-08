package com.traceagile.application.testcase;

import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.testcase.AutomationFramework;
import com.traceagile.domain.testcase.TestTechnique;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** F-AUT-01 frameworks proposés par technique, modifiables par l'administrateur. */
@Service
@Transactional
public class AutomationFrameworkService {

    private final AutomationFrameworkRepository frameworks;

    public AutomationFrameworkService(AutomationFrameworkRepository frameworks) {
        this.frameworks = frameworks;
    }

    @Transactional(readOnly = true)
    public List<AutomationFramework> all() {
        return frameworks.findAllByOrderByTechniqueAscPositionAsc();
    }

    /** Remplace la liste d'une technique ; les tests existants gardent leur framework (texte libre). */
    public List<AutomationFramework> replace(TestTechnique technique, List<String> names) {
        Set<String> seen = new HashSet<>();
        for (String name : names) {
            if (name == null || name.isBlank()) {
                throw new BusinessRuleException("FRAMEWORK_NAME_REQUIRED", "Le nom du framework est obligatoire.");
            }
            if (!seen.add(name.strip().toLowerCase(Locale.ROOT))) {
                throw new BusinessRuleException("FRAMEWORK_DUPLICATED", "Le framework « " + name.strip() + " » apparaît deux fois.");
            }
        }
        frameworks.findByTechniqueOrderByPositionAsc(technique).forEach(frameworks::delete);
        for (int i = 0; i < names.size(); i++) {
            frameworks.save(new AutomationFramework(technique, names.get(i), i + 1));
        }
        return frameworks.findByTechniqueOrderByPositionAsc(technique);
    }
}
