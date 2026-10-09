import { describe, expect, it } from 'vitest';
import type { ScopeItem, SprintSummary } from '../../api/planning';
import { defaultSprint, loadColor, needsDecision, span } from './model';

describe('§8 règles d’affichage de la planification', () => {
  it('F-PLN-02 position d’un sprint sur la frise de sa release', () => {
    // Release de 6 semaines, deuxième sprint de 2 semaines : un tiers à partir d'un tiers.
    const { left, width } = span('2026-10-26', '2026-11-08', '2026-10-12', '2026-11-22');
    expect(left).toBeCloseTo(33.33, 1);
    expect(width).toBeCloseTo(33.33, 1);
  });

  it('F-PLN-05 jauge : alerte rouge au-delà de 100 %', () => {
    expect(loadColor(120)).toBe('red');
    expect(loadColor(90)).toBe('orange');
    expect(loadColor(50)).toBe('teal');
    expect(loadColor(null)).toBe('gray');
  });

  it('sprint par défaut : l’actif, sinon le premier planifié', () => {
    const s = (key: string, status: SprintSummary['status']) => ({ key, status }) as SprintSummary;
    expect(defaultSprint([s('SPR-1', 'CLOSED'), s('SPR-2', 'ACTIVE'), s('SPR-3', 'PLANNED')])).toBe('SPR-2');
    expect(defaultSprint([s('SPR-1', 'CLOSED'), s('SPR-3', 'PLANNED')])).toBe('SPR-3');
    expect(defaultSprint([])).toBeNull();
  });

  it('F-PLN-06 décision de clôture pour les stories ni terminées, ni rejetées, ni obsolètes', () => {
    const item = (status: ScopeItem['status']) => ({ status }) as ScopeItem;
    expect(needsDecision(item('IN_SPRINT'))).toBe(true);
    expect(needsDecision(item('DONE'))).toBe(false);
    expect(needsDecision(item('ACCEPTED'))).toBe(false);
    expect(needsDecision(item('OBSOLETE'))).toBe(false);
  });
});
