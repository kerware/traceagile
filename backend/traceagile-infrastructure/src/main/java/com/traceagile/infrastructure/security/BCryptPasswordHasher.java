package com.traceagile.infrastructure.security;

import com.traceagile.application.administration.PasswordHasher;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

/** NF-07 Mots de passe BCrypt (coût 12). */
@Component
public class BCryptPasswordHasher implements PasswordHasher {

    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(12);

    @Override
    public String hash(String rawPassword) {
        return encoder.encode(rawPassword);
    }

    @Override
    public boolean matches(String rawPassword, String hash) {
        return rawPassword != null && hash != null && encoder.matches(rawPassword, hash);
    }
}
