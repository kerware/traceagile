package com.traceagile.executionserver.job;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.time.Duration;
import java.util.HexFormat;
import java.util.Map;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * §10.4 webhook signé vers TraceAgile : corps JSON, {@code X-TraceAgile-Signature: sha256=<hex>}
 * (HMAC-SHA256 du corps avec le secret du jeton). Trois essais ; ensuite TraceAgile se rattrape par
 * polling ({@code GET /api/v1/jobs/{id}}) ou par son délai.
 */
@Component
public class WebhookSender {

    public static final String SIGNATURE_HEADER = "X-TraceAgile-Signature";
    private static final Logger LOG = LoggerFactory.getLogger(WebhookSender.class);

    private final ObjectMapper json;
    private final RestClient http;

    public WebhookSender(ObjectMapper json) {
        this.json = json;
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(Duration.ofSeconds(5));
        factory.setReadTimeout(Duration.ofSeconds(15));
        this.http = RestClient.builder().requestFactory(factory).build();
    }

    /** @return true si TraceAgile a accepté l'événement */
    public boolean send(String url, String secret, Map<String, Object> event) {
        byte[] body;
        try {
            body = json.writeValueAsBytes(event);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
        String signature = sign(secret, body);
        for (int attempt = 1; attempt <= 3; attempt++) {
            try {
                http.post().uri(url).contentType(MediaType.APPLICATION_JSON).header(SIGNATURE_HEADER, signature).body(body).retrieve().toBodilessEntity();
                return true;
            } catch (RuntimeException e) {
                LOG.warn("Webhook {} vers {} : essai {} en échec ({})", event.get("event"), url, attempt, e.getMessage());
                sleep(500L * attempt);
            }
        }
        return false;
    }

    public static String sign(String secret, byte[] body) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return "sha256=" + HexFormat.of().formatHex(mac.doFinal(body));
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException(e);
        }
    }

    private static void sleep(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
