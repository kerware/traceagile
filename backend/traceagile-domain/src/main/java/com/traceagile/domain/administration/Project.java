package com.traceagile.domain.administration;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.regex.Pattern;

/** §3.1 Project : conteneur racine. Porte ses membres et leur rôle (§2.2). */
@Entity
@Table(name = "projects")
public class Project extends AuditableEntity {

    private static final Pattern KEY = Pattern.compile("[A-Z]{3,10}");

    @Column(name = "project_key", nullable = false, unique = true, length = 10, updatable = false)
    private String key;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(columnDefinition = "text")
    private String description;

    @Column(nullable = false)
    private boolean archived;

    @OneToMany(mappedBy = "project", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ProjectMember> members = new ArrayList<>();

    protected Project() {
    }

    public Project(String key, String name, String description) {
        if (key == null || !KEY.matcher(key).matches()) {
            throw new BusinessRuleException("PROJECT_KEY_INVALID",
                    "La clé du projet doit comporter 3 à 10 lettres majuscules (A-Z).");
        }
        this.key = key;
        rename(name);
        this.description = description;
    }

    public String getKey() {
        return key;
    }

    public String getName() {
        return name;
    }

    public void rename(String name) {
        if (name == null || name.isBlank()) {
            throw new BusinessRuleException("PROJECT_NAME_REQUIRED", "Le nom du projet est obligatoire.");
        }
        this.name = name.strip();
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isArchived() {
        return archived;
    }

    public void setArchived(boolean archived) {
        this.archived = archived;
    }

    public List<ProjectMember> getMembers() {
        return Collections.unmodifiableList(members);
    }

    /** Attribue ou remplace le rôle d'un utilisateur sur ce projet (un seul rôle par projet). */
    public void setMember(User user, ProjectRole role) {
        Objects.requireNonNull(role, "role");
        findMember(user).ifPresentOrElse(
                member -> member.setRole(role),
                () -> members.add(new ProjectMember(this, user, role)));
    }

    public void removeMember(User user) {
        findMember(user).ifPresent(members::remove);
    }

    public Optional<ProjectRole> roleOf(User user) {
        return findMember(user).map(ProjectMember::getRole);
    }

    /** §2.2 : l'administrateur système a tous les droits ; sinon le rôle sur le projet décide. */
    public boolean allows(User user, Permission permission) {
        if (user.isSystemAdmin()) {
            return true;
        }
        return roleOf(user).map(role -> role.allows(permission)).orElse(false);
    }

    private Optional<ProjectMember> findMember(User user) {
        // Identité d'objet tant que l'utilisateur n'est pas persisté, identifiant ensuite.
        return members.stream()
                .filter(m -> m.getUser() == user
                        || (user.getId() != null && user.getId().equals(m.getUser().getId())))
                .findFirst();
    }
}
