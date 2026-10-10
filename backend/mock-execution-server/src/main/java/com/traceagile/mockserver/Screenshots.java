package com.traceagile.mockserver;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.zip.CRC32;
import java.util.zip.DeflaterOutputStream;

/**
 * §10.5 copie d'écran simulée d'un test en échec : PNG 640 × 360 (navigateur stylisé, zone d'erreur
 * rouge), encodé sans AWT pour tourner sur une JRE minimale. La teinte dépend du test pour distinguer
 * les captures.
 */
final class Screenshots {

    static final int WIDTH = 640;
    static final int HEIGHT = 360;

    private Screenshots() {
    }

    static byte[] failure(String testKey, boolean technicalError) {
        int seed = Math.abs(testKey.hashCode());
        int[] accent = {40 + seed % 120, 90 + seed % 100, 160 + seed % 80};
        int[] alert = technicalError ? new int[] {140, 60, 170} : new int[] {220, 50, 50};
        ByteArrayOutputStream raw = new ByteArrayOutputStream();
        for (int y = 0; y < HEIGHT; y++) {
            raw.write(0); // filtre « None »
            for (int x = 0; x < WIDTH; x++) {
                int[] c;
                if (y < 36) {
                    c = new int[] {225, 228, 232}; // barre du navigateur
                    if (y > 10 && y < 26 && x > 70 && x < 560) {
                        c = new int[] {255, 255, 255}; // barre d'adresse
                    }
                } else if (y < 70) {
                    c = accent; // en-tête de l'application
                } else if (y > 150 && y < 230 && x > 120 && x < 520) {
                    boolean border = y < 154 || y > 226 || x < 124 || x > 516;
                    c = border ? alert : new int[] {253, 236, 236}; // encadré d'erreur
                } else {
                    c = (x / 40 + y / 40) % 2 == 0 ? new int[] {248, 249, 250} : new int[] {242, 244, 246};
                }
                raw.write(c[0]);
                raw.write(c[1]);
                raw.write(c[2]);
            }
        }
        try {
            ByteArrayOutputStream png = new ByteArrayOutputStream();
            png.write(new byte[] {(byte) 0x89, 'P', 'N', 'G', '\r', '\n', 0x1A, '\n'});
            ByteArrayOutputStream header = new ByteArrayOutputStream();
            writeInt(header, WIDTH);
            writeInt(header, HEIGHT);
            header.write(new byte[] {8, 2, 0, 0, 0}); // 8 bits, RGB
            chunk(png, "IHDR", header.toByteArray());
            ByteArrayOutputStream compressed = new ByteArrayOutputStream();
            try (DeflaterOutputStream deflate = new DeflaterOutputStream(compressed)) {
                deflate.write(raw.toByteArray());
            }
            chunk(png, "IDAT", compressed.toByteArray());
            chunk(png, "IEND", new byte[0]);
            return png.toByteArray();
        } catch (IOException e) {
            throw new IllegalStateException(e);
        }
    }

    private static void chunk(ByteArrayOutputStream out, String type, byte[] data) throws IOException {
        writeInt(out, data.length);
        byte[] typeBytes = type.getBytes(StandardCharsets.US_ASCII);
        out.write(typeBytes);
        out.write(data);
        CRC32 crc = new CRC32();
        crc.update(typeBytes);
        crc.update(data);
        writeInt(out, (int) crc.getValue());
    }

    private static void writeInt(ByteArrayOutputStream out, int value) {
        out.write(value >>> 24);
        out.write(value >>> 16);
        out.write(value >>> 8);
        out.write(value);
    }
}
