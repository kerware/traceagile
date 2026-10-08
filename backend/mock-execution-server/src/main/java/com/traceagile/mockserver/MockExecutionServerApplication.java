package com.traceagile.mockserver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/** §10.5 Simulateur du serveur d'exécution distant (port 8090). */
@SpringBootApplication
public class MockExecutionServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(MockExecutionServerApplication.class, args);
    }
}
