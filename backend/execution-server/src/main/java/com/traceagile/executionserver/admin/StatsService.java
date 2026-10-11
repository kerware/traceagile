package com.traceagile.executionserver.admin;

import com.traceagile.executionserver.ServerProperties;
import com.traceagile.executionserver.job.JobRunner;
import com.traceagile.executionserver.tool.ToolService;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Service;

/**
 * ADR-0026 statistiques de suivi du tableau de bord : activité en direct, volumes et taux de réussite
 * sur 7 jours, série quotidienne sur 14 jours, résultats par framework et tests les plus en échec
 * sur 30 jours, état des outils.
 */
@Service
public class StatsService {

    public record Live(int runningJobs, int busyAgents, int agents, int pendingTests) {
    }

    public record Totals(int jobs, int tests, int passed, int failed, int errors, Double passRate, Long averageJobMs) {
    }

    public record Day(LocalDate day, int jobs, int passed, int failed, int errors) {
    }

    public record FrameworkStats(String framework, int tests, int passed, Double passRate, Long averageMs) {
    }

    public record FailingTest(String testKey, String identifier, String project, int failures, Instant lastFailure) {
    }

    public record Dashboard(Live live, Totals week, List<Day> days, List<FrameworkStats> frameworks, List<FailingTest> failing, int toolsInstalled,
                            int toolsTotal, String platform) {
    }

    private final JdbcClient db;
    private final JobRunner runner;
    private final ToolService tools;
    private final ServerProperties properties;
    private final Clock clock;

    public StatsService(JdbcClient db, JobRunner runner, ToolService tools, ServerProperties properties, Clock clock) {
        this.db = db;
        this.runner = runner;
        this.tools = tools;
        this.properties = properties;
        this.clock = clock;
    }

    public Dashboard dashboard() {
        Instant now = clock.instant();
        Timestamp week = Timestamp.from(now.minus(7, ChronoUnit.DAYS));
        Timestamp month = Timestamp.from(now.minus(30, ChronoUnit.DAYS));
        int pending = db.sql("select count(*) from job_tests t join jobs j on j.id = t.job_id where j.status in ('ACCEPTED', 'RUNNING') and t.status = 'PENDING'")
                .query(Integer.class).single();
        Live live = new Live(runner.runningJobs(), runner.busyAgents(), properties.agents(), pending);

        Totals totals = db.sql("""
                select count(*) as jobs, coalesce(sum(total), 0) as tests, coalesce(sum(passed), 0) as passed, coalesce(sum(failed), 0) as failed,
                       coalesce(sum(errored), 0) as errors,
                       avg(case when ended_at is not null and started_at is not null then datediff('MILLISECOND', started_at, ended_at) end) as average
                from jobs where submitted_at >= ?""").param(week).query((rs, row) -> {
                    int passed = rs.getInt("passed");
                    int executed = passed + rs.getInt("failed") + rs.getInt("errors");
                    double average = rs.getDouble("average");
                    return new Totals(rs.getInt("jobs"), rs.getInt("tests"), passed, rs.getInt("failed"), rs.getInt("errors"),
                            executed == 0 ? null : Math.round(1000.0 * passed / executed) / 10.0, rs.wasNull() ? null : Math.round(average));
                }).single();

        Map<LocalDate, Day> byDay = new LinkedHashMap<>();
        LocalDate today = LocalDate.ofInstant(now, ZoneOffset.UTC);
        for (int i = 13; i >= 0; i--) {
            LocalDate day = today.minusDays(i);
            byDay.put(day, new Day(day, 0, 0, 0, 0));
        }
        db.sql("""
                select cast(submitted_at as date) as jour, count(*) as jobs, sum(passed) as passed, sum(failed) as failed, sum(errored) as errors
                from jobs where submitted_at >= ? group by cast(submitted_at as date)""")
                .param(Timestamp.from(today.minusDays(13).atStartOfDay().toInstant(ZoneOffset.UTC)))
                .query((rs, row) -> new Day(rs.getDate("jour").toLocalDate(), rs.getInt("jobs"), rs.getInt("passed"), rs.getInt("failed"), rs.getInt("errors")))
                .list().forEach(d -> byDay.computeIfPresent(d.day(), (k, v) -> d));

        List<FrameworkStats> frameworks = db.sql("""
                select coalesce(t.framework, 'Non précisé') as framework, count(*) as tests, sum(case when t.status = 'PASSED' then 1 else 0 end) as passed,
                       sum(case when t.status in ('PASSED', 'FAILED', 'ERROR') then 1 else 0 end) as executed, avg(t.duration_ms) as average
                from job_tests t join jobs j on j.id = t.job_id
                where j.submitted_at >= ? and t.status not in ('PENDING', 'RUNNING')
                group by coalesce(t.framework, 'Non précisé') order by count(*) desc""").param(month).query((rs, row) -> {
                    int executed = rs.getInt("executed");
                    int passed = rs.getInt("passed");
                    double average = rs.getDouble("average");
                    return new FrameworkStats(rs.getString("framework"), rs.getInt("tests"), passed,
                            executed == 0 ? null : Math.round(1000.0 * passed / executed) / 10.0, rs.wasNull() ? null : Math.round(average));
                }).list();

        List<FailingTest> failing = db.sql("""
                select t.test_key, max(t.test_identifier) as identifier, max(j.project) as project, count(*) as failures, max(t.ended_at) as last_failure
                from job_tests t join jobs j on j.id = t.job_id
                where j.submitted_at >= ? and t.status in ('FAILED', 'ERROR')
                group by t.test_key order by count(*) desc, max(t.ended_at) desc limit 5""").param(month)
                .query((rs, row) -> new FailingTest(rs.getString("test_key"), rs.getString("identifier"), rs.getString("project"), rs.getInt("failures"),
                        rs.getTimestamp("last_failure") == null ? null : rs.getTimestamp("last_failure").toInstant()))
                .list();

        var states = tools.states();
        int installed = (int) states.stream().filter(s -> s.status() == ToolService.Status.INSTALLED).count();
        return new Dashboard(live, totals, new ArrayList<>(byDay.values()), frameworks, failing, installed, states.size(),
                com.traceagile.executionserver.process.Platform.current().name());
    }
}
