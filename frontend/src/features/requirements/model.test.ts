import { describe, expect, it } from 'vitest';
import { allowedParentTypes, FIBONACCI, needsSplitting, userStorySentence } from './model';

describe('§4 règles d’affichage des exigences', () => {
  it('F-REQ-05 construit la phrase « En tant que… je veux… afin de… »', () => {
    expect(userStorySentence('client', 'payer', 'recevoir ma commande')).toBe(
      'En tant que client, je veux payer afin de recevoir ma commande.',
    );
    expect(userStorySentence('client', 'payer', '')).toBe('En tant que client, je veux payer.');
    expect(userStorySentence('', '', '')).toBe('');
  });

  it('F-REQ-06 propose la suite de Fibonacci', () => {
    expect(FIBONACCI).toEqual([1, 2, 3, 5, 8, 13, 21]);
  });

  it('F-REQ-07 alerte « Story à découper » à partir de 13 points', () => {
    expect(needsSplitting(8)).toBe(false);
    expect(needsSplitting(13)).toBe(true);
    expect(needsSplitting(null)).toBe(false);
  });

  it('§3.3-1 parents autorisés selon le type', () => {
    expect(allowedParentTypes('EPIC')).toEqual([]);
    expect(allowedParentTypes('FEATURE')).toEqual(['EPIC']);
    expect(allowedParentTypes('USER_STORY')).toEqual(['FEATURE', 'EPIC']);
    expect(allowedParentTypes('BUSINESS_RULE')).toHaveLength(6);
  });
});
