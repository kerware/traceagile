import { describe, expect, it } from 'vitest';
import { reorder } from './reorder';

describe('F-REQ-03 réordonnancement par glisser-déposer', () => {
  const keys = ['A', 'B', 'C', 'D'];

  it('vers le bas : insertion après l’élément survolé', () => {
    expect(reorder(keys, 'A', 'C')).toEqual({ ordered: ['B', 'C', 'A', 'D'], afterKey: 'C', beforeKey: 'D' });
  });

  it('vers le haut : insertion avant l’élément survolé', () => {
    expect(reorder(keys, 'D', 'B')).toEqual({ ordered: ['A', 'D', 'B', 'C'], afterKey: 'A', beforeKey: 'B' });
  });

  it('en tête et en fin de liste', () => {
    expect(reorder(keys, 'C', 'A')).toEqual({ ordered: ['C', 'A', 'B', 'D'], afterKey: undefined, beforeKey: 'A' });
    expect(reorder(keys, 'A', 'D')).toEqual({ ordered: ['B', 'C', 'D', 'A'], afterKey: 'D', beforeKey: undefined });
  });

  it('sans déplacement : null', () => {
    expect(reorder(keys, 'B', 'B')).toBeNull();
    expect(reorder(keys, 'B', 'Z')).toBeNull();
  });
});
