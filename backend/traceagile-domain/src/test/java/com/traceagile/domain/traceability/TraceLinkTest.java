package com.traceagile.domain.traceability;

import static org.assertj.core.api.Assertions.assertThat;

import com.traceagile.domain.administration.Project;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** §3.1 TraceLink ; F-TRA-02 types de lien. */
class TraceLinkTest {

    @Test
    @DisplayName("F-TRA-02 VERIFIES et PARTIALLY_VERIFIES comptent dans la couverture, RELATES_TO non")
    void coverage() {
        assertThat(LinkType.VERIFIES.countsForCoverage()).isTrue();
        assertThat(LinkType.PARTIALLY_VERIFIES.countsForCoverage()).isTrue();
        assertThat(LinkType.RELATES_TO.countsForCoverage()).isFalse();
    }

    @Test
    @DisplayName("§3.1 un lien relie un test à une exigence ou à un critère, avec son origine")
    void link() {
        UUID test = UUID.randomUUID();
        UUID requirement = UUID.randomUUID();
        TraceLink link = TraceLink.testToRequirement(new Project("SHOP", "Boutique", null), test, requirement,
                LinkType.VERIFIES, LinkOrigin.GHERKIN_TAG);

        assertThat(link.getSourceType()).isEqualTo(TraceEntityType.TEST_CASE);
        assertThat(link.getTargetType()).isEqualTo(TraceEntityType.REQUIREMENT);
        assertThat(link.getSourceId()).isEqualTo(test);
        assertThat(link.getTargetId()).isEqualTo(requirement);
        assertThat(link.getOrigin()).isEqualTo(LinkOrigin.GHERKIN_TAG);
    }

    @Test
    @DisplayName("§3.3-7 une modification de l'exigence rend le lien suspect jusqu'à sa revue")
    void suspicion() {
        TraceLink link = TraceLink.testToRequirement(new Project("SHOP", "Boutique", null), UUID.randomUUID(), UUID.randomUUID(),
                LinkType.VERIFIES, LinkOrigin.MANUAL);
        assertThat(link.isSuspect()).isFalse();

        link.markSuspect(java.time.Instant.parse("2026-10-09T10:00:00Z"));
        assertThat(link.isSuspect()).isTrue();
        assertThat(link.getSuspectSince()).isEqualTo(java.time.Instant.parse("2026-10-09T10:00:00Z"));

        link.markSuspect(java.time.Instant.parse("2026-10-10T10:00:00Z"));
        assertThat(link.getSuspectSince()).as("la première modification fait foi").isEqualTo(java.time.Instant.parse("2026-10-09T10:00:00Z"));

        link.clearSuspicion();
        assertThat(link.isSuspect()).isFalse();
        assertThat(link.getSuspectSince()).isNull();
    }
}
