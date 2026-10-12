package com.traceagile.api.web;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * Installation hors Docker (docs/installation.md) : quand le jar embarque l'interface (profil Maven
 * {@code distribution}), les routes de l'application renvoient {@code index.html} (React Router prend le
 * relais) et {@code /guide/} le guide d'utilisation ; en-têtes de sécurité équivalents à ceux de
 * frontend/nginx.conf. Sans interface embarquée (image Docker de l'API), le filtre est inactif.
 */
@Component
public class EmbeddedFrontendFilter extends OncePerRequestFilter {

    static final String APP_CSP = "default-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob:; frame-ancestors 'none'";
    static final String GUIDE_CSP = "default-src 'self'; script-src 'none'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;"
            + " font-src https://fonts.gstatic.com; img-src 'self' data:; frame-ancestors 'none'";

    private final boolean embedded = new ClassPathResource("static/index.html").exists();

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        return !embedded || !"GET".equals(request.getMethod()) || path.startsWith("/api/") || path.startsWith("/actuator")
                || path.startsWith("/v3/") || path.startsWith("/swagger-ui");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws ServletException, IOException {
        String path = request.getRequestURI();
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Referrer-Policy", "same-origin");
        if (path.equals("/guide") || path.equals("/guide/")) {
            response.setHeader("Content-Security-Policy", GUIDE_CSP);
            response.setHeader("Cache-Control", "no-cache");
            request.getRequestDispatcher("/guide/index.html").forward(request, response);
            return;
        }
        response.setHeader("Content-Security-Policy", path.startsWith("/guide/") ? GUIDE_CSP : APP_CSP);
        String last = path.substring(path.lastIndexOf('/') + 1);
        if (!last.contains(".")) {
            // route de l'application : index.html jamais mis en cache (il désigne les fichiers de la version en place)
            response.setHeader("Cache-Control", "no-cache");
            request.getRequestDispatcher("/index.html").forward(request, response);
            return;
        }
        chain.doFilter(request, response);
    }
}
