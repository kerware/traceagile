import { describe, expect, it } from 'vitest';
import { ADMIN, TESTER } from '../test/server';
import { navigationFor } from './navigation';

describe('§13.1 menu latéral', () => {
  it("liste les entrées du §13.1 dans l'ordre, avec les routes du §13.2", () => {
    const items = navigationFor('SHOP', TESTER);

    expect(items.map((i) => i.id)).toEqual([
      'dashboard', 'backlog', 'tests', 'exploratory', 'planning', 'campaigns',
      'myExecutions', 'traceability', 'defects', 'reports', 'documentation',
    ]);
    expect(items[0]?.to).toBe('/p/SHOP/dashboard');
    expect(items.find((i) => i.id === 'myExecutions')?.to).toBe('/p/SHOP/my-executions');
  });

  it('affiche Administration selon le rôle : administrateur système uniquement', () => {
    expect(navigationFor('SHOP', ADMIN).map((i) => i.id)).toContain('administration');
    expect(navigationFor('SHOP', TESTER).map((i) => i.id)).not.toContain('administration');
  });

  it('sans projet sélectionné, seules les entrées globales restent', () => {
    expect(navigationFor(null, ADMIN).map((i) => i.id)).toEqual(['documentation', 'administration']);
    expect(navigationFor(null, TESTER).map((i) => i.id)).toEqual(['documentation']);
  });

  it('Documentation, sous Rapports, ouvre le guide d’utilisation HTML dans un nouvel onglet', () => {
    const items = navigationFor('SHOP', ADMIN);
    const documentation = items.find((i) => i.id === 'documentation');
    expect(documentation).toEqual({ id: 'documentation', to: '/guide/', external: true });
    expect(items.map((i) => i.id).slice(-3)).toEqual(['reports', 'documentation', 'administration']);
  });
});
