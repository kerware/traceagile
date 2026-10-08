package com.traceagile.domain.common;

/**
 * F-REQ-03 Rang lexicographique (principe LexoRank) : chaîne en base 36 (0-9, a-z) lue comme une
 * fraction. Insérer entre deux éléments ne demande qu'un nouveau rang, sans renuméroter la liste.
 * Les rangs produits ne se terminent jamais par « 0 », ce qui garantit qu'un rang plus petit existe.
 * La colonne SQL utilise la collation « C » pour que PostgreSQL trie comme {@link String#compareTo}.
 */
public final class Rank {

    private static final String DIGITS = "0123456789abcdefghijklmnopqrstuvwxyz";
    private static final int BASE = DIGITS.length();

    private Rank() {
    }

    /**
     * @param lower rang de l'élément précédent, ou {@code null} en tête de liste
     * @param upper rang de l'élément suivant, ou {@code null} en fin de liste
     * @return un rang strictement compris entre les deux
     */
    public static String between(String lower, String upper) {
        String low = lower == null ? "" : lower;
        if (upper != null && low.compareTo(upper) >= 0) {
            throw new IllegalArgumentException("Rangs inversés : " + lower + " ≥ " + upper);
        }
        StringBuilder result = new StringBuilder();
        boolean upperBounded = upper != null;
        for (int i = 0; ; i++) {
            int lowDigit = i < low.length() ? digit(low.charAt(i)) : 0;
            int highDigit = upperBounded && i < upper.length() ? digit(upper.charAt(i)) : BASE;
            if (lowDigit == highDigit) {
                result.append(DIGITS.charAt(lowDigit));
                continue;
            }
            int middle = (lowDigit + highDigit) / 2;
            if (middle > lowDigit) {
                return result.append(DIGITS.charAt(middle)).toString();
            }
            // Chiffres consécutifs : on garde celui du bas et on cherche plus loin, sans borne haute.
            result.append(DIGITS.charAt(lowDigit));
            upperBounded = false;
        }
    }

    private static int digit(char c) {
        int value = DIGITS.indexOf(c);
        if (value < 0) {
            throw new IllegalArgumentException("Caractère de rang invalide : " + c);
        }
        return value;
    }
}
