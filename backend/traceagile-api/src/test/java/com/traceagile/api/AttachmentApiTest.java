package com.traceagile.api;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.traceagile.domain.administration.ProjectRole;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.ResultActions;

/** ADR-0024 pièces jointes : captures des pas (F-EXE-01), reprises par l'anomalie (F-EXE-03), exigences, droits. */
class AttachmentApiTest extends AbstractApiTest {

    static final String P = "/api/v1/projects/SHOP";
    static final byte[] PNG = {(byte) 0x89, 'P', 'N', 'G', 13, 10, 26, 10};

    String po;
    String qa;
    String execution;
    JsonNode steps;

    @BeforeEach
    void data() throws Exception {
        user("po", false);
        user("qa1", false);
        user("dev", false);
        user("viewer", false);
        project("SHOP", Map.of("po", ProjectRole.PRODUCT_OWNER, "qa1", ProjectRole.TESTER, "dev", ProjectRole.DEVELOPER, "viewer", ProjectRole.VIEWER));
        po = bearer("po");
        qa = bearer("qa1");
        send(po, P + "/requirements", Map.of("type", "BUSINESS_RULE", "title", "Payer par carte"));
        send(qa, P + "/test-cases", Map.of("kind", "MANUAL", "title", "Payer", "steps", List.of(
                Map.of("action", "Saisir la carte", "expectedResult", "Carte acceptée"),
                Map.of("action", "Valider", "expectedResult", "Commande payée"),
                Map.of("action", "Ouvrir l'e-mail", "expectedResult", "Reçu")),
                "links", List.of(Map.of("requirementKey", "REQ-1", "linkType", "VERIFIES"))));
        send(qa, P + "/test-cases/TC-1/status", Map.of("status", "READY"));
        send(qa, P + "/campaigns", Map.of("name", "Recette", "scopeType", "REGRESSION"));
        send(qa, P + "/campaigns/CMP-1/items/select", Map.of("strategy", "MANUAL", "testKeys", List.of("TC-1")));
        String item = readJson(mvc.perform(get(P + "/campaigns/CMP-1").header("Authorization", qa)).andReturn().getResponse().getContentAsString())
                .get("items").get(0).get("id").asText();
        execution = send(qa, P + "/campaign-items/" + item + "/executions", Map.of()).get("id").asText();
        steps = readJson(mvc.perform(get(P + "/executions/" + execution).header("Authorization", qa)).andReturn().getResponse().getContentAsString())
                .get("steps");
    }

    JsonNode send(String token, String url, Object body) throws Exception {
        String text = mvc.perform(post(url).header("Authorization", token).contentType(MediaType.APPLICATION_JSON).content(toJson(body)))
                .andExpect(status().is2xxSuccessful()).andReturn().getResponse().getContentAsString();
        return text.isBlank() ? null : readJson(text);
    }

    ResultActions upload(String token, String targetType, String targetId, String name, byte[] content) throws Exception {
        return mvc.perform(multipart(P + "/attachments").file(new MockMultipartFile("file", name, "application/octet-stream", content))
                .param("targetType", targetType).param("targetId", targetId).header("Authorization", token));
    }

    String step(int position) {
        return steps.get(position - 1).get("id").asText();
    }

    @Test
    @DisplayName("F-EXE-01 captures des pas ; F-EXE-03 l'anomalie reprend celles des pas jusqu'au pas en échec ; contenu partagé conservé")
    void stepCapturesFollowTheDefect() throws Exception {
        String capture = readJson(upload(qa, "EXECUTION_STEP", step(1), "saisie.png", PNG)
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.contentType", is("image/png")))
                .andExpect(jsonPath("$.image", is(true)))
                .andReturn().getResponse().getContentAsString()).get("id").asText();
        upload(qa, "EXECUTION_STEP", step(2), "C:\\captures\\refus.png", PNG).andExpect(jsonPath("$.fileName", is("refus.png")));
        upload(qa, "EXECUTION_STEP", step(3), "mail.txt", "x".getBytes(StandardCharsets.UTF_8)).andExpect(status().isCreated());
        upload(bearer("dev"), "EXECUTION_STEP", step(1), "x.png", PNG).andExpect(status().isForbidden());
        upload(qa, "EXECUTION_STEP", step(1), "virus.exe", PNG)
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("ATTACHMENT_TYPE_REFUSED")));
        upload(qa, "EXECUTION_STEP", java.util.UUID.randomUUID().toString(), "x.png", PNG).andExpect(status().isNotFound());

        mvc.perform(get(P + "/attachments").param("targetType", "EXECUTION_STEP").param("targetIds", step(1) + "," + step(2) + "," + step(3))
                        .header("Authorization", bearer("viewer")))
                .andExpect(jsonPath("$[*].fileName", contains("saisie.png", "refus.png", "mail.txt")));

        for (int position = 1; position <= 2; position++) {
            mvc.perform(put(P + "/executions/" + execution + "/steps/" + position).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                    .content(toJson(Map.of("status", position == 1 ? "PASSED" : "FAILED", "actualResult", "Refusée")))).andExpect(status().isOk());
        }
        JsonNode defect = send(qa, P + "/executions/" + execution + "/defects", Map.of("title", "Carte refusée", "severity", "MAJOR"));
        mvc.perform(get(P + "/attachments").param("targetType", "DEFECT").param("targetIds", defect.get("id").asText()).header("Authorization", qa))
                .andExpect(jsonPath("$[*].fileName", contains("saisie.png", "refus.png")));

        mvc.perform(get(P + "/attachments/" + capture + "/content").header("Authorization", bearer("viewer")))
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Type", "image/png"))
                .andExpect(header().string("Content-Disposition", startsWith("inline")))
                .andExpect(header().string("X-Content-Type-Options", "nosniff"))
                .andExpect(content().bytes(PNG));
        mvc.perform(delete(P + "/attachments/" + capture).header("Authorization", bearer("viewer"))).andExpect(status().isForbidden());
        mvc.perform(delete(P + "/attachments/" + capture).header("Authorization", qa)).andExpect(status().isNoContent());
        // la copie de l'anomalie partage le contenu : il n'est pas effacé
        String copy = readJson(mvc.perform(get(P + "/attachments").param("targetType", "DEFECT").param("targetIds", defect.get("id").asText())
                .header("Authorization", qa)).andReturn().getResponse().getContentAsString()).get(0).get("id").asText();
        mvc.perform(get(P + "/attachments/" + copy + "/content").header("Authorization", qa)).andExpect(content().bytes(PNG));
    }

    @Test
    @DisplayName("ADR-0024 pièce jointe d'une exigence : qui commente ; un texte se télécharge (pas d'affichage)")
    void requirementAttachment() throws Exception {
        String requirementId = readJson(mvc.perform(get(P + "/requirements/REQ-1").header("Authorization", po)).andReturn().getResponse()
                .getContentAsString()).get("id").asText();
        upload(bearer("viewer"), "REQUIREMENT", requirementId, "maquette.png", PNG).andExpect(status().isForbidden());
        String id = readJson(upload(bearer("dev"), "REQUIREMENT", requirementId, "notes.md", "# Notes".getBytes(StandardCharsets.UTF_8))
                .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString()).get("id").asText();
        mvc.perform(get(P + "/attachments/" + id + "/content").header("Authorization", po))
                .andExpect(header().string("Content-Disposition", startsWith("attachment")))
                .andExpect(header().string("Content-Security-Policy", "sandbox"));
        mvc.perform(get(P + "/attachments").param("targetType", "REQUIREMENT").param("targetIds", requirementId).header("Authorization", po))
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].createdBy", is("dev")));
        mvc.perform(get("/api/v1/projects/SHOP/attachments/" + java.util.UUID.randomUUID() + "/content").header("Authorization", po))
                .andExpect(status().isNotFound());
    }
}
