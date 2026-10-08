package com.traceagile.application.common;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** F-REQ-23 lecture et écriture CSV (RFC 4180, séparateur « ; » ou « , »). */
class CsvTest {

    @Test
    @DisplayName("F-REQ-23 détecte le séparateur, gère guillemets, retours à la ligne et BOM")
    void parse() {
        String csv = "﻿type;title;criteria\r\n"
                + "USER_STORY;\"Payer; vite\";\"Ligne 1\nLigne 2\"\r\n"
                + "EPIC;\"Dit \"\"bonjour\"\"\";\n";

        List<List<String>> rows = Csv.parse(csv);

        assertThat(rows).containsExactly(
                List.of("type", "title", "criteria"),
                List.of("USER_STORY", "Payer; vite", "Ligne 1\nLigne 2"),
                List.of("EPIC", "Dit \"bonjour\"", ""));
    }

    @Test
    @DisplayName("F-REQ-23 accepte aussi la virgule")
    void comma() {
        assertThat(Csv.parse("a,b\n1,\"2,5\"")).containsExactly(List.of("a", "b"), List.of("1", "2,5"));
    }

    @Test
    @DisplayName("F-REQ-23 ignore les lignes vides")
    void blankLines() {
        assertThat(Csv.parse("a;b\n\n1;2\n\n")).hasSize(2);
    }

    @Test
    @DisplayName("F-REQ-23 guillemet non fermé → CSV_MALFORMED")
    void unclosedQuote() {
        assertThatThrownBy(() -> Csv.parse("a;b\n\"1;2\n"))
                .isInstanceOf(UnprocessableException.class)
                .extracting("code").isEqualTo("CSV_MALFORMED");
    }

    @Test
    @DisplayName("F-REQ-23 écriture : « ; », guillemets si nécessaire, BOM pour Excel")
    void write() {
        String csv = Csv.write(List.of(List.of("key", "title"), List.of("REQ-1", "Payer; \"vite\"")));

        assertThat(csv).isEqualTo("﻿key;title\r\nREQ-1;\"Payer; \"\"vite\"\"\"\r\n");
    }
}
