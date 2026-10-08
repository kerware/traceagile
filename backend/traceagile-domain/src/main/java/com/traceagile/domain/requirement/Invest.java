package com.traceagile.domain.requirement;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.util.stream.Stream;

/** F-REQ-07 Indicateur INVEST : six cases cochées par le PO ou le testeur. */
@Embeddable
public record Invest(
        @Column(name = "invest_independent", nullable = false) boolean independent,
        @Column(name = "invest_negotiable", nullable = false) boolean negotiable,
        @Column(name = "invest_valuable", nullable = false) boolean valuable,
        @Column(name = "invest_estimable", nullable = false) boolean estimable,
        @Column(name = "invest_small", nullable = false) boolean small,
        @Column(name = "invest_testable", nullable = false) boolean testable) {

    public static final Invest NONE = new Invest(false, false, false, false, false, false);

    public long checkedCount() {
        return Stream.of(independent, negotiable, valuable, estimable, small, testable).filter(b -> b).count();
    }

    public boolean isComplete() {
        return checkedCount() == 6;
    }
}
