package com.traceagile.api.security;

import com.nimbusds.jose.jwk.source.ImmutableSecret;
import java.nio.charset.StandardCharsets;
import java.util.List;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.access.expression.method.DefaultMethodSecurityExpressionHandler;
import org.springframework.security.access.expression.method.MethodSecurityExpressionHandler;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.web.SecurityFilterChain;

/**
 * §11.1 Sécurité : API sans état, jeton d'accès JWT en en-tête {@code Authorization: Bearer},
 * rôles par projet évalués avec {@code @PreAuthorize} et {@link ProjectPermissionEvaluator}.
 */
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    public static final String SYSTEM_ADMIN_AUTHORITY = "ROLE_SYSTEM_ADMIN";

    static final String[] PUBLIC_PATHS = {
            "/api/v1/auth/**",
            "/actuator/health/**", "/actuator/info",
            "/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html"
    };

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http, ProblemSecurityHandlers handlers,
                                            JwtAuthenticationConverter jwtConverter) throws Exception {
        http
                // Jeton Bearer en en-tête, aucun cookie d'authentification hors /auth (SameSite=Strict) : ADR-0003
                .csrf(csrf -> csrf.disable())
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(PUBLIC_PATHS).permitAll()
                        .anyRequest().authenticated())
                .oauth2ResourceServer(oauth -> oauth
                        .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtConverter))
                        .authenticationEntryPoint(handlers)
                        .accessDeniedHandler(handlers))
                .exceptionHandling(e -> e.authenticationEntryPoint(handlers).accessDeniedHandler(handlers));
        return http.build();
    }

    @Bean
    SecretKey jwtSecretKey(SecurityProperties properties) {
        return new SecretKeySpec(properties.jwtSecret().getBytes(StandardCharsets.UTF_8), "HmacSHA256");
    }

    @Bean
    JwtEncoder jwtEncoder(SecretKey key) {
        return new NimbusJwtEncoder(new ImmutableSecret<>(key));
    }

    @Bean
    JwtDecoder jwtDecoder(SecretKey key) {
        NimbusJwtDecoder decoder = NimbusJwtDecoder.withSecretKey(key).macAlgorithm(MacAlgorithm.HS256).build();
        decoder.setJwtValidator(JwtValidators.createDefaultWithIssuer(AccessTokenService.ISSUER));
        return decoder;
    }

    /** Le login est le nom du principal ; la revendication {@code adm} donne {@code ROLE_SYSTEM_ADMIN}. */
    @Bean
    JwtAuthenticationConverter jwtAuthenticationConverter() {
        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(jwt -> {
            boolean admin = Boolean.TRUE.equals(jwt.getClaimAsBoolean(AccessTokenService.CLAIM_SYSTEM_ADMIN));
            return admin ? List.<GrantedAuthority>of(new SimpleGrantedAuthority(SYSTEM_ADMIN_AUTHORITY)) : List.of();
        });
        return converter;
    }

    @Bean
    static MethodSecurityExpressionHandler methodSecurityExpressionHandler(ProjectPermissionEvaluator evaluator) {
        DefaultMethodSecurityExpressionHandler handler = new DefaultMethodSecurityExpressionHandler();
        handler.setPermissionEvaluator(evaluator);
        return handler;
    }

    public static boolean isSystemAdmin(Authentication authentication) {
        return authentication.getAuthorities().stream()
                .anyMatch(a -> SYSTEM_ADMIN_AUTHORITY.equals(a.getAuthority()));
    }
}
