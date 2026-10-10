package com.traceagile.api;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
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

/** §5 tests exploratoires : sessions (F-EXP-05 à F-EXP-10), débriefing PROOF (F-EXP-11 à F-EXP-13), métriques (§5.4). */
class ExploratorySessionApiTest extends AbstractApiTest {

    static final String P = "/api/v1/projects/SHOP";
    String po;
    String qa;
    String item;

    @BeforeEach
    void data() throws Exception {
        user("po", false);
        user("qa1", false);
        user("qa2", false);
        user("viewer", false);
        project("SHOP", Map.of("po", ProjectRole.PRODUCT_OWNER, "qa1", ProjectRole.TESTER, "qa2", ProjectRole.TESTER, "viewer", ProjectRole.VIEWER));
        po = bearer("po");
        qa = bearer("qa1");
        send(po, P + "/requirements", Map.of("type", "FEATURE", "title", "Catalogue"));
        send(po, P + "/requirements", Map.of("type", "USER_STORY", "title", "Rechercher un produit", "parentKey", "REQ-1",
                "criteria", List.of(Map.of("format", "TEXT", "content", "Les résultats correspondent à la saisie"),
                        Map.of("format", "TEXT", "content", "Une recherche sans résultat propose des suggestions"))));
        // TC-1 charte liée à la story REQ-2
        send(qa, P + "/test-cases", Map.of("kind", "EXPLORATORY", "title", "Explorer la recherche",
                "explore", "la recherche", "with", "des saisies inhabituelles", "toDiscover", "les erreurs mal gérées",
                "timeboxMin", 60, "heuristics", List.of("SFDIPOT"), "areas", List.of("Recherche", "Filtres", "Tri"),
                "links", List.of(Map.of("requirementKey", "REQ-2", "linkType", "VERIFIES"))));
        send(qa, P + "/test-cases/TC-1/status", Map.of("status", "READY"));
        mvc.perform(post(P + "/campaigns").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("name", "Exploration", "scopeType", "REGRESSION")))).andExpect(status().isCreated());
        send(qa, P + "/campaigns/CMP-1/items/select", Map.of("strategy", "MANUAL", "testKeys", List.of("TC-1")));
        item = readJson(mvc.perform(get(P + "/campaigns/CMP-1").header("Authorization", qa)).andReturn().getResponse().getContentAsString())
                .get("items").get(0).get("id").asText();
    }

    JsonNode send(String token, String url, Object body) throws Exception {
        String json = mvc.perform(post(url).header("Authorization", token).contentType(MediaType.APPLICATION_JSON).content(toJson(body)))
                .andExpect(status().is2xxSuccessful()).andReturn().getResponse().getContentAsString();
        return json.isBlank() ? null : readJson(json);
    }

    ResultActions act(String token, String url, Object body) throws Exception {
        return mvc.perform(post(url).header("Authorization", token).contentType(MediaType.APPLICATION_JSON).content(toJson(body)));
    }

    String start() throws Exception {
        return readJson(act(qa, P + "/campaign-items/" + item + "/sessions", Map.of())
                .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString()).get("id").asText();
    }

    void finish(String session) throws Exception {
        act(qa, P + "/sessions/" + session + "/finish", Map.of("testPct", 60, "bugPct", 30, "setupPct", 10,
                "areasCovered", List.of("Recherche", "Filtres"), "status", "FAILED")).andExpect(status().isOk());
    }

    @Test
    @DisplayName("Lot 6 — critère de fin (§15.3 étape 3) : session chronométrée, notes, BUG converti en anomalie, débriefing approuvé par le PO")
    void sessionJourney() throws Exception {
        String session = start();
        mvc.perform(get(P + "/sessions/" + session).header("Authorization", qa))
                .andExpect(jsonPath("$.state", is("RUNNING")))
                .andExpect(jsonPath("$.charter.key", is("TC-1")))
                .andExpect(jsonPath("$.missionSentence", is("Explorer la recherche avec des saisies inhabituelles pour découvrir les erreurs mal gérées.")))
                .andExpect(jsonPath("$.timeboxMin", is(60)))
                .andExpect(jsonPath("$.areas", contains("Recherche", "Filtres", "Tri")))
                .andExpect(jsonPath("$.campaign.key", is("CMP-1")))
                .andExpect(jsonPath("$.attempt", is(1)))
                .andExpect(jsonPath("$.owner", is(true)));
        mvc.perform(get(P + "/campaigns/CMP-1").header("Authorization", qa)).andExpect(jsonPath("$.items[0].lastStatus", is("RUNNING")));

        // F-EXP-06 notes typées ; F-EXP-10 brouillon et pause
        act(qa, P + "/sessions/" + session + "/notes", Map.of("type", "NOTE", "text", "Recherche vide : message clair"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.offsetSeconds", greaterThanOrEqualTo(0)));
        JsonNode bug = send(qa, P + "/sessions/" + session + "/notes", Map.of("type", "BUG", "text", "Les guillemets cassent la page de résultats"));
        mvc.perform(patch(P + "/sessions/" + session).header("Authorization", qa).contentType("application/merge-patch+json")
                        .content(toJson(Map.of("draft", "Le tri par prix ", "paused", true))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.state", is("PAUSED")))
                .andExpect(jsonPath("$.draft", is("Le tri par prix ")));
        mvc.perform(patch(P + "/sessions/" + session).header("Authorization", qa).contentType("application/merge-patch+json")
                .content(toJson(Map.of("paused", false)))).andExpect(jsonPath("$.state", is("RUNNING")));

        // F-EXP-07 BUG → anomalie pré-remplie, liée à la tentative et aux exigences de la charte
        String noteUrl = P + "/sessions/" + session + "/notes/" + bug.get("id").asText();
        JsonNode draft = readJson(mvc.perform(get(noteUrl + "/defect-draft").header("Authorization", qa))
                .andExpect(jsonPath("$.title", is("TC-1 Explorer la recherche : Les guillemets cassent la page de résultats")))
                .andExpect(jsonPath("$.description", containsString("**Session** : tentative 1")))
                .andExpect(jsonPath("$.description", containsString("**Mission** : Explorer la recherche")))
                .andExpect(jsonPath("$.requirementKeys", contains("REQ-2")))
                .andReturn().getResponse().getContentAsString());
        act(qa, noteUrl + "/defects", Map.of("title", draft.get("title").asText(), "description", draft.get("description").asText(),
                        "severity", "MAJOR"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.defect.key", is("DEF-1")))
                .andExpect(jsonPath("$.defect.requirementKeys", contains("REQ-2")))
                .andExpect(jsonPath("$.executions[0].testKey", is("TC-1")));
        act(qa, noteUrl + "/defects", Map.of("title", "x", "severity", "MAJOR")).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("SESSION_NOTE_ALREADY_CONVERTED")));
        mvc.perform(get(P + "/sessions/" + session).header("Authorization", qa))
                .andExpect(jsonPath("$.notes[1].defect.key", is("DEF-1")))
                .andExpect(jsonPath("$.defects[0].key", is("DEF-1")));

        // F-EXP-09 fin : TBS, zones couvertes, statut de la tentative
        act(qa, P + "/sessions/" + session + "/finish", Map.of("testPct", 50, "bugPct", 30, "setupPct", 10, "areasCovered", List.of(),
                "status", "PASSED")).andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code", is("SESSION_TBS_INVALID")));
        finish(session);
        mvc.perform(get(P + "/campaigns/CMP-1").header("Authorization", qa)).andExpect(jsonPath("$.items[0].lastStatus", is("FAILED")));
        mvc.perform(get(P + "/requirements/REQ-2").header("Authorization", po)).andExpect(jsonPath("$.verificationStatus", is("FAILED")));

        // F-EXP-11 débriefing PROOF ; F-EXP-13 approuvé par le PO, pas par le testeur
        act(qa, P + "/sessions/" + session + "/debrief", Map.of("past", "Recherche et filtres parcourus", "results", "1 bogue (DEF-1)",
                "obstacles", "Peu de produits", "outlook", "Explorer le tri\nExplorer la pagination", "feelings", 3)).andExpect(status().isOk());
        act(qa, P + "/sessions/" + session + "/debrief/approve", Map.of()).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("SESSION_SELF_APPROVAL")));
        act(bearer("viewer"), P + "/sessions/" + session + "/debrief/approve", Map.of()).andExpect(status().isForbidden());
        act(po, P + "/sessions/" + session + "/debrief/approve", Map.of())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.state", is("DEBRIEFED")))
                .andExpect(jsonPath("$.approvedBy", is("po")))
                .andExpect(jsonPath("$.proof.outlookItems", contains("Explorer le tri", "Explorer la pagination")));

        // F-EXP-12 l'Outlook crée des chartes de suivi, liées aux mêmes exigences
        act(qa, P + "/sessions/" + session + "/follow-up-charters", Map.of("missions", List.of("le tri")))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.created", contains("TC-2")));
        mvc.perform(get(P + "/test-cases/TC-2").header("Authorization", qa))
                .andExpect(jsonPath("$.kind", is("EXPLORATORY")))
                .andExpect(jsonPath("$.charter.explore", is("le tri")))
                .andExpect(jsonPath("$.charter.with", is("des saisies inhabituelles")))
                .andExpect(jsonPath("$.requirements[0].requirementKey", is("REQ-2")));
    }

    @Test
    @DisplayName("F-EXP-05 règles : une seule session en cours, seule une charte, seul le testeur agit sur sa session ; listes « en cours » et « à débriefer »")
    void rules() throws Exception {
        String session = start();
        act(qa, P + "/campaign-items/" + item + "/sessions", Map.of()).andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code", is("EXECUTION_IN_PROGRESS")));
        act(bearer("qa2"), P + "/sessions/" + session + "/notes", Map.of("type", "NOTE", "text", "intrus")).andExpect(status().isForbidden());
        act(bearer("viewer"), P + "/campaign-items/" + item + "/sessions", Map.of()).andExpect(status().isForbidden());
        mvc.perform(get(P + "/sessions/" + session).header("Authorization", bearer("qa2"))).andExpect(jsonPath("$.owner", is(false)));
        mvc.perform(get(P + "/sessions").param("state", "RUNNING", "PAUSED").header("Authorization", qa))
                .andExpect(jsonPath("$[*].id", contains(session)))
                .andExpect(jsonPath("$[0].charter.key", is("TC-1")))
                .andExpect(jsonPath("$[0].tester", is("qa1")));
        finish(session);
        mvc.perform(get(P + "/sessions").param("state", "FINISHED").header("Authorization", po))
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].debriefed", is(false)));
        mvc.perform(get(P + "/sessions/00000000-0000-0000-0000-000000000000").header("Authorization", qa)).andExpect(status().isNotFound());
        mvc.perform(get(P + "/sessions/" + session + "/notes/00000000-0000-0000-0000-000000000000/defect-draft").header("Authorization", qa))
                .andExpect(status().isUnprocessableEntity());
        // une nouvelle session = une nouvelle tentative
        String second = start();
        mvc.perform(get(P + "/sessions/" + second).header("Authorization", qa)).andExpect(jsonPath("$.attempt", is(2)));
    }

    @Test
    @DisplayName("F-EXP-04 propositions de chartes depuis une exigence ; F-EXP-02 heuristiques extensibles par projet")
    void proposalsAndHeuristics() throws Exception {
        mvc.perform(get(P + "/requirements/REQ-2/charter-proposals").header("Authorization", qa))
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].source", is("CRITERION")))
                .andExpect(jsonPath("$[0].criterionPosition", is(1)))
                .andExpect(jsonPath("$[0].title", is("Explorer « Rechercher un produit » : Les résultats correspondent à la saisie")))
                .andExpect(jsonPath("$[0].requirementKeys", contains("REQ-2")));

        mvc.perform(get(P + "/heuristics").header("Authorization", qa))
                .andExpect(jsonPath("$.suggested", contains("SFDIPOT", "FEW HICCUPPS", "CRUD", "Goldilocks", "Tours de Whittaker")))
                .andExpect(jsonPath("$.custom", hasSize(0)));
        mvc.perform(put(P + "/heuristics").header("Authorization", qa).contentType(MediaType.APPLICATION_JSON)
                        .content(toJson(Map.of("custom", List.of(" RCRCRC ", "rcrcrc", "Persona")))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.custom", contains("RCRCRC", "Persona")));
        mvc.perform(put(P + "/heuristics").header("Authorization", bearer("viewer")).contentType(MediaType.APPLICATION_JSON)
                .content(toJson(Map.of("custom", List.of("x"))))).andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("§5.4 métriques par campagne : sessions, durée, TBS, anomalies par heure, chartes planifiées / exécutées, zones jamais explorées")
    void metrics() throws Exception {
        String session = start();
        JsonNode bug = send(qa, P + "/sessions/" + session + "/notes", Map.of("type", "BUG", "text", "Erreur 500"));
        send(qa, P + "/sessions/" + session + "/notes/" + bug.get("id").asText() + "/defects", Map.of("title", "Erreur 500", "severity", "MAJOR"));
        finish(session);
        send(qa, P + "/sessions/" + session + "/debrief", Map.of("past", "p", "results", "r", "feelings", 4));
        mvc.perform(get(P + "/exploratory/metrics").param("scope", "campaign:CMP-1").header("Authorization", bearer("viewer")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sessions", is(1)))
                .andExpect(jsonPath("$.awaitingApproval", is(1)))
                .andExpect(jsonPath("$.chartersPlanned", is(1)))
                .andExpect(jsonPath("$.chartersExecuted", is(1)))
                .andExpect(jsonPath("$.averageTbs.testPct", is(60.0)))
                .andExpect(jsonPath("$.averageConfidence", is(4.0)))
                .andExpect(jsonPath("$.neverExploredAreas", contains("Tri")));
        mvc.perform(get(P + "/exploratory/metrics").header("Authorization", qa)).andExpect(jsonPath("$.sessions", is(1)));
        mvc.perform(get(P + "/exploratory/metrics").param("scope", "sprint:SPR-9").header("Authorization", qa)).andExpect(status().isNotFound());
    }
}
