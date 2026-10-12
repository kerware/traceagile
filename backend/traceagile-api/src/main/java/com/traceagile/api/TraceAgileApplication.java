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
        // Installation hors Docker sous Windows : un TEMP en nom court 8.3 (C:\Users\ADMINI~1\…) casse les
        // sockets unix des Pipe NIO de la JVM, donc le démarrage de Tomcat ; le dossier personnel convient.
        if (System.getProperty("os.name", "").startsWith("Windows") && System.getProperty("jdk.net.unixdomain.tmpdir") == null) {
            System.setProperty("jdk.net.unixdomain.tmpdir", System.getProperty("user.home"));
        }
        SpringApplication.run(TraceAgileApplication.class, args);
    }
}
