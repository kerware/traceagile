package com.traceagile.domain.git;

/** ADR-0030 authentification d'un dépôt Git déclaré dans l'administration. */
public enum GitAuthType {
    /** Dépôt public (ou dépôt local du serveur d'exécution). */
    NONE,
    /** Jeton d'accès personnel, en HTTPS (GitHub, GitLab…), avec un nom d'utilisateur. */
    TOKEN,
    /** Clé privée SSH ; les projets se clonent en {@code git@hôte:chemin/projet.git}. */
    SSH_KEY
}
