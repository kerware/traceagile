package com.traceagile.api;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.traceagile.application.planning.PlanningService;
import com.traceagile.application.planning.PlanningService.ReleaseCommand;
import com.traceagile.application.planning.PlanningService.SprintCommand;
import com.traceagile.application.planning.SprintRepository;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.administration.ProjectRole;
import com.traceagile.domain.planning.Sprint;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementStatus;
import com.traceagile.domain.requirement.RequirementType;
import com.traceagile.domain.testcase.TestCase;
import com.traceagile.domain.testcase.TestCaseStatus;
import com.traceagile.domain.traceability.LinkOrigin;
import com.traceagile.domain.traceability.LinkType;
import com.traceagile.domain.traceability.TraceLink;
import jakarta.persistence.EntityManager;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * §14 NF-01, NF-02, NF-03 banc de mesure (ADR-0024) sur le volume de référence : 5 000 exigences et
 * 10 000 tests ; une release de 500 exigences couvertes par 1 000 tests. Lancé à part :
 * {@code mvn -Pperf -pl traceagile-api -am verify -Dsurefire.failIfNoSpecifiedTests=false}. Les
 * mesures passent par la pile Spring complète (sécurité, sérialisation) via MockMvc, sans le réseau ;
 * résultats dans {@code target/nf-benchmark.md}.
 */
@Tag("perf")
@TestPropertySource(properties = {"spring.jpa.properties.hibernate.jdbc.batch_size=500", "spring.jpa.properties.hibernate.order_inserts=true",
        "spring.jpa.properties.hibernate.generate_statistics=true"})
class PerformanceBenchmarkTest extends AbstractApiTest {

    static final String P = "/api/v1/projects/PERF";
    /** Échelle du jeu ({@code -Dperf.scale=0.2} pour un diagnostic rapide) ; 1 = volume du §14. */
    static final double SCALE = Double.parseDouble(System.getProperty("perf.scale", "1"));
    static final int FEATURES = 50;
    static final int REQUIREMENTS = (int) (5_000 * SCALE);
    static final int TESTS = (int) (10_000 * SCALE);
    static final int RELEASE_SCOPE = (int) (500 * SCALE);
    static final int RELEASE_TESTS = (int) (1_000 * SCALE);

    @Autowired
    EntityManager em;
    @Autowired
    TransactionTemplate transactions;
    @Autowired
    PlanningService planning;
    @Autowired
    SprintRepository sprints;

    final Map<String, String> results = new LinkedHashMap<>();

    @Test
    @DisplayName("§14 NF-01 lectures paginées p95, NF-02 matrice d'une release (500 × 1 000), NF-03 PDF du bilan de release")
    void benchmark() throws Exception {
        user("perf", false);
        project("PERF", Map.of("perf", ProjectRole.ADMINISTRATOR));
        String token;
        long start = System.nanoTime();
        List<UUID> stories = generate();
        results.put("Génération du jeu (5 000 exigences, 10 000 tests, 10 000 liens)", millis(start) + " ms");

        // Diagnostic : requêtes SQL d'un appel au backlog
        org.hibernate.stat.Statistics stats = em.getEntityManagerFactory().unwrap(org.hibernate.SessionFactory.class).getStatistics();
        stats.clear();
        long t0 = System.nanoTime();
        mvc.perform(get(P + "/requirements?page=0&size=50").header("Authorization", bearer("perf"))).andExpect(status().isOk());
        System.out.println("NF-DIAG backlog " + millis(t0) + " ms, requêtes " + stats.getPrepareStatementCount() + ", entités chargées "
                + stats.getEntityLoadCount() + ", collections " + stats.getCollectionFetchCount() + ", plus lente : " + stats.getQueryExecutionMaxTimeQueryString()
                + " (" + stats.getQueryExecutionMaxTime() + " ms)");
        if (Boolean.getBoolean("perf.diagnostic")) {
            return;
        }

        // NF-01 p95 des lectures paginées (après 10 appels de chauffe) ; un jeton neuf par mesure (durée de vie de 15 min)
        p95(bearer("perf"), "NF-01 backlog paginé (50 / page)", i -> P + "/requirements?page=" + (i % 100) + "&size=50");
        p95(bearer("perf"), "NF-01 tests paginés (50 / page)", i -> P + "/test-cases?page=" + (i % 200) + "&size=50");
        p95(bearer("perf"), "NF-01 recherche plein texte du backlog", i -> P + "/requirements?q=story%20" + (i * 37 % REQUIREMENTS) + "&size=50");
        p95(bearer("perf"), "NF-01 recherche globale Ctrl+K", i -> P + "/search?q=story%20" + (i * 53 % REQUIREMENTS));

        // NF-02 matrice de la release
        token = bearer("perf");
        long best = Long.MAX_VALUE;
        long worst = 0;
        for (int i = 0; i < 5; i++) {
            long t = System.nanoTime();
            mvc.perform(get(P + "/traceability/matrix").param("scope", "release:REL-1").param("tests", "linked").header("Authorization", token))
                    .andExpect(status().isOk());
            long ms = millis(t);
            best = Math.min(best, ms);
            worst = Math.max(worst, ms);
        }
        results.put("NF-02 matrice release 500 × 1 000 (5 appels, pire / meilleur)", worst + " ms / " + best + " ms");

        // NF-03 PDF du bilan de release
        token = bearer("perf");
        long pdfWorst = 0;
        for (int i = 0; i < 3; i++) {
            long t = System.nanoTime();
            mvc.perform(get(P + "/releases/REL-1/report").param("format", "pdf").header("Authorization", token)).andExpect(status().isOk());
            pdfWorst = Math.max(pdfWorst, millis(t));
        }
        results.put("NF-03 PDF du bilan de release (3 appels, pire)", pdfWorst + " ms");

        StringBuilder report = new StringBuilder("| Mesure | Résultat |\n| --- | --- |\n");
        results.forEach((k, v) -> report.append("| ").append(k).append(" | ").append(v).append(" |\n"));
        Path out = Path.of("target", "nf-benchmark.md");
        Files.writeString(out, report.toString(), StandardCharsets.UTF_8);
        System.out.println(report);
        assertThat(stories).hasSize(REQUIREMENTS - FEATURES);
    }

    interface Url {
        String at(int i);
    }

    private void p95(String token, String label, Url url) throws Exception {
        for (int i = 0; i < 10; i++) {
            mvc.perform(get(url.at(i)).header("Authorization", token)).andExpect(status().isOk());
        }
        long[] times = new long[60];
        for (int i = 0; i < times.length; i++) {
            long t = System.nanoTime();
            mvc.perform(get(url.at(i + 10)).header("Authorization", token)).andExpect(status().isOk());
            times[i] = millis(t);
        }
        Arrays.sort(times);
        results.put(label + " — p95 (60 appels)", times[(int) Math.ceil(times.length * 0.95) - 1] + " ms (médiane " + times[times.length / 2] + " ms)");
        System.out.println("NF-BENCH " + label + " p95 " + times[(int) Math.ceil(times.length * 0.95) - 1] + " ms");
    }

    private static long millis(long start) {
        return (System.nanoTime() - start) / 1_000_000;
    }

    /** 50 features, 4 950 stories (les 500 premières prêtes et dans SPR-1 de REL-1), 10 000 tests liés. */
    private List<UUID> generate() throws IOException {
        Project project = transactions.execute(s -> em.createQuery("select p from Project p where p.key = 'PERF'", Project.class).getSingleResult());
        List<UUID> featureIds = new ArrayList<>();
        List<UUID> storyIds = new ArrayList<>();
        transactions.executeWithoutResult(s -> {
            Project p = em.merge(project);
            for (int f = 1; f <= FEATURES; f++) {
                Requirement feature = new Requirement(p, "REQ-" + f, RequirementType.FEATURE, "Feature " + f, rank(f));
                em.persist(feature);
                featureIds.add(feature.getId());
            }
        });
        for (int from = FEATURES + 1; from <= REQUIREMENTS; from += 500) {
            int first = from;
            transactions.executeWithoutResult(s -> {
                Project p = em.merge(project);
                for (int n = first; n < Math.min(first + 500, REQUIREMENTS + 1); n++) {
                    Requirement story = new Requirement(p, "REQ-" + n, RequirementType.USER_STORY, "Story " + n, rank(n));
                    story.moveUnder(em.getReference(Requirement.class, featureIds.get(n % FEATURES)));
                    story.estimate(3);
                    story.addCriterion(com.traceagile.domain.requirement.CriterionFormat.TEXT, "Le résultat attendu est obtenu");
                    if (n <= FEATURES + RELEASE_SCOPE) {
                        story.changeStatus(RequirementStatus.READY);
                    }
                    em.persist(story);
                    storyIds.add(story.getId());
                }
                em.flush();
                em.clear();
            });
        }
        planning.createRelease("PERF", new ReleaseCommand("Version perf", null, LocalDate.of(2026, 10, 1), LocalDate.of(2026, 12, 31)));
        planning.createSprint("PERF", new SprintCommand("Sprint perf", null, LocalDate.of(2026, 10, 1), LocalDate.of(2026, 10, 14), null, "REL-1"));
        transactions.executeWithoutResult(s -> {
            Sprint sprint = sprints.findByProject_KeyAndKey("PERF", "SPR-1").orElseThrow();
            List<Requirement> scope = storyIds.subList(0, RELEASE_SCOPE).stream().map(id -> em.find(Requirement.class, id)).toList();
            sprint.replaceScope(scope);
        });
        for (int from = 1; from <= TESTS; from += 500) {
            int first = from;
            transactions.executeWithoutResult(s -> {
                Project p = em.merge(project);
                for (int n = first; n < Math.min(first + 500, TESTS + 1); n++) {
                    TestCase test = TestCase.manual(p, "TC-" + n, "Test " + n);
                    test.addStep("Agir", "Résultat", null);
                    test.changeStatus(TestCaseStatus.READY);
                    em.persist(test);
                    // les 1 000 premiers tests couvrent les 500 exigences de la release (2 par exigence) ; les autres le reste du backlog
                    UUID target = n <= RELEASE_TESTS ? storyIds.get((n - 1) / 2) : storyIds.get(RELEASE_SCOPE + (n % (storyIds.size() - RELEASE_SCOPE)));
                    em.persist(TraceLink.testToRequirement(p, test.getId(), target, LinkType.VERIFIES, LinkOrigin.MANUAL));
                }
                em.flush();
                em.clear();
            });
        }
        return storyIds;
    }

    private static String rank(int n) {
        return String.format("b%06d", n);
    }
}
