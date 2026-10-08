package com.traceagile.application.common;

import com.traceagile.domain.administration.Project;

/** §3 Clés lisibles séquentielles par projet et par préfixe : REQ-12, TC-45, SPR-3… */
public interface KeyGenerator {

    /** @return la clé suivante, par exemple {@code REQ-13} pour le préfixe {@code REQ} */
    String next(Project project, String prefix);
}
