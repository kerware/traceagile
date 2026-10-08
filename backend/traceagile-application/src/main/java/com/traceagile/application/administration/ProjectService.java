package com.traceagile.application.administration;

import com.traceagile.application.common.ConflictException;
import com.traceagile.application.common.NotFoundException;
import com.traceagile.domain.administration.Permission;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.administration.User;
import com.traceagile.domain.common.BusinessRuleException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Projets, membres et contrôle d'accès par projet (§2.2, §12 Administration). */
@Service
@Transactional
public class ProjectService {

    private final ProjectRepository projects;
    private final UserRepository users;

    private final ApplicationEventPublisher events;

    public ProjectService(ProjectRepository projects, UserRepository users, ApplicationEventPublisher events) {
        this.projects = projects;
        this.users = users;
        this.events = events;
    }

    public Project create(CreateProjectCommand command) {
        if (projects.existsByKey(command.key())) {
            throw new ConflictException("PROJECT_KEY_TAKEN", "La clé « " + command.key() + " » est déjà utilisée.");
        }
        Project project = projects.save(new Project(command.key(), command.name(), command.description()));
        events.publishEvent(new ProjectCreated(project.getKey()));
        return project;
    }

    @Transactional(readOnly = true)
    public Project get(String key) {
        return projects.findByKey(key)
                .orElseThrow(() -> new NotFoundException("PROJECT_NOT_FOUND", "Projet « " + key + " » introuvable."));
    }

    /** §2.2 : un utilisateur sans rôle sur un projet ne le voit pas ; l'administrateur système voit tout. */
    @Transactional(readOnly = true)
    public Page<Project> listVisible(User user, Pageable pageable) {
        return user.isSystemAdmin()
                ? projects.findAll(pageable)
                : projects.findDistinctByMembers_User_Login(user.getLogin(), pageable);
    }

    /** Projets où l'utilisateur a un rôle (§12 GET /me), indépendamment du statut d'administrateur système. */
    @Transactional(readOnly = true)
    public List<Project> memberships(User user) {
        return projects.findDistinctByMembers_User_Login(user.getLogin(), Pageable.unpaged()).getContent();
    }

    /** §12 PUT /projects/{key}/members : la liste fournie remplace entièrement les membres. */
    public Project replaceMembers(String key, List<MemberAssignment> assignments) {
        Project project = get(key);
        Set<String> logins = new HashSet<>();
        for (MemberAssignment assignment : assignments) {
            if (!logins.add(assignment.login())) {
                throw new BusinessRuleException("MEMBER_DUPLICATED",
                        "L'utilisateur « " + assignment.login() + " » apparaît plusieurs fois.");
            }
        }
        List<User> assigned = assignments.stream()
                .map(a -> users.findByLogin(a.login()).orElseThrow(
                        () -> new NotFoundException("USER_NOT_FOUND", "Utilisateur « " + a.login() + " » introuvable.")))
                .toList();
        project.getMembers().stream()
                .map(member -> member.getUser())
                .filter(user -> !logins.contains(user.getLogin()))
                .toList()
                .forEach(project::removeMember);
        for (int i = 0; i < assignments.size(); i++) {
            project.setMember(assigned.get(i), assignments.get(i).role());
        }
        return project;
    }

    /** §2.2 Évalué pour chaque endpoint d'un projet ; un projet inconnu est refusé. */
    @Transactional(readOnly = true)
    public boolean isAllowed(String login, String projectKey, Permission permission) {
        return projects.findByKey(projectKey)
                .flatMap(project -> users.findByLogin(login).map(user -> user.isActive() && project.allows(user, permission)))
                .orElse(false);
    }
}
