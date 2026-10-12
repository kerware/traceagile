package com.traceagile.api;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.traceagile.domain.administration.ProjectRole;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.ResultActions;

/** §8.3 campagnes, §8.4 exécution manuelle, §8.6 anomalies (critère de fin du lot 5). */
class CampaignExecutionApiTest extends AbstractApiTest {

    static final String P = "/api/v1/projects/SHOP";
    String po;
    String qa;

    @BeforeEach
    void data() throws Exception {
        user("po", false);
        user("qa1", false);
        user("qa2", false);
        user("dev", false);
        user("viewer", false);
        project("SHOP", Map.of("po", ProjectRole.PRODUCT_OWNER, "qa1", ProjectRole.TESTER, "qa2", ProjectRole.TESTER,
                "dev", ProjectRole.DEVELOPER, "viewer", ProjectRole.VIEWER));
        po = bearer("po");
        qa = bearer("qa1");
        // REQ-1 feature > REQ-2 story HIGH prête, dans SPR-1
        send(po, P + "/requirements", Map.of("type", "FEATURE", "title", "Panier"));
        send(po, P + "/requirements", Map.of("type", "USER_STORY", "title", "Ajouter au panier", "parentKey", "REQ-1",
                "riskLevel", "HIGH", "storyPoints", 3, "criteria", List.of(Map.of("format", "TEXT", "content", "Ajouté"))));
        send(po, P + "/requirements/REQ-2/status", Map.of("status", "READY", "acknowledgeUnmet", true));
        send(po, P + "/sprints", Map.of("name", "Sprint 1", "startDate", "2026-10-12", "endDate", "2026-10-25"));
        mvc.perform(put(P + "/sprints/SPR-1/scope").header("Authorization", po).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("requirementKeys", List.of("REQ-2"))))).andExpect(status().isOk());
        // TC-1 manuel MUST paramétré, jeu « Recette » d'une ligne (ADR-0028 ; deux lignes pour les tests qui en ont besoin : ADR-0022),
        // lié ; TC-2 manuel « smoke » non lié ; TC-3 automatisé lié ; TC-4 brouillon smoke
        send(qa, P + "/test-cases", Map.of("kind", "MANUAL", "title", "Ajouter un produit", "priority", "MUST", "estimatedDurationMin", 10,
                "steps", List.of(Map.of("action", "Ouvrir ${produit}", "expectedResult", "La fiche s'affiche"),
                        Map.of("action", "Ajouter au panier", "expectedResult", "Total ${prix}")),
                "parameters", List.of(Map.of("name", "prix", "defaultValue", "2,50 €")),
                "dataSets", List.of(Map.of("name", "Recette", "rows", List.of(Map.of("produit", "Stylo")))),
                "links", List.of(Map.of("requirementKey", "REQ-2", "linkType", "VERIFIES"))));
        send(qa, P + "/test-cases", Map.of("kind", "MANUAL", "title", "Accueil", "priority", "COULD", "tags", List.of("smoke"),
                "steps", List.of(Map.of("action", "Ouvrir l'accueil", "expectedResult", "OK"))));
        send(qa, P + "/test-cases", Map.of("kind", "AUTOMATED", "title", "API panier", "technique", "API", "testIdentifier", "CartApiTest#add",
                "links", List.of(Map.of("requirementKey", "REQ-2", "linkType", "VERIFIES"))));
        send(qa, P + "/test-cases", Map.of("kind", "MANUAL", "title", "Brouillon", "tags", List.of("smoke")));
        for (String key : List.of("TC-1", "TC-2", "TC-3")) {
            send(qa, P + "/test-cases/" + key + "/status", Map.of("status", "READY"));
        }
    }

    JsonNode send(String token, String url, Object body) throws Exception {
        String json = mvc.perform(post(url).header("Authorization", token).contentType(MediaType.APPLICATION_JSON).content(toJson(body)))
                .andExpect(status().is2xxSuccessful()).andReturn().getResponse().getContentAsString();
        return json.isBlank() ? null : readJson(json);
    }

    /** ADR-0018 jeu « Recette » de TC-1 (Stylo / Cahier à 3,90 €). */
    void recetteDataSet() throws Exception {
        mvc.perform(patch(P + "/test-cases/TC-1").header("Authorization", qa).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("dataSets", List.of(Map.of("name", "Recette",
                                "rows", List.of(Map.of("produit", "Stylo"), Map.of("produit", "Cahier", "prix", "3,90 €"))))))))
                .andExpect(status().isOk());
    }

    void campaign() throws Exception {
        mvc.perform(post(P + "/campaigns").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("name", "Recette SPR-1", "scopeType", "SPRINT", "sprintKey", "SPR-1",
                                "environment", "recette", "buildVersion", "2.0.0-rc1"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.campaign.key", is("CMP-1")))
                .andExpect(jsonPath("$.campaign.plannedStart", is("2026-10-12")));
    }

    ResultActions select(Map<String, Object> body) throws Exception {
        return mvc.perform(post(P + "/campaigns/CMP-1/items/select").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(body)));
    }

    String itemId(String testKey) throws Exception {
        JsonNode items = readJson(mvc.perform(get(P + "/campaigns/CMP-1").header("Authorization", qa)).andReturn().getResponse()
                .getContentAsString()).get("items");
        for (JsonNode item : items) {
            if (item.get("test").get("key").asText().equals(testKey)) {
                return item.get("id").asText();
            }
        }
        throw new IllegalStateException(testKey);
    }

    String startExecution(String itemId, Map<String, Object> body) throws Exception {
        return send(qa, P + "/campaign-items/" + itemId + "/executions", body).get("id").asText();
    }

    @Test
    @DisplayName("Lot 5 — critère de fin : un test manuel exécuté en échec crée une anomalie liée (F-CMP-01, F-CMP-02, F-CMP-04, F-EXE-01 à F-EXE-03)")
    void failedManualTestCreatesLinkedDefect() throws Exception {
        campaign();
        select(Map.of("strategy", "SPRINT_REQUIREMENTS"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.added", contains("TC-1", "TC-3")))
                .andExpect(jsonPath("$.campaign.items[0].riskScore", is(16)))
                .andExpect(jsonPath("$.campaign.items[1].executedByServer", is(true)))
                .andExpect(jsonPath("$.campaign.items[0].id").isNotEmpty());
        // ADR-0022 sélectionné, TC-1 est décliné sur la ligne « Stylo » de son jeu ; le jeu complété ensuite
        // (deux lignes) ne change pas la ligne de l'élément
        recetteDataSet();
        String tc1 = itemId("TC-1");
        mvc.perform(patch(P + "/campaign-items/" + tc1).header("Authorization", qa).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("assignee", "qa1"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.assignee.login", is("qa1")));
        mvc.perform(get(P + "/my-executions").param("status", "NOT_RUN").header("Authorization", qa))
                .andExpect(jsonPath("$[*].test.key", contains("TC-1")))
                .andExpect(jsonPath("$[0].dataSets[0].rows", is(2)));

        String execution = startExecution(tc1, Map.of());
        mvc.perform(get(P + "/executions/" + execution).header("Authorization", qa))
                .andExpect(jsonPath("$.status", is("RUNNING")))
                .andExpect(jsonPath("$.steps[0].action", is("Ouvrir Stylo")))
                .andExpect(jsonPath("$.steps[1].expectedResult", is("Total 2,50 €")));
        mvc.perform(put(P + "/executions/" + execution + "/steps/1").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("status", "PASSED")))).andExpect(status().isOk());
        mvc.perform(put(P + "/executions/" + execution + "/steps/2").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("status", "FAILED", "actualResult", "Total 0 €"))))
                .andExpect(jsonPath("$.status", is("FAILED")))
                .andExpect(jsonPath("$.endedAt").exists());

        JsonNode draft = readJson(mvc.perform(get(P + "/executions/" + execution + "/defect-draft").header("Authorization", qa))
                .andExpect(jsonPath("$.title", is("TC-1 Ajouter un produit : échec au pas 2 (Ajouter au panier)")))
                .andExpect(jsonPath("$.description", containsString("**Obtenu** : Total 0 €")))
                .andExpect(jsonPath("$.description", containsString("2.0.0-rc1")))
                .andExpect(jsonPath("$.requirementKeys", contains("REQ-2")))
                .andReturn().getResponse().getContentAsString());
        mvc.perform(post(P + "/executions/" + execution + "/defects").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("title", draft.get("title").asText(), "description", draft.get("description").asText(),
                                "severity", "CRITICAL"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.defect.key", is("DEF-1")))
                .andExpect(jsonPath("$.defect.requirementKeys", contains("REQ-2")))
                .andExpect(jsonPath("$.executions[0].testKey", is("TC-1")));

        mvc.perform(get(P + "/executions/" + execution).header("Authorization", qa)).andExpect(jsonPath("$.defects[0].key", is("DEF-1")));
        mvc.perform(get(P + "/requirements/REQ-2").header("Authorization", po)).andExpect(jsonPath("$.verificationStatus", is("FAILED")));
        mvc.perform(get(P + "/requirements/REQ-2/defects").header("Authorization", po))
                .andExpect(jsonPath("$[0].defect.key", is("DEF-1")))
                .andExpect(jsonPath("$[0].linked", is(true)));
        mvc.perform(get(P + "/requirements/REQ-2/executions").header("Authorization", po))
                .andExpect(jsonPath("$[0].status", is("FAILED")))
                .andExpect(jsonPath("$[0].campaign.key", is("CMP-1")));
        mvc.perform(get(P + "/requirements/REQ-2/checklists").header("Authorization", po))
                .andExpect(jsonPath("$.dod[2].outcome", is("UNSATISFIED")));
        mvc.perform(get(P + "/campaigns/CMP-1/progress").header("Authorization", po))
                .andExpect(jsonPath("$.byStatus.FAILED", is(1)))
                .andExpect(jsonPath("$.executed", is(1)))
                .andExpect(jsonPath("$.executedPercent", is(50.0)));
    }

    @Test
    @DisplayName("F-CMP-02 sélection cumulable : tag, manuelle, analyse d'impact, reprise des échecs ; non prêts et doublons signalés")
    void selectionStrategies() throws Exception {
        campaign();
        select(Map.of("strategy", "TAG", "tag", "Smoke"))
                .andExpect(jsonPath("$.added", contains("TC-2")))
                .andExpect(jsonPath("$.skipped[0].testKey", is("TC-4")))
                .andExpect(jsonPath("$.skipped[0].reason", is("NOT_READY_DRAFT")));
        select(Map.of("strategy", "MANUAL", "testKeys", List.of("TC-2", "TC-3")))
                .andExpect(jsonPath("$.added", contains("TC-3")))
                .andExpect(jsonPath("$.skipped[0].reason", is("ALREADY_SELECTED")));
        select(Map.of("strategy", "IMPACT", "requirementKeys", List.of("REQ-1")))
                .andExpect(jsonPath("$.added", contains("TC-1")));
        select(Map.of("strategy", "TAG")).andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("SELECTION_TAG_REQUIRED")));
        select(Map.of("tag", "smoke")).andExpect(status().isBadRequest());

        // reprise des échecs dans une nouvelle campagne de régression
        String tc2 = itemId("TC-2");
        String execution = startExecution(tc2, Map.of());
        mvc.perform(put(P + "/executions/" + execution + "/steps/1").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("status", "FAILED")))).andExpect(status().isOk());
        send(qa, P + "/campaigns", Map.of("name", "Régression", "scopeType", "REGRESSION"));
        mvc.perform(post(P + "/campaigns/CMP-2/items/select").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("strategy", "FROM_CAMPAIGN", "campaignKey", "CMP-1"))))
                .andExpect(jsonPath("$.added", contains("TC-2")));
        // ADR-0017 n'importe quels résultats : ici, les tests jamais exécutés
        mvc.perform(post(P + "/campaigns/CMP-2/items/select").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("strategy", "FROM_CAMPAIGN", "campaignKey", "CMP-1", "statuses", List.of("NOT_RUN")))))
                .andExpect(jsonPath("$.added", contains("TC-1", "TC-3")));
        mvc.perform(post(P + "/campaigns/CMP-2/items/select").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("strategy", "SPRINT_REQUIREMENTS"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("SELECTION_SPRINT_REQUIRED")));
    }

    @Test
    @DisplayName("F-CMP-03 / F-CMP-04 / F-CMP-05 tri par risque, ordre manuel, affectation, charge par testeur")
    void orderAssignmentWorkload() throws Exception {
        campaign();
        select(Map.of("strategy", "MANUAL", "testKeys", List.of("TC-2", "TC-1", "TC-3")));
        mvc.perform(get(P + "/campaigns/CMP-1").header("Authorization", qa))
                .andExpect(jsonPath("$.items[*].test.key", contains("TC-1", "TC-3", "TC-2")));
        String tc1 = itemId("TC-1");
        String tc2 = itemId("TC-2");
        String tc3 = itemId("TC-3");
        mvc.perform(put(P + "/campaigns/CMP-1/items/order").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("itemIds", List.of(tc2, tc3, tc1)))))
                .andExpect(jsonPath("$.items[*].test.key", contains("TC-2", "TC-3", "TC-1")));
        mvc.perform(post(P + "/campaigns/CMP-1/items/sort-by-risk").header("Authorization", qa))
                .andExpect(jsonPath("$.items[*].test.key", contains("TC-1", "TC-3", "TC-2")));

        mvc.perform(patch(P + "/campaign-items/" + tc3).header("Authorization", qa).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("assignee", "qa1"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("CAMPAIGN_ITEM_AUTOMATED")));
        mvc.perform(patch(P + "/campaign-items/" + tc1).header("Authorization", qa).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("assignee", "po"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("ASSIGNEE_CANNOT_EXECUTE")));
        mvc.perform(patch(P + "/campaign-items/" + tc1).header("Authorization", qa).contentType("application/merge-patch+json")
                .content(toJson(Map.of("assignee", "qa2")))).andExpect(status().isOk());
        mvc.perform(get(P + "/campaigns/CMP-1").header("Authorization", qa))
                .andExpect(jsonPath("$.workload[0].assignee.login", is("qa2")))
                .andExpect(jsonPath("$.workload[0].manualMinutes", is(10)))
                .andExpect(jsonPath("$.workload[1].assignee").doesNotExist())
                .andExpect(jsonPath("$.workload[1].unestimated", is(1)));
        mvc.perform(get(P + "/testers").header("Authorization", qa))
                .andExpect(jsonPath("$[*].login", containsInAnyOrder("qa1", "qa2")));

        mvc.perform(delete(P + "/campaign-items/" + tc2).header("Authorization", qa)).andExpect(status().isNoContent());
        startExecution(tc1, Map.of());
        mvc.perform(delete(P + "/campaign-items/" + tc1).header("Authorization", qa))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("CAMPAIGN_ITEM_EXECUTED")));
    }

    @Test
    @DisplayName("F-EXE-02 / F-EXE-04 statut forcé avec commentaire, tentatives, historique figé ; campagne terminée en lecture seule")
    void attemptsAndOverride() throws Exception {
        campaign();
        select(Map.of("strategy", "MANUAL", "testKeys", List.of("TC-2")));
        String item = itemId("TC-2");
        String first = startExecution(item, Map.of());
        mvc.perform(post(P + "/campaign-items/" + item + "/executions").header("Authorization", qa))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("EXECUTION_IN_PROGRESS")));
        mvc.perform(patch(P + "/executions/" + first).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("status", "BLOCKED"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("EXECUTION_COMMENT_REQUIRED")));
        mvc.perform(patch(P + "/executions/" + first).header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("status", "BLOCKED", "comment", "Recette indisponible"))))
                .andExpect(jsonPath("$.status", is("BLOCKED")))
                .andExpect(jsonPath("$.statusOverridden", is(true)));

        String second = startExecution(item, Map.of());
        mvc.perform(put(P + "/executions/" + second + "/steps/1").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("status", "PASSED"))))
                .andExpect(jsonPath("$.attempt", is(2)))
                .andExpect(jsonPath("$.status", is("PASSED")))
                .andExpect(jsonPath("$.attempts", hasSize(2)));
        mvc.perform(put(P + "/executions/" + first + "/steps/1").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("status", "PASSED"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("EXECUTION_NOT_LATEST")));

        mvc.perform(post(P + "/campaigns/CMP-1/complete").header("Authorization", qa)).andExpect(jsonPath("$.campaign.status", is("COMPLETED")));
        mvc.perform(put(P + "/executions/" + second + "/steps/1").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("status", "FAILED"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("CAMPAIGN_CLOSED")));
        mvc.perform(get(P + "/my-executions").header("Authorization", qa)).andExpect(jsonPath("$", hasSize(0)));
    }

    @Test
    @DisplayName("F-DEF-01 / F-DEF-02 cycle de vie d'une anomalie, If-Match, droits ; filtres")
    void defectLifecycle() throws Exception {
        mvc.perform(post(P + "/defects").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("title", "Libellé tronqué", "severity", "MINOR", "externalRef", "JIRA-12",
                                "requirementKeys", List.of("REQ-2")))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.defect.status", is("OPEN")))
                .andExpect(jsonPath("$.allowedTransitions", containsInAnyOrder("IN_PROGRESS", "RESOLVED", "REJECTED")));
        mvc.perform(post(P + "/defects").header("Authorization", bearer("viewer")).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("title", "X", "severity", "MINOR")))).andExpect(status().isForbidden());
        mvc.perform(post(P + "/defects").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("title", "Sans sévérité")))).andExpect(status().isBadRequest());
        mvc.perform(patch(P + "/defects/DEF-1").header("Authorization", bearer("dev")).header("If-Match", "\"7\"")
                .contentType("application/merge-patch+json").content(toJson(Map.of("status", "RESOLVED"))))
                .andExpect(status().isPreconditionFailed());
        mvc.perform(patch(P + "/defects/DEF-1").header("Authorization", bearer("dev")).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("status", "RESOLVED"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.defect.status", is("RESOLVED")));
        mvc.perform(patch(P + "/defects/DEF-1").header("Authorization", po).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("status", "REJECTED"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("DEFECT_STATUS_TRANSITION_INVALID")));
        mvc.perform(patch(P + "/defects/DEF-1").header("Authorization", po).contentType("application/merge-patch+json")
                .content("{\"status\":\"CLOSED\",\"externalRef\":null}")).andExpect(jsonPath("$.defect.externalRef").doesNotExist());
        mvc.perform(get(P + "/defects").param("status", "CLOSED").header("Authorization", bearer("viewer")))
                .andExpect(jsonPath("$[*].key", contains("DEF-1")));
        mvc.perform(get(P + "/defects").param("severity", "BLOCKER").header("Authorization", qa)).andExpect(jsonPath("$", hasSize(0)));
    }

    @Test
    @DisplayName("§3.3-6 un test ou une exigence exécutés ne se suppriment plus ; F-MAN-02 tri par fréquence d'exécution")
    void executedCannotBeDeleted() throws Exception {
        campaign();
        select(Map.of("strategy", "MANUAL", "testKeys", List.of("TC-1", "TC-2")));
        startExecution(itemId("TC-1"), Map.of());
        mvc.perform(delete(P + "/test-cases/TC-1").header("Authorization", qa))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_ALREADY_EXECUTED")));
        mvc.perform(delete(P + "/test-cases/TC-2").header("Authorization", qa))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_IN_CAMPAIGN")));
        mvc.perform(delete(P + "/requirements/REQ-2").header("Authorization", po))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("REQ_ALREADY_EXECUTED")));
        mvc.perform(get(P + "/test-cases").param("sort", "executionCount,desc").param("kind", "MANUAL").header("Authorization", qa))
                .andExpect(jsonPath("$.content[0].key", is("TC-1")))
                .andExpect(jsonPath("$.content[0].executionCount", is(1)));
    }

    @Test
    @DisplayName("§2.2 le développeur ne crée pas de campagne ; le lecteur consulte")
    void rights() throws Exception {
        mvc.perform(post(P + "/campaigns").header("Authorization", bearer("dev")).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("name", "X", "scopeType", "REGRESSION")))).andExpect(status().isForbidden());
        campaign();
        mvc.perform(get(P + "/campaigns").header("Authorization", bearer("viewer"))).andExpect(jsonPath("$[0].key", is("CMP-1")));
        mvc.perform(post(P + "/campaigns").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("name", "X", "scopeType", "SPRINT"))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("CAMPAIGN_SCOPE_INVALID")));
        mvc.perform(patch(P + "/campaigns/CMP-1").header("Authorization", qa).header("If-Match", "\"5\"")
                .contentType("application/merge-patch+json").content(toJson(Map.of("buildVersion", "2.0.0")))).andExpect(status().isPreconditionFailed());
        mvc.perform(get(P + "/campaigns/CMP-9").header("Authorization", qa)).andExpect(status().isNotFound());
    }

    /** CMP-1 : TC-1 affecté à qa2 et en échec, TC-2 réussi, TC-3 (automatisé) jamais exécuté. */
    void campaignWithResults() throws Exception {
        campaign();
        select(Map.of("strategy", "MANUAL", "testKeys", List.of("TC-1", "TC-2", "TC-3")));
        mvc.perform(patch(P + "/campaign-items/" + itemId("TC-1")).header("Authorization", qa).contentType("application/merge-patch+json")
                .content(toJson(Map.of("assignee", "qa2")))).andExpect(status().isOk());
        String failed = startExecution(itemId("TC-1"), Map.of());
        mvc.perform(put(P + "/executions/" + failed + "/steps/1").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("status", "FAILED")))).andExpect(status().isOk());
        String passed = startExecution(itemId("TC-2"), Map.of());
        mvc.perform(put(P + "/executions/" + passed + "/steps/1").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("status", "PASSED")))).andExpect(status().isOk());
    }

    ResultActions copy(Map<String, Object> body) throws Exception {
        return mvc.perform(post(P + "/campaigns/CMP-1/copy").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(body)));
    }

    @Test
    @DisplayName("ADR-0017 dupliquer une campagne : mêmes tests dans le même ordre, affectations conservées, sans exécution")
    void duplicate() throws Exception {
        campaignWithResults();
        copy(Map.of("name", "Recette SPR-1 bis", "buildVersion", "2.0.0-rc2"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.campaign.campaign.key", is("CMP-2")))
                .andExpect(jsonPath("$.campaign.campaign.status", is("PLANNED")))
                .andExpect(jsonPath("$.campaign.campaign.sprintKey", is("SPR-1")))
                .andExpect(jsonPath("$.campaign.campaign.environment", is("recette")))
                .andExpect(jsonPath("$.campaign.campaign.buildVersion", is("2.0.0-rc2")))
                // ordre de la source (sélection triée par score de risque), pas l'ordre des cles
                .andExpect(jsonPath("$.copied", contains("TC-1", "TC-3", "TC-2")))
                .andExpect(jsonPath("$.campaign.items[*].test.key", contains("TC-1", "TC-3", "TC-2")))
                .andExpect(jsonPath("$.campaign.items[0].assignee.login", is("qa2")))
                .andExpect(jsonPath("$.campaign.items[*].lastStatus", contains("NOT_RUN", "NOT_RUN", "NOT_RUN")))
                .andExpect(jsonPath("$.campaign.items[0].id").isNotEmpty());
    }

    @Test
    @DisplayName("ADR-0017 générer une campagne selon les résultats : tests en échec ou non exécutés, nouveau périmètre, sans affectation")
    void generateFromResults() throws Exception {
        campaignWithResults();
        copy(Map.of("name", "Reprise des échecs", "scopeType", "REGRESSION", "statuses", List.of("FAILED", "BLOCKED"), "keepAssignees", false))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.campaign.campaign.scopeType", is("REGRESSION")))
                .andExpect(jsonPath("$.campaign.campaign.sprintKey").doesNotExist())
                .andExpect(jsonPath("$.copied", contains("TC-1")))
                .andExpect(jsonPath("$.campaign.items[0].assignee").doesNotExist());
        copy(Map.of("name", "Non exécutés", "statuses", List.of("NOT_RUN")))
                .andExpect(jsonPath("$.copied", contains("TC-3")));
    }

    @Test
    @DisplayName("ADR-0017 copie : tests qui ne sont plus prêts signalés, source terminée acceptée ; validation et droits")
    void copyRules() throws Exception {
        campaignWithResults();
        mvc.perform(post(P + "/campaigns/CMP-1/complete").header("Authorization", qa)).andExpect(status().isOk());
        send(qa, P + "/test-cases/TC-2/status", Map.of("status", "OBSOLETE"));
        copy(Map.of("name", "Après clôture"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.copied", contains("TC-1", "TC-3")))
                .andExpect(jsonPath("$.skipped[0].testKey", is("TC-2")))
                .andExpect(jsonPath("$.skipped[0].reason", is("NOT_READY_OBSOLETE")));
        copy(Map.of("buildVersion", "x")).andExpect(status().isBadRequest());
        copy(Map.of("name", "X", "scopeType", "SPRINT")).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("CAMPAIGN_SCOPE_INVALID")));
        mvc.perform(post(P + "/campaigns/CMP-1/copy").header("Authorization", bearer("viewer")).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("name", "X")))).andExpect(status().isForbidden());
        mvc.perform(post(P + "/campaigns/CMP-9/copy").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("name", "X")))).andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("ADR-0018 fiche test : ses exécutions et anomalies ; anomalies d'une exigence directes ou trouvées par traçabilité, rattachement")
    void testRunsAndTracedDefects() throws Exception {
        campaign();
        select(Map.of("strategy", "MANUAL", "testKeys", List.of("TC-1", "TC-2")));
        String execution = startExecution(itemId("TC-1"), Map.of());
        mvc.perform(put(P + "/executions/" + execution + "/steps/1").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("status", "FAILED")))).andExpect(status().isOk());
        // anomalie volontairement rattachée à aucune exigence
        send(qa, P + "/executions/" + execution + "/defects", Map.of("title", "Fiche vide", "severity", "MINOR", "requirementKeys", List.of()));

        mvc.perform(get(P + "/test-cases/TC-1/executions").header("Authorization", po))
                .andExpect(jsonPath("$[0].id", is(execution)))
                .andExpect(jsonPath("$[0].status", is("FAILED")))
                .andExpect(jsonPath("$[0].campaign.key", is("CMP-1")));
        mvc.perform(get(P + "/test-cases/TC-1/defects").header("Authorization", po)).andExpect(jsonPath("$[*].key", contains("DEF-1")));
        mvc.perform(get(P + "/test-cases/TC-2/defects").header("Authorization", po)).andExpect(jsonPath("$", hasSize(0)));

        mvc.perform(get(P + "/requirements/REQ-2/defects").header("Authorization", po))
                .andExpect(jsonPath("$[0].defect.key", is("DEF-1")))
                .andExpect(jsonPath("$[0].linked", is(false)))
                .andExpect(jsonPath("$[0].viaTests", contains("TC-1")));
        mvc.perform(post(P + "/requirements/REQ-2/defects/DEF-1").header("Authorization", bearer("viewer"))).andExpect(status().isForbidden());
        mvc.perform(post(P + "/requirements/REQ-2/defects/DEF-1").header("Authorization", qa))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.defect.requirementKeys", contains("REQ-2")));
        mvc.perform(get(P + "/requirements/REQ-2/defects").header("Authorization", po))
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].linked", is(true)))
                .andExpect(jsonPath("$[0].viaTests", contains("TC-1")));
        mvc.perform(get(P + "/test-cases/TC-9/executions").header("Authorization", po)).andExpect(status().isNotFound());
    }

    JsonNode items() throws Exception {
        return readJson(mvc.perform(get(P + "/campaigns/CMP-1").header("Authorization", qa)).andReturn().getResponse().getContentAsString())
                .get("items");
    }

    ResultActions patchItem(String id, Map<String, Object> body) throws Exception {
        return mvc.perform(patch(P + "/campaign-items/" + id).header("Authorization", qa).contentType("application/merge-patch+json")
                .content(toJson(body)));
    }

    @Test
    @DisplayName("ADR-0018 test sélectionné avec un jeu de données : une ligne par élément, déclinaison de toutes les lignes, valeurs à l'exécution")
    void dataSetInCampaign() throws Exception {
        recetteDataSet();
        campaign();
        // ADR-0022 la sélection décline déjà TC-1 sur les lignes de son premier jeu
        select(Map.of("strategy", "MANUAL", "testKeys", List.of("TC-1", "TC-2")))
                .andExpect(jsonPath("$.added", contains("TC-1", "TC-2")))
                .andExpect(jsonPath("$.campaign.items[*].test.key", contains("TC-1", "TC-1", "TC-2")))
                .andExpect(jsonPath("$.campaign.items[0].dataSetRow", is(0)))
                .andExpect(jsonPath("$.campaign.items[1].dataSetRow", is(1)))
                .andExpect(jsonPath("$.campaign.items[2].dataSetName").doesNotExist());
        String tc1 = itemId("TC-1");
        mvc.perform(post(P + "/campaign-items/" + tc1 + "/expand-data-set").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("dataSetName", "recette"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[*].test.key", contains("TC-1", "TC-1", "TC-2")))
                .andExpect(jsonPath("$.items[0].dataSetName", is("Recette")))
                .andExpect(jsonPath("$.items[0].dataSetRow", is(0)))
                .andExpect(jsonPath("$.items[0].dataSetValues.produit", is("Stylo")))
                .andExpect(jsonPath("$.items[1].dataSetRow", is(1)))
                .andExpect(jsonPath("$.items[1].dataSetValues.prix", is("3,90 €")))
                .andExpect(jsonPath("$.items[1].id").isNotEmpty());
        // idempotent : les lignes déjà présentes ne sont pas dupliquées
        mvc.perform(post(P + "/campaign-items/" + tc1 + "/expand-data-set").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("dataSetName", "Recette")))).andExpect(jsonPath("$.items", hasSize(3)));
        select(Map.of("strategy", "MANUAL", "testKeys", List.of("TC-1")))
                .andExpect(jsonPath("$.skipped[0].reason", is("ALREADY_SELECTED")));

        String row2 = items().get(1).get("id").asText();
        patchItem(row2, Map.of("assignee", "qa1")).andExpect(jsonPath("$.dataSetRow", is(1)));
        String execution = startExecution(row2, Map.of());
        mvc.perform(get(P + "/executions/" + execution).header("Authorization", qa))
                .andExpect(jsonPath("$.dataSetName", is("Recette")))
                .andExpect(jsonPath("$.dataSetRow", is(1)))
                .andExpect(jsonPath("$.steps[0].action", is("Ouvrir Cahier")))
                .andExpect(jsonPath("$.steps[1].expectedResult", is("Total 3,90 €")));
        mvc.perform(get(P + "/test-cases/TC-1/executions").header("Authorization", qa))
                .andExpect(jsonPath("$[0].dataSetName", is("Recette")))
                .andExpect(jsonPath("$[0].dataSetRow", is(1)));
        mvc.perform(get(P + "/my-executions").header("Authorization", qa).param("status", "RUNNING"))
                .andExpect(jsonPath("$[0].dataSetRow", is(1)));

        // règles : ligne imposée par la campagne, élément exécuté figé, doublon, jeu inconnu
        mvc.perform(put(P + "/executions/" + execution + "/steps/1").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("status", "PASSED"))));
        mvc.perform(put(P + "/executions/" + execution + "/steps/2").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("status", "PASSED")))).andExpect(jsonPath("$.status", is("PASSED")));
        mvc.perform(post(P + "/campaign-items/" + row2 + "/executions").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("dataSetName", "Recette", "row", 0))))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("EXECUTION_DATASET_BOUND")));
        patchItem(row2, Map.of("dataSetName", "Recette", "dataSetRow", 0)).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("CAMPAIGN_ITEM_EXECUTED")));
        patchItem(tc1, Map.of("dataSetName", "Recette", "dataSetRow", 1)).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("CAMPAIGN_ITEM_DUPLICATE")));
        patchItem(itemId("TC-2"), Map.of("dataSetName", "Recette", "dataSetRow", 0)).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("EXECUTION_DATASET_UNKNOWN")));
        patchItem(tc1, Map.of("dataSetRow", 5)).andExpect(status().isUnprocessableEntity());
        // retour aux valeurs par défaut
        patchItem(tc1, java.util.Collections.singletonMap("dataSetName", null))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.dataSetName").doesNotExist());

        // ADR-0017 la copie garde les lignes
        copy(Map.of("name", "Bis"))
                .andExpect(jsonPath("$.copied", contains("TC-1", "TC-1", "TC-2")))
                .andExpect(jsonPath("$.campaign.items[1].dataSetRow", is(1)));
    }

    ResultActions patchTest(String key, Map<String, Object> body) throws Exception {
        return mvc.perform(patch(P + "/test-cases/" + key).header("Authorization", qa).contentType("application/merge-patch+json")
                .content(toJson(body)));
    }

    @Test
    @DisplayName("ADR-0018 un pas appelle un autre cas de test : paramètres transmis, pas déroulés à l'exécution ; cycles, nature et suppression contrôlés")
    void calledTestSteps() throws Exception {
        // TC-5 réutilisable « Se connecter », paramètre ${login}
        send(qa, P + "/test-cases", Map.of("kind", "MANUAL", "title", "Se connecter",
                "steps", List.of(Map.of("action", "Saisir ${login}", "expectedResult", "Champ rempli"),
                        Map.of("action", "Valider", "expectedResult", "Connecté en tant que ${login}")),
                "parameters", List.of(Map.of("name", "login", "defaultValue", "invité"))));
        // TC-6 appelle TC-5 avec login = ${client}
        mvc.perform(post(P + "/test-cases").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("kind", "MANUAL", "title", "Commander",
                                "steps", List.of(Map.of("calledTestKey", "TC-5", "callParameters", Map.of("login", "${client}")),
                                        Map.of("action", "Payer ${montant}", "expectedResult", "Payé")),
                                "parameters", List.of(Map.of("name", "client", "defaultValue", "alice"),
                                        Map.of("name", "montant", "defaultValue", "10 €")),
                                // ADR-0028 un test manuel paramétré prêt a un jeu de données
                                "dataSets", List.of(Map.of("name", "Clients", "rows", List.of(Map.of("client", "alice", "montant", "10 €"))))))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.key", is("TC-6")))
                .andExpect(jsonPath("$.steps[0].calledTest.key", is("TC-5")))
                .andExpect(jsonPath("$.steps[0].calledTest.title", is("Se connecter")))
                .andExpect(jsonPath("$.steps[0].callParameters.login", is("${client}")))
                .andExpect(jsonPath("$.parameters[*].name", containsInAnyOrder("client", "montant")));
        mvc.perform(get(P + "/test-cases/TC-5").header("Authorization", qa)).andExpect(jsonPath("$.calledBy", contains("TC-6")));

        // règles
        patchTest("TC-5", Map.of("steps", List.of(Map.of("calledTestKey", "TC-6")))).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_CALL_CYCLE")));
        patchTest("TC-6", Map.of("steps", List.of(Map.of("calledTestKey", "TC-6")))).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_CALL_CYCLE")));
        patchTest("TC-6", Map.of("steps", List.of(Map.of("calledTestKey", "TC-3")))).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_CALL_INVALID")));
        patchTest("TC-6", Map.of("steps", List.of(Map.of("calledTestKey", "TC-99")))).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_CALL_INVALID")));
        patchTest("TC-6", Map.of("steps", List.of(Map.of("expectedResult", "sans action")))).andExpect(status().isUnprocessableEntity());
        mvc.perform(delete(P + "/test-cases/TC-5").header("Authorization", qa)).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("TEST_CALLED")));

        // exécution : pas de TC-5 déroulés avec login = alice, puis le pas propre à TC-6
        send(qa, P + "/test-cases/TC-6/status", Map.of("status", "READY"));
        campaign();
        select(Map.of("strategy", "MANUAL", "testKeys", List.of("TC-6")));
        String execution = startExecution(itemId("TC-6"), Map.of());
        mvc.perform(get(P + "/executions/" + execution).header("Authorization", qa))
                .andExpect(jsonPath("$.steps", hasSize(3)))
                .andExpect(jsonPath("$.steps[0].action", is("Saisir alice")))
                .andExpect(jsonPath("$.steps[0].calledFrom", is("TC-5 Se connecter")))
                .andExpect(jsonPath("$.steps[1].expectedResult", is("Connecté en tant que alice")))
                .andExpect(jsonPath("$.steps[2].action", is("Payer 10 €")))
                .andExpect(jsonPath("$.steps[2].calledFrom").doesNotExist());
        mvc.perform(put(P + "/executions/" + execution + "/steps/3").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("status", "FAILED")))).andExpect(jsonPath("$.status", is("FAILED")));
    }
}
