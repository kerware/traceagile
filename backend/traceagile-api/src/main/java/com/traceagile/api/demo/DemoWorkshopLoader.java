package com.traceagile.api.demo;

import com.traceagile.application.attachment.AttachmentService;
import com.traceagile.application.defect.DefectRepository;
import com.traceagile.application.requirement.NfrMeasurementService;
import com.traceagile.application.requirement.RequirementService;
import com.traceagile.application.requirement.WorkshopService;
import com.traceagile.domain.attachment.Attachment;
import com.traceagile.domain.defect.DefectSeverity;
import com.traceagile.domain.requirement.ExampleCard;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementType;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.util.Optional;
import org.springframework.stereotype.Component;

/**
 * §15.1 jeu de démonstration du lot 9 (ADR-0024), idempotent : atelier Example Mapping sur la story
 * « Choisir le mode de livraison » (règles, exemples, une question ouverte et une résolue ; aucune
 * conversion : elle rendrait les tests de la story suspects, §3.3-7), commentaires citant des clés, valeurs mesurées des ENF, capture jointe à l'anomalie
 * bloquante.
 */
@Component
public class DemoWorkshopLoader {

    static final String STORY = "Choisir le mode de livraison";

    private final RequirementService requirements;
    private final WorkshopService workshop;
    private final NfrMeasurementService measurements;
    private final AttachmentService attachments;
    private final DefectRepository defects;

    public DemoWorkshopLoader(RequirementService requirements, WorkshopService workshop, NfrMeasurementService measurements,
                              AttachmentService attachments, DefectRepository defects) {
        this.requirements = requirements;
        this.workshop = workshop;
        this.measurements = measurements;
        this.attachments = attachments;
        this.defects = defects;
    }

    public void load(String project) {
        Optional<Requirement> story = byTitle(project, RequirementType.USER_STORY, STORY);
        if (story.isEmpty() || !workshop.comments(project, story.get().getKey()).isEmpty()) {
            return;
        }
        String key = story.get().getKey();
        ExampleCard relay = workshop.addCard(project, key, ExampleCard.Kind.RULE, null, "Le point relais est choisi sur une carte, à moins de 10 km");
        ExampleCard home = workshop.addCard(project, key, ExampleCard.Kind.RULE, null, "La livraison à domicile coûte 4,90 € sous 50 € d'achat");
        workshop.addCard(project, key, ExampleCard.Kind.EXAMPLE, relay.getId(),
                "Adresse à Lyon : les 3 points relais les plus proches sont proposés");
        workshop.addCard(project, key, ExampleCard.Kind.EXAMPLE, relay.getId(), "Adresse en zone rurale sans relais à moins de 10 km : message explicite");
        workshop.addCard(project, key, ExampleCard.Kind.EXAMPLE, home.getId(), "Panier de 49,99 € : 4,90 € de frais");
        workshop.addComment(project, key, "qa1", "Que propose-t-on si le point relais choisi ferme avant la livraison ?", true);
        var resolved = workshop.addComment(project, key, "qa2", "Les lockers comptent-ils comme points relais ?", true);
        workshop.resolve(project, resolved.getId(), "po", true);
        String rule = byTitle(project, RequirementType.BUSINESS_RULE, "Livraison gratuite dès 50 € d'achat").map(Requirement::getKey)
                .orElse("la règle métier de livraison gratuite");
        workshop.addComment(project, key, "po", "Oui pour les lockers. La gratuité suit " + rule + " ; la campagne de régression CMP-3 la vérifie.",
                false);

        // F-REQ-18 valeurs mesurées : temps de réponse (seuil respecté), disponibilité (cible atteinte)
        byTitle(project, RequirementType.NON_FUNCTIONAL, "Temps de réponse des pages").ifPresent(r -> {
            measurements.record(project, r.getKey(), 1180);
            measurements.record(project, r.getKey(), 950);
        });
        byTitle(project, RequirementType.NON_FUNCTIONAL, "Disponibilité du tunnel de commande")
                .ifPresent(r -> measurements.record(project, r.getKey(), 99.93));

        // F-EXE-03 capture jointe à l'anomalie bloquante
        defects.findByProject_KeyOrderByKeyNumberDesc(project).stream().filter(d -> d.getSeverity() == DefectSeverity.BLOCKER).findFirst()
                .ifPresent(d -> attachments.upload(project, Attachment.Target.DEFECT, d.getId(), "capture-paiement-refuse.png", capture()));
    }

    private Optional<Requirement> byTitle(String project, RequirementType type, String title) {
        return requirements.backlog(project).stream().filter(r -> r.getType() == type && r.getTitle().equals(title)).findFirst();
    }

    private byte[] capture() {
        try (InputStream in = getClass().getResourceAsStream("/demo/capture-paiement-refuse.png")) {
            return in == null ? new byte[0] : in.readAllBytes();
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }
}
