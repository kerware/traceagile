package com.traceagile.mockserver;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Base64;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * ADR-0020 authentification du simulateur : {@code /api/v1/health} est public ; {@code /api/v1/tokens}
 * exige l'administrateur du serveur (HTTP Basic) ; tout le reste exige un jeton Bearer émis par le serveur.
 */
@Component
public class SecurityFilter extends OncePerRequestFilter {

    static final String TOKEN_ATTRIBUTE = "simulator.token";

    private final TokenStore tokens;
    private final SimulatorProperties properties;

    public SecurityFilter(TokenStore tokens, SimulatorProperties properties) {
        this.tokens = tokens;
        this.properties = properties;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        return !path.startsWith("/api/v1/") || path.equals("/api/v1/health");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws ServletException, IOException {
        String authorization = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (request.getRequestURI().startsWith("/api/v1/tokens")) {
            if (!isAdmin(authorization)) {
                response.setHeader(HttpHeaders.WWW_AUTHENTICATE, "Basic realm=\"mock-execution-server\"");
                deny(response, "ADMIN_REQUIRED", "Identifiants de l'administrateur du serveur requis.");
                return;
            }
            chain.doFilter(request, response);
            return;
        }
        String token = authorization != null && authorization.startsWith("Bearer ") ? authorization.substring(7).strip() : null;
        var record = tokens.authenticate(token);
        if (record.isEmpty()) {
            response.setHeader(HttpHeaders.WWW_AUTHENTICATE, "Bearer");
            deny(response, "TOKEN_INVALID", "Jeton absent, inconnu ou révoqué : demandez un jeton au serveur (POST /api/v1/tokens).");
            return;
        }
        request.setAttribute(TOKEN_ATTRIBUTE, record.get());
        chain.doFilter(request, response);
    }

    private boolean isAdmin(String authorization) {
        if (authorization == null || !authorization.startsWith("Basic ")) {
            return false;
        }
        try {
            String decoded = new String(Base64.getDecoder().decode(authorization.substring(6).strip()), StandardCharsets.UTF_8);
            String expected = properties.adminUser() + ":" + properties.adminPassword();
            return MessageDigest.isEqual(decoded.getBytes(StandardCharsets.UTF_8), expected.getBytes(StandardCharsets.UTF_8));
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    private static void deny(HttpServletResponse response, String code, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.getWriter().write("{\"code\":\"" + code + "\",\"message\":\"" + message.replace("\"", "'") + "\"}");
    }
}
