package com.traceagile.executionserver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * ADR-0026 serveur d'exécution réel : il émet les jetons de TraceAgile, installe les outils de test
 * (Playwright, Selenium, Cypress, Robot Framework, Maven, JDK, Gatling…), exécute les jobs reçus par
 * l'API du §10 et renvoie les résultats par webhooks signés. Interface d'administration React.
 */
@SpringBootApplication
@ConfigurationPropertiesScan
@EnableScheduling
public class ExecutionServerApplication {

    public static void main(String[] args) {
        // Windows : un TEMP en nom court 8.3 (C:\Users\ADMINI~1\…) casse les sockets unix des Pipe NIO
        // de la JVM, et donc le démarrage de Tomcat ; le dossier personnel convient toujours.
        if (com.traceagile.executionserver.process.Platform.current().windows() && System.getProperty("jdk.net.unixdomain.tmpdir") == null) {
            System.setProperty("jdk.net.unixdomain.tmpdir", System.getProperty("user.home"));
        }
        SpringApplication.run(ExecutionServerApplication.class, args);
    }
}
