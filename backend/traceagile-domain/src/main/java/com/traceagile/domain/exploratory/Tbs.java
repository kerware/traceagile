package com.traceagile.domain.exploratory;

import com.traceagile.domain.common.BusinessRuleException;

/** F-EXP-09 répartition du temps de session (SBTM) : Test, Bug investigation, Setup, en pourcentages. */
public record Tbs(int testPct, int bugPct, int setupPct) {

    public void validate() {
        if (testPct < 0 || bugPct < 0 || setupPct < 0 || testPct + bugPct + setupPct != 100) {
            throw new BusinessRuleException("SESSION_TBS_INVALID",
                    "La répartition Test / Bug / Setup doit totaliser 100 % (saisi : " + (testPct + bugPct + setupPct) + " %).");
        }
    }
}
