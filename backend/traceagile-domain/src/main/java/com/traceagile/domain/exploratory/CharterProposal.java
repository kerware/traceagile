package com.traceagile.domain.exploratory;

import java.util.List;

/**
 * F-EXP-04 charte proposée depuis une exigence, que le testeur valide (création d'un test
 * exploratoire lié) ou rejette. {@code source} : {@code CRITERION} (avec sa position) ou {@code NFR}.
 */
public record CharterProposal(String source, Integer criterionPosition, String title, String explore, String with,
                              String toDiscover, List<String> areas, List<String> heuristics, List<String> requirementKeys) {
}
