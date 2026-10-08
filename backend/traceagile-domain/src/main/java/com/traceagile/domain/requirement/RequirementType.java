package com.traceagile.domain.requirement;

import java.util.EnumSet;
import java.util.Set;

/** §3.2 RequirementType, avec les règles de parenté du §3.3-1 (ADR-0009 pour TECHNICAL_ENABLER). */
public enum RequirementType {
    EPIC,
    FEATURE,
    USER_STORY,
    BUSINESS_RULE,
    NON_FUNCTIONAL,
    TECHNICAL_ENABLER;

    /** Types de parent autorisés. */
    public Set<RequirementType> allowedParents() {
        return switch (this) {
            case EPIC -> EnumSet.noneOf(RequirementType.class);
            case FEATURE -> EnumSet.of(EPIC);
            case USER_STORY, TECHNICAL_ENABLER -> EnumSet.of(FEATURE, EPIC);
            case BUSINESS_RULE, NON_FUNCTIONAL -> EnumSet.allOf(RequirementType.class);
        };
    }

    /** Seule la USER_STORY exige un parent (§3.3-1 : « a un parent FEATURE ou EPIC »). */
    public boolean allowsNoParent() {
        return this != USER_STORY;
    }

    /** Types estimés en points (F-REQ-06, item DoR « estimation renseignée »). */
    public boolean isEstimable() {
        return this == USER_STORY || this == TECHNICAL_ENABLER;
    }
}
