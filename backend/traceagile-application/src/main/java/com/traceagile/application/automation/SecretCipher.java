package com.traceagile.application.automation;

/** ADR-0020 chiffrement des secrets au repos (jeton du serveur d'exécution, secret de signature). */
public interface SecretCipher {

    String encrypt(String plain);

    String decrypt(String cipher);
}
