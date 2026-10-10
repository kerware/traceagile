package com.traceagile.api.demo;

import com.traceagile.application.campaign.CampaignFolderService;
import com.traceagile.application.campaign.CampaignRepository;
import com.traceagile.application.campaign.CampaignService;
import com.traceagile.application.campaign.CampaignService.CampaignCommand;
import com.traceagile.application.campaign.CampaignService.CampaignPatch;
import com.traceagile.application.campaign.CampaignService.SelectionParams;
import com.traceagile.application.campaign.CampaignService.Strategy;
import com.traceagile.application.defect.DefectService;
import com.traceagile.application.defect.DefectService.DefectCommand;
import com.traceagile.application.defect.DefectService.DefectPatch;
import com.traceagile.application.execution.ExecutionRepository;
import com.traceagile.application.execution.ExecutionService;
import com.traceagile.application.exploratory.ExploratorySessionRepository;
import com.traceagile.application.planning.PlanningService;
import com.traceagile.application.traceability.TraceLinkService;
import com.traceagile.domain.campaign.Campaign;
import com.traceagile.domain.campaign.CampaignItem;
import com.traceagile.domain.campaign.CampaignScope;
import com.traceagile.domain.defect.Defect;
import com.traceagile.domain.defect.DefectDraft;
import com.traceagile.domain.defect.DefectSeverity;
import com.traceagile.domain.defect.DefectStatus;
import com.traceagile.domain.execution.Execution;
import com.traceagile.domain.execution.ExecutionOrigin;
import com.traceagile.domain.execution.ExecutionStatus;
import com.traceagile.domain.execution.StepResult;
import com.traceagile.domain.exploratory.ExploratorySession;
import com.traceagile.domain.exploratory.NoteType;
import com.traceagile.domain.exploratory.Proof;
import com.traceagile.domain.exploratory.Tbs;
import com.traceagile.domain.planning.Sprint;
import com.traceagile.domain.testcase.TestKind;
import com.traceagile.domain.testcase.TestTechnique;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.EnumMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import org.springframework.stereotype.Component;

/**
 * §15.1 campagnes de démonstration (lots 5 et 6), idempotent :
 * <ul>
 *   <li>{@code CMP-1} « Recette SPR-1 », terminée : tout exécuté ; un test manuel échoue (DEF-1,
 *       corrigée puis close) et repasse à la 2ᵉ tentative ; un test automatisé échoue (DEF-2 critique, ouverte) ;</li>
 *   <li>{@code CMP-2} « Recette SPR-2 », en cours : tests affectés à qa1 et qa2, quelques-uns
 *       exécutés (DEF-3 bloquante en cours de correction), le reste à faire (« Mes exécutions ») ;</li>
 *   <li>{@code CMP-3} « Régression 2.0 », planifiée (tests tagués {@code regression}) ;</li>
 *   <li>sessions exploratoires (lot 6) : deux par charte de CMP-1 (la première bloquée), une de qa1
 *       dans CMP-2, toutes débriefées et approuvées par le PO ; celle de qa2 dans CMP-2 attend l'approbation ;</li>
 *   <li>DEF-4 mineure, DEF-5 rejetée, DEF-6 sans exigence (orphelins F-TRA-06).</li>
 * </ul>
 */
@Component
public class DemoCampaignLoader {

    private final CampaignService campaigns;
    private final CampaignRepository campaignRepository;
    private final ExecutionRepository executions;
    private final ExecutionService executionService;
    private final DefectService defects;
    private final PlanningService planning;
    private final TraceLinkService links;
    private final CampaignFolderService folders;
    private final ExploratorySessionRepository sessions;

    public DemoCampaignLoader(CampaignService campaigns, CampaignRepository campaignRepository, ExecutionRepository executions,
                              ExecutionService executionService, DefectService defects, PlanningService planning, TraceLinkService links,
                              CampaignFolderService folders, ExploratorySessionRepository sessions) {
        this.sessions = sessions;
        this.links = links;
        this.folders = folders;
        this.campaigns = campaigns;
        this.campaignRepository = campaignRepository;
        this.executions = executions;
        this.executionService = executionService;
        this.defects = defects;
        this.planning = planning;
    }

    public void load(String project) {
        if (campaignRepository.existsByProject_Key(project)) {
            organize(project);
            return;
        }
        Sprint spr1 = planning.sprint(project, "SPR-1");
        Sprint spr2 = planning.sprint(project, "SPR-2");
        sprint1(project, spr1);
        sprint2(project, spr2);
        Campaign regression = campaigns.create(project, new CampaignCommand("Régression 2.0", CampaignScope.REGRESSION, null, null,
                "preprod", "2.0.0", spr2.getEndDate().minusDays(2), spr2.getEndDate()));
        campaigns.select(project, regression.getKey(), Strategy.TAG, params("regression"));

        Defect minor = defects.create(project, new DefectCommand("Infobulle du prix tronquée sur mobile", "Le libellé « TTC » déborde.",
                DefectSeverity.MINOR, null, keysOf(spr2, 1)));
        Defect rejected = defects.create(project, new DefectCommand("Couleur du bouton « Payer » peu contrastée",
                "Contraste conforme après vérification (4,6:1).", DefectSeverity.TRIVIAL, null, List.of()));
        defects.update(project, rejected.getKey(), status(DefectStatus.REJECTED), null);
        defects.create(project, new DefectCommand("Journal applicatif : avertissement au démarrage", "Sans exigence associée.",
                DefectSeverity.MAJOR, "OPS-118", List.of()));
        defects.update(project, minor.getKey(), status(DefectStatus.IN_PROGRESS), null);
        organize(project);
    }

    /**
     * ADR-0018 range les campagnes de démonstration (y compris sur une base créée avant les dossiers) :
     * recettes de sprint et régression sous « Version 2.0 », dossier « Archives » vide.
     */
    void organize(String project) {
        if (!folders.all(project).isEmpty()) {
            return;
        }
        for (Campaign campaign : campaignRepository.findByProject_KeyOrderByKeyNumberDesc(project)) {
            String folder = switch (campaign.getName()) {
                case "Recette SPR-1", "Recette SPR-2" -> "Version 2.0/Recettes de sprint";
                case "Régression 2.0" -> "Version 2.0/Régression";
                default -> null;
            };
            if (folder != null) {
                campaigns.update(project, campaign.getKey(), new CampaignPatch(null, null, null, null, null, Optional.of(folder)), null);
            }
        }
        folders.create(project, "Archives");
    }

    /** CMP-1 terminée sur SPR-1. */
    private void sprint1(String project, Sprint sprint) {
        Campaign campaign = campaigns.create(project, new CampaignCommand("Recette SPR-1", CampaignScope.SPRINT, sprint.getKey(), null,
                "recette", "2.0.0-rc1", null, null));
        campaigns.select(project, campaign.getKey(), Strategy.SPRINT_REQUIREMENTS, params(null));
        Instant clock = at(sprint.getStartDate().plusDays(3));
        boolean manualFailed = false;
        boolean automatedFailed = false;
        int index = 0;
        for (CampaignItem item : campaign.getItems()) {
            clock = clock.plusSeconds(3_600);
            String tester = index++ % 2 == 0 ? "qa1" : "qa2";
            TestKind kind = item.getTestCase().getKind();
            if (kind == TestKind.MANUAL) {
                campaigns.assign(project, item.getId(), tester);
                if (!manualFailed) {
                    manualFailed = true;
                    Execution failed = manual(item, tester, clock, true);
                    Defect defect = defectFrom(project, failed, DefectSeverity.MAJOR);
                    defects.update(project, defect.getKey(), status(DefectStatus.RESOLVED), null);
                    defects.update(project, defect.getKey(), status(DefectStatus.CLOSED), null);
                    clock = clock.plusSeconds(86_400);
                }
                manual(item, tester, clock, false);
            } else if (kind == TestKind.EXPLORATORY) {
                // §15.1 deux sessions débriefées par charte : la première écourtée (bloquée ou partielle), la seconde complète
                campaigns.assign(project, item.getId(), tester);
                boolean search = item.getTestCase().getTitle().contains("recherche");
                session(item, tester, clock, 25, new Tbs(30, 10, 60), List.of(), ExecutionStatus.BLOCKED,
                        List.of(note(NoteType.NOTE, 120, "Index de recherche vide en recette"), note(NoteType.ISSUE, 900, "Jeu de données incomplet : aucun produit avec accent")),
                        new Proof("Mise en place de l'environnement", "Session bloquée : index vide", "Index de recherche non alimenté en recette",
                                "Relancer après réindexation", 2), true);
                clock = clock.plusSeconds(86_400);
                session(item, tester, clock, search ? 55 : 65, search ? new Tbs(70, 20, 10) : new Tbs(75, 15, 10),
                        item.getTestCase().getCharter().getAreas(), ExecutionStatus.PASSED,
                        search ? List.of(note(NoteType.NOTE, 300, "« café » et « cafe » donnent les mêmes résultats"),
                                note(NoteType.QUESTION, 1_500, "Faut-il tolérer deux fautes de frappe ?"),
                                note(NoteType.IDEA, 2_700, "Proposer des suggestions quand il n'y a aucun résultat"))
                                : List.of(note(NoteType.NOTE, 240, "Fiche lisible sur téléphone, images nettes"),
                                note(NoteType.BUG, 1_800, "Infobulle du prix tronquée sur petit écran"),
                                note(NoteType.NOTE, 3_000, "Lecteur d'écran : prix bien annoncé")),
                        new Proof(search ? "Recherche par mot-clé, accents, fautes de frappe" : "Fiche produit sur téléphone et tablette",
                                search ? "Aucun défaut bloquant ; une question sur la tolérance aux fautes" : "Un défaut d'affichage mineur (infobulle)",
                                null, search ? "Explorer les suggestions de recherche\nExplorer le tri des résultats" : "Explorer le zoom des images",
                                search ? 4 : 3), true);
            } else if (!automatedFailed && item.getTestCase().getAutomation().getTechnique() != TestTechnique.BDD
                    && links.requirementsOf(item.getTestCase()).size() == 1) {
                // Un échec qui ne touche qu'une story : SPR-1 reste validé à 75 % (3 stories sur 4).
                automatedFailed = true;
                Execution failed = executionService.record(item, ExecutionOrigin.AUTOMATED, ExecutionStatus.FAILED, "ci", clock,
                        clock.plusSeconds(42), "AssertionError : frais de port attendus 0,00 €, obtenus 4,90 €");
                defectFrom(project, failed, DefectSeverity.CRITICAL);
            } else {
                executionService.record(item, ExecutionOrigin.AUTOMATED, ExecutionStatus.PASSED, "ci", clock, clock.plusSeconds(30), null);
            }
        }
        campaigns.complete(project, campaign.getKey());
    }

    /** CMP-2 en cours sur SPR-2 : une partie exécutée, le reste dans « Mes exécutions ». */
    private void sprint2(String project, Sprint sprint) {
        Campaign campaign = campaigns.create(project, new CampaignCommand("Recette SPR-2", CampaignScope.SPRINT, sprint.getKey(), null,
                "recette", "2.0.0-rc2", null, null));
        campaigns.select(project, campaign.getKey(), Strategy.SPRINT_REQUIREMENTS, params(null));
        campaigns.select(project, campaign.getKey(), Strategy.TAG, params("smoke"));
        Instant clock = at(sprint.getStartDate().plusDays(1));
        // Alternance qa1 / qa2 par nature : chacun a des tests manuels et des chartes. Seul le premier
        // test manuel de chacun est exécuté, pour que « Mes exécutions » en garde à faire pour les deux.
        Map<TestKind, Integer> turns = new EnumMap<>(TestKind.class);
        Set<String> executedBy = new HashSet<>();
        int automated = 0;
        for (CampaignItem item : campaign.getItems()) {
            TestKind kind = item.getTestCase().getKind();
            if (kind == TestKind.AUTOMATED) {
                if (automated++ < 4) {
                    executionService.record(item, ExecutionOrigin.AUTOMATED, ExecutionStatus.PASSED, "ci", clock, clock.plusSeconds(25), null);
                }
                continue;
            }
            int turn = turns.merge(kind, 1, Integer::sum) - 1;
            String tester = turn % 2 == 0 ? "qa1" : "qa2";
            campaigns.assign(project, item.getId(), tester);
            if (kind == TestKind.EXPLORATORY) {
                // qa1 : session débriefée et approuvée ; qa2 : session terminée, débriefing à approuver
                clock = clock.plusSeconds(10_800);
                boolean approved = tester.equals("qa1");
                session(item, tester, clock, approved ? 110 : 80, approved ? new Tbs(60, 30, 10) : new Tbs(55, 25, 20),
                        item.getTestCase().getCharter().getAreas().stream().limit(1).toList(), ExecutionStatus.PASSED,
                        List.of(note(NoteType.NOTE, 600, "Parcours nominal sans anomalie"),
                                note(NoteType.QUESTION, 2_400, "Comportement attendu après expiration de session ?"),
                                note(NoteType.IDEA, 3_900, "Tester avec deux onglets ouverts")),
                        new Proof("Parcours nominal puis cas d'erreur", "Pas de défaut, une question ouverte", null,
                                "Explorer l'expiration de session", approved ? 4 : 3), approved);
                continue;
            }
            if (kind == TestKind.MANUAL && executedBy.add(tester)) {
                clock = clock.plusSeconds(7_200);
                boolean fail = tester.equals("qa2");
                Execution execution = manual(item, tester, clock, fail);
                if (fail) {
                    Defect blocker = defectFrom(project, execution, DefectSeverity.BLOCKER);
                    defects.update(project, blocker.getKey(), status(DefectStatus.IN_PROGRESS), null);
                }
            }
        }
    }

    private record DemoNote(NoteType type, long offsetSeconds, String text) {
    }

    private static DemoNote note(NoteType type, long offsetSeconds, String text) {
        return new DemoNote(type, offsetSeconds, text);
    }

    /** §5.2 session rejouée à une date passée : notes, fin, débriefing, approbation par le PO si {@code approved}. */
    private void session(CampaignItem item, String tester, Instant start, int minutes, Tbs tbs, List<String> areas, ExecutionStatus status,
                         List<DemoNote> notes, Proof proof, boolean approved) {
        ExploratorySession session = ExploratorySession.start(item, tester, start);
        notes.forEach(n -> session.addNote(n.type(), n.text(), start.plusSeconds(n.offsetSeconds())));
        Instant end = start.plusSeconds(minutes * 60L);
        session.finish(tbs, areas, status, end);
        session.debrief(proof, tester, end.plusSeconds(1_800));
        if (approved) {
            session.approve("po", end.plusSeconds(7_200));
        }
        sessions.save(session);
    }

    /** Exécution pas à pas rejouée à une date passée ; {@code fail} : le dernier pas échoue. */
    private Execution manual(CampaignItem item, String tester, Instant start, boolean fail) {
        Execution execution = Execution.manual(item, tester, start, null, null);
        Instant clock = start;
        List<StepResult> steps = execution.getSteps();
        for (StepResult step : steps) {
            clock = clock.plusSeconds(90);
            boolean last = step.getPosition() == steps.getLast().getPosition();
            execution.recordStep(step.getPosition(), fail && last ? ExecutionStatus.FAILED : ExecutionStatus.PASSED,
                    fail && last ? "Le résultat diffère de l'attendu (voir capture)." : null, clock);
        }
        return executions.save(execution);
    }

    private Defect defectFrom(String project, Execution execution, DefectSeverity severity) {
        DefectDraft draft = DefectDraft.from(execution);
        return defects.createFromExecution(project, execution.getId(), new DefectCommand(draft.title(), draft.description(), severity, null, null));
    }

    private static List<String> keysOf(Sprint sprint, int count) {
        return sprint.requirements().stream().limit(count).map(r -> r.getKey()).toList();
    }

    private static SelectionParams params(String tag) {
        return new SelectionParams(null, tag, null, null, null);
    }

    private static DefectPatch status(DefectStatus status) {
        return new DefectPatch(null, null, null, Optional.of(status), null, null);
    }

    private static Instant at(LocalDate date) {
        return date.atTime(9, 0).toInstant(ZoneOffset.UTC);
    }
}
