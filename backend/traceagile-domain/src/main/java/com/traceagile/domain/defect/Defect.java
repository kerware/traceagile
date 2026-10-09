package com.traceagile.domain.defect;

import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.requirement.Requirement;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * §3.1 Defect (F-DEF-01) : titre, description, sévérité, statut, référence externe (F-DEF-02),
 * liée aux exécutions et aux exigences.
 */
@Entity
@Table(name = "defects")
public class Defect extends AuditableEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @Column(name = "defect_key", nullable = false, length = 20, updatable = false)
    private String key;

    @Column(name = "key_number", nullable = false, updatable = false)
    private int keyNumber;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "text")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private DefectSeverity severity;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 12)
    private DefectStatus status = DefectStatus.OPEN;

    @Column(name = "external_ref", length = 100)
    private String externalRef;

    @ManyToMany
    @JoinTable(name = "defect_executions", joinColumns = @JoinColumn(name = "defect_id"), inverseJoinColumns = @JoinColumn(name = "execution_id"))
    private List<Execution> executions = new ArrayList<>();

    @ManyToMany
    @JoinTable(name = "defect_requirements", joinColumns = @JoinColumn(name = "defect_id"), inverseJoinColumns = @JoinColumn(name = "requirement_id"))
    private List<Requirement> requirements = new ArrayList<>();

    protected Defect() {
    }

    public Defect(Project project, String key, String title, String description, DefectSeverity severity) {
        this.project = Objects.requireNonNull(project);
        this.key = Objects.requireNonNull(key);
        this.keyNumber = Integer.parseInt(key.substring(key.lastIndexOf('-') + 1));
        retitle(title);
        describe(description);
        setSeverity(severity);
    }

    public void retitle(String title) {
        if (title == null || title.isBlank()) {
            throw new BusinessRuleException("DEFECT_TITLE_REQUIRED", "Le titre de l'anomalie est obligatoire.");
        }
        this.title = title.strip().length() > 200 ? title.strip().substring(0, 200) : title.strip();
    }

    public void describe(String description) {
        this.description = description == null || description.isBlank() ? null : description;
    }

    public void setSeverity(DefectSeverity severity) {
        this.severity = Objects.requireNonNull(severity, "severity");
    }

    public void setExternalRef(String externalRef) {
        this.externalRef = externalRef == null || externalRef.isBlank() ? null : externalRef.strip();
    }

    public void changeStatus(DefectStatus target) {
        if (target == status) {
            return;
        }
        if (!status.canMoveTo(target)) {
            throw new BusinessRuleException("DEFECT_STATUS_TRANSITION_INVALID", "Transition " + status + " → " + target + " interdite.");
        }
        status = target;
    }

    public void linkExecution(Execution execution) {
        if (executions.stream().noneMatch(e -> e == execution || (e.getId() != null && e.getId().equals(execution.getId())))) {
            executions.add(execution);
        }
    }

    public void replaceRequirements(List<Requirement> linked) {
        requirements.clear();
        linked.stream().distinct().forEach(requirements::add);
    }

    /** §7.3 / F-REQ-19 anomalie bloquante ou critique encore ouverte. */
    public boolean isOpenBlocking() {
        return status.isOpen() && severity.isBlocking();
    }

    public Map<String, Object> snapshot() {
        Map<String, Object> s = new LinkedHashMap<>();
        s.put("title", title);
        s.put("description", description);
        s.put("severity", severity.name());
        s.put("status", status.name());
        s.put("externalRef", externalRef);
        s.put("requirements", requirements.stream().map(Requirement::getKey).toList());
        return s;
    }

    public Project getProject() {
        return project;
    }

    public String getKey() {
        return key;
    }

    public int getKeyNumber() {
        return keyNumber;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public DefectSeverity getSeverity() {
        return severity;
    }

    public DefectStatus getStatus() {
        return status;
    }

    public String getExternalRef() {
        return externalRef;
    }

    public List<Execution> getExecutions() {
        return List.copyOf(executions);
    }

    public List<Requirement> getRequirements() {
        return List.copyOf(requirements);
    }
}
