import { describe, expect, it } from 'vitest';
import { node } from '../../test/requirements';
import { cellColor, percent, scopeOptions } from './model';

describe('§7 règles d’affichage de la traçabilité', () => {
  it('§7.2 périmètres : le projet puis les épics et features, indentés', () => {
    const tree = [node('REQ-1', { type: 'EPIC', title: 'Panier', children: [
      node('REQ-2', { type: 'FEATURE', title: 'Gestion', children: [node('REQ-3', { type: 'USER_STORY', title: 'Ajouter' })] }),
    ] })];
    expect(scopeOptions(tree, 'Tout le projet')).toEqual([
      { value: 'project', label: 'Tout le projet' },
      { value: 'requirement:REQ-1', label: 'REQ-1 — Panier' },
      { value: 'requirement:REQ-2', label: '  REQ-2 — Gestion' },
    ]);
  });

  it('F-TRA-04 couleur d’une cellule : suspect, puis dernier résultat, puis type de lien', () => {
    const cell = { requirementKey: 'REQ-1', testKey: 'TC-1', linkId: 'l', linkType: 'VERIFIES' as const, origin: 'MANUAL' as const, criterionPositions: [], suspect: false, version: 0 };
    expect(cellColor(cell)).toBe('teal');
    expect(cellColor({ ...cell, linkType: 'RELATES_TO' })).toBe('gray');
    expect(cellColor({ ...cell, lastResult: 'FAILED' })).toBe('red');
    expect(cellColor({ ...cell, lastResult: 'PASSED', suspect: true })).toBe('violet');
  });

  it('§7.2 pourcentage lisible, « — » pour un périmètre vide', () => {
    expect(percent(50)).toBe('50 %');
    expect(percent(66.6667)).toBe('66,7 %');
    expect(percent(66.6667, 'en')).toBe('66.7 %');
    expect(percent(undefined)).toBe('—');
  });
});
