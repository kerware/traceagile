import { describe, expect, it } from 'vitest';
import { ADMIN, TESTER } from '../test/server';
import { navigationFor } from './navigation';

describe('§13.1 menu latéral', () => {
  it("liste les entrées du §13.1 dans l'ordre, avec les routes du §13.2", () => {
    const items = navigationFor('SHOP', TESTER);

    expect(items.map((i) => i.id)).toEqual([
      'dashboard', 'backlog', 'tests', 'exploratory', 'planning', 'campaigns',
      'myExecutions', 'traceability', 'defects', 'reports',
    ]);
    expect(items[0]?.to).toBe('/p/SHOP/dashboard');
    expect(items.find((i) => i.id === 'myExecutions')?.to).toBe('/p/SHOP/my-executions');
  });

  it('affiche Administration selon le rôle : administrateur système uniquement', () => {
    expect(navigationFor('SHOP', ADMIN).map((i) => i.id)).toContain('administration');
    expect(navigationFor('SHOP', TESTER).map((i) => i.id)).not.toContain('administration');
  });

  it('sans projet sélectionné, seules les entrées globales restent', () => {
    expect(navigationFor(null, ADMIN).map((i) => i.id)).toEqual(['administration']);
    expect(navigationFor(null, TESTER)).toEqual([]);
  });
});
