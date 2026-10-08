package com.traceagile.domain.administration;

/** Droits élémentaires sur un projet, dérivés des colonnes du tableau §2.2. */
public enum Permission {
    PROJECT_READ,
    /** Administration du projet : membres, paramètres. */
    PROJECT_ADMIN,

    REQUIREMENT_READ,
    /** Créer, modifier, prioriser, valider. */
    REQUIREMENT_WRITE,
    REQUIREMENT_COMMENT,
    ACCEPTANCE_CRITERION_PROPOSE,

    TEST_READ,
    /** Créer et modifier tout type de test. */
    TEST_WRITE,
    /** Créer et modifier les tests automatisés. */
    AUTOMATED_TEST_WRITE,

    PLANNING_READ,
    /** Créer releases et sprints, définir le périmètre. */
    PLANNING_WRITE,
    CAMPAIGN_READ,
    CAMPAIGN_WRITE,

    EXECUTION_READ,
    /** Exécuter, saisir des sessions, créer des anomalies. */
    EXECUTION_WRITE,
    AUTOMATED_RUN_LAUNCH
}
