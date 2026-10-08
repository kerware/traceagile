package com.traceagile.domain.common;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** F-REQ-03 Rang lexicographique (type LexoRank) : insérer sans renuméroter la liste. */
class RankTest {

    @Test
    @DisplayName("F-REQ-03 premier rang d'une liste vide : milieu de l'alphabet")
    void firstRank() {
        assertThat(Rank.between(null, null)).isEqualTo("i");
    }

    @Test
    @DisplayName("F-REQ-03 un rang inséré est strictement entre ses voisins")
    void strictlyBetween() {
        assertThat(Rank.between("a", "c")).isEqualTo("b");
        assertThat(Rank.between("a", "b")).isGreaterThan("a").isLessThan("b");
        assertThat(Rank.between("az", "b")).isGreaterThan("az").isLessThan("b");
        assertThat(Rank.between("a", "a1")).isGreaterThan("a").isLessThan("a1");
    }

    @Test
    @DisplayName("F-REQ-03 en tête et en fin de liste")
    void beforeFirstAndAfterLast() {
        assertThat(Rank.between(null, "i")).isLessThan("i");
        assertThat(Rank.between("i", null)).isGreaterThan("i");
        assertThat(Rank.between("z", null)).isGreaterThan("z");
        assertThat(Rank.between(null, "01")).isLessThan("01");
    }

    @Test
    @DisplayName("F-REQ-03 un rang ne se termine jamais par 0 : on peut toujours insérer devant")
    void neverEndsWithZero() {
        String rank = "1";
        for (int i = 0; i < 50; i++) {
            rank = Rank.between(null, rank);
            assertThat(rank).doesNotEndWith("0");
        }
    }

    @Test
    @DisplayName("F-REQ-03 bornes inversées → erreur")
    void rejectsInvertedBounds() {
        assertThatThrownBy(() -> Rank.between("b", "a")).isInstanceOf(IllegalArgumentException.class);
        assertThatThrownBy(() -> Rank.between("b", "b")).isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("F-REQ-03 1 000 insertions aléatoires conservent l'ordre voulu")
    void randomInsertionsKeepOrder() {
        Random random = new Random(42);
        List<String> ranks = new ArrayList<>();
        for (int i = 0; i < 1000; i++) {
            int position = random.nextInt(ranks.size() + 1);
            String lower = position == 0 ? null : ranks.get(position - 1);
            String upper = position == ranks.size() ? null : ranks.get(position);
            ranks.add(position, Rank.between(lower, upper));
        }
        assertThat(ranks).isSorted().doesNotHaveDuplicates();
        assertThat(ranks).allMatch(r -> r.length() < 40);
    }
}
