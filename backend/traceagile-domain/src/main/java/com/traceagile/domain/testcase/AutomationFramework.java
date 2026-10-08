package com.traceagile.domain.testcase;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;

/**
 * F-AUT-01 donnée de référence : framework proposé pour une technique, modifiable par
 * l'administrateur. Les techniques elles-mêmes sont fixes (elles portent des champs propres, ADR-0012).
 */
@Entity
@Table(name = "automation_frameworks")
public class AutomationFramework extends AuditableEntity {

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TestTechnique technique;

    @Column(nullable = false, length = 60)
    private String name;

    @Column(nullable = false)
    private int position;

    protected AutomationFramework() {
    }

    public AutomationFramework(TestTechnique technique, String name, int position) {
        if (name == null || name.isBlank()) {
            throw new BusinessRuleException("FRAMEWORK_NAME_REQUIRED", "Le nom du framework est obligatoire.");
        }
        this.technique = technique;
        this.name = name.strip();
        this.position = position;
    }

    public TestTechnique getTechnique() {
        return technique;
    }

    public String getName() {
        return name;
    }

    public int getPosition() {
        return position;
    }
}
