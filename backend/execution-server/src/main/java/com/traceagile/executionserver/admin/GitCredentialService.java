package com.traceagile.executionserver.admin;

import java.sql.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Service;

/**
 * Identifiants des dépôts Git privés, par hôte (utilisateur + jeton d'accès personnel). Le secret
 * n'est jamais renvoyé par l'API d'administration ; il est conservé dans la base du serveur (ADR-0026).
 */
@Service
public class GitCredentialService {

    public record GitCredential(String host, String username, String secret, Instant updatedAt) {
    }

    private final JdbcClient db;
    private final Clock clock;

    public GitCredentialService(JdbcClient db, Clock clock) {
        this.db = db;
        this.clock = clock;
    }

    public List<GitCredential> list() {
        return db.sql("select * from git_credentials order by host").query((rs, row) -> new GitCredential(rs.getString("host"), rs.getString("username"),
                rs.getString("secret"), rs.getTimestamp("updated_at").toInstant())).list();
    }

    public Optional<GitCredential> find(String host) {
        return list().stream().filter(c -> c.host().equalsIgnoreCase(host)).findFirst();
    }

    public void save(String host, String username, String secret) {
        String key = host.strip().toLowerCase(Locale.ROOT);
        db.sql("delete from git_credentials where host = ?").param(key).update();
        db.sql("insert into git_credentials (host, username, secret, updated_at) values (?, ?, ?, ?)")
                .params(key, username.strip(), secret.strip(), Timestamp.from(clock.instant())).update();
    }

    public boolean delete(String host) {
        return db.sql("delete from git_credentials where host = ?").param(host.strip().toLowerCase(Locale.ROOT)).update() == 1;
    }
}
