package com.traceagile.api.git;

import com.traceagile.domain.git.GitAuthType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;
import java.util.UUID;

/** ADR-0030 dépôts Git déclarés et leurs projets ; le secret n'est jamais renvoyé ({@code hasSecret}). */
final class GitDtos {

    private GitDtos() {
    }

    record GitProjectResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID sourceId,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "« dépôt / projet »") String label,
            String defaultBranch,
            String description,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String cloneUrl,
            String webUrl,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) long version) {
    }

    record GitSourceResponse(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) UUID id,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String name,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String baseUrl,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) GitAuthType authType,
            String username,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "Un jeton ou une clé est enregistré (jamais renvoyé)") boolean hasSecret,
            String description,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) List<GitProjectResponse> projects) {
    }

    record GitSourceRequest(
            @Size(max = 100) String name,
            @Size(max = 300) String baseUrl,
            @Size(max = 500) String description,
            @Schema(description = "NONE, TOKEN (jeton HTTPS) ou SSH_KEY (clé privée)") GitAuthType authType,
            @Size(max = 100) String username,
            @Schema(description = "Jeton ou clé privée ; vide = secret enregistré conservé") @Size(max = 20000) String secret) {
    }

    record GitProjectRequest(
            @NotBlank @Size(max = 200) String name,
            @Size(max = 200) String defaultBranch,
            @Size(max = 500) String description) {
    }
}
