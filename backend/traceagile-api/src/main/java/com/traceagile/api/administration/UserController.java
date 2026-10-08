package com.traceagile.api.administration;

import com.traceagile.api.administration.AdministrationDtos.CreateUserRequest;
import com.traceagile.api.administration.AdministrationDtos.UpdateUserRequest;
import com.traceagile.api.administration.AdministrationDtos.UserResponse;
import com.traceagile.api.web.PageResponse;
import com.traceagile.api.web.Versions;
import com.traceagile.application.administration.CreateUserCommand;
import com.traceagile.application.administration.UpdateUserCommand;
import com.traceagile.application.administration.UserAdministrationService;
import com.traceagile.domain.administration.User;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.net.URI;
import java.util.UUID;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** §12 Administration des utilisateurs, réservée à l'administrateur système (§2.2). */
@RestController
@RequestMapping("/api/v1/users")
@PreAuthorize("hasRole('SYSTEM_ADMIN')")
@Tag(name = "Administration")
public class UserController {

    private final UserAdministrationService users;
    private final AdministrationMapper mapper;

    public UserController(UserAdministrationService users, AdministrationMapper mapper) {
        this.users = users;
        this.mapper = mapper;
    }

    @GetMapping
    public PageResponse<UserResponse> list(@ParameterObject Pageable pageable) {
        return PageResponse.of(users.list(pageable), mapper::toResponse);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> get(@PathVariable UUID id) {
        return withEtag(users.get(id));
    }

    @PostMapping
    public ResponseEntity<UserResponse> create(@Valid @RequestBody CreateUserRequest request) {
        User user = users.create(new CreateUserCommand(request.login(), request.email(), request.displayName(),
                request.password(), request.systemAdmin()));
        return ResponseEntity.created(URI.create("/api/v1/users/" + user.getId())).body(mapper.toResponse(user));
    }

    @PatchMapping(path = "/{id}", consumes = {"application/merge-patch+json", "application/json"})
    public ResponseEntity<UserResponse> update(@PathVariable UUID id,
                                               @RequestHeader(name = HttpHeaders.IF_MATCH, required = false) String ifMatch,
                                               @Valid @RequestBody UpdateUserRequest request) {
        User user = users.update(id, new UpdateUserCommand(request.email(), request.displayName(), request.password(),
                request.active(), request.systemAdmin()), Versions.parseIfMatch(ifMatch));
        return withEtag(user);
    }

    private ResponseEntity<UserResponse> withEtag(User user) {
        return ResponseEntity.ok().eTag(Versions.etag(user)).body(mapper.toResponse(user));
    }
}
