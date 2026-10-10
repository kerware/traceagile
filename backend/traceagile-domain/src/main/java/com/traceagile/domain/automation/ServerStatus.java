package com.traceagile.domain.automation;

/** ADR-0020 état d'un serveur d'exécution, mis à jour par le heartbeat (§10.2, toutes les 60 s). */
public enum ServerStatus {
    /** Aucun jeton émis par le serveur n'est enregistré. */
    UNPAIRED,
    /** Jamais interrogé depuis l'appairage. */
    UNKNOWN,
    ONLINE,
    /** Injoignable ou en erreur. */
    OFFLINE,
    /** Le serveur refuse le jeton (révoqué ou expiré) : il faut l'appairer à nouveau. */
    UNAUTHORIZED
}
