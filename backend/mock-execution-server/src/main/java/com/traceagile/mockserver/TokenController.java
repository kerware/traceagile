package com.traceagile.mockserver;

import com.traceagile.mockserver.TokenStore.IssuedToken;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** ADR-0020 émission, liste et révocation des jetons par l'administrateur du serveur (HTTP Basic). */
@RestController
@RequestMapping("/api/v1/tokens")
public class TokenController {

    public record TokenRequest(String label) {
    }

    public record TokenInfo(String tokenId, String label, String hint, Instant createdAt, Instant lastUsedAt) {
    }

    private final TokenStore tokens;

    public TokenController(TokenStore tokens) {
        this.tokens = tokens;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public IssuedToken issue(@RequestBody(required = false) TokenRequest request) {
        return tokens.issue(request == null || request.label() == null ? "TraceAgile" : request.label());
    }

    @GetMapping
    public List<TokenInfo> list() {
        return tokens.list().stream().map(r -> new TokenInfo(r.tokenId(), r.label(), r.hint(), r.createdAt(), r.lastUsedAt())).toList();
    }

    @DeleteMapping("/{tokenId}")
    public ResponseEntity<Map<String, String>> revoke(@PathVariable String tokenId) {
        return tokens.revoke(tokenId) ? ResponseEntity.noContent().build()
                : ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("code", "TOKEN_NOT_FOUND"));
    }
}
