package com.traceagile.api.search;

import com.traceagile.application.common.NotFoundException;
import com.traceagile.application.search.NotificationService;
import com.traceagile.application.search.SearchService;
import com.traceagile.application.search.SearchService.Hit;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** §13.1 recherche globale ({@code Ctrl+K}), aperçu d'une clé au survol, notifications de la barre supérieure (ADR-0024). */
@RestController
@RequestMapping("/api/v1/projects/{projectKey}")
@Tag(name = "Recherche")
public class SearchController {

    static final String READ = "hasPermission(#projectKey, 'Project', 'PROJECT_READ')";

    private final SearchService search;
    private final NotificationService notifications;

    public SearchController(SearchService search, NotificationService notifications) {
        this.search = search;
        this.notifications = notifications;
    }

    public record SearchHit(
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) SearchService.ItemType type,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String key,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) String title,
            @Schema(description = "Type d'exigence, nature du test, sévérité, campagne d'un run…") String detail,
            String status) {
    }

    public record NotificationsResponse(
            String activeSprintKey,
            String activeSprintName,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int myTests,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int sessionsToApprove,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int blockingDefects,
            @Schema(requiredMode = Schema.RequiredMode.REQUIRED) int failedRuns) {
    }

    /** Clé exacte, puis préfixe de clé, puis titre ; 20 résultats au plus, 2 caractères au moins. */
    @GetMapping("/search")
    @PreAuthorize(READ)
    public List<SearchHit> search(@PathVariable String projectKey, @RequestParam String q) {
        return search.search(projectKey, q).stream().map(SearchController::hit).toList();
    }

    /** Aperçu d'une clé ({@code REQ-12}, {@code TC-45}…) : 404 si elle n'existe pas dans le projet. */
    @GetMapping("/items/{itemKey}")
    @PreAuthorize(READ)
    public SearchHit item(@PathVariable String projectKey, @PathVariable String itemKey) {
        return search.find(projectKey, itemKey).map(SearchController::hit)
                .orElseThrow(() -> new NotFoundException("ITEM_NOT_FOUND", "« " + itemKey + " » introuvable."));
    }

    @GetMapping("/notifications")
    @PreAuthorize(READ)
    public NotificationsResponse notifications(@PathVariable String projectKey, Authentication authentication) {
        NotificationService.Notifications n = notifications.of(projectKey, authentication.getName());
        return new NotificationsResponse(n.activeSprintKey(), n.activeSprintName(), n.myTests(), n.sessionsToApprove(), n.blockingDefects(),
                n.failedRuns());
    }

    private static SearchHit hit(Hit h) {
        return new SearchHit(h.type(), h.key(), h.title(), h.detail(), h.status());
    }
}
