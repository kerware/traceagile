package com.traceagile.mockserver;

import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** §10.2 GET /api/v1/health : état et version, utilisé pour le heartbeat. */
@RestController
@RequestMapping("/api/v1")
public class HealthController {

    static final String NAME = "mock-execution-server";
    static final String VERSION = "1.0.0";

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "UP", "name", NAME, "version", VERSION);
    }
}
