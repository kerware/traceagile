package com.traceagile.application.attachment;

/** §11.3 port {@code FileStorage} : contenu des pièces jointes, adressé par une clé opaque (ADR-0024). */
public interface FileStorage {

    /** Enregistre le contenu et renvoie sa clé. */
    String store(byte[] content);

    byte[] read(String key);

    void delete(String key);
}
