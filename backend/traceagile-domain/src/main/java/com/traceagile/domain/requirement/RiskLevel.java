package com.traceagile.domain.requirement;

/** §3.2 RiskLevel ; poids 1, 2, 4, 8 pour la couverture pondérée (§7.2). */
public enum RiskLevel {
    LOW(1),
    MEDIUM(2),
    HIGH(4),
    CRITICAL(8);

    private final int weight;

    RiskLevel(int weight) {
        this.weight = weight;
    }

    public int weight() {
        return weight;
    }
}
