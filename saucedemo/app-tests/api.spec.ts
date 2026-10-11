import { expect, test } from '@playwright/test';

/**
 * ENF « Contrat HTTP du site » (SWAG REQ-17) — test d'API sans navigateur (fixture `request`).
 * Swag Labs est une application monopage sans API métier : le contrat vérifié est celui des
 * ressources publiques (page d'entrée, manifeste d'application web et ses icônes).
 */
test.describe('Contrat HTTP', () => {
  test('expose le manifeste PWA et ses icônes', { tag: '@REQ-17' }, async ({ request }) => {
    const accueil = await request.get('/');
    expect(accueil.status()).toBe(200);
    expect(accueil.headers()['content-type']).toContain('text/html');
    expect(await accueil.text()).toContain('<title>Swag Labs</title>');

    const reponse = await request.get('/manifest.json');
    expect(reponse.status()).toBe(200);
    const manifeste = await reponse.json();
    expect(manifeste).toMatchObject({ name: 'Swag Labs', short_name: 'Swag Labs', scope: '/' });
    expect(manifeste.icons).toHaveLength(4);

    for (const icone of manifeste.icons as { src: string; type: string }[]) {
      const image = await request.get(icone.src);
      expect(image.status(), icone.src).toBe(200);
      expect(image.headers()['content-type']).toBe(icone.type);
    }
  });
});
