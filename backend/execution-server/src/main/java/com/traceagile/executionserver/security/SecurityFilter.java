package com.traceagile.executionserver.security;

import com.traceagile.executionserver.ServerProperties;
import com.traceagile.executionserver.token.TokenService;
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
 * ADR-0026 authentification :
 * <ul>
 *   <li>{@code /api/v1/health} et l'interface (fichiers statiques) sont publics ;</li>
 *   <li>{@code /api/v1/tokens} et {@code /api/admin/**} exigent l'administrateur du serveur (HTTP Basic) ;</li>
 *   <li>le reste de {@code /api/v1} exige un jeton Bearer émis par le serveur (TraceAgile).</li>
 * </ul>
 * Pas de fenêtre de connexion du navigateur : la réponse 401 de l'administration n'annonce pas « Basic »,
 * l'interface gère elle-même la connexion.
 */
@Component
public class SecurityFilter extends OncePerRequestFilter {

    public static final String TOKEN_ATTRIBUTE = "execution-server.token";

    private final TokenService tokens;
    private final ServerProperties properties;

    public SecurityFilter(TokenService tokens, ServerProperties properties) {
        this.tokens = tokens;
        this.properties = properties;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        return !path.startsWith("/api/") || path.equals("/api/v1/health");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws ServletException, IOException {
        String path = request.getRequestURI();
        String authorization = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (path.startsWith("/api/v1/tokens") || path.startsWith("/api/admin/")) {
            if (!isAdmin(authorization)) {
                if (path.startsWith("/api/v1/tokens")) {
                    response.setHeader(HttpHeaders.WWW_AUTHENTICATE, "Basic realm=\"execution-server\"");
                }
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

    boolean isAdmin(String authorization) {
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
