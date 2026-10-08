package com.traceagile.api.administration;

import com.traceagile.api.administration.AdministrationDtos.MemberResponse;
import com.traceagile.api.administration.AdministrationDtos.MembershipResponse;
import com.traceagile.api.administration.AdministrationDtos.ProjectResponse;
import com.traceagile.api.administration.AdministrationDtos.UserResponse;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.administration.ProjectMember;
import com.traceagile.domain.administration.ProjectRole;
import com.traceagile.domain.administration.User;
import java.util.List;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

/** §11.1 MapStruct : entités ↔ DTO. */
@Mapper
public interface AdministrationMapper {

    UserResponse toResponse(User user);

    @Mapping(target = "memberCount", expression = "java(project.getMembers().size())")
    ProjectResponse toResponse(Project project, ProjectRole myRole);

    @Mapping(target = "login", source = "user.login")
    @Mapping(target = "displayName", source = "user.displayName")
    MemberResponse toResponse(ProjectMember member);

    List<MemberResponse> toMemberResponses(List<ProjectMember> members);

    @Mapping(target = "key", source = "project.key")
    @Mapping(target = "name", source = "project.name")
    MembershipResponse toMembership(Project project, ProjectRole role);
}
