package com.traceagile.executionserver.job;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.traceagile.executionserver.job.JobSpec.TestSpec;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

/** ADR-0026 persistance des jobs, de leurs tests, événements et artefacts (H2, JDBC). */
@Repository
public class JobStore {

    public enum JobStatus { ACCEPTED, RUNNING, COMPLETED, CANCELLED, INTERRUPTED }

    public record JobRow(String id, String tokenId, String tokenLabel, String runId, String project, String campaign, String environment,
                         String buildVersion, String repositoryUrl, String branch, String callbackUrl, String baseUrl, JobStatus status,
                         String agent, int timeoutMinutes, int parallelism, int retryFailed, Instant submittedAt, Instant startedAt,
                         Instant endedAt, int total, int passed, int failed, int errored, int skipped, String errorMessage) {

        public boolean finished() {
            return status == JobStatus.COMPLETED || status == JobStatus.CANCELLED || status == JobStatus.INTERRUPTED;
        }
    }

    public record TestRow(long id, int position, TestSpec spec, String status, int attempts, Long durationMs, String message, Instant startedAt,
                          Instant endedAt, Map<String, Double> metrics) {
    }

    public record ArtifactRow(String jobId, String name, String contentType, String kind, String executionId, long size) {
    }

    private final JdbcClient db;
    private final ObjectMapper json;

    public JobStore(JdbcClient db, ObjectMapper json) {
        this.db = db;
        this.json = json;
    }

    public Optional<String> jobIdFor(String tokenId, String runId) {
        return db.sql("select id from jobs where token_id = ? and run_id = ?").params(tokenId, runId).query(String.class).optional();
    }

    @Transactional
    public void create(String jobId, String tokenId, JobSpec spec, String baseUrl, Instant now) {
        db.sql("""
                insert into jobs (id, token_id, run_id, project, campaign, environment, build_version, repository_url, branch, callback_url, base_url,
                                  status, timeout_minutes, parallelism, retry_failed, submitted_at, total)
                values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACCEPTED', ?, ?, ?, ?, ?)""")
                .params(jobId, tokenId, spec.runId(), spec.project(), spec.campaign(), spec.environment(), spec.buildVersion(), spec.repositoryUrl(),
                        spec.branch(), spec.callbackUrl(), baseUrl, spec.timeoutMinutes(), spec.parallelism(), spec.retryFailed(), Timestamp.from(now),
                        spec.tests().size())
                .update();
        int position = 0;
        for (TestSpec test : spec.tests()) {
            db.sql("""
                    insert into job_tests (job_id, position, execution_id, test_key, technique, framework, path, test_identifier, gherkin_source,
                                           parameters_json, status)
                    values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')""")
                    .params(jobId, ++position, test.executionId(), test.testKey(), test.technique(), test.framework(), test.path(), test.testIdentifier(),
                            test.gherkinSource(), write(extra(test)))
                    .update();
        }
    }

    public Optional<JobRow> job(String jobId) {
        return db.sql(JOB_SELECT + " where j.id = ?").param(jobId).query(this::mapJob).optional();
    }

    /** Derniers jobs, filtrés par statut et par texte (run, projet, campagne, jeton). */
    public List<JobRow> jobs(String status, String text, int limit) {
        String like = text == null || text.isBlank() ? null : "%" + text.strip().toLowerCase() + "%";
        return db.sql(JOB_SELECT + " " + """
                 where (? is null or j.status = ?)
                   and (? is null or lower(j.run_id) like ? or lower(coalesce(j.project, '')) like ? or lower(coalesce(j.campaign, '')) like ?
                        or lower(t.label) like ? or lower(j.id) like ?)
                 order by j.submitted_at desc limit ?""")
                .params(status, status, like, like, like, like, like, like, limit).query(this::mapJob).list();
    }

    public List<JobRow> unfinished() {
        return db.sql(JOB_SELECT + " where j.status in ('ACCEPTED', 'RUNNING') order by j.submitted_at").query(this::mapJob).list();
    }

    public List<TestRow> tests(String jobId) {
        return db.sql("select * from job_tests where job_id = ? order by position").param(jobId).query(this::mapTest).list();
    }

    public void started(String jobId, String agent, Instant at) {
        db.sql("update jobs set status = 'RUNNING', agent = ?, started_at = ? where id = ?").params(agent, Timestamp.from(at), jobId).update();
    }

    public void finished(String jobId, JobStatus status, Instant at, String error) {
        db.sql("""
                update jobs set status = ?, ended_at = ?, error_message = ?,
                  passed = (select count(*) from job_tests where job_id = ? and status = 'PASSED'),
                  failed = (select count(*) from job_tests where job_id = ? and status = 'FAILED'),
                  errored = (select count(*) from job_tests where job_id = ? and status = 'ERROR'),
                  skipped = (select count(*) from job_tests where job_id = ? and status = 'SKIPPED')
                where id = ?""")
                .params(status.name(), Timestamp.from(at), error, jobId, jobId, jobId, jobId, jobId).update();
    }

    public void testStarted(long testId, Instant at) {
        db.sql("update job_tests set status = 'RUNNING', started_at = ? where id = ?").params(Timestamp.from(at), testId).update();
    }

    public void testFinished(long testId, String status, int attempts, long durationMs, String message, Map<String, Double> metrics, Instant at) {
        db.sql("update job_tests set status = ?, attempts = ?, duration_ms = ?, message = ?, metrics_json = ?, ended_at = ? where id = ?")
                .params(status, attempts, durationMs, truncate(message, 4000), metrics.isEmpty() ? null : write(metrics), Timestamp.from(at), testId).update();
    }

    public void event(String jobId, Map<String, Object> event, Instant at) {
        db.sql("insert into job_events (job_id, event_json, created_at) values (?, ?, ?)").params(jobId, write(event), Timestamp.from(at)).update();
    }

    public List<Map<String, Object>> events(String jobId) {
        return db.sql("select event_json from job_events where job_id = ? order by id").param(jobId).query(String.class).list().stream()
                .map(this::readMap).toList();
    }

    public void artifact(ArtifactRow artifact) {
        db.sql("delete from artifacts where job_id = ? and name = ?").params(artifact.jobId(), artifact.name()).update();
        db.sql("insert into artifacts (job_id, name, content_type, kind, execution_id, size_bytes) values (?, ?, ?, ?, ?, ?)")
                .params(artifact.jobId(), artifact.name(), artifact.contentType(), artifact.kind(), artifact.executionId(), artifact.size()).update();
    }

    public List<ArtifactRow> artifacts(String jobId) {
        return db.sql("select * from artifacts where job_id = ? order by case when kind = 'SCREENSHOT' then 0 else 1 end, name").param(jobId)
                .query((rs, row) -> new ArtifactRow(rs.getString("job_id"), rs.getString("name"), rs.getString("content_type"), rs.getString("kind"),
                        rs.getString("execution_id"), rs.getLong("size_bytes")))
                .list();
    }

    public Optional<ArtifactRow> artifact(String jobId, String name) {
        return artifacts(jobId).stream().filter(a -> a.name().equals(name)).findFirst();
    }

    /** Rétention : jobs terminés avant la date, dont les fichiers peuvent être supprimés. */
    public List<String> finishedBefore(Instant limit) {
        return db.sql("select id from jobs where ended_at is not null and ended_at < ?").param(Timestamp.from(limit)).query(String.class).list();
    }

    public void forgetArtifacts(String jobId) {
        db.sql("delete from artifacts where job_id = ?").param(jobId).update();
    }

    // ------------------------------------------------------------------------------------------- lecture

    private static final String JOB_SELECT = "select j.*, t.label as token_label from jobs j join tokens t on t.id = j.token_id";

    private JobRow mapJob(ResultSet rs, int row) throws SQLException {
        return new JobRow(rs.getString("id"), rs.getString("token_id"), rs.getString("token_label"), rs.getString("run_id"), rs.getString("project"),
                rs.getString("campaign"), rs.getString("environment"), rs.getString("build_version"), rs.getString("repository_url"), rs.getString("branch"),
                rs.getString("callback_url"), rs.getString("base_url"), JobStatus.valueOf(rs.getString("status")), rs.getString("agent"),
                rs.getInt("timeout_minutes"), rs.getInt("parallelism"), rs.getInt("retry_failed"), instant(rs, "submitted_at"), instant(rs, "started_at"),
                instant(rs, "ended_at"), rs.getInt("total"), rs.getInt("passed"), rs.getInt("failed"), rs.getInt("errored"), rs.getInt("skipped"),
                rs.getString("error_message"));
    }

    /** Paramètres, jeu de données, tags et ADR-0030 dépôt propre au test (sans ses identifiants). */
    private static Map<String, Object> extra(TestSpec test) {
        Map<String, Object> extra = new LinkedHashMap<>();
        extra.put("parameters", test.parameters());
        extra.put("dataSet", test.dataSet());
        extra.put("tags", test.tags());
        if (test.repositoryUrl() != null) {
            Map<String, Object> repository = new LinkedHashMap<>();
            repository.put("url", test.repositoryUrl());
            repository.put("branch", test.branch());
            extra.put("repository", repository);
        }
        return extra;
    }

    private static String text(Object value) {
        return value == null ? null : String.valueOf(value);
    }

    private TestRow mapTest(ResultSet rs, int row) throws SQLException {
        Map<String, Object> extra = readMap(rs.getString("parameters_json"));
        TestSpec spec = new TestSpec(rs.getString("execution_id"), rs.getString("test_key"), rs.getString("technique"), rs.getString("framework"),
                rs.getString("path"), rs.getString("test_identifier"), rs.getString("gherkin_source"), map(extra.get("dataSet")),
                map(extra.get("parameters")), extra.get("tags") instanceof List<?> tags ? tags.stream().map(String::valueOf).toList() : List.of(),
                text(map(extra.get("repository")).get("url")), text(map(extra.get("repository")).get("branch")), null);
        long duration = rs.getLong("duration_ms");
        String metrics = rs.getString("metrics_json");
        return new TestRow(rs.getLong("id"), rs.getInt("position"), spec, rs.getString("status"), rs.getInt("attempts"), rs.wasNull() ? null : duration,
                rs.getString("message"), instant(rs, "started_at"), instant(rs, "ended_at"),
                metrics == null ? Map.of() : read(metrics, new TypeReference<Map<String, Double>>() { }));
    }

    @SuppressWarnings("unchecked")
    private static Map<String, Object> map(Object value) {
        return value instanceof Map<?, ?> m ? (Map<String, Object>) m : Map.of();
    }

    static Instant instant(ResultSet rs, String column) throws SQLException {
        Timestamp timestamp = rs.getTimestamp(column);
        return timestamp == null ? null : timestamp.toInstant();
    }

    private static String truncate(String text, int max) {
        return text == null || text.length() <= max ? text : text.substring(0, max - 1) + "…";
    }

    private String write(Object value) {
        try {
            return json.writeValueAsString(value);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
    }

    private Map<String, Object> readMap(String text) {
        return text == null ? Map.of() : read(text, new TypeReference<Map<String, Object>>() { });
    }

    private <T> T read(String text, TypeReference<T> type) {
        try {
            return json.readValue(text, type);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
    }
}
