package com.traceagile.application.requirement;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.traceagile.application.common.UnprocessableException;
import com.traceagile.application.requirement.RequirementService.CreateRequirementCommand;
import com.traceagile.domain.administration.Project;
import com.traceagile.domain.common.BusinessRuleException;
import com.traceagile.domain.requirement.CriterionFormat;
import com.traceagile.domain.requirement.Priority;
import com.traceagile.domain.requirement.Requirement;
import com.traceagile.domain.requirement.RequirementType;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

/** F-REQ-23 import CSV d'exigences et export CSV du backlog filtré. */
@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class RequirementCsvServiceTest {

    static final String HEADER = "type;parent key;title;asA;iWant;soThat;priority;points;tags;acceptance criteria\n";

    @Mock
    RequirementService requirements;

    RequirementCsvService service;
    Project shop = new Project("SHOP", "Boutique", null);
    List<CreateRequirementCommand> created = new ArrayList<>();
    int counter = 100;

    @BeforeEach
    void setUp() {
        service = new RequirementCsvService(requirements);
        when(requirements.create(eq("SHOP"), any())).thenAnswer(inv -> {
            CreateRequirementCommand command = inv.getArgument(1);
            created.add(command);
            return new Requirement(shop, "REQ-" + (++counter), command.type(), command.title(), "i");
        });
    }

    @Test
    @DisplayName("F-REQ-23 colonnes de la spec ; critères séparés par || ; Gherkin détecté")
    void importRows() {
        String csv = HEADER
                + "EPIC;;Panier et commande;;;;MUST;;panier;\n"
                + "USER_STORY;REQ-7;Livraison gratuite;client;la livraison offerte dès 50 €;commander plus;SHOULD;5;panier, promo;"
                + "\"Le seuil est affiché || Scénario: seuil atteint\n  Étant donné un panier de 50 €\n  Alors la livraison est offerte\"\n";

        List<String> keys = service.importCsv("SHOP", csv);

        assertThat(keys).containsExactly("REQ-101", "REQ-102");
        CreateRequirementCommand story = created.get(1);
        assertThat(story.type()).isEqualTo(RequirementType.USER_STORY);
        assertThat(story.parentKey()).isEqualTo("REQ-7");
        assertThat(story.details().asA()).contains("client");
        assertThat(story.details().priority()).contains(Priority.SHOULD);
        assertThat(story.details().storyPoints()).contains(5);
        assertThat(story.details().tags()).contains(List.of("panier", "promo"));
        assertThat(story.criteria()).extracting(RequirementService.CriterionDraft::format)
                .containsExactly(CriterionFormat.TEXT, CriterionFormat.GHERKIN);
        assertThat(story.criteria().get(1).content()).startsWith("Scénario: seuil atteint");
    }

    @Test
    @DisplayName("F-REQ-23 un parent peut être une ligne précédente du fichier (colonne key facultative)")
    void parentFromSameFile() {
        String csv = "key;" + HEADER
                + "X-1;EPIC;;Catalogue;;;;;;;\n"
                + "X-2;FEATURE;X-1;Recherche;;;;;;;\n";

        service.importCsv("SHOP", csv);

        assertThat(created.get(1).parentKey()).isEqualTo("REQ-101");
    }

    @Test
    @DisplayName("F-REQ-23 tout ou rien : les erreurs sont listées par ligne")
    void errorsByLine() {
        when(requirements.create(eq("SHOP"), any())).thenAnswer(inv -> {
            CreateRequirementCommand command = inv.getArgument(1);
            if (command.title().equals("Sans parent")) {
                throw new BusinessRuleException("REQ_PARENT_REQUIRED", "Une USER_STORY doit avoir un parent FEATURE ou EPIC.");
            }
            return new Requirement(shop, "REQ-" + (++counter), command.type(), command.title(), "i");
        });
        String csv = HEADER
                + "EPIC;;Catalogue;;;;;;;\n"
                + "LEGENDE;;Type inconnu;;;;;;;\n"
                + "USER_STORY;;Sans parent;;;;;;;\n"
                + "USER_STORY;REQ-1;Points faux;;;;;quatre;;\n";

        assertThatThrownBy(() -> service.importCsv("SHOP", csv))
                .isInstanceOf(UnprocessableException.class)
                .satisfies(e -> {
                    UnprocessableException ex = (UnprocessableException) e;
                    assertThat(ex.getCode()).isEqualTo("CSV_INVALID");
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> errors = (List<Map<String, Object>>) ex.getDetails().get("lineErrors");
                    assertThat(errors).extracting(m -> m.get("line")).containsExactly(3, 4, 5);
                });
    }

    @Test
    @DisplayName("F-REQ-23 en-tête obligatoire : colonnes type et title")
    void missingColumns() {
        assertThatThrownBy(() -> service.importCsv("SHOP", "titre;description\nA;B\n"))
                .extracting("code").isEqualTo("CSV_HEADER_INVALID");
        verify(requirements, never()).create(any(), any());
    }

    @Test
    @DisplayName("F-REQ-23 export : mêmes colonnes que l'import, précédées de la clé, suivies du statut et du risque")
    void export() {
        Requirement epic = new Requirement(shop, "REQ-1", RequirementType.EPIC, "Catalogue", "a");
        Requirement feature = new Requirement(shop, "REQ-2", RequirementType.FEATURE, "Recherche", "b");
        feature.moveUnder(epic);
        feature.setTags(List.of("recherche", "seo"));
        feature.addCriterion(CriterionFormat.TEXT, "A");
        feature.addCriterion(CriterionFormat.TEXT, "B");
        when(requirements.search(eq("SHOP"), any(), any())).thenReturn(new org.springframework.data.domain.PageImpl<>(List.of(epic, feature)));

        String csv = service.exportCsv("SHOP", RequirementFilter.NONE);

        assertThat(csv.lines().toList()).containsExactly(
                "﻿key;type;parent key;title;asA;iWant;soThat;priority;points;tags;acceptance criteria;status;risk",
                "REQ-1;EPIC;;Catalogue;;;;SHOULD;;;;DRAFT;MEDIUM",
                "REQ-2;FEATURE;REQ-1;Recherche;;;;SHOULD;;\"recherche, seo\";A || B;DRAFT;MEDIUM");
        ArgumentCaptor<RequirementFilter> filter = ArgumentCaptor.forClass(RequirementFilter.class);
        verify(requirements).search(eq("SHOP"), filter.capture(), any());
    }
}
