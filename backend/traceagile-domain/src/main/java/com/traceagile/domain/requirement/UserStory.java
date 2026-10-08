package com.traceagile.domain.requirement;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

/** §3.1 userStory {asA, iWant, soThat} ; F-REQ-05 phrase guidée. */
@Embeddable
public record UserStory(
        @Column(name = "story_as_a", length = 500) String asA,
        @Column(name = "story_i_want", length = 2000) String iWant,
        @Column(name = "story_so_that", length = 2000) String soThat) {

    public static final UserStory EMPTY = new UserStory(null, null, null);

    public UserStory {
        asA = blankToNull(asA);
        iWant = blankToNull(iWant);
        soThat = blankToNull(soThat);
    }

    public boolean isEmpty() {
        return asA == null && iWant == null && soThat == null;
    }

    /** « En tant que client, je veux payer afin de recevoir ma commande. » */
    public String sentence() {
        if (isEmpty()) {
            return "";
        }
        StringBuilder sentence = new StringBuilder("En tant que ").append(asA == null ? "…" : asA)
                .append(", je veux ").append(iWant == null ? "…" : iWant);
        if (soThat != null) {
            sentence.append(" afin de ").append(soThat);
        }
        return sentence.append('.').toString();
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.strip();
    }
}
