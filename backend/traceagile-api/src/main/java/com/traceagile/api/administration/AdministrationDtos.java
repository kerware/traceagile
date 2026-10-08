package com.traceagile.api.administration;

import com.traceagile.domain.administration.ProjectRole;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** DTO de l'authentification et de l'administration (§12). Aucune entité n'est exposée (§11.1). */
public interface AdministrationDtos {

    String LOGIN_PATTERN = "[a-z0-9._-]{2,32}";
    String LOGIN_MESSAGE = "2 à 32 caractères parmi a-z, 0-9, « . », « _ » et « - »";

    record LoginRequest(@NotBlank String login, @NotBlank String password) {
    }

    record TokenResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String accessToken,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String tokenType,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long expiresIn,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) MeResponse user) {
    }

    record MeResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String login,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String email,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String displayName,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean systemAdmin,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<MembershipResponse> projects) {
    }

    record MembershipResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ProjectRole role) {
    }

    record UserResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String login,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String email,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String displayName,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean active,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean systemAdmin,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long version,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant createdAt,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant updatedAt) {
    }

    record CreateUserRequest(
            @NotBlank @Pattern(regexp = LOGIN_PATTERN, message = LOGIN_MESSAGE) String login,
            @NotBlank @Email String email,
            @Size(max = 100) String displayName,
            @NotBlank @Size(min = 8, max = 72, message = "8 à 72 caractères") String password,
            boolean systemAdmin) {
    }

    /** JSON Merge Patch (RFC 7396) simplifié : un champ absent ou {@code null} reste inchangé (ADR-0005). */
    record UpdateUserRequest(
            @Email String email,
            @Size(max = 100) String displayName,
            @Size(min = 8, max = 72, message = "8 à 72 caractères") String password,
            Boolean active,
            Boolean systemAdmin) {
    }

    record ProjectResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            String description,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean archived,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int memberCount,
            @Schema(description = "Rôle de l'utilisateur courant ; absent pour un administrateur système non membre") ProjectRole myRole,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long version,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) Instant createdAt,
            String createdBy) {
    }

    record CreateProjectRequest(
            @NotBlank @Pattern(regexp = "[A-Z]{3,10}", message = "3 à 10 lettres majuscules (A-Z)") String key,
            @NotBlank @Size(max = 200) String name,
            String description) {
    }

    record MemberRequest(
            @NotBlank String login,
            @NotNull ProjectRole role) {
    }

    record MemberResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String login,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String displayName,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) ProjectRole role) {
    }
}
