package com.traceagile.application.administration;

/** Port de hachage des mots de passe (NF-07 : BCrypt coût 12 dans l'infrastructure). */
public interface PasswordHasher {

    String hash(String rawPassword);

    boolean matches(String rawPassword, String hash);
}
