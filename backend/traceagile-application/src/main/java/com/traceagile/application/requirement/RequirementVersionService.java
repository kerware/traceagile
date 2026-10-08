package com.traceagile.application.requirement;

import com.traceagile.application.audit.AuditService;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.domain.audit.AuditAction;
import com.traceagile.domain.common.FieldChange;
import com.traceagile.domain.common.SnapshotDiff;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementVersion;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** F-REQ-21 versions figées (automatiques au passage à READY, ou à la demande) et comparaison. */
@Service
@Transactional
public class RequirementVersionService {

    private final RequirementService requirements;
    private final RequirementVersionRepository versions;
    private final AuditService audit;

    public RequirementVersionService(RequirementService requirements, RequirementVersionRepository versions, AuditService audit) {
        this.requirements = requirements;
        this.versions = versions;
        this.audit = audit;
    }

    public RequirementVersion freeze(String projectKey, String key, String comment) {
        Requirement requirement = requirements.get(projectKey, key);
        RequirementVersion version = versions.save(RequirementVersion.freeze(requirement, comment));
        audit.record(requirement.getProject().getId(), AuditService.REQUIREMENT, requirement.getId(), key,
                AuditAction.VERSION_CREATED, Map.of(), Map.of("version", version.getVersionNumber()));
        return version;
    }

    @Transactional(readOnly = true)
    public List<RequirementVersion> list(String projectKey, String key) {
        return versions.findByRequirementOrderByVersionNumberDesc(requirements.get(projectKey, key));
    }

    @Transactional(readOnly = true)
    public RequirementVersion get(String projectKey, String key, int number) {
        return versions.findByRequirementAndVersionNumber(requirements.get(projectKey, key), number)
                .orElseThrow(() -> new NotFoundException("VERSION_NOT_FOUND", "Version " + number + " introuvable."));
    }

    /** Différences de la version {@code from} à la version {@code to}. */
    @Transactional(readOnly = true)
    public List<FieldChange> diff(String projectKey, String key, int from, int to) {
        return SnapshotDiff.between(get(projectKey, key, from).getSnapshot(), get(projectKey, key, to).getSnapshot());
    }
}
