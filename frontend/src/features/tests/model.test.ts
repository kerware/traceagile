import { describe, expect, it } from 'vitest';
import { buildFolderTree, charterSentence, mergeParameters, PARAMETER_NAME, parseCell, stepVariables, TECHNIQUES } from './model';

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

  it('ADR-0013 paramètres : détectés d’abord, puis déclarés (marqués non utilisés pour un test manuel)', () => {
    const rows = mergeParameters([{ name: 'devise', defaultValue: 'EUR', description: '' }, { name: 'prix', defaultValue: '2', description: '' }], ['prix', 'produit'], true);
    expect(rows.map((r) => [r.name, r.detected, r.unused, r.defaultValue])).toEqual([
      ['prix', true, false, '2'],
      ['produit', true, false, ''],
      ['devise', false, true, 'EUR'],
    ]);
    expect(mergeParameters([{ name: 'url', defaultValue: '', description: '' }], [], false)[0]!.unused).toBe(false);
  });

  it('ADR-0013 nom de paramètre : lettres sans accent, chiffres, _ - .', () => {
    expect(['nom-produit', 'prix_ttc', 'a.b'].every((n) => PARAMETER_NAME.test(n))).toBe(true);
    expect(['', 'avec espace', 'é', 'a/b'].some((n) => PARAMETER_NAME.test(n))).toBe(false);
  });

  it('ADR-0013 arbre des dossiers : ancêtres créés, totaux cumulés, non classés à part', () => {
    const { roots, unclassified } = buildFolderTree([
      { name: 'Panier/Ajout', tests: ['TC-1', 'TC-2'] },
      { name: 'Panier/Vide', tests: [] },
      { name: 'Commande', tests: ['TC-3'] },
      { name: '', tests: ['TC-4'] },
    ]);
    expect(roots.map((r) => [r.path, r.total])).toEqual([['Commande', 1], ['Panier', 2]]);
    expect(roots[1]!.children.map((c) => c.name)).toEqual(['Ajout', 'Vide']);
    expect(unclassified).toEqual(['TC-4']);
  });
});
