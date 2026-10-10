import { expect, test } from '@playwright/test';
import { readFile } from 'node:fs/promises';
import { connexion } from './support';

/**
 * Parcours 5 (§15.3) — critère de fin du lot 8 : le PO consulte le tableau de bord, génère le bilan
 * de SPR-2, constate le verdict « No go » ou « Go sous réserve » et exporte le PDF. Le bilan de SPR-1,
 * figé à la clôture du sprint, reste accessible par son lien permanent (F-RPT-04).
 */
test('Parcours 5 : le PO consulte le bilan de SPR-2, constate le verdict et exporte le PDF', async ({ page }) => {
  test.setTimeout(90_000);

  await test.step('Le tableau de bord montre le sprint actif, la couverture, les anomalies et le burndown', async () => {
    await connexion(page, 'po');
    await page.goto('/p/SHOP/dashboard');
    await expect(page.getByTestId('widget-sprint')).toContainText('SPR-2');
    await expect(page.getByTestId('widget-coverage')).toBeVisible();
    await expect(page.getByTestId('widget-defects')).toBeVisible();
    await expect(page.getByTestId('chart-burndown').locator('svg')).toBeVisible();
  });

  await test.step('Le bilan de SPR-1, figé à la clôture, est dans la liste des rapports', async () => {
    await page.goto('/p/SHOP/reports');
    const figé = page.getByTestId('reports-table').getByRole('row').filter({ hasText: 'SPR-1' }).filter({ hasText: 'Figé' });
    await expect(figé.first()).toBeVisible();
  });

  let cle = '';
  await test.step('Le PO génère le bilan du sprint actif SPR-2', async () => {
    await page.getByTestId('report-generate').click();
    await expect(page.getByTestId('generate-definition')).toHaveValue('Bilan de sprint');
    await expect(page.getByTestId('generate-scope')).toHaveValue(/^SPR-2/);
    await page.getByTestId('generate-submit').click();
    await expect(page.getByTestId('report-page')).toBeVisible();
    cle = (await page.locator('[data-testid=report-page] .mantine-Badge-root').first().innerText()).trim();
    expect(cle).toMatch(/^RPT-\d+$/);
  });

  await test.step('Le verdict est « No go » ou « Go sous réserve » ; le bilan affiche ses 8 sections', async () => {
    await expect(page.getByTestId('report-verdict')).toHaveAttribute('data-verdict', /^(NO_GO|GO_WITH_RESERVATIONS)$/);
    const bilan = page.frameLocator('[data-testid=report-frame]');
    await expect(bilan.getByRole('heading', { name: '1. Synthèse' })).toBeVisible();
    await expect(bilan.getByRole('heading', { name: '8. Recommandation de mise en production' })).toBeVisible();
  });

  await test.step('Le PO exporte le PDF', async () => {
    const telechargement = page.waitForEvent('download');
    await page.getByTestId(`export-${cle}`).click();
    await page.getByTestId(`export-${cle}-PDF`).click();
    const fichier = await telechargement;
    expect(fichier.suggestedFilename()).toBe(`${cle}.pdf`);
    const contenu = await readFile((await fichier.path())!);
    expect(contenu.subarray(0, 5).toString('latin1')).toBe('%PDF-');
  });
});
