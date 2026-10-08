package com.traceagile.domain.traceability;

/** F-TRA-02 type de lien ; RELATES_TO est informatif et ne compte pas dans la couverture. */
public enum LinkType {
    VERIFIES,
    PARTIALLY_VERIFIES,
    RELATES_TO;

    public boolean countsForCoverage() {
        return this != RELATES_TO;
    }
}
