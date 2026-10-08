package com.traceagile.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = "com.traceagile")
@EntityScan("com.traceagile.domain")
@EnableJpaRepositories("com.traceagile.infrastructure.persistence")
@ConfigurationPropertiesScan
public class TraceAgileApplication {

    public static void main(String[] args) {
        SpringApplication.run(TraceAgileApplication.class, args);
    }
}
