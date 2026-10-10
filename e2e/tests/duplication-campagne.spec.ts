import { expect, test } from '@playwright/test';
import { connexion } from './support';

/**
 * ADR-0017 — à partir de la campagne terminée CMP-1 de la démo : générer une campagne de rejeu
 * avec ses tests en échec, puis dupliquer cette nouvelle campagne.
 */
test('Campagne générée depuis les échecs de CMP-1, puis dupliquée', async ({ page }) => {
  const suffixe = Date.now().toString().slice(-6);
  let echecs = 0;

  await test.step('Sur CMP-1 terminée, le testeur choisit « selon le dernier résultat » : échecs cochés', async () => {
    await connexion(page, 'qa1');
    await page.goto('/p/SHOP/campaigns/CMP-1');
    await page.getByTestId('campaign-copy').click();
    await expect(page.getByTestId('copy-status-FAILED')).toBeChecked();
    await expect(page.getByTestId('copy-status-ERROR')).toBeChecked();
    const compte = (await page.getByTestId('copy-count').textContent()) ?? '';
    echecs = Number(/(\d+) tests?/.exec(compte)?.[1]);
    expect(echecs).toBeGreaterThan(0);
  });

  await test.step('Il génère une campagne de régression pour le build 2.0.1', async () => {
    await page.getByTestId('copy-name').fill(`Rejeu des échecs ${suffixe}`);
    await page.getByTestId('copy-scope').click();
    await page.getByRole('option', { name: 'Régression' }).click();
    await page.getByTestId('copy-build').fill('2.0.1');
    await page.getByTestId('copy-submit').click();
    await expect(page.getByRole('heading', { name: `Rejeu des échecs ${suffixe}` })).toBeVisible();
    await expect(page.getByTestId('campaign-items').locator('tbody tr')).toHaveCount(echecs);
    await expect(page.getByTestId('campaign-items')).not.toContainText(/Réussi|Échec/);
  });

  await test.step('Il duplique la nouvelle campagne : mêmes tests, même ordre', async () => {
    const ordre = await page.getByTestId('campaign-items').locator('tbody tr').first().getAttribute('data-testid');
    await page.getByTestId('campaign-copy').click();
    await page.getByTestId('copy-name').fill(`Rejeu bis ${suffixe}`);
    await page.getByTestId('copy-submit').click();
    await expect(page.getByRole('heading', { name: `Rejeu bis ${suffixe}` })).toBeVisible();
    await expect(page.getByTestId('campaign-items').locator('tbody tr')).toHaveCount(echecs);
    await expect(page.getByTestId('campaign-items').locator('tbody tr').first()).toHaveAttribute('data-testid', ordre!);
  });
});
