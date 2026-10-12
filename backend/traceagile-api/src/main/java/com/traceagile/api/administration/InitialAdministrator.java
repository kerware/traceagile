package com.traceagile.api.administration;

import com.traceagile.application.administration.CreateUserCommand;
import com.traceagile.application.administration.UserAdministrationService;
import com.traceagile.application.administration.UserRepository;
import java.security.SecureRandom;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Installation hors Docker (docs/installation.md) : données de démarrage. Sur une base sans
 * utilisateur, crée l'administrateur système ({@code TRACEAGILE_ADMIN_LOGIN},
 * {@code TRACEAGILE_ADMIN_PASSWORD}) ; sans mot de passe configuré, en tire un au hasard et l'écrit une
 * fois dans le journal. Le schéma et les référentiels viennent des migrations Flyway. Inactif sous le
 * profil demo, qui crée ses propres comptes.
 */
@Component
@Profile("!demo")
public class InitialAdministrator implements ApplicationRunner {

    private static final Logger LOG = LoggerFactory.getLogger(InitialAdministrator.class);
    private static final String ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";

    private final UserRepository users;
    private final UserAdministrationService service;
    private final String login;
    private final String password;
    private final String email;

    public InitialAdministrator(UserRepository users, UserAdministrationService service,
                                @Value("${traceagile.bootstrap.admin-login:admin}") String login,
                                @Value("${traceagile.bootstrap.admin-password:}") String password,
                                @Value("${traceagile.bootstrap.admin-email:admin@traceagile.local}") String email) {
        this.users = users;
        this.service = service;
        this.login = login;
        this.password = password;
        this.email = email;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        ensure();
    }

    /** @return le mot de passe de l'administrateur créé, ou null si la base a déjà des utilisateurs */
    @Transactional
    public String ensure() {
        if (users.count() > 0) {
            return null;
        }
        boolean generated = password == null || password.isBlank();
        String secret = generated ? random() : password;
        service.create(new CreateUserCommand(login, email, "Administrateur", secret, true));
        if (generated) {
            LOG.warn("Premier démarrage : administrateur « {} » créé avec le mot de passe {} — changez-le dès la première connexion"
                    + " (ou fixez TRACEAGILE_ADMIN_PASSWORD avant le premier démarrage).", login, secret);
        } else {
            LOG.info("Premier démarrage : administrateur « {} » créé (mot de passe TRACEAGILE_ADMIN_PASSWORD).", login);
        }
        return secret;
    }

    private static String random() {
        SecureRandom random = new SecureRandom();
        StringBuilder text = new StringBuilder();
        for (int i = 0; i < 20; i++) {
            text.append(ALPHABET.charAt(random.nextInt(ALPHABET.length())));
        }
        return text.toString();
    }
}
