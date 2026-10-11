import { expect, test } from '@playwright/test';
import { seConnecter } from '../support/swaglabs';

/**
 * ENF « Temps de chargement du catalogue » (SWAG REQ-16) : seuil 3 000 ms, cible 1 000 ms au p95.
 * Mesure légère (5 connexions successives) : délai entre le clic « Login » et l'affichage des six
 * produits. Les métriques sont jointes au rapport (p95Ms, comme celles du serveur d'exécution).
 */
const ITERATIONS = 5;
const SEUIL_MS = 3_000;

test.describe('Performance', () => {
  test('temps de chargement du catalogue', { tag: '@REQ-16' }, async ({ page }) => {
    const mesures: number[] = [];
    for (let i = 0; i < ITERATIONS; i++) {
      await page.context().clearCookies();
      const debut = Date.now();
      await seConnecter(page, 'standard_user');
      await expect(page.getByTestId('inventory-item')).toHaveCount(6);
      mesures.push(Date.now() - debut);
    }
    const tries = [...mesures].sort((a, b) => a - b);
    const p95Ms = tries[Math.ceil(tries.length * 0.95) - 1]!;
    await test.info().attach('metrics.json', {
      body: JSON.stringify({ p95Ms, medianeMs: tries[Math.floor(tries.length / 2)], mesures }),
      contentType: 'application/json',
    });
    console.log(`p95 du chargement du catalogue : ${p95Ms} ms (${mesures.join(', ')})`);
    expect(p95Ms, `p95 ${p95Ms} ms`).toBeLessThan(SEUIL_MS);
  });
});
