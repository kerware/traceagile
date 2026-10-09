package com.traceagile.domain.traceability;

/** §7.3 statut de vérification d'une exigence (pastille de couleur). */
public enum VerificationStatus {
    /** Gris : aucun test lié. */
    NOT_COVERED,
    /** Bleu : tests liés, aucune exécution. */
    NOT_RUN,
    /** Jaune : au moins une exécution, d'autres non exécutées. */
    IN_PROGRESS,
    /** Vert : dernière exécution de chaque test lié = PASSED. */
    VALIDATED,
    /** Rouge : un test FAILED ou une anomalie bloquante / critique ouverte. */
    FAILED,
    /** Orange : un test BLOCKED, aucun FAILED. */
    BLOCKED,
    /** Violet : exigence modifiée depuis la dernière vérification d'un test lié. */
    SUSPECT
}
