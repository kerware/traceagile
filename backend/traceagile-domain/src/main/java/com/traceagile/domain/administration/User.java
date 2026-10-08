package com.traceagile.domain.administration;

import com.traceagile.domain.common.AuditableEntity;
import com.traceagile.domain.common.BusinessRuleException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.util.regex.Pattern;

/** §3.1 User. */
@Entity
@Table(name = "users")
public class User extends AuditableEntity {

    private static final Pattern LOGIN = Pattern.compile("[a-z0-9._-]{2,32}");
    private static final Pattern EMAIL = Pattern.compile("[^@\\s]+@[^@\\s]+\\.[^@\\s]+");

    @Column(nullable = false, unique = true, length = 32)
    private String login;

    @Column(nullable = false, length = 254)
    private String email;

    @Column(name = "display_name", nullable = false, length = 100)
    private String displayName;

    @Column(name = "password_hash", nullable = false, length = 100)
    private String passwordHash;

    @Column(nullable = false)
    private boolean active = true;

    /** Administrateur de l'application (ADR-0004) : utilisateurs, projets, paramètres. */
    @Column(name = "system_admin", nullable = false)
    private boolean systemAdmin;

    protected User() {
    }

    public User(String login, String email, String displayName, String passwordHash) {
        if (login == null || !LOGIN.matcher(login).matches()) {
            throw new BusinessRuleException("USER_LOGIN_INVALID",
                    "Le login doit comporter 2 à 32 caractères parmi a-z, 0-9, « . », « _ » et « - ».");
        }
        this.login = login;
        setEmail(email);
        setDisplayName(displayName);
        this.passwordHash = passwordHash;
    }

    public String getLogin() {
        return login;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        if (email == null || !EMAIL.matcher(email).matches()) {
            throw new BusinessRuleException("USER_EMAIL_INVALID", "Adresse e-mail invalide.");
        }
        this.email = email;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName == null || displayName.isBlank() ? login : displayName.strip();
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public boolean isSystemAdmin() {
        return systemAdmin;
    }

    public void setSystemAdmin(boolean systemAdmin) {
        this.systemAdmin = systemAdmin;
    }
}
