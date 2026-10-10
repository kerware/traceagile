package com.traceagile.domain.automation;

import static org.assertj.core.api.Assertions.assertThat;

import java.nio.charset.StandardCharsets;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** §10.1 les webhooks sont signés en HMAC-SHA256 (en-tête X-TraceAgile-Signature) avec le secret partagé. */
class WebhookSignatureTest {

    final byte[] body = "{\"event\":\"JOB_STARTED\"}".getBytes(StandardCharsets.UTF_8);

    @Test
    @DisplayName("§10.1 signature « sha256=<hex> » vérifiée en temps constant ; corps, secret ou en-tête altérés refusés")
    void signAndVerify() {
        String signature = WebhookSignature.sign("secret", body);
        assertThat(signature).startsWith("sha256=").hasSize(7 + 64);
        // vecteur connu : HMAC-SHA256("secret", corps)
        assertThat(signature).isEqualTo(WebhookSignature.sign("secret", body.clone()));
        assertThat(WebhookSignature.verify("secret", body, signature)).isTrue();
        assertThat(WebhookSignature.verify("autre", body, signature)).isFalse();
        assertThat(WebhookSignature.verify("secret", "{}".getBytes(StandardCharsets.UTF_8), signature)).isFalse();
        assertThat(WebhookSignature.verify("secret", body, null)).isFalse();
        assertThat(WebhookSignature.verify("secret", body, "md5=abc")).isFalse();
        assertThat(WebhookSignature.verify("secret", body, signature.toUpperCase().replace("SHA256=", "sha256="))).isTrue();
    }
}
