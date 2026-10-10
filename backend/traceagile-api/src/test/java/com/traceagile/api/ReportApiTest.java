package com.traceagile.api;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
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
import org.springframework.test.web.servlet.ResultActions;

/** §9 bilans, tableau de bord et rapports configurables (F-RPT-01 à F-RPT-04, ADR-0023). */
class ReportApiTest extends AbstractApiTest {

    static final String P = "/api/v1/projects/SHOP";

    String po;
    String qa;
    String admin;

    @BeforeEach
    void data() throws Exception {
        user("admin", false);
        user("po", false);
        user("qa1", false);
        user("dev", false);
        user("viewer", false);
        project("SHOP", Map.of("admin", ProjectRole.ADMINISTRATOR, "po", ProjectRole.PRODUCT_OWNER, "qa1", ProjectRole.TESTER,
                "dev", ProjectRole.DEVELOPER, "viewer", ProjectRole.VIEWER));
        po = bearer("po");
        qa = bearer("qa1");
        admin = bearer("admin");
        // REQ-2 story CRITICAL (3 pts), REQ-3 story sans test (2 pts), dans SPR-1 de REL-1
        send(po, P + "/requirements", Map.of("type", "FEATURE", "title", "Paiement"));
        send(po, P + "/requirements", Map.of("type", "USER_STORY", "title", "Payer par carte", "parentKey", "REQ-1", "riskLevel", "CRITICAL",
                "storyPoints", 3, "criteria", List.of(Map.of("format", "TEXT", "content", "Paiement accepté"))));
        send(po, P + "/requirements", Map.of("type", "USER_STORY", "title", "Reçu par e-mail", "parentKey", "REQ-1", "storyPoints", 2,
                "criteria", List.of(Map.of("format", "TEXT", "content", "Reçu envoyé"))));
        for (String key : List.of("REQ-2", "REQ-3")) {
            send(po, P + "/requirements/" + key + "/status", Map.of("status", "READY", "acknowledgeUnmet", true));
        }
        send(po, P + "/releases", Map.of("name", "Version 2.0", "startDate", "2026-10-12", "endDate", "2026-11-08"));
        send(po, P + "/sprints", Map.of("name", "Sprint 1", "goal", "Payer en ligne", "startDate", "2026-10-12", "endDate", "2026-10-25",
                "releaseKey", "REL-1"));
        mvc.perform(put(P + "/sprints/SPR-1/scope").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("requirementKeys", List.of("REQ-2", "REQ-3"))))).andExpect(status().isOk());
        send(qa, P + "/test-cases", Map.of("kind", "MANUAL", "title", "Payer avec une carte valide", "priority", "MUST",
                "steps", List.of(Map.of("action", "Payer", "expectedResult", "Commande payée")),
                "links", List.of(Map.of("requirementKey", "REQ-2", "linkType", "VERIFIES"))));
        send(qa, P + "/test-cases/TC-1/status", Map.of("status", "READY"));
        // CMP-1 de SPR-1 : TC-1 échoue, anomalie BLOCKER ouverte → No go
        send(qa, P + "/campaigns", Map.of("name", "Recette SPR-1", "scopeType", "SPRINT", "sprintKey", "SPR-1"));
        send(qa, P + "/campaigns/CMP-1/items/select", Map.of("strategy", "SPRINT_REQUIREMENTS"));
        String item = send(qa, P + "/campaigns/CMP-1", null, true).get("items").get(0).get("id").asText();
        String execution = send(qa, P + "/campaign-items/" + item + "/executions", Map.of()).get("id").asText();
        mvc.perform(put(P + "/executions/" + execution + "/steps/1").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("status", "FAILED", "actualResult", "Paiement refusé")))).andExpect(status().isOk());
        send(qa, P + "/executions/" + execution + "/defects", Map.of("title", "Paiement refusé à tort", "severity", "BLOCKER"));
    }

    JsonNode send(String token, String url, Object body) throws Exception {
        return send(token, url, body, false);
    }

    JsonNode send(String token, String url, Object body, boolean read) throws Exception {
        String text = (read ? mvc.perform(get(url).header("Authorization", token))
                : mvc.perform(post(url).header("Authorization", token).contentType(MediaType.APPLICATION_JSON).content(toJson(body))))
                .andExpect(status().is2xxSuccessful()).andReturn().getResponse().getContentAsString();
        return text.isBlank() ? null : readJson(text);
    }

    String definitionId(String name) throws Exception {
        for (JsonNode d : send(qa, P + "/report-definitions", null, true)) {
            if (d.get("name").asText().equals(name)) {
                return d.get("id").asText();
            }
        }
        throw new AssertionError(name);
    }

    ResultActions generate(String token, String definitionId, String scopeKey) throws Exception {
        return mvc.perform(post(P + "/reports").header("Authorization", token).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(scopeKey == null ? Map.of("definitionId", definitionId) : Map.of("definitionId", definitionId, "scopeKey", scopeKey))));
    }

    @Test
    @DisplayName("ADR-0023 définitions : intégrées (§9.2, §9.3) lisibles par tous, personnalisées par admin / PO / testeur, intégrée non modifiable mais duplicable")
    void definitions() throws Exception {
        mvc.perform(get(P + "/report-definitions").header("Authorization", bearer("viewer")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].name", contains("Bilan de release", "Bilan de sprint")))
                .andExpect(jsonPath("$[1].sections", contains("SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS",
                        "RECOMMENDATION")))
                .andExpect(jsonPath("$[1].builtIn", is(true)));
        Map<String, Object> quality = Map.of("name", "Synthèse qualité", "scopeType", "SPRINT", "sections", List.of("COVERAGE", "BURNDOWN", "DEFECT_LIST"),
                "defaultFormat", "DOCX", "includeCharts", true, "includeDetails", true);
        mvc.perform(post(P + "/report-definitions").header("Authorization", bearer("dev")).contentType(MediaType.APPLICATION_JSON).content(toJson(quality)))
                .andExpect(status().isForbidden());
        String id = readJson(mvc.perform(post(P + "/report-definitions").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(quality)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.defaultFormat", is("DOCX")))
                .andReturn().getResponse().getContentAsString()).get("id").asText();
        mvc.perform(post(P + "/report-definitions").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON).content(toJson(quality)))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code", is("REPORT_DEFINITION_DUPLICATE")));
        mvc.perform(post(P + "/report-definitions").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("name", "Vide", "scopeType", "SPRINT", "sections", List.of()))))
                .andExpect(status().isBadRequest());
        mvc.perform(post(P + "/report-definitions").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("name", "Régression", "scopeType", "SPRINT", "sections", List.of("REGRESSION")))))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("REPORT_SECTION_SCOPE")));

        String builtIn = definitionId("Bilan de sprint");
        mvc.perform(put(P + "/report-definitions/" + builtIn).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON).content(toJson(quality)))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("REPORT_DEFINITION_BUILT_IN")));
        mvc.perform(delete(P + "/report-definitions/" + builtIn).header("Authorization", qa)).andExpect(status().isUnprocessableEntity());
        mvc.perform(post(P + "/report-definitions/" + builtIn + "/duplicate").header("Authorization", po))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name", is("Copie de Bilan de sprint")))
                .andExpect(jsonPath("$.builtIn", is(false)));
        mvc.perform(put(P + "/report-definitions/" + id).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("name", "Synthèse qualité v2", "scopeType", "RELEASE", "sections", List.of("SPRINT_TREND", "REGRESSION")))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.defaultFormat", is("PDF")));
        mvc.perform(delete(P + "/report-definitions/" + id).header("Authorization", qa)).andExpect(status().isNoContent());
    }

    @Test
    @DisplayName("§9.2 bilan de sprint généré (RPT-n) : 8 sections, verdict No go (BLOCKER ouverte, validation < 80 %), exports dans tous les formats")
    void sprintReview() throws Exception {
        String sprint = definitionId("Bilan de sprint");
        generate(bearer("dev"), sprint, "SPR-1").andExpect(status().isForbidden());
        generate(qa, sprint, null).andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("REPORT_SCOPE_KEY_REQUIRED")));
        generate(qa, sprint, "SPR-1")
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.report.key", is("RPT-1")))
                .andExpect(jsonPath("$.report.title", is("Bilan de sprint — SPR-1 — Sprint 1")))
                .andExpect(jsonPath("$.report.verdict", is("NO_GO")))
                .andExpect(jsonPath("$.report.frozen", is(false)))
                .andExpect(jsonPath("$.data.summary.goal", is("Payer en ligne")))
                .andExpect(jsonPath("$.data.summary.objective", is("NOT_ACHIEVED")))
                .andExpect(jsonPath("$.data.delivery.committedStories", is(2)))
                .andExpect(jsonPath("$.data.delivery.committedPoints", is(5)))
                .andExpect(jsonPath("$.data.coverage.design.percent", is(50.0)))
                .andExpect(jsonPath("$.data.coverage.uncovered[0].key", is("REQ-3")))
                .andExpect(jsonPath("$.data.execution.byStatus.FAILED", is(1)))
                .andExpect(jsonPath("$.data.defects.openBySeverity.BLOCKER", is(1)))
                .andExpect(jsonPath("$.data.defects.blocking[0].title", is("Paiement refusé à tort")))
                .andExpect(jsonPath("$.data.risks[0].key", is("REQ-2")))
                .andExpect(jsonPath("$.data.recommendation.verdict", is("NO_GO")))
                .andExpect(jsonPath("$.data.recommendation.reasons", hasSize(3)))
                .andExpect(jsonPath("$.data.burndown").doesNotExist());

        mvc.perform(get(P + "/reports/RPT-1/export").param("format", "pdf").header("Authorization", bearer("viewer")))
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Type", "application/pdf"))
                .andExpect(header().string("Content-Disposition", startsWith("attachment; filename=\"RPT-1-bilan-de-sprint-spr-1-sprint-1.pdf\"")))
                .andExpect(result -> assertThat(new String(result.getResponse().getContentAsByteArray(), 0, 5, StandardCharsets.US_ASCII)).isEqualTo("%PDF-"));
        mvc.perform(get(P + "/reports/RPT-1/export").param("format", "word").header("Authorization", qa))
                .andExpect(header().string("Content-Type", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"))
                .andExpect(result -> assertThat(result.getResponse().getContentAsByteArray()).startsWith('P', 'K'));
        mvc.perform(get(P + "/reports/RPT-1/export").param("format", "xlsx").header("Authorization", qa)).andExpect(status().isOk());
        mvc.perform(get(P + "/reports/RPT-1/export").param("format", "html").param("download", "false").header("Authorization", qa))
                .andExpect(header().string("Content-Disposition", startsWith("inline")))
                .andExpect(content().string(containsString("Recommandation : No go")));
        mvc.perform(get(P + "/reports/RPT-1/export").param("format", "md").header("Authorization", qa))
                .andExpect(content().string(containsString("## 8. Recommandation de mise en production")));
        mvc.perform(get(P + "/reports/RPT-1/export").param("format", "csv").header("Authorization", qa))
                .andExpect(content().string(containsString("REQ-3;Reçu par e-mail;Non couverte")));
        mvc.perform(get(P + "/reports/RPT-1/export").param("format", "json").header("Authorization", qa))
                .andExpect(jsonPath("$.verdict", is("NO_GO")))
                .andExpect(jsonPath("$.data.summary.verdict", is("NO_GO")));
        mvc.perform(get(P + "/reports/RPT-1/export").param("format", "odt").header("Authorization", qa))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("REPORT_FORMAT_UNSUPPORTED")));
        mvc.perform(get(P + "/reports").header("Authorization", bearer("viewer"))).andExpect(jsonPath("$[0].key", is("RPT-1")));
        mvc.perform(get(P + "/reports/RPT-9").header("Authorization", qa)).andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("§9.2 verdict modifiable par le PO avec commentaire ; F-RPT-04 figé : lien permanent, plus de suppression")
    void verdictAndFreeze() throws Exception {
        String sprint = definitionId("Bilan de sprint");
        generate(qa, sprint, "SPR-1").andExpect(status().isCreated());
        generate(qa, sprint, "SPR-1").andExpect(status().isCreated());

        mvc.perform(put(P + "/reports/RPT-1/verdict").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("verdict", "GO_WITH_RESERVATIONS", "comment", "x")))).andExpect(status().isForbidden());
        mvc.perform(put(P + "/reports/RPT-1/verdict").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("verdict", "GO_WITH_RESERVATIONS"))))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("VERDICT_COMMENT_REQUIRED")));
        mvc.perform(put(P + "/reports/RPT-1/verdict").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("verdict", "GO_WITH_RESERVATIONS", "comment", "Contournement validé avec le métier"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.report.verdict", is("GO_WITH_RESERVATIONS")))
                .andExpect(jsonPath("$.report.computedVerdict", is("NO_GO")))
                .andExpect(jsonPath("$.verdictBy", is("po")));
        mvc.perform(get(P + "/reports/RPT-1/export").param("format", "html").header("Authorization", qa))
                .andExpect(content().string(containsString("Objectif partiellement atteint")))
                .andExpect(content().string(containsString("Contournement validé avec le métier")));

        mvc.perform(post(P + "/reports/RPT-1/freeze").header("Authorization", bearer("viewer"))).andExpect(status().isForbidden());
        mvc.perform(post(P + "/reports/RPT-1/freeze").header("Authorization", qa))
                .andExpect(jsonPath("$.report.frozen", is(true)))
                .andExpect(jsonPath("$.report.frozenBy", is("qa1")));
        mvc.perform(post(P + "/reports/RPT-1/freeze").header("Authorization", qa))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("REPORT_ALREADY_FROZEN")));
        mvc.perform(delete(P + "/reports/RPT-1").header("Authorization", qa))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("REPORT_FROZEN")));
        mvc.perform(delete(P + "/reports/RPT-2").header("Authorization", qa)).andExpect(status().isNoContent());
        mvc.perform(get(P + "/reports").header("Authorization", qa)).andExpect(jsonPath("$[*].key", contains("RPT-1")));
    }

    @Test
    @DisplayName("§9.2 « figé à la clôture » : clore le sprint génère et fige son bilan ; §12 bilans de sprint / release calculés à la demande")
    void closeAndOnDemand() throws Exception {
        mvc.perform(post(P + "/sprints/SPR-1/start").header("Authorization", po)).andExpect(status().isOk());
        mvc.perform(get(P + "/sprints/SPR-1/report").header("Authorization", bearer("viewer")))
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Type", "application/json"))
                .andExpect(jsonPath("$.key").doesNotExist())
                .andExpect(jsonPath("$.data.header.scope", is("sprint:SPR-1")))
                .andExpect(jsonPath("$.data.header.status", is("ACTIVE")));
        mvc.perform(get(P + "/releases/REL-1/report").param("format", "json").header("Authorization", qa))
                .andExpect(jsonPath("$.sections", contains("SUMMARY", "DELIVERY", "COVERAGE", "EXECUTION", "EXPLORATORY", "DEFECTS", "RISKS",
                        "SPRINT_TREND", "REGRESSION", "NFR", "RECOMMENDATION")))
                .andExpect(jsonPath("$.data.sprintTrend[0].key", is("SPR-1")));
        mvc.perform(get(P + "/sprints/SPR-1/report").param("format", "pdf").header("Authorization", qa))
                .andExpect(header().string("Content-Type", "application/pdf"));

        mvc.perform(post(P + "/sprints/SPR-1/close").header("Authorization", po)).andExpect(status().isOk());
        mvc.perform(get(P + "/reports").header("Authorization", qa))
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].definitionName", is("Bilan de sprint")))
                .andExpect(jsonPath("$[0].scope", is("sprint:SPR-1")))
                .andExpect(jsonPath("$[0].frozen", is(true)))
                .andExpect(jsonPath("$[0].frozenBy", is("clôture du sprint")));
        mvc.perform(get(P + "/reports/RPT-1").header("Authorization", qa))
                .andExpect(jsonPath("$.data.header.status", is("CLOSED")))
                .andExpect(jsonPath("$.data.delivery.returnedStories", is(2)));
    }

    @Test
    @DisplayName("F-RPT-01 / F-RPT-02 tableau de bord : sprint actif, couverture, dernière campagne, anomalies par sévérité, burndown, burnup")
    void dashboard() throws Exception {
        mvc.perform(post(P + "/sprints/SPR-1/start").header("Authorization", po)).andExpect(status().isOk());
        mvc.perform(get(P + "/dashboard").header("Authorization", bearer("viewer")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.activeSprint.key", is("SPR-1")))
                .andExpect(jsonPath("$.activeSprint.committedPoints", is(5)))
                .andExpect(jsonPath("$.sprintCoverage.design.percent", is(50.0)))
                .andExpect(jsonPath("$.releaseCoverage.scope", is("release:REL-1")))
                .andExpect(jsonPath("$.lastCampaign.key", is("CMP-1")))
                .andExpect(jsonPath("$.lastCampaign.byStatus.FAILED", is(1)))
                .andExpect(jsonPath("$.openDefectsBySeverity.BLOCKER", is(1)))
                .andExpect(jsonPath("$.burndown", hasSize(14)))
                .andExpect(jsonPath("$.burndown[0].reference", is(5.0)))
                .andExpect(jsonPath("$.releaseKey", is("REL-1")))
                .andExpect(jsonPath("$.burnup[0].reference", is(5.0)))
                .andExpect(jsonPath("$.lastRuns", hasSize(0)))
                .andExpect(jsonPath("$.defectsBySprint[0].defectsCreated").exists());
        mvc.perform(get("/api/v1/projects/NOPE/dashboard").header("Authorization", qa)).andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("§9.2 règles du verdict paramétrables par l'administrateur du projet ; elles s'appliquent aux bilans suivants")
    void verdictRules() throws Exception {
        mvc.perform(get(P + "/verdict-rules").header("Authorization", bearer("viewer")))
                .andExpect(jsonPath("$.goMinValidation", is(95.0)))
                .andExpect(jsonPath("$.reservedMinValidation", is(80.0)));
        Map<String, Object> lenient = Map.of("goMinValidation", 0, "reservedMinValidation", 0, "goForbidsCriticalDefects", false,
                "goRequiresCriticalRequirements", false, "reservedForbidsBlockerDefects", false);
        mvc.perform(put(P + "/verdict-rules").header("Authorization", po).contentType(MediaType.APPLICATION_JSON).content(toJson(lenient)))
                .andExpect(status().isForbidden());
        mvc.perform(put(P + "/verdict-rules").header("Authorization", admin).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("goMinValidation", 50, "reservedMinValidation", 60, "goForbidsCriticalDefects", true,
                                "goRequiresCriticalRequirements", true, "reservedForbidsBlockerDefects", true))))
                .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("VERDICT_RULES_INVALID")));
        mvc.perform(put(P + "/verdict-rules").header("Authorization", admin).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("goMinValidation", 120))))
                .andExpect(status().isBadRequest());
        mvc.perform(put(P + "/verdict-rules").header("Authorization", admin).contentType(MediaType.APPLICATION_JSON).content(toJson(lenient)))
                .andExpect(status().isOk()).andExpect(jsonPath("$.goMinValidation", is(0.0)));
        generate(qa, definitionId("Bilan de sprint"), "SPR-1").andExpect(jsonPath("$.report.verdict", is("GO")));
    }
}
