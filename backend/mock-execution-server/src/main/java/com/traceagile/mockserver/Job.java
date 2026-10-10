package com.traceagile.mockserver;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/** Job reçu par le simulateur : requête (§10.3), statut, événements émis (polling), journaux. */
public class Job {

    private final String jobId;
    private final String tokenId;
    private final Map<String, Object> request;
    private final List<Map<String, Object>> events = new ArrayList<>();
    private final StringBuilder logs = new StringBuilder();
    private volatile String status = "ACCEPTED";
    private volatile boolean cancelled;
    private volatile Instant startedAt;
    private volatile Instant endedAt;
    private volatile String report;

    public Job(String jobId, String tokenId, Map<String, Object> request) {
        this.jobId = jobId;
        this.tokenId = tokenId;
        this.request = request;
    }

    public String jobId() {
        return jobId;
    }

    public String tokenId() {
        return tokenId;
    }

    public String runId() {
        return String.valueOf(request.get("runId"));
    }

    public Map<String, Object> request() {
        return request;
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> tests() {
        return (List<Map<String, Object>>) request.getOrDefault("tests", List.of());
    }

    public String callbackUrl() {
        return String.valueOf(request.get("callbackUrl"));
    }

    public synchronized void record(Map<String, Object> event) {
        events.add(event);
    }

    public synchronized List<Map<String, Object>> events() {
        return List.copyOf(events);
    }

    public synchronized void log(String line) {
        logs.append(Instant.now()).append(' ').append(line).append('\n');
    }

    public synchronized String logs() {
        return logs.toString();
    }

    public String status() {
        return status;
    }

    public void status(String status) {
        this.status = status;
    }

    public boolean cancelled() {
        return cancelled;
    }

    public void cancel() {
        this.cancelled = true;
    }

    public Instant startedAt() {
        return startedAt;
    }

    public void startedAt(Instant startedAt) {
        this.startedAt = startedAt;
    }

    public Instant endedAt() {
        return endedAt;
    }

    public void endedAt(Instant endedAt) {
        this.endedAt = endedAt;
    }

    public String report() {
        return report;
    }

    public void report(String report) {
        this.report = report;
    }
}
