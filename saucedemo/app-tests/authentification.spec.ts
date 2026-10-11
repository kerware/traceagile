import { expect, test } from '@playwright/test';
import comptes from '../data/comptes.json' with { type: 'json' };
import { seConnecter } from '../support/swaglabs';

/**
 * Feature « Authentification » (SWAG REQ-3, REQ-4) — test piloté par les données : une étape par
 * ligne du jeu « Comptes » (data/comptes.json), le même jeu que celui du test dans TraceAgile.
 */
test.describe('Authentification', () => {
  test('connexion avec chaque compte du jeu de données', { tag: ['@REQ-3', '@REQ-4'] }, async ({ page }) => {
    for (const compte of comptes) {
      await test.step(`${compte.utilisateur} : ${compte.resultat}`, async () => {
        await page.context().clearCookies();
        await seConnecter(page, compte.utilisateur);
        if (compte.resultat === 'catalogue') {
          await expect(page).toHaveURL(/inventory\.html$/);
          await expect(page.getByTestId('title')).toHaveText('Products');
        } else {
          await expect(page.getByTestId('error')).toHaveText(compte.message);
          await expect(page).not.toHaveURL(/inventory/);
        }
      });
    }
  });
});
