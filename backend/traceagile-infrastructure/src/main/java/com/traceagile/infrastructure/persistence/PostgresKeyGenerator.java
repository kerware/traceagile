package com.traceagile.infrastructure.persistence;

import com.traceagile.application.common.KeyGenerator;
import com.traceagile.domain.administration.Project;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * §3 Clés séquentielles par projet et par préfixe. Une seule instruction atomique
 * ({@code insert … on conflict do update … returning}) : pas de doublon sous accès concurrent. Elle
 * participe à la transaction en cours, donc une création annulée ne consomme pas de numéro.
 */
@Component
public class PostgresKeyGenerator implements KeyGenerator {

    private static final String NEXT = """
            insert into key_sequences (project_id, prefix, next_value) values (?, ?, 2)
            on conflict (project_id, prefix) do update set next_value = key_sequences.next_value + 1
            returning next_value - 1
            """;

    private final JdbcTemplate jdbc;

    public PostgresKeyGenerator(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Override
    public String next(Project project, String prefix) {
        Integer value = jdbc.queryForObject(NEXT, Integer.class, project.getId(), prefix);
        return prefix + "-" + value;
    }
}
