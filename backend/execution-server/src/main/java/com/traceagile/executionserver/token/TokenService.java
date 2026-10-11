package com.traceagile.executionserver.token;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Service;

/**
 * ADR-0020 / ADR-0026 jetons émis par le serveur : un jeton Bearer et un secret de signature des
 * webhooks, tirés au hasard (256 bits). Seule l'empreinte SHA-256 du jeton est conservée ; le secret
 * est gardé pour signer les webhooks. Un jeton révoqué est conservé (historique des jobs).
 */
@Service
public class TokenService {

    public record IssuedToken(String tokenId, String token, String webhookSecret, String label, Instant createdAt) {
    }

    public record TokenRecord(String tokenId, String label, String hint, String webhookSecret, Instant createdAt, Instant lastUsedAt,
                              Instant revokedAt) {
    }

    private final JdbcClient db;
    private final Clock clock;
    private final SecureRandom random = new SecureRandom();

    public TokenService(JdbcClient db, Clock clock) {
        this.db = db;
        this.clock = clock;
    }

    public IssuedToken issue(String label) {
        String token = "ets_" + randomPart();
        String secret = "whs_" + randomPart();
        String id = "tok-" + UUID.randomUUID().toString().substring(0, 8);
        Instant now = clock.instant();
        String name = label == null || label.isBlank() ? "TraceAgile" : label.strip();
        db.sql("insert into tokens (id, label, token_hash, webhook_secret, hint, created_at) values (?, ?, ?, ?, ?, ?)")
                .params(id, name.length() > 120 ? name.substring(0, 120) : name, hash(token), secret, token.substring(token.length() - 4),
                        Timestamp.from(now))
                .update();
        return new IssuedToken(id, token, secret, name, now);
    }

    /** Jeton actif reconnu ; sa date de dernière utilisation est mise à jour. */
    public Optional<TokenRecord> authenticate(String token) {
        if (token == null || token.isBlank()) {
            return Optional.empty();
        }
        Optional<TokenRecord> record = db.sql(SELECT + " where token_hash = ? and revoked_at is null").param(hash(token)).query(TokenService::map).optional();
        record.ifPresent(r -> db.sql("update tokens set last_used_at = ? where id = ?").params(Timestamp.from(clock.instant()), r.tokenId()).update());
        return record;
    }

    public Optional<TokenRecord> byId(String tokenId) {
        return db.sql(SELECT + " where id = ?").param(tokenId).query(TokenService::map).optional();
    }

    public List<TokenRecord> list() {
        return db.sql(SELECT + " order by created_at desc").query(TokenService::map).list();
    }

    public boolean revoke(String tokenId) {
        return db.sql("update tokens set revoked_at = ? where id = ? and revoked_at is null").params(Timestamp.from(clock.instant()), tokenId).update() == 1;
    }

    private static final String SELECT = "select id, label, hint, webhook_secret, created_at, last_used_at, revoked_at from tokens";

    private static TokenRecord map(java.sql.ResultSet rs, int row) throws java.sql.SQLException {
        return new TokenRecord(rs.getString("id"), rs.getString("label"), rs.getString("hint"), rs.getString("webhook_secret"),
                instant(rs.getTimestamp("created_at")), instant(rs.getTimestamp("last_used_at")), instant(rs.getTimestamp("revoked_at")));
    }

    static Instant instant(Timestamp timestamp) {
        return timestamp == null ? null : timestamp.toInstant();
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
