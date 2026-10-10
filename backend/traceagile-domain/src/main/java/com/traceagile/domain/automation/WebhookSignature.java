package com.traceagile.domain.automation;

import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.Locale;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/** §10.1 signature HMAC-SHA256 d'un webhook : en-tête {@code X-TraceAgile-Signature: sha256=<hex>}. */
public final class WebhookSignature {

    public static final String HEADER = "X-TraceAgile-Signature";
    private static final String PREFIX = "sha256=";

    private WebhookSignature() {
    }

    public static String sign(String secret, byte[] body) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return PREFIX + HexFormat.of().formatHex(mac.doFinal(body));
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException("HMAC-SHA256 indisponible", e);
        }
    }

    /** Comparaison en temps constant ; la casse de l'hexadécimal est indifférente. */
    public static boolean verify(String secret, byte[] body, String header) {
        if (secret == null || header == null || !header.toLowerCase(Locale.ROOT).startsWith(PREFIX)) {
            return false;
        }
        byte[] expected = sign(secret, body).getBytes(StandardCharsets.US_ASCII);
        byte[] actual = header.toLowerCase(Locale.ROOT).getBytes(StandardCharsets.US_ASCII);
        return MessageDigest.isEqual(expected, actual);
    }
}
