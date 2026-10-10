package com.traceagile.api;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.traceagile.domain.administration.ProjectRole;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.ResultActions;

/** ADR-0018 campagnes rangées dans une arborescence de dossiers. */
class CampaignFolderApiTest extends AbstractApiTest {

    static final String P = "/api/v1/projects/SHOP";
    String qa;

    @BeforeEach
    void data() throws Exception {
        user("qa1", false);
        user("viewer", false);
        project("SHOP", Map.of("qa1", ProjectRole.TESTER, "viewer", ProjectRole.VIEWER));
        qa = bearer("qa1");
    }

    ResultActions campaign(Map<String, Object> body) throws Exception {
        return mvc.perform(post(P + "/campaigns").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON).content(toJson(body)));
    }

    ResultActions folder(String token, String path) throws Exception {
        return mvc.perform(post(P + "/campaign-folders").header("Authorization", token).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("path", path))));
    }

    @Test
    @DisplayName("ADR-0018 dossiers de campagnes : création (vide possible), rangement, renommage d'une branche, suppression d'un dossier vide, droits")
    void folders() throws Exception {
        folder(qa, " Version 2.0 / Sprints ").andExpect(status().isCreated()).andExpect(jsonPath("$.path", is("Version 2.0/Sprints")));
        folder(qa, "Version 2.0/sprints").andExpect(status().isConflict());
        folder(bearer("viewer"), "Autre").andExpect(status().isForbidden());
        campaign(Map.of("name", "Recette SPR-1", "scopeType", "REGRESSION", "folder", "Version 2.0/Sprints"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.campaign.folder", is("Version 2.0/Sprints")));
        campaign(Map.of("name", "Non rangée", "scopeType", "REGRESSION")).andExpect(jsonPath("$.campaign.folder").doesNotExist());
        mvc.perform(get(P + "/campaign-folders").header("Authorization", bearer("viewer")))
                .andExpect(jsonPath("$", contains("Version 2.0", "Version 2.0/Sprints")));

        // une campagne terminée se range encore (archivage)
        mvc.perform(post(P + "/campaigns/CMP-2/complete").header("Authorization", qa)).andExpect(status().isOk());
        mvc.perform(patch(P + "/campaigns/CMP-2").header("Authorization", qa).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("folder", "Archives/2026"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.campaign.folder", is("Archives/2026")));
        mvc.perform(patch(P + "/campaigns/CMP-2").header("Authorization", qa).contentType("application/merge-patch+json")
                .content(toJson(Map.of("name", "Renommée")))).andExpect(status().isUnprocessableEntity());

        // renommer une branche reclasse les campagnes et sous-dossiers
        mvc.perform(post(P + "/campaign-folders/move").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("from", "Version 2.0", "to", "Releases/2.0"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.movedCampaigns", is(1)));
        mvc.perform(get(P + "/campaigns/CMP-1").header("Authorization", qa)).andExpect(jsonPath("$.campaign.folder", is("Releases/2.0/Sprints")));
        mvc.perform(get(P + "/campaign-folders").header("Authorization", qa))
                .andExpect(jsonPath("$", contains("Archives", "Archives/2026", "Releases", "Releases/2.0", "Releases/2.0/Sprints")));
        mvc.perform(post(P + "/campaign-folders/move").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("from", "Releases", "to", "Releases/2.0/x"))))
                .andExpect(status().isUnprocessableEntity());

        mvc.perform(delete(P + "/campaign-folders").param("path", "Releases").header("Authorization", qa))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("CAMPAIGN_FOLDER_NOT_EMPTY")));
        folder(qa, "Vide/Sous-dossier").andExpect(status().isCreated());
        mvc.perform(delete(P + "/campaign-folders").param("path", "Vide").header("Authorization", qa)).andExpect(status().isNoContent());
        mvc.perform(get(P + "/campaign-folders").header("Authorization", qa))
                .andExpect(jsonPath("$", contains("Archives", "Archives/2026", "Releases", "Releases/2.0", "Releases/2.0/Sprints")));

        // ADR-0017 une copie reste dans le dossier de sa source
        mvc.perform(post(P + "/campaigns/CMP-1/copy").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("name", "Copie")))).andExpect(jsonPath("$.campaign.campaign.folder", is("Releases/2.0/Sprints")));
    }
}
