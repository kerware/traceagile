import { describe, expect, it } from 'vitest';
import { charterSentence, parseCell, stepVariables, TECHNIQUES } from './model';

describe('§6 règles d’affichage des tests', () => {
  it('F-EXP-01 phrase de mission « Explorer… avec… pour découvrir… »', () => {
    expect(charterSentence('le panier', 'des produits en rupture', 'les incohérences')).toBe(
      'Explorer le panier avec des produits en rupture pour découvrir les incohérences.',
    );
    expect(charterSentence('le panier', '', 'les incohérences')).toBe('Explorer le panier pour découvrir les incohérences.');
    expect(charterSentence('', '', '')).toBe('');
  });

  it('F-MAN-01 variables ${nom} des pas, sans doublon, dans l’ordre', () => {
    expect(
      stepVariables([
        { action: 'Ouvrir ${produit}', expectedResult: 'Prix ${prix}' },
        { action: 'Quantité ${quantite}', expectedResult: 'Total ${prix}', testData: '${produit}' },
      ]),
    ).toEqual(['produit', 'prix', 'quantite']);
  });

  it('§6.1 jeu de données : nombres et booléens reconnus dans la grille', () => {
    expect(parseCell('49.99')).toBe(49.99);
    expect(parseCell('true')).toBe(true);
    expect(parseCell('Stylo')).toBe('Stylo');
    expect(parseCell('')).toBe('');
  });

  it('§6.1 huit techniques', () => {
    expect(TECHNIQUES).toHaveLength(8);
  });
});
