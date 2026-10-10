package com.traceagile.mockserver;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.Comparator;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Component;

/**
 * ADR-0020 jetons émis par le serveur : jeton Bearer et secret de signature des webhooks, tirés au
 * hasard (256 bits). Le serveur ne garde que l'empreinte SHA-256 du jeton ; le secret reste en mémoire
 * pour signer les webhooks. Les jetons ne survivent pas à un redémarrage du simulateur.
 */
@Component
public class TokenStore {

    public record IssuedToken(String tokenId, String token, String webhookSecret, String label, Instant createdAt) {
    }

    public record TokenRecord(String tokenId, String tokenHash, String webhookSecret, String label, String hint, Instant createdAt,
                              Instant lastUsedAt) {
    }

    private final SecureRandom random = new SecureRandom();
    private final Map<String, TokenRecord> byHash = new ConcurrentHashMap<>();

    public IssuedToken issue(String label) {
        String token = "ets_" + randomPart();
        String secret = "whs_" + randomPart();
        String id = "tok-" + UUID.randomUUID().toString().substring(0, 8);
        Instant now = Instant.now();
        byHash.put(hash(token), new TokenRecord(id, hash(token), secret, label, token.substring(token.length() - 4), now, null));
        return new IssuedToken(id, token, secret, label, now);
    }

    /** Jeton reconnu (et date de dernière utilisation mise à jour). */
    public Optional<TokenRecord> authenticate(String token) {
        if (token == null || token.isBlank()) {
            return Optional.empty();
        }
        return Optional.ofNullable(byHash.computeIfPresent(hash(token), (h, r) ->
                new TokenRecord(r.tokenId(), r.tokenHash(), r.webhookSecret(), r.label(), r.hint(), r.createdAt(), Instant.now())));
    }

    public Optional<TokenRecord> byId(String tokenId) {
        return byHash.values().stream().filter(r -> r.tokenId().equals(tokenId)).findFirst();
    }

    public List<TokenRecord> list() {
        return byHash.values().stream().sorted(Comparator.comparing(TokenRecord::createdAt)).toList();
    }

    public boolean revoke(String tokenId) {
        return byHash.values().removeIf(r -> r.tokenId().equals(tokenId));
    }

    private String randomPart() {
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    static String hash(String token) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(token.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
